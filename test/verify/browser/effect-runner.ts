import type { EffectReference } from '../../../src/types';
import { compileEffectChain } from '../../../src/core/effects/chain-compiler';
import { createEffectReference } from '../../../src/core/effects/reference';
import { getEffectDescriptorById } from '../../../src/core/effects/registry';
import { getRequiredDeviceLimits } from '../../../src/core/gpu-device-limits';
import { collectGpuCapabilities, type GpuCapabilities } from '../../../src/core/gpu-capabilities';
import { setGeneratedKernelVariantOverride } from '../../../src/core/generated-models/luma-model-pipeline';
import { VideoFrameUploader } from '../../../src/core/renderer/frame-uploader';
import {
  flushGpuResourceErrors,
  subscribeGpuResourceErrors,
  type GpuResourceError,
} from '../../../src/core/gpu-resource-cache';
import type { OptimizationFeatureFlags } from '../../../src/core/optimization-flags';
import { resolveAnime4kPresetEffectChain } from '../../../src/engines/anime4k/preset-resolver';
import type { Anime4KPresetId, PerformanceTier } from '../../../src/types';
import {
  runGpuPerformanceSuite,
  type GpuPerformanceSuiteReport,
  type GpuPerformanceSuiteRequest,
} from './gpu-performance-suite';
import {
  TemporalMetricsAccumulator,
  defaultTemporalThresholds,
  type TemporalMetricsSummary,
  type TemporalThresholds,
} from './temporal-metrics';

interface VerifyRequest {
  effectId: string;
  width: number;
  height: number;
  rgba: number[];
  outputMode?: 'final' | 'luma' | 'rgba';
  includePreview?: boolean;
  terminalPresentation?: boolean;
  optimizationFlags?: Partial<OptimizationFeatureFlags>;
  kernelVariantOverride?: string;
}

interface VerifyResponse {
  width: number;
  height: number;
  rgba?: number[];
  lumaF32?: number[];
  rgbaF32?: number[];
  pngBase64?: string;
  timings?: VerifyChainTimings;
  adapterInfo: string;
  passCount: number;
  peakTextureBytes: number;
  textureSlotCount: number;
  terminalPresented: boolean;
}

interface VerifyChainRequest {
  effectIds: string[];
  width: number;
  height: number;
  targetWidth: number;
  targetHeight: number;
  rgba?: number[];
  rgbaBase64?: string;
  includePreview?: boolean;
  includeFloatOutput?: boolean;
  optimizationFlags?: Partial<OptimizationFeatureFlags>;
  terminalPresentation?: boolean;
  kernelVariantOverride?: string;
  outputEncoding?: 'rgba-array' | 'png-base64';
}

interface VerifyChainTimings {
  inputDecodeMs: number;
  compileMs: number;
  gpuExecutionMs: number;
  readbackMs: number;
  pngEncodeMs: number;
}

interface VerifyGpuContext {
  device: GPUDevice;
  capabilities: GpuCapabilities;
  adapterInfo: string;
  readbackRgba8Pipeline?: GPURenderPipeline;
  readbackLumaF32Pipeline?: GPUComputePipeline;
  readbackPackedX2LumaF32Pipeline?: GPUComputePipeline;
  readbackRgbaF32Pipeline?: GPUComputePipeline;
}

function decodeBase64Bytes(value: string): Uint8Array {
  const binary = atob(value);
  const bytes = new Uint8Array(binary.length);
  for (let index = 0; index < binary.length; index += 1) bytes[index] = binary.charCodeAt(index);
  return bytes;
}

async function encodeRgbaAsPngBase64(rgba: Uint8Array, width: number, height: number): Promise<string> {
  const canvas = new OffscreenCanvas(width, height);
  const context = canvas.getContext('2d');
  if (!context) throw new Error('Unable to create the PNG encoding canvas.');
  const pixels = new Uint8ClampedArray(rgba);
  context.putImageData(new ImageData(pixels, width, height), 0, 0);
  const blob = await canvas.convertToBlob({ type: 'image/png' });
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onerror = () => reject(reader.error ?? new Error('Failed to encode PNG as Base64.'));
    reader.onload = () => {
      const dataUrl = String(reader.result);
      resolve(dataUrl.slice(dataUrl.indexOf(',') + 1));
    };
    reader.readAsDataURL(blob);
  });
}

interface VerifyExternalTextureRequest {
  videoUrl: string;
}

interface VerifyExternalTextureResponse {
  width: number;
  height: number;
  adapterInfo: string;
  nativeInput: number[];
  externalInput: number[];
  nativeClamp: number[];
  externalClamp: number[];
  directExternalClamp: number[];
}

interface VerifyTemporalRequest {
  videoUrl: string;
  effectIds: string[];
  targetWidth: number;
  targetHeight: number;
  frameCount: number;
  fps: number;
  baselineFlags: Partial<OptimizationFeatureFlags>;
  optimizedFlags: Partial<OptimizationFeatureFlags>;
  externalTexture?: boolean;
  motionOnly?: boolean;
  thresholds?: Partial<TemporalThresholds>;
}

interface VerifyTemporalResponse {
  width: number;
  height: number;
  outputWidth: number;
  outputHeight: number;
  adapterInfo: string;
  baselinePassCount: number;
  optimizedPassCount: number;
  externalTextureActive: boolean;
  metrics: TemporalMetricsSummary;
}

declare global {
  interface Window {
    __runEffectVerification?: (request: VerifyRequest) => Promise<VerifyResponse>;
    __runChainVerification?: (request: VerifyChainRequest) => Promise<VerifyResponse>;
    __probeEffectVerification?: () => Promise<{ available: boolean; summary: string }>;
    __resetEffectVerification?: () => void;
    __runGpuPerformanceSuite?: (request?: GpuPerformanceSuiteRequest) => Promise<GpuPerformanceSuiteReport>;
    __resolvePresetChain?: (preset: Anime4KPresetId, tier: PerformanceTier) => string[];
    __runExternalTextureVerification?: (
      request: VerifyExternalTextureRequest,
    ) => Promise<VerifyExternalTextureResponse>;
    __runTemporalVerification?: (request: VerifyTemporalRequest) => Promise<VerifyTemporalResponse>;
  }
}

