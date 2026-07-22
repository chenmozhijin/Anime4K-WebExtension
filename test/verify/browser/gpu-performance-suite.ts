import type { PerformanceTier } from '../../../src/types';
import type {
  PipelinePass,
  PipelineProfileRecorder,
} from '../../../src/core/effects/backend-types';
import { compileEffectChain } from '../../../src/core/effects/chain-compiler';
import { collectGpuCapabilities } from '../../../src/core/gpu-capabilities';
import { getRequiredDeviceLimits } from '../../../src/core/gpu-device-limits';
import { RenderCompositePass } from '../../../src/core/gpu-passes/render-composite-pass';
import { DepthToSpacePass } from '../../../src/core/gpu-passes/depth-to-space-pass';
import { createEffectReference } from '../../../src/core/effects/reference';
import { getEffectDescriptorById } from '../../../src/core/effects/registry';
import { resolveAnime4kPresetEffectChain } from '../../../src/engines/anime4k/preset-resolver';
import {
  resolveOptimizationFeatureFlags,
  type OptimizationFeatureFlags,
} from '../../../src/core/optimization-flags';
import {
  summarizePerformanceSamples,
  type PerformanceStatistics,
} from '../../../src/core/performance-statistics';
import { getGeneratedKernelTuningReport } from '../../../src/core/generated-models/luma-model-pipeline';

const fallbackPresentationWGSL = `
@group(0) @binding(0) var linearSampler: sampler;
@group(0) @binding(1) var sourceTexture: texture_2d<f32>;

@fragment
fn main(@location(0) uv: vec2f) -> @location(0) vec4f {
  return textureSampleBaseClampToEdge(sourceTexture, linearSampler, uv);
}
`;

export interface GpuPerformanceSuiteRequest {
  width?: number;
  height?: number;
  targetWidth?: number;
  targetHeight?: number;
  warmupFrames?: number;
  warmupMinimumMs?: number;
  frames?: number;
  repeats?: number;
  batchSize?: number;
  tiers?: PerformanceTier[];
  optimizationFlags?: Partial<OptimizationFeatureFlags>;
  effectIds?: string[];
  microKernel?: 'depth-to-space';
  workloadId?: string;
  videoUrl?: string;
}

interface MetricReport {
  samples: number[];
  statistics: PerformanceStatistics;
}

interface RepeatReport {
  repeat: number;
  gpuMs: MetricReport | null;
  encodeMs: MetricReport;
  uploadMs: MetricReport;
  submitMs: MetricReport;
  queueCompletionMs: MetricReport;
  endToEndMs: MetricReport;
  fps: number;
}

interface TierReport {
  tier: string;
  workloadKind: 'preset' | 'effects' | 'micro-kernel';
  passCount: number;
  peakTextureBytes: number;
  textureSlotCount: number;
  terminalPresented: boolean;
  requiredModules: string[];
  planHash: string;
  warmupFramesExecuted: number;
  warmupMs: number;
  repeats: RepeatReport[];
  aggregate: Omit<RepeatReport, 'repeat'>;
}

export interface GpuPerformanceSuiteReport {
  schemaVersion: 1;
  timestamp: string;
  browser: ReturnType<typeof collectGpuCapabilities>['browser'];
  adapter: ReturnType<typeof collectGpuCapabilities>['adapter'];
  features: GPUFeatureName[];
  limits: ReturnType<typeof collectGpuCapabilities>['limits'];
  timestampQuery: boolean;
  uploadFormat: 'rgba16float';
  presentationFormat: 'rgba8unorm';
  input: { width: number; height: number };
  target: { width: number; height: number };
  measurement: {
    warmupFrames: number;
    warmupMinimumMs: number;
    frames: number;
    repeats: number;
    batchSize: number;
  };
  optimizationFlags: OptimizationFeatureFlags;
  source: {
    kind: 'synthetic-canvas' | 'video';
    url?: string;
  };
  workload: {
    kind: 'preset' | 'effects' | 'micro-kernel';
    id: string;
    effectIds?: string[];
    microKernel?: 'depth-to-space';
  };
  kernelTuning: ReturnType<typeof getGeneratedKernelTuningReport>;
  tiers: TierReport[];
}

function metric(samples: number[]): MetricReport {
  return { samples, statistics: summarizePerformanceSamples(samples) };
}

function hashString(value: string): string {
  let hash = 0x811c9dc5;
  for (let index = 0; index < value.length; index += 1) {
    hash ^= value.charCodeAt(index);
    hash = Math.imul(hash, 0x01000193) >>> 0;
  }
  return hash.toString(16).padStart(8, '0');
}

