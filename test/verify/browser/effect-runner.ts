import type { EffectReference } from '../../../src/types';
import { compileEffectChain } from '../../../src/core/effects/chain-compiler';
import { createEffectReference } from '../../../src/core/effects/reference';
import { getEffectDescriptorById } from '../../../src/core/effects/registry';
import { getRequiredDeviceLimits } from '../../../src/core/gpu-device-limits';

interface VerifyRequest {
  effectId: string;
  width: number;
  height: number;
  rgba: number[];
  outputMode?: 'final' | 'luma' | 'rgba';
  includePreview?: boolean;
}

interface VerifyResponse {
  width: number;
  height: number;
  rgba?: number[];
  lumaF32?: number[];
  rgbaF32?: number[];
  adapterInfo: string;
}

interface VerifyGpuContext {
  device: GPUDevice;
  adapterInfo: string;
  readbackRgba8Pipeline?: GPURenderPipeline;
  readbackLumaF32Pipeline?: GPUComputePipeline;
  readbackPackedX2LumaF32Pipeline?: GPUComputePipeline;
  readbackRgbaF32Pipeline?: GPUComputePipeline;
}

declare global {
  interface Window {
    __runEffectVerification?: (request: VerifyRequest) => Promise<VerifyResponse>;
    __probeEffectVerification?: () => Promise<{ available: boolean; summary: string }>;
    __resetEffectVerification?: () => void;
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

function createInputTexture(device: GPUDevice, request: VerifyRequest): GPUTexture {
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
  return { device, adapterInfo };
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

window.__runEffectVerification = async (request: VerifyRequest): Promise<VerifyResponse> => {
  const descriptor = getEffectDescriptorById(request.effectId);
  if (!descriptor) {
    throw new Error(`Effect is not registered: ${request.effectId}`);
  }

  const context = await getVerifyGpuContext();
  const { device, adapterInfo } = context;
  const inputTexture = createInputTexture(device, request);
  const effect: EffectReference = createEffectReference(descriptor);
  const scale = descriptor.dimensionBehavior.kind === 'scale' ? descriptor.dimensionBehavior.scale ?? 1 : 1;
  const targetDimensions = descriptor.dimensionBehavior.kind === 'target'
    ? { width: request.width * scale, height: request.height * scale }
    : { width: request.width * scale, height: request.height * scale };

  const plan = await compileEffectChain({
    device,
    inputTexture,
    effects: [effect],
    sourceDimensions: { width: request.width, height: request.height },
    targetDimensions,
  });

  const encoder = device.createCommandEncoder({ label: `verify/${request.effectId}/encoder` });
  plan.pipelines.forEach(pipeline => pipeline.pass(encoder));
  device.queue.submit([encoder.finish()]);
  await device.queue.onSubmittedWorkDone();

  const lumaTextureProvider = plan.pipelines[0] as { getLumaOutputTexture?: () => GPUTexture };
  const readbackTexture = request.outputMode === 'luma' && lumaTextureProvider.getLumaOutputTexture
    ? lumaTextureProvider.getLumaOutputTexture()
    : plan.outputTexture;

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
      plan.outputTexture,
      plan.outputDimensions.width,
      plan.outputDimensions.height,
    )
    : null;

  plan.pipelines.forEach(pipeline => pipeline.destroy?.());
  inputTexture.destroy();

  return {
    width: plan.outputDimensions.width,
    height: plan.outputDimensions.height,
    ...(rgba ? { rgba: Array.from(rgba) } : {}),
    ...(lumaF32 ? { lumaF32: Array.from(lumaF32) } : {}),
    ...(rgbaF32 ? { rgbaF32: Array.from(rgbaF32) } : {}),
    adapterInfo,
  };
};