function align(value: number, alignment: number): number {
  return Math.ceil(value / alignment) * alignment;
}

async function getAdapterInfo(adapter: GPUAdapter): Promise<string> {
  const adapterWithInfo = adapter as GPUAdapter & {
    requestAdapterInfo?: () => Promise<{ vendor?: string; architecture?: string; device?: string; description?: string }>;
    info?: { vendor?: string; architecture?: string; device?: string; description?: string };
  };

  const info = adapterWithInfo.info ?? (adapterWithInfo.requestAdapterInfo ? await adapterWithInfo.requestAdapterInfo() : null);
  return info
    ? [info.vendor, info.architecture, info.device, info.description].filter(Boolean).join(' / ') || 'WebGPU adapter'
    : 'WebGPU adapter';
}

function createInputTexture(
  device: GPUDevice,
  request: Pick<VerifyRequest, 'effectId' | 'width' | 'height'> & { rgba: ArrayLike<number> },
): GPUTexture {
  const texture = device.createTexture({
    label: `verify/input/${request.effectId}`,
    size: { width: request.width, height: request.height },
    format: 'rgba8unorm',
    usage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.COPY_DST | GPUTextureUsage.RENDER_ATTACHMENT,
  });

  device.queue.writeTexture(
    { texture },
    new Uint8Array(request.rgba),
    { bytesPerRow: request.width * 4, rowsPerImage: request.height },
    { width: request.width, height: request.height },
  );

  return texture;
}

const readbackShader = `
struct VertexOut {
  @builtin(position) position: vec4f,
};

@vertex
fn vertexMain(@builtin(vertex_index) vertexIndex: u32) -> VertexOut {
  var positions = array<vec2f, 3>(
    vec2f(-1.0, -1.0),
    vec2f(3.0, -1.0),
    vec2f(-1.0, 3.0),
  );
  var output: VertexOut;
  output.position = vec4f(positions[vertexIndex], 0.0, 1.0);
  return output;
}

@group(0) @binding(0) var sourceTexture: texture_2d<f32>;

@fragment
fn fragmentMain(@builtin(position) position: vec4f) -> @location(0) vec4f {
  return textureLoad(sourceTexture, vec2i(position.xy), 0);
}
`;

function getReadbackRgba8Pipeline(context: VerifyGpuContext): GPURenderPipeline {
  if (context.readbackRgba8Pipeline) return context.readbackRgba8Pipeline;
  const { device } = context;
  const shaderModule = device.createShaderModule({
    label: 'verify/readback/shader',
    code: readbackShader,
  });
  context.readbackRgba8Pipeline = device.createRenderPipeline({
    label: 'verify/readback/pipeline',
    layout: 'auto',
    vertex: {
      module: shaderModule,
      entryPoint: 'vertexMain',
    },
    fragment: {
      module: shaderModule,
      entryPoint: 'fragmentMain',
      targets: [{ format: 'rgba8unorm' }],
    },
    primitive: { topology: 'triangle-list' },
  });
  return context.readbackRgba8Pipeline;
}

async function readTextureAsRgba8(context: VerifyGpuContext, texture: GPUTexture, width: number, height: number): Promise<Uint8Array> {
  const { device } = context;
  const outputTexture = device.createTexture({
    label: 'verify/readback/rgba8',
    size: { width, height },
    format: 'rgba8unorm',
    usage: GPUTextureUsage.RENDER_ATTACHMENT | GPUTextureUsage.COPY_SRC,
  });

  const pipeline = getReadbackRgba8Pipeline(context);
  const bindGroup = device.createBindGroup({
    label: 'verify/readback/bind-group',
    layout: pipeline.getBindGroupLayout(0),
    entries: [
      { binding: 0, resource: texture.createView() },
    ],
  });

  const bytesPerRow = align(width * 4, 256);
  const readBuffer = device.createBuffer({
    label: 'verify/readback/buffer',
    size: bytesPerRow * height,
    usage: GPUBufferUsage.COPY_DST | GPUBufferUsage.MAP_READ,
  });

  const encoder = device.createCommandEncoder({ label: 'verify/readback/encoder' });
  const renderPass = encoder.beginRenderPass({
    colorAttachments: [{
      view: outputTexture.createView(),
      loadOp: 'clear',
      clearValue: { r: 0, g: 0, b: 0, a: 0 },
      storeOp: 'store',
    }],
  });
  renderPass.setPipeline(pipeline);
  renderPass.setBindGroup(0, bindGroup);
  renderPass.draw(3);
  renderPass.end();
  encoder.copyTextureToBuffer(
    { texture: outputTexture },
    { buffer: readBuffer, bytesPerRow, rowsPerImage: height },
    { width, height },
  );
  device.queue.submit([encoder.finish()]);
  await device.queue.onSubmittedWorkDone();
  await readBuffer.mapAsync(GPUMapMode.READ);
  const mapped = new Uint8Array(readBuffer.getMappedRange());
  const rgba = new Uint8Array(width * height * 4);
  for (let y = 0; y < height; y += 1) {
    rgba.set(mapped.subarray(y * bytesPerRow, y * bytesPerRow + width * 4), y * width * 4);
  }
  readBuffer.unmap();
  outputTexture.destroy();
  readBuffer.destroy();
  return rgba;
}

const readbackLumaF32Shader = `
@group(0) @binding(0) var sourceTexture: texture_2d<f32>;
@group(0) @binding(1) var<storage, read_write> outData: array<f32>;

@compute
@workgroup_size(8, 8)
fn computeMain(@builtin(global_invocation_id) pixel: vec3u) {
  let size = textureDimensions(sourceTexture);
  if (pixel.x >= size.x || pixel.y >= size.y) {
    return;
  }

  let index = pixel.y * size.x + pixel.x;
  outData[index] = textureLoad(sourceTexture, vec2i(pixel.xy), 0).r;
}
`;