function createSourceCanvas(width: number, height: number): HTMLCanvasElement {
  const canvas = document.createElement('canvas');
  canvas.width = width;
  canvas.height = height;
  const context = canvas.getContext('2d', { alpha: false });
  if (!context) {
    throw new Error('Unable to create benchmark upload canvas.');
  }
  const image = context.createImageData(width, height);
  for (let y = 0; y < height; y += 1) {
    for (let x = 0; x < width; x += 1) {
      const offset = (y * width + x) * 4;
      image.data[offset] = Math.round((x / Math.max(1, width - 1)) * 255);
      image.data[offset + 1] = Math.round((y / Math.max(1, height - 1)) * 255);
      image.data[offset + 2] = (Math.imul(x + 17, 31) ^ Math.imul(y + 7, 131)) & 0xff;
      image.data[offset + 3] = 255;
    }
  }
  context.putImageData(image, 0, 0);
  return canvas;
}

async function createVideoSource(url: string): Promise<HTMLVideoElement> {
  const video = document.createElement('video');
  video.crossOrigin = 'anonymous';
  video.muted = true;
  video.playsInline = true;
  video.preload = 'auto';
  video.src = url;
  await new Promise<void>((resolve, reject) => {
    const cleanup = () => {
      video.removeEventListener('loadeddata', onLoaded);
      video.removeEventListener('error', onError);
    };
    const onLoaded = () => {
      cleanup();
      resolve();
    };
    const onError = () => {
      cleanup();
      reject(new Error(`Unable to load benchmark video: ${video.error?.message ?? url}`));
    };
    video.addEventListener('loadeddata', onLoaded, { once: true });
    video.addEventListener('error', onError, { once: true });
    video.load();
  });
  return video;
}

function destroyVideoSource(video: HTMLVideoElement): void {
  video.pause();
  video.removeAttribute('src');
  video.load();
}

class BatchTimestampRecorder implements PipelineProfileRecorder {
  private readonly querySet: GPUQuerySet;
  private readonly resolveBuffer: GPUBuffer;
  private readonly readBuffer: GPUBuffer;
  private readonly framePairs: Array<Array<[number, number]>> = [];
  private queryCount = 0;
  private currentFrame = -1;

  constructor(private readonly device: GPUDevice, capacity: number) {
    this.querySet = device.createQuerySet({ type: 'timestamp', count: capacity });
    this.resolveBuffer = device.createBuffer({
      size: capacity * 8,
      usage: GPUBufferUsage.QUERY_RESOLVE | GPUBufferUsage.COPY_SRC,
    });
    this.readBuffer = device.createBuffer({
      size: capacity * 8,
      usage: GPUBufferUsage.COPY_DST | GPUBufferUsage.MAP_READ,
    });
  }

  beginFrame(): void {
    this.currentFrame += 1;
    this.framePairs.push([]);
  }

  recordPass(_pass: PipelinePass, encode: () => void): void {
    encode();
  }

  recordNamedPass(_label: string, _group: string, encode: () => void): void {
    encode();
  }

  createComputePassDescriptor(): GPUComputePassDescriptor {
    return { timestampWrites: this.allocatePair() };
  }

  createRenderPassDescriptor(
    _pass: PipelinePass,
    descriptor: GPURenderPassDescriptor,
  ): GPURenderPassDescriptor {
    return { ...descriptor, timestampWrites: this.allocatePair() };
  }

  async resolve(): Promise<{ gpuMs: number[]; queueCompletionMs: number }> {
    const byteLength = this.queryCount * 8;
    const encoder = this.device.createCommandEncoder({ label: 'benchmark/timestamps/resolve' });
    encoder.resolveQuerySet(this.querySet, 0, this.queryCount, this.resolveBuffer, 0);
    encoder.copyBufferToBuffer(this.resolveBuffer, 0, this.readBuffer, 0, byteLength);
    this.device.queue.submit([encoder.finish()]);
    const queueStartedAt = performance.now();
    await this.device.queue.onSubmittedWorkDone();
    const queueCompletionMs = performance.now() - queueStartedAt;
    await this.readBuffer.mapAsync(GPUMapMode.READ, 0, byteLength);
    const timestamps = new BigUint64Array(this.readBuffer.getMappedRange(0, byteLength).slice(0));
    this.readBuffer.unmap();
    const gpuMs = this.framePairs.map(pairs => pairs.reduce((total, [begin, end]) => (
      total + Number(timestamps[end] - timestamps[begin]) / 1_000_000
    ), 0));
    return { gpuMs, queueCompletionMs };
  }

  destroy(): void {
    this.querySet.destroy();
    this.resolveBuffer.destroy();
    this.readBuffer.destroy();
  }