const readbackPackedX2LumaF32Shader = `
@group(0) @binding(0) var sourceTexture: texture_2d<f32>;
@group(0) @binding(1) var<storage, read_write> outData: array<f32>;

@compute
@workgroup_size(8, 8)
fn computeMain(@builtin(global_invocation_id) pixel: vec3u) {
  let packedSize = textureDimensions(sourceTexture);
  let outputSize = packedSize * vec2u(2u, 2u);
  if (pixel.x >= outputSize.x || pixel.y >= outputSize.y) {
    return;
  }

  let stagePos = pixel.xy / vec2u(2u, 2u);
  let lane = (pixel.y % 2u) * 2u + (pixel.x % 2u);
  let index = pixel.y * outputSize.x + pixel.x;
  outData[index] = clamp(textureLoad(sourceTexture, vec2i(stagePos), 0)[lane], 0.0, 1.0);
}
`;

const readbackRgbaF32Shader = `
@group(0) @binding(0) var sourceTexture: texture_2d<f32>;
@group(0) @binding(1) var<storage, read_write> outData: array<f32>;

@compute
@workgroup_size(8, 8)
fn computeMain(@builtin(global_invocation_id) pixel: vec3u) {
  let size = textureDimensions(sourceTexture);
  if (pixel.x >= size.x || pixel.y >= size.y) {
    return;
  }

  let index = (pixel.y * size.x + pixel.x) * 4u;
  let sample = textureLoad(sourceTexture, vec2i(pixel.xy), 0);
  outData[index] = sample.r;
  outData[index + 1u] = sample.g;
  outData[index + 2u] = sample.b;
  outData[index + 3u] = sample.a;
}
`;

function getReadbackLumaF32Pipeline(context: VerifyGpuContext, isPackedX2: boolean): GPUComputePipeline {
  const existing = isPackedX2 ? context.readbackPackedX2LumaF32Pipeline : context.readbackLumaF32Pipeline;
  if (existing) return existing;

  const { device } = context;
  const shaderModule = device.createShaderModule({
    label: isPackedX2 ? 'verify/readback-packed-x2-luma-f32/shader' : 'verify/readback-luma-f32/shader',
    code: isPackedX2 ? readbackPackedX2LumaF32Shader : readbackLumaF32Shader,
  });
  const pipeline = device.createComputePipeline({
    label: isPackedX2 ? 'verify/readback-packed-x2-luma-f32/pipeline' : 'verify/readback-luma-f32/pipeline',
    layout: 'auto',
    compute: {
      module: shaderModule,
      entryPoint: 'computeMain',
    },
  });
  if (isPackedX2) {
    context.readbackPackedX2LumaF32Pipeline = pipeline;
  } else {
    context.readbackLumaF32Pipeline = pipeline;
  }
  return pipeline;
}

async function readTextureFirstChannelAsF32(
  context: VerifyGpuContext,
  texture: GPUTexture,
  width: number,
  height: number,
): Promise<Float32Array> {
  const { device } = context;
  const textureSize = { width: texture.width, height: texture.height };
  const isPackedX2 = textureSize.width * 2 === width && textureSize.height * 2 === height;
  if (!isPackedX2 && (textureSize.width !== width || textureSize.height !== height)) {
    throw new Error(`Unsupported LUMA readback texture size ${textureSize.width}x${textureSize.height} for output ${width}x${height}.`);
  }

  const pipeline = getReadbackLumaF32Pipeline(context, isPackedX2);
  const readBuffer = device.createBuffer({
    label: 'verify/readback-luma-f32/read-buffer',
    size: width * height * 4,
    usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_SRC | GPUBufferUsage.COPY_DST,
  });
  const mapBuffer = device.createBuffer({
    label: 'verify/readback-luma-f32/map-buffer',
    size: width * height * 4,
    usage: GPUBufferUsage.COPY_DST | GPUBufferUsage.MAP_READ,
  });
  const bindGroup = device.createBindGroup({
    label: 'verify/readback-luma-f32/bind-group',
    layout: pipeline.getBindGroupLayout(0),
    entries: [
      { binding: 0, resource: texture.createView() },
      { binding: 1, resource: { buffer: readBuffer } },
    ],
  });

  const encoder = device.createCommandEncoder({ label: 'verify/readback-luma-f32/encoder' });
  const pass = encoder.beginComputePass();
  pass.setPipeline(pipeline);
  pass.setBindGroup(0, bindGroup);
  pass.dispatchWorkgroups(Math.ceil(width / 8), Math.ceil(height / 8));
  pass.end();
  encoder.copyBufferToBuffer(readBuffer, 0, mapBuffer, 0, width * height * 4);
  device.queue.submit([encoder.finish()]);
  await device.queue.onSubmittedWorkDone();
  await mapBuffer.mapAsync(GPUMapMode.READ);
  const mapped = mapBuffer.getMappedRange();
  const values = new Float32Array(mapped.slice(0));
  mapBuffer.unmap();
  readBuffer.destroy();
  mapBuffer.destroy();
  return values;
}

async function readTextureRgbaAsF32(
  context: VerifyGpuContext,
  texture: GPUTexture,
  width: number,
  height: number,
): Promise<Float32Array> {
  const { device } = context;
  if (!context.readbackRgbaF32Pipeline) {
    const shaderModule = device.createShaderModule({
      label: 'verify/readback-rgba-f32/shader',
      code: readbackRgbaF32Shader,
    });
    context.readbackRgbaF32Pipeline = device.createComputePipeline({
      label: 'verify/readback-rgba-f32/pipeline',
      layout: 'auto',
      compute: {
        module: shaderModule,
        entryPoint: 'computeMain',
      },
    });
  }
  const pipeline = context.readbackRgbaF32Pipeline;
  const byteLength = width * height * 4 * 4;
  const readBuffer = device.createBuffer({
    label: 'verify/readback-rgba-f32/read-buffer',
    size: byteLength,
    usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_SRC | GPUBufferUsage.COPY_DST,
  });
  const mapBuffer = device.createBuffer({
    label: 'verify/readback-rgba-f32/map-buffer',
    size: byteLength,
    usage: GPUBufferUsage.COPY_DST | GPUBufferUsage.MAP_READ,
  });
  const bindGroup = device.createBindGroup({
    label: 'verify/readback-rgba-f32/bind-group',
    layout: pipeline.getBindGroupLayout(0),
    entries: [
      { binding: 0, resource: texture.createView() },
      { binding: 1, resource: { buffer: readBuffer } },
    ],
  });

  const encoder = device.createCommandEncoder({ label: 'verify/readback-rgba-f32/encoder' });
  const pass = encoder.beginComputePass();
  pass.setPipeline(pipeline);
  pass.setBindGroup(0, bindGroup);
  pass.dispatchWorkgroups(Math.ceil(width / 8), Math.ceil(height / 8));
  pass.end();
  encoder.copyBufferToBuffer(readBuffer, 0, mapBuffer, 0, byteLength);
  device.queue.submit([encoder.finish()]);
  await device.queue.onSubmittedWorkDone();
  await mapBuffer.mapAsync(GPUMapMode.READ);
  const mapped = mapBuffer.getMappedRange();
  const values = new Float32Array(mapped.slice(0));
  mapBuffer.unmap();
  readBuffer.destroy();
  mapBuffer.destroy();
  return values;
}

class RgbaF32PairReadback {
  private readonly byteLength: number;
  private readonly readBuffers: GPUBuffer[];
  private readonly mapBuffers: GPUBuffer[];
  private readonly bindGroups: GPUBindGroup[];

  constructor(
    private readonly context: VerifyGpuContext,
    textures: readonly [GPUTexture, GPUTexture],
    private readonly width: number,
    private readonly height: number,
  ) {
    const { device } = context;
    if (!context.readbackRgbaF32Pipeline) {
      const shaderModule = device.createShaderModule({
        label: 'verify/readback-rgba-f32/shader',
        code: readbackRgbaF32Shader,
      });
      context.readbackRgbaF32Pipeline = device.createComputePipeline({
        label: 'verify/readback-rgba-f32/pipeline',
        layout: 'auto',
        compute: {
          module: shaderModule,
          entryPoint: 'computeMain',
        },
      });
    }
    const pipeline = context.readbackRgbaF32Pipeline;
    this.byteLength = width * height * 4 * 4;
    this.readBuffers = textures.map((_, index) => device.createBuffer({
      label: `verify/temporal/read-buffer/${index}`,
      size: this.byteLength,
      usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_SRC,
    }));
    this.mapBuffers = textures.map((_, index) => device.createBuffer({
      label: `verify/temporal/map-buffer/${index}`,
      size: this.byteLength,
      usage: GPUBufferUsage.COPY_DST | GPUBufferUsage.MAP_READ,
    }));
    this.bindGroups = textures.map((texture, index) => device.createBindGroup({
      label: `verify/temporal/readback-bind-group/${index}`,
      layout: pipeline.getBindGroupLayout(0),
      entries: [
        { binding: 0, resource: texture.createView() },
        { binding: 1, resource: { buffer: this.readBuffers[index] } },
      ],
    }));
  }

  encode(encoder: GPUCommandEncoder): void {
    const pipeline = this.context.readbackRgbaF32Pipeline!;
    for (let index = 0; index < this.bindGroups.length; index += 1) {
      const pass = encoder.beginComputePass({ label: `verify/temporal/readback/${index}` });
      pass.setPipeline(pipeline);
      pass.setBindGroup(0, this.bindGroups[index]);
      pass.dispatchWorkgroups(Math.ceil(this.width / 8), Math.ceil(this.height / 8));
      pass.end();
      encoder.copyBufferToBuffer(
        this.readBuffers[index],
        0,
        this.mapBuffers[index],
        0,
        this.byteLength,
      );
    }
  }

  async read(): Promise<[Float32Array, Float32Array]> {
    await Promise.all(this.mapBuffers.map(buffer => buffer.mapAsync(GPUMapMode.READ)));
    const values = this.mapBuffers.map(buffer => {
      const result = new Float32Array(buffer.getMappedRange().slice(0));
      buffer.unmap();
      return result;
    });
    return values as [Float32Array, Float32Array];
  }

  destroy(): void {
    this.readBuffers.forEach(buffer => buffer.destroy());
    this.mapBuffers.forEach(buffer => buffer.destroy());
  }
}

async function createDevice(): Promise<VerifyGpuContext> {
  if (!navigator.gpu) {
    throw new Error('WebGPU is not available in this browser.');
  }
  const adapter = await navigator.gpu.requestAdapter();
  if (!adapter) {
    throw new Error('No WebGPU adapter is available.');
  }
  const adapterInfo = await getAdapterInfo(adapter);
  const device = await adapter.requestDevice({
    requiredLimits: getRequiredDeviceLimits(adapter),
  });
  return {
    device,
    adapterInfo,
    capabilities: collectGpuCapabilities({
      adapter,
      device,
      presentationFormat: 'rgba8unorm',
    }),
  };
}

let verifyGpuContext: VerifyGpuContext | null = null;
let verifyGpuContextPromise: Promise<VerifyGpuContext> | null = null;

async function getVerifyGpuContext(): Promise<VerifyGpuContext> {
  if (verifyGpuContext) return verifyGpuContext;
  if (!verifyGpuContextPromise) {
    verifyGpuContextPromise = createDevice().then(context => {
      verifyGpuContext = context;
      context.device.lost.then(() => {
        if (verifyGpuContext === context) {
          verifyGpuContext = null;
          verifyGpuContextPromise = null;
        }
      });
      return context;
    }).catch(error => {
      verifyGpuContextPromise = null;
      throw error;
    });
  }
  return verifyGpuContextPromise;
}