  private allocatePair(): GPUComputePassTimestampWrites {
    if (this.currentFrame < 0) {
      throw new Error('Timestamp frame was not started.');
    }
    const beginningOfPassWriteIndex = this.queryCount;
    const endOfPassWriteIndex = this.queryCount + 1;
    this.queryCount += 2;
    this.framePairs[this.currentFrame].push([beginningOfPassWriteIndex, endOfPassWriteIndex]);
    return {
      querySet: this.querySet,
      beginningOfPassWriteIndex,
      endOfPassWriteIndex,
    };
  }
}

async function encodeWarmupFrames(options: {
  device: GPUDevice;
  source: HTMLCanvasElement | HTMLVideoElement;
  inputTexture: GPUTexture;
  passes: PipelinePass[];
  frames: number;
  batchSize: number;
  width: number;
  height: number;
}): Promise<void> {
  for (let frame = 0; frame < options.frames; frame += options.batchSize) {
    const framesInBatch = Math.min(options.batchSize, options.frames - frame);
    for (let index = 0; index < framesInBatch; index += 1) {
      options.device.queue.copyExternalImageToTexture(
        { source: options.source },
        { texture: options.inputTexture },
        { width: options.width, height: options.height },
      );
      const encoder = options.device.createCommandEncoder({ label: 'benchmark/warmup/frame' });
      options.passes.forEach(pass => pass.pass(encoder));
      options.device.queue.submit([encoder.finish()]);
    }
    await options.device.queue.onSubmittedWorkDone();
  }
}

async function measureRepeat(options: {
  repeat: number;
  device: GPUDevice;
  source: HTMLCanvasElement | HTMLVideoElement;
  inputTexture: GPUTexture;
  passes: PipelinePass[];
  passCount: number;
  frames: number;
  batchSize: number;
  width: number;
  height: number;
  timestampQuery: boolean;
}): Promise<RepeatReport> {
  const gpuSamples: number[] = [];
  const encodeSamples: number[] = [];
  const uploadSamples: number[] = [];
  const submitSamples: number[] = [];
  const queueSamples: number[] = [];
  const endToEndSamples: number[] = [];
  let totalDuration = 0;

  for (let frame = 0; frame < options.frames; frame += options.batchSize) {
    const framesInBatch = Math.min(options.batchSize, options.frames - frame);
    const recorder = options.timestampQuery
      ? new BatchTimestampRecorder(options.device, Math.max(2, options.passCount * 2 * framesInBatch))
      : null;
    const batchStartedAt = performance.now();
    for (let index = 0; index < framesInBatch; index += 1) {
      const uploadStartedAt = performance.now();
      options.device.queue.copyExternalImageToTexture(
        { source: options.source },
        { texture: options.inputTexture },
        { width: options.width, height: options.height },
      );
      uploadSamples.push(performance.now() - uploadStartedAt);

      recorder?.beginFrame();
      const encodeStartedAt = performance.now();
      const encoder = options.device.createCommandEncoder({ label: 'benchmark/measure/frame' });
      options.passes.forEach(pass => pass.pass(encoder, recorder ?? undefined));
      const commandBuffer = encoder.finish();
      encodeSamples.push(performance.now() - encodeStartedAt);

      const submitStartedAt = performance.now();
      options.device.queue.submit([commandBuffer]);
      submitSamples.push(performance.now() - submitStartedAt);
    }

    let queueCompletionMs: number;
    if (recorder) {
      const resolved = await recorder.resolve();
      gpuSamples.push(...resolved.gpuMs);
      queueCompletionMs = resolved.queueCompletionMs;
      recorder.destroy();
    } else {
      const queueStartedAt = performance.now();
      await options.device.queue.onSubmittedWorkDone();
      queueCompletionMs = performance.now() - queueStartedAt;
    }
    const batchDuration = performance.now() - batchStartedAt;
    totalDuration += batchDuration;
    for (let index = 0; index < framesInBatch; index += 1) {
      queueSamples.push(queueCompletionMs / framesInBatch);
      endToEndSamples.push(batchDuration / framesInBatch);
    }
  }

  return {
    repeat: options.repeat,
    gpuMs: options.timestampQuery ? metric(gpuSamples) : null,
    encodeMs: metric(encodeSamples),
    uploadMs: metric(uploadSamples),
    submitMs: metric(submitSamples),
    queueCompletionMs: metric(queueSamples),
    endToEndMs: metric(endToEndSamples),
    fps: options.frames * 1000 / totalDuration,
  };
}