function resetVerifyGpuContext(): void {
  const context = verifyGpuContext;
  verifyGpuContext = null;
  verifyGpuContextPromise = null;
  context?.device.destroy();
}

window.__probeEffectVerification = async () => {
  try {
    const context = await getVerifyGpuContext();
    return { available: true, summary: context.adapterInfo };
  } catch (error) {
    return { available: false, summary: error instanceof Error ? error.message : String(error) };
  }
};

window.__resetEffectVerification = resetVerifyGpuContext;
window.__runGpuPerformanceSuite = runGpuPerformanceSuite;
window.__resolvePresetChain = (preset, tier) => resolveAnime4kPresetEffectChain(preset, tier)
  .map(effect => effect.id);

async function loadVerificationVideo(url: string): Promise<HTMLVideoElement> {
  const video = document.createElement('video');
  video.crossOrigin = 'anonymous';
  video.muted = true;
  video.playsInline = true;
  video.preload = 'auto';
  video.src = url;
  await new Promise<void>((resolve, reject) => {
    video.addEventListener('loadeddata', () => resolve(), { once: true });
    video.addEventListener('error', () => reject(
      new Error(`Unable to decode verification video: ${video.error?.message ?? url}`),
    ), { once: true });
    video.load();
  });
  return video;
}

window.__runExternalTextureVerification = async (
  request: VerifyExternalTextureRequest,
): Promise<VerifyExternalTextureResponse> => {
  const context = await getVerifyGpuContext();
  const { device, capabilities, adapterInfo } = context;
  if (!capabilities.externalTexture) {
    throw new Error('GPUExternalTexture is unavailable.');
  }
  const descriptor = getEffectDescriptorById('anime4k/Helper/ClampHighlights');
  if (!descriptor) {
    throw new Error('ClampHighlights is not registered.');
  }
  const video = await loadVerificationVideo(request.videoUrl);
  const width = video.videoWidth;
  const height = video.videoHeight;
  const createInput = (label: string) => device.createTexture({
    label,
    size: { width, height },
    format: 'rgba16float',
    usage: GPUTextureUsage.TEXTURE_BINDING
      | GPUTextureUsage.COPY_DST
      | GPUTextureUsage.RENDER_ATTACHMENT,
  });
  const nativeInput = createInput('verify external/native input');
  const externalInput = createInput('verify external/converted input');
  const directExternalClamp = createInput('verify external/direct clamp output');
  const effect = createEffectReference(descriptor);
  const optimizationFlags = {
    fusedClampHighlights: true,
    terminalDirect: false,
    externalTexture: false,
  };
  const compileClamp = (inputTexture: GPUTexture) => compileEffectChain({
    device,
    capabilities,
    inputTexture,
    effects: [effect],
    sourceDimensions: { width, height },
    targetDimensions: { width, height },
    optimizationFlags,
  });
  const nativePlan = await compileClamp(nativeInput);
  const externalPlan = await compileClamp(externalInput);
  const conversionUploader = new VideoFrameUploader();
  conversionUploader.setExternalTextureEnabled(true);
  const directUploader = new VideoFrameUploader();
  directUploader.setExternalTextureEnabled(true);
  directUploader.setExternalClampHighlightsEnabled(true);

  try {
    device.pushErrorScope('validation');
    device.queue.copyExternalImageToTexture(
      { source: video },
      { texture: nativeInput },
      { width, height },
    );
    const nativeEncoder = device.createCommandEncoder({ label: 'verify external/native clamp' });
    nativePlan.pipelines.forEach(pipeline => pipeline.pass(nativeEncoder));

    const externalEncoder = device.createCommandEncoder({ label: 'verify external/converted clamp' });
    conversionUploader.copyFrame(device, video, externalInput, externalEncoder);
    externalPlan.pipelines.forEach(pipeline => pipeline.pass(externalEncoder));

    const directEncoder = device.createCommandEncoder({ label: 'verify external/direct clamp' });
    directUploader.copyFrame(device, video, directExternalClamp, directEncoder);
    device.queue.submit([nativeEncoder.finish(), externalEncoder.finish(), directEncoder.finish()]);
    await device.queue.onSubmittedWorkDone();
    const validationError = await device.popErrorScope();
    if (validationError) {
      throw new Error(`External texture verification failed validation: ${validationError.message}`);
    }

    const [
      nativeInputValues,
      externalInputValues,
      nativeClampValues,
      externalClampValues,
      directExternalClampValues,
    ] = await Promise.all([
      readTextureRgbaAsF32(context, nativeInput, width, height),
      readTextureRgbaAsF32(context, externalInput, width, height),
      readTextureRgbaAsF32(context, nativePlan.outputTexture, width, height),
      readTextureRgbaAsF32(context, externalPlan.outputTexture, width, height),
      readTextureRgbaAsF32(context, directExternalClamp, width, height),
    ]);
    return {
      width,
      height,
      adapterInfo,
      nativeInput: Array.from(nativeInputValues),
      externalInput: Array.from(externalInputValues),
      nativeClamp: Array.from(nativeClampValues),
      externalClamp: Array.from(externalClampValues),
      directExternalClamp: Array.from(directExternalClampValues),
    };
  } finally {
    nativePlan.pipelines.forEach(pipeline => pipeline.destroy?.());
    externalPlan.pipelines.forEach(pipeline => pipeline.destroy?.());
    conversionUploader.dispose();
    directUploader.dispose();
    nativeInput.destroy();
    externalInput.destroy();
    directExternalClamp.destroy();
    video.pause();
    video.removeAttribute('src');
    video.load();
  }
};

async function seekVerificationVideo(video: HTMLVideoElement, time: number): Promise<void> {
  const durationLimit = Number.isFinite(video.duration)
    ? Math.max(0, video.duration - 1e-4)
    : time;
  const target = Math.min(time, durationLimit);
  if (Math.abs(video.currentTime - target) < 1e-6 && video.readyState >= video.HAVE_CURRENT_DATA) {
    return;
  }
  await new Promise<void>((resolve, reject) => {
    let seeked = false;
    let framePresented = typeof video.requestVideoFrameCallback !== 'function';
    let videoFrameCallbackId: number | undefined;
    const hardTimeoutId = window.setTimeout(() => {
      cleanup();
      reject(new Error(`Timed out seeking verification video to ${target.toFixed(6)}s.`));
    }, 15000);
    const maybeResolve = () => {
      if (!seeked || !framePresented) return;
      cleanup();
      resolve();
    };
    const onSeeked = () => {
      seeked = true;
      // Chromium may not publish a newly sought surface while paused.
      if (!framePresented) void video.play().catch(onError);
      maybeResolve();
    };
    const onError = () => {
      cleanup();
      reject(new Error(`Unable to seek verification video to ${target.toFixed(6)}s.`));
    };
    const cleanup = () => {
      window.clearTimeout(hardTimeoutId);
      if (videoFrameCallbackId !== undefined) video.cancelVideoFrameCallback(videoFrameCallbackId);
      video.pause();
      video.removeEventListener('seeked', onSeeked);
      video.removeEventListener('error', onError);
    };
    video.addEventListener('seeked', onSeeked, { once: true });
    video.addEventListener('error', onError, { once: true });
    if (typeof video.requestVideoFrameCallback === 'function') {
      const waitForTargetFrame: VideoFrameRequestCallback = (_now, metadata) => {
        // Requested samples sit one quarter-frame after their intended PTS.
        // A half-frame tolerance accepts that decoded frame but rejects the
        // previously displayed frame from the preceding seek.
        const delta = metadata.mediaTime - target;
        if (seeked && delta >= -1 / 48 && delta <= 3 / 48) {
          framePresented = true;
          maybeResolve();
          return;
        }
        videoFrameCallbackId = video.requestVideoFrameCallback(waitForTargetFrame);
      };
      videoFrameCallbackId = video.requestVideoFrameCallback(waitForTargetFrame);
    }
    video.currentTime = target;
  });
}

window.__runTemporalVerification = async (
  request: VerifyTemporalRequest,
): Promise<VerifyTemporalResponse> => {
  const context = await getVerifyGpuContext();
  const { device, capabilities, adapterInfo } = context;
  const descriptors = request.effectIds.map(effectId => {
    const descriptor = getEffectDescriptorById(effectId);
    if (!descriptor) throw new Error(`Effect is not registered: ${effectId}`);
    return descriptor;
  });
  const video = await loadVerificationVideo(request.videoUrl);
  const width = video.videoWidth;
  const height = video.videoHeight;
  const createInput = (label: string) => device.createTexture({
    label,
    size: { width, height },
    format: 'rgba16float',
    usage: GPUTextureUsage.TEXTURE_BINDING
      | GPUTextureUsage.COPY_DST
      | GPUTextureUsage.RENDER_ATTACHMENT,
  });
  const baselineInput = createInput('verify temporal/baseline input');
  const optimizedInput = createInput('verify temporal/optimized input');
  const effects = descriptors.map(descriptor => createEffectReference(descriptor));
  const externalTextureActive = Boolean(request.externalTexture && capabilities.externalTexture);
  if (request.externalTexture && !externalTextureActive) {
    throw new Error('GPUExternalTexture is unavailable for temporal verification.');
  }
  const directExternalClamp = externalTextureActive
    && effects[0]?.id === 'anime4k/Helper/ClampHighlights';
  const optimizedEffects = directExternalClamp ? effects.slice(1) : effects;
  const targetDimensions = { width: request.targetWidth, height: request.targetHeight };
  const compile = (inputTexture: GPUTexture, chain: EffectReference[], flags: Partial<OptimizationFeatureFlags>) =>
    compileEffectChain({
      device,
      capabilities,
      inputTexture,
      effects: chain,
      sourceDimensions: { width, height },
      targetDimensions,
      optimizationFlags: flags,
    });
  const baselinePlan = await compile(baselineInput, effects, request.baselineFlags);
  const optimizedPlan = await compile(optimizedInput, optimizedEffects, request.optimizedFlags);
  if (
    baselinePlan.outputDimensions.width !== optimizedPlan.outputDimensions.width
    || baselinePlan.outputDimensions.height !== optimizedPlan.outputDimensions.height
  ) {
    throw new Error('Temporal baseline and optimized output dimensions differ.');
  }
  const uploader = new VideoFrameUploader();
  uploader.setExternalTextureEnabled(externalTextureActive);
  uploader.setExternalClampHighlightsEnabled(directExternalClamp);
  const thresholds = { ...defaultTemporalThresholds, ...request.thresholds };
  const metrics = new TemporalMetricsAccumulator(
    baselinePlan.outputDimensions.width,
    baselinePlan.outputDimensions.height,
    thresholds,
    request.motionOnly,
  );
  const readback = new RgbaF32PairReadback(
    context,
    [baselinePlan.outputTexture, optimizedPlan.outputTexture],
    baselinePlan.outputDimensions.width,
    baselinePlan.outputDimensions.height,
  );

  try {
    for (let frameIndex = 0; frameIndex < request.frameCount; frameIndex += 1) {
      await seekVerificationVideo(video, (frameIndex + 0.25) / request.fps);
      device.queue.copyExternalImageToTexture(
        { source: video },
        { texture: baselineInput },
        { width, height },
      );
      const encoder = device.createCommandEncoder({ label: `verify temporal/frame ${frameIndex}` });
      if (externalTextureActive) {
        uploader.copyFrame(device, video, optimizedInput, encoder);
      } else {
        device.queue.copyExternalImageToTexture(
          { source: video },
          { texture: optimizedInput },
          { width, height },
        );
      }
      baselinePlan.pipelines.forEach(pipeline => pipeline.pass(encoder));
      optimizedPlan.pipelines.forEach(pipeline => pipeline.pass(encoder));
      readback.encode(encoder);
      device.queue.submit([encoder.finish()]);
      const [baseline, optimized] = await readback.read();
      metrics.addFrame(baseline, optimized, frameIndex);
    }
    return {
      width,
      height,
      outputWidth: baselinePlan.outputDimensions.width,
      outputHeight: baselinePlan.outputDimensions.height,
      adapterInfo,
      baselinePassCount: baselinePlan.passCount,
      optimizedPassCount: optimizedPlan.passCount + (externalTextureActive ? 1 : 0),
      externalTextureActive,
      metrics: metrics.summarize(),
    };
  } finally {
    baselinePlan.pipelines.forEach(pipeline => pipeline.destroy?.());
    optimizedPlan.pipelines.forEach(pipeline => pipeline.destroy?.());
    readback.destroy();
    uploader.dispose();
    baselineInput.destroy();
    optimizedInput.destroy();
    video.pause();
    video.removeAttribute('src');
    video.load();
  }
};