function aggregateRepeats(repeats: RepeatReport[]): Omit<RepeatReport, 'repeat'> {
  const collect = (key: keyof Omit<RepeatReport, 'repeat' | 'fps'>): number[] => repeats.flatMap(repeat => {
    const report = repeat[key];
    return report ? report.samples : [];
  });
  return {
    gpuMs: repeats.some(repeat => repeat.gpuMs) ? metric(collect('gpuMs')) : null,
    encodeMs: metric(collect('encodeMs')),
    uploadMs: metric(collect('uploadMs')),
    submitMs: metric(collect('submitMs')),
    queueCompletionMs: metric(collect('queueCompletionMs')),
    endToEndMs: metric(collect('endToEndMs')),
    fps: repeats.reduce((sum, repeat) => sum + repeat.fps, 0) / repeats.length,
  };
}

export async function runGpuPerformanceSuite(
  request: GpuPerformanceSuiteRequest = {},
): Promise<GpuPerformanceSuiteReport> {
  if (!navigator.gpu) {
    throw new Error('WebGPU is unavailable.');
  }
  let width = request.width ?? 1920;
  let height = request.height ?? 1080;
  const warmupFrames = request.warmupFrames ?? 60;
  const warmupMinimumMs = request.warmupMinimumMs ?? 0;
  const frames = request.frames ?? 300;
  const repeats = request.repeats ?? 5;
  const batchSize = request.batchSize ?? 6;
  const tiers = request.tiers ?? ['performance', 'balanced', 'quality', 'ultra'];
  const optimizationFlags = resolveOptimizationFeatureFlags(request.optimizationFlags);
  if (request.effectIds && request.microKernel) {
    throw new Error('GPU benchmark accepts either effectIds or microKernel, not both.');
  }
  const source = request.videoUrl
    ? await createVideoSource(request.videoUrl)
    : createSourceCanvas(width, height);
  if (source instanceof HTMLVideoElement) {
    width = source.videoWidth;
    height = source.videoHeight;
  }
  const targetWidth = request.targetWidth ?? width * 2;
  const targetHeight = request.targetHeight ?? height * 2;
  const adapter = await navigator.gpu.requestAdapter();
  if (!adapter) {
    throw new Error('No WebGPU adapter is available.');
  }
  const timestampQuery = adapter.features.has('timestamp-query');
  const device = await adapter.requestDevice({
    requiredLimits: getRequiredDeviceLimits(adapter),
    ...(timestampQuery ? { requiredFeatures: ['timestamp-query' as GPUFeatureName] } : {}),
  });
  const capabilities = collectGpuCapabilities({ adapter, device, presentationFormat: 'rgba8unorm' });
  const inputTexture = device.createTexture({
    label: 'benchmark/input-rgba16float',
    size: { width, height },
    format: 'rgba16float',
    usage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.COPY_DST | GPUTextureUsage.RENDER_ATTACHMENT,
  });
  const presentationTexture = device.createTexture({
    label: 'benchmark/presentation-rgba8unorm',
    size: { width: targetWidth, height: targetHeight },
    format: 'rgba8unorm',
    usage: GPUTextureUsage.RENDER_ATTACHMENT | GPUTextureUsage.TEXTURE_BINDING,
  });
  const presentationView = presentationTexture.createView();
  const terminalTarget = {
    width: targetWidth,
    height: targetHeight,
    format: 'rgba8unorm' as const,
    getCurrentView: () => presentationView,
  };
  const tierReports: TierReport[] = [];

  try {
    const effectIds = request.effectIds;
    const workloadKind = request.microKernel ? 'micro-kernel' : effectIds ? 'effects' : 'preset';
    const workloadId = request.workloadId
      ?? (request.microKernel ? `micro:${request.microKernel}` : effectIds ? effectIds.join('+') : 'preset:A+A');
    const workloadCases = request.microKernel || effectIds
      ? [{ id: workloadId, tier: undefined }]
      : tiers.map(tier => ({ id: tier, tier }));

    for (const workloadCase of workloadCases) {
      const effects = effectIds?.map(effectId => {
        const descriptor = getEffectDescriptorById(effectId);
        if (!descriptor) {
          throw new Error(`Unknown GPU benchmark effect: ${effectId}`);
        }
        return createEffectReference(descriptor);
      }) ?? (workloadCase.tier ? resolveAnime4kPresetEffectChain('A+A', workloadCase.tier) : []);
      const plan = request.microKernel ? null : await compileEffectChain({
          device,
          inputTexture,
          effects,
          sourceDimensions: { width, height },
          targetDimensions: { width: targetWidth, height: targetHeight },
          terminalTarget,
          capabilities,
          optimizationFlags,
        });
      const microPass = request.microKernel === 'depth-to-space'
        ? new DepthToSpacePass({
          device,
          inputTextures: [inputTexture, inputTexture, inputTexture],
          name: 'Benchmark DepthToSpace',
          cacheKeyPrefix: 'benchmark/micro/depth-to-space',
          vectorized: optimizationFlags.vectorizedPixelShuffle,
        })
        : null;
      let fallbackPresentation: RenderCompositePass | null = null;
      const passes: PipelinePass[] = plan ? [...plan.pipelines] : microPass ? [microPass] : [];
      if (plan && !plan.terminalPresenter) {
        fallbackPresentation = new RenderCompositePass({
          device,
          inputTextures: [plan.outputTexture],
          outputSize: { width: targetWidth, height: targetHeight },
          fragmentWGSL: fallbackPresentationWGSL,
          name: 'Benchmark final presentation',
          cacheKeyPrefix: 'benchmark/final-presentation',
          terminalTarget,
        });
        passes.push(fallbackPresentation);
      }
      const measuredPassCount = plan
        ? plan.passCount + (fallbackPresentation ? 1 : 0)
        : passes.length;
      try {
        const warmupStartedAt = performance.now();
        let warmupFramesExecuted = 0;
        // Satisfy both a frame count and elapsed-time floor. Fast kernels otherwise
        // finish 60 frames before clocks, caches, and lazy driver compilation settle.
        do {
          await encodeWarmupFrames({
            device,
            source,
            inputTexture,
            passes,
            frames: warmupFrames,
            batchSize,
            width,
            height,
          });
          warmupFramesExecuted += warmupFrames;
        } while (performance.now() - warmupStartedAt < warmupMinimumMs);
        const warmupMs = performance.now() - warmupStartedAt;
        const repeatReports: RepeatReport[] = [];
        for (let repeat = 0; repeat < repeats; repeat += 1) {
          repeatReports.push(await measureRepeat({
            repeat: repeat + 1,
            device,
            source,
            inputTexture,
            passes,
            passCount: measuredPassCount,
            frames,
            batchSize,
            width,
            height,
            timestampQuery,
          }));
        }
        const planSignature = JSON.stringify({
          workloadId: workloadCase.id,
          modules: plan?.requiredModules ?? [],
          passCount: measuredPassCount,
          optimizationFlags,
        });
        tierReports.push({
          tier: workloadCase.id,
          workloadKind,
          passCount: measuredPassCount,
          peakTextureBytes: plan?.peakTextureBytes
            ?? (microPass ? microPass.outputTexture.width * microPass.outputTexture.height * 8 : 0),
          textureSlotCount: plan?.textureSlotCount ?? (microPass ? 1 : 0),
          terminalPresented: Boolean(plan?.terminalPresenter),
          requiredModules: plan?.requiredModules ?? [],
          planHash: hashString(planSignature),
          warmupFramesExecuted,
          warmupMs,
          repeats: repeatReports,
          aggregate: aggregateRepeats(repeatReports),
        });
      } finally {
        fallbackPresentation?.destroy();
        plan?.pipelines.forEach(pass => pass.destroy?.());
        microPass?.destroy();
      }
    }
  } finally {
    await device.queue.onSubmittedWorkDone().catch(() => undefined);
    inputTexture.destroy();
    presentationTexture.destroy();
    device.destroy();
    if (source instanceof HTMLVideoElement) {
      destroyVideoSource(source);
    }
  }

  return {
    schemaVersion: 1,
    timestamp: new Date().toISOString(),
    browser: capabilities.browser,
    adapter: capabilities.adapter,
    features: [...capabilities.features],
    limits: capabilities.limits,
    timestampQuery,
    uploadFormat: 'rgba16float',
    presentationFormat: 'rgba8unorm',
    input: { width, height },
    target: { width: targetWidth, height: targetHeight },
    measurement: { warmupFrames, warmupMinimumMs, frames, repeats, batchSize },
    optimizationFlags,
    source: {
      kind: request.videoUrl ? 'video' : 'synthetic-canvas',
      ...(request.videoUrl ? { url: request.videoUrl } : {}),
    },
    workload: {
      kind: request.microKernel ? 'micro-kernel' : request.effectIds ? 'effects' : 'preset',
      id: request.workloadId
        ?? (request.microKernel ? `micro:${request.microKernel}` : request.effectIds?.join('+') ?? 'preset:A+A'),
      ...(request.effectIds ? { effectIds: request.effectIds } : {}),
      ...(request.microKernel ? { microKernel: request.microKernel } : {}),
    },
    kernelTuning: getGeneratedKernelTuningReport(device),
    tiers: tierReports,
  };
}