window.__runEffectVerification = async (request: VerifyRequest): Promise<VerifyResponse> => {
  const descriptor = getEffectDescriptorById(request.effectId);
  if (!descriptor) {
    throw new Error(`Effect is not registered: ${request.effectId}`);
  }

  const context = await getVerifyGpuContext();
  const { device, adapterInfo, capabilities } = context;
  const inputTexture = createInputTexture(device, request);
  const effect: EffectReference = createEffectReference(descriptor);
  const scale = descriptor.dimensionBehavior.kind === 'scale' ? descriptor.dimensionBehavior.scale ?? 1 : 1;
  const targetDimensions = descriptor.dimensionBehavior.kind === 'target'
    ? { width: request.width * scale, height: request.height * scale }
    : { width: request.width * scale, height: request.height * scale };
  const terminalTexture = request.terminalPresentation
    ? device.createTexture({
      label: `verify/terminal/${request.effectId}`,
      size: targetDimensions,
      format: 'rgba8unorm',
      usage: GPUTextureUsage.RENDER_ATTACHMENT | GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.COPY_SRC,
    })
    : null;
  const resourceErrors: GpuResourceError[] = [];
  const unsubscribeResourceErrors = subscribeGpuResourceErrors(
    device,
    error => resourceErrors.push(error),
  );

  device.pushErrorScope('validation');
  setGeneratedKernelVariantOverride(device, request.kernelVariantOverride);
  let plan;
  try {
    plan = await compileEffectChain({
      device,
      capabilities,
      inputTexture,
      effects: [effect],
      sourceDimensions: { width: request.width, height: request.height },
      targetDimensions,
      optimizationFlags: request.optimizationFlags,
      terminalTarget: terminalTexture ? {
        width: targetDimensions.width,
        height: targetDimensions.height,
        format: 'rgba8unorm',
        getCurrentView: () => terminalTexture.createView(),
      } : undefined,
    });
  } finally {
    setGeneratedKernelVariantOverride(device);
  }
  const compileValidationError = await device.popErrorScope();
  await flushGpuResourceErrors(device);
  if (compileValidationError || resourceErrors.length > 0) {
    plan.pipelines.forEach(pipeline => pipeline.destroy?.());
    terminalTexture?.destroy();
    inputTexture.destroy();
    unsubscribeResourceErrors();
    const details = [
      compileValidationError?.message,
      ...resourceErrors.map(error => `${error.source}: ${error.message}`),
    ].filter(Boolean).join(' | ');
    throw new Error(`WebGPU validation failed during effect compilation: ${details}`);
  }

  device.pushErrorScope('validation');
  const encoder = device.createCommandEncoder({ label: `verify/${request.effectId}/encoder` });
  plan.pipelines.forEach(pipeline => pipeline.pass(encoder));
  device.queue.submit([encoder.finish()]);
  await device.queue.onSubmittedWorkDone();
  const executionValidationError = await device.popErrorScope();
  if (executionValidationError) {
    plan.pipelines.forEach(pipeline => pipeline.destroy?.());
    terminalTexture?.destroy();
    inputTexture.destroy();
    unsubscribeResourceErrors();
    throw new Error(`WebGPU validation failed during effect execution: ${executionValidationError.message}`);
  }

  const lumaTextureProvider = plan.pipelines[0] as { getLumaOutputTexture?: () => GPUTexture | undefined };
  const lumaTexture = lumaTextureProvider.getLumaOutputTexture?.();
  const finalTexture = plan.terminalPresenter && terminalTexture
    ? terminalTexture
    : plan.outputTexture;
  const readbackTexture = request.outputMode === 'luma' && lumaTexture
    ? lumaTexture
    : finalTexture;

  const rgba = request.includePreview
    ? await readTextureAsRgba8(
      context,
      readbackTexture,
      plan.outputDimensions.width,
      plan.outputDimensions.height,
    )
    : null;
  const lumaF32 = request.outputMode === 'luma'
    ? await readTextureFirstChannelAsF32(
      context,
      readbackTexture,
      plan.outputDimensions.width,
      plan.outputDimensions.height,
    )
    : null;
  const rgbaF32 = request.outputMode === 'rgba'
    ? await readTextureRgbaAsF32(
      context,
      finalTexture,
      plan.outputDimensions.width,
      plan.outputDimensions.height,
    )
    : null;

  plan.pipelines.forEach(pipeline => pipeline.destroy?.());
  unsubscribeResourceErrors();
  terminalTexture?.destroy();
  inputTexture.destroy();

  return {
    width: plan.outputDimensions.width,
    height: plan.outputDimensions.height,
    ...(rgba ? { rgba: Array.from(rgba) } : {}),
    ...(lumaF32 ? { lumaF32: Array.from(lumaF32) } : {}),
    ...(rgbaF32 ? { rgbaF32: Array.from(rgbaF32) } : {}),
    adapterInfo,
    passCount: plan.passCount,
    peakTextureBytes: plan.peakTextureBytes,
    textureSlotCount: plan.textureSlotCount,
    terminalPresented: Boolean(plan.terminalPresenter),
  };
};

window.__runChainVerification = async (request: VerifyChainRequest): Promise<VerifyResponse> => {
  const inputDecodeStartedAt = performance.now();
  const inputRgba = request.rgbaBase64
    ? decodeBase64Bytes(request.rgbaBase64)
    : new Uint8Array(request.rgba ?? []);
  if (inputRgba.byteLength !== request.width * request.height * 4) {
    throw new Error(`Chain input has ${inputRgba.byteLength} bytes; expected ${request.width * request.height * 4}.`);
  }
  const inputDecodeMs = performance.now() - inputDecodeStartedAt;
  const descriptors = request.effectIds.map(effectId => {
    const descriptor = getEffectDescriptorById(effectId);
    if (!descriptor) {
      throw new Error(`Effect is not registered: ${effectId}`);
    }
    return descriptor;
  });
  const context = await getVerifyGpuContext();
  const { device, adapterInfo, capabilities } = context;
  const inputTexture = createInputTexture(device, {
    effectId: request.effectIds.join('+'),
    width: request.width,
    height: request.height,
    rgba: inputRgba,
  });
  const targetDimensions = { width: request.targetWidth, height: request.targetHeight };
  const terminalTexture = request.terminalPresentation
    ? device.createTexture({
      label: 'verify/chain/terminal',
      size: targetDimensions,
      format: 'rgba8unorm',
      usage: GPUTextureUsage.RENDER_ATTACHMENT | GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.COPY_SRC,
    })
    : null;
  const resourceErrors: GpuResourceError[] = [];
  const unsubscribeResourceErrors = subscribeGpuResourceErrors(
    device,
    error => resourceErrors.push(error),
  );
  const effects = descriptors.map(descriptor => createEffectReference(descriptor));

  device.pushErrorScope('validation');
  setGeneratedKernelVariantOverride(device, request.kernelVariantOverride);
  let plan;
  const compileStartedAt = performance.now();
  try {
    plan = await compileEffectChain({
      device,
      capabilities,
      inputTexture,
      effects,
      sourceDimensions: { width: request.width, height: request.height },
      targetDimensions,
      optimizationFlags: request.optimizationFlags,
      terminalTarget: terminalTexture ? {
        ...targetDimensions,
        format: 'rgba8unorm',
        getCurrentView: () => terminalTexture.createView(),
      } : undefined,
    });
  } finally {
    setGeneratedKernelVariantOverride(device);
  }
  const compileMs = performance.now() - compileStartedAt;
  const compileValidationError = await device.popErrorScope();
  await flushGpuResourceErrors(device);
  if (compileValidationError || resourceErrors.length > 0) {
    plan.pipelines.forEach(pipeline => pipeline.destroy?.());
    terminalTexture?.destroy();
    inputTexture.destroy();
    unsubscribeResourceErrors();
    const details = [
      compileValidationError?.message,
      ...resourceErrors.map(error => `${error.source}: ${error.message}`),
    ].filter(Boolean).join(' | ');
    throw new Error(`WebGPU validation failed during chain compilation: ${details}`);
  }

  device.pushErrorScope('validation');
  const gpuExecutionStartedAt = performance.now();
  const encoder = device.createCommandEncoder({ label: 'verify/chain/encoder' });
  plan.pipelines.forEach(pipeline => pipeline.pass(encoder));
  device.queue.submit([encoder.finish()]);
  await device.queue.onSubmittedWorkDone();
  const gpuExecutionMs = performance.now() - gpuExecutionStartedAt;
  const executionValidationError = await device.popErrorScope();
  if (executionValidationError) {
    plan.pipelines.forEach(pipeline => pipeline.destroy?.());
    terminalTexture?.destroy();
    inputTexture.destroy();
    unsubscribeResourceErrors();
    throw new Error(`WebGPU validation failed during chain execution: ${executionValidationError.message}`);
  }

  const finalTexture = plan.terminalPresenter && terminalTexture
    ? terminalTexture
    : plan.outputTexture;
  const readbackStartedAt = performance.now();
  const rgba = request.includePreview
    ? await readTextureAsRgba8(
      context,
      finalTexture,
      plan.outputDimensions.width,
      plan.outputDimensions.height,
    )
    : null;
  const readbackMs = performance.now() - readbackStartedAt;
  const rgbaF32 = request.includeFloatOutput === false
    ? null
    : await readTextureRgbaAsF32(
      context,
      finalTexture,
      plan.outputDimensions.width,
      plan.outputDimensions.height,
    );

  const pngEncodeStartedAt = performance.now();
  const pngBase64 = rgba && request.outputEncoding === 'png-base64'
    ? await encodeRgbaAsPngBase64(rgba, plan.outputDimensions.width, plan.outputDimensions.height)
    : undefined;
  const pngEncodeMs = performance.now() - pngEncodeStartedAt;

  plan.pipelines.forEach(pipeline => pipeline.destroy?.());
  terminalTexture?.destroy();
  inputTexture.destroy();
  unsubscribeResourceErrors();
  return {
    width: plan.outputDimensions.width,
    height: plan.outputDimensions.height,
    rgba: rgba && request.outputEncoding !== 'png-base64' ? Array.from(rgba) : undefined,
    pngBase64,
    timings: {
      inputDecodeMs,
      compileMs,
      gpuExecutionMs,
      readbackMs,
      pngEncodeMs,
    },
    rgbaF32: rgbaF32 ? Array.from(rgbaF32) : undefined,
    adapterInfo,
    passCount: plan.passCount,
    peakTextureBytes: plan.peakTextureBytes,
    textureSlotCount: plan.textureSlotCount,
    terminalPresented: Boolean(plan.terminalPresenter),
  };
};
