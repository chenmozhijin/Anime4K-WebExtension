import { beforeEach, describe, expect, it, vi } from 'vitest';
import { installChromeMock } from '../support/chrome';
import { createMockCanvasContext, createWebGpuMock, installWebGpuMock } from '../support/webgpu';

const compileEffectChain = vi.fn();

vi.mock('../../src/core/effects/chain-compiler', () => ({
  compileEffectChain,
}));

type MockVideoHarness = {
  video: HTMLVideoElement;
  setReadyState: (value: number) => void;
  setDimensions: (width: number, height: number) => void;
  setMetadataReady: (ready: boolean) => void;
  requestSpy: ReturnType<typeof vi.fn>;
  cancelSpy: ReturnType<typeof vi.fn>;
};

function createMockVideo(
  options: {
    readyState?: number;
    width?: number;
    height?: number;
  } = {},
): MockVideoHarness {
  let readyState = options.readyState ?? 4;
  let width = options.width ?? 320;
  let height = options.height ?? 180;
  const requestSpy = vi.fn(() => 1);
  const cancelSpy = vi.fn();
  const video = document.createElement('video');

  Object.defineProperty(video, 'readyState', {
    configurable: true,
    get: () => readyState,
  });
  Object.defineProperty(video, 'videoWidth', {
    configurable: true,
    get: () => width,
  });
  Object.defineProperty(video, 'videoHeight', {
    configurable: true,
    get: () => height,
  });
  Object.defineProperty(video, 'HAVE_CURRENT_DATA', { configurable: true, value: 2 });
  Object.defineProperty(video, 'HAVE_FUTURE_DATA', { configurable: true, value: 3 });
  Object.defineProperty(video, 'HAVE_METADATA', { configurable: true, value: 1 });

  (
    video as HTMLVideoElement & {
      requestVideoFrameCallback: typeof HTMLVideoElement.prototype.requestVideoFrameCallback;
      cancelVideoFrameCallback: typeof HTMLVideoElement.prototype.cancelVideoFrameCallback;
    }
  ).requestVideoFrameCallback = requestSpy;
  (
    video as HTMLVideoElement & {
      requestVideoFrameCallback: typeof HTMLVideoElement.prototype.requestVideoFrameCallback;
      cancelVideoFrameCallback: typeof HTMLVideoElement.prototype.cancelVideoFrameCallback;
    }
  ).cancelVideoFrameCallback = cancelSpy;

  return {
    video,
    setReadyState: (value: number) => {
      readyState = value;
    },
    setDimensions: (nextWidth: number, nextHeight: number) => {
      width = nextWidth;
      height = nextHeight;
    },
    setMetadataReady: (ready: boolean) => {
      readyState = ready ? 4 : 0;
      width = ready ? width || 320 : 0;
      height = ready ? height || 180 : 0;
    },
    requestSpy,
    cancelSpy,
  };
}

function createCompiledPlan(device: GPUDevice) {
  const outputTexture = device.createTexture({
    size: [320, 180],
    format: 'rgba16float',
    usage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.RENDER_ATTACHMENT,
  });
  const destroySpy = vi.fn();

  return {
    outputTexture,
    destroySpy,
    plan: {
      pipelines: [
        {
          pass: vi.fn(),
          getOutputTexture: () => outputTexture,
          updateParam: vi.fn(),
          destroy: destroySpy,
        },
      ],
      outputTexture,
      outputDimensions: { width: 320, height: 180 },
      warmupSteps: 1,
      requiredModules: ['test:renderer'],
    },
  };
}

async function createRendererHarness(options: {
  onError?: (error: Error) => void;
  video?: MockVideoHarness;
  performanceMonitorMode?: 'off' | 'lite' | 'gpu';
  onPerformanceSnapshot?: ReturnType<typeof vi.fn>;
  webgpuFeatures?: GPUFeatureName[];
} = {}) {
  installChromeMock();
  const webgpu = installWebGpuMock({ features: options.webgpuFeatures });
  const videoHarness = options.video ?? createMockVideo();
  const { plan, destroySpy } = createCompiledPlan(webgpu.device as unknown as GPUDevice);
  compileEffectChain.mockResolvedValue(plan);

  const canvas = document.createElement('canvas');
  const context = createMockCanvasContext(webgpu.device as unknown as GPUDevice);
  vi.spyOn(canvas, 'getContext').mockImplementation((type: string) => {
    if (type === 'webgpu') {
      return context;
    }
    return null;
  });

  const { Renderer } = await import('../../src/core/renderer');
  vi.spyOn(Renderer, 'detectWebGPUFeatures').mockResolvedValue(true);

  const renderer = await Renderer.create({
    video: videoHarness.video,
    canvas,
    effects: [],
    effectsSignature: 'test',
    targetDimensions: { width: 320, height: 180 },
    onError: options.onError,
    performanceMonitorMode: options.performanceMonitorMode,
    performanceModeName: 'Test Mode',
    performanceTier: 'balanced',
    onPerformanceSnapshot: options.onPerformanceSnapshot,
  });

  return {
    Renderer,
    renderer,
    webgpu,
    context,
    canvas,
    videoHarness,
    destroySpy,
  };
}

describe('renderer lifecycle', () => {
  beforeEach(() => {
    compileEffectChain.mockReset();
  });

  it('builds pipelines and releases them on destroy', async () => {
    const { renderer, destroySpy } = await createRendererHarness();

    renderer.destroy();

    expect(compileEffectChain).toHaveBeenCalled();
    expect(destroySpy).toHaveBeenCalledOnce();
  });

  it('fails initialization when WebGPU validation errors are captured during pipeline build', async () => {
    installChromeMock();
    const webgpu = installWebGpuMock();
    const { outputTexture } = createCompiledPlan(webgpu.device as unknown as GPUDevice);
    const videoHarness = createMockVideo();

    compileEffectChain.mockImplementation(async ({ device }: { device: GPUDevice }) => {
      (device as unknown as { emitUncapturedError: (error: { name?: string; message?: string }) => void }).emitUncapturedError({
        name: 'GPUValidationError',
        message: 'mock validation failure',
      });

      return {
        pipelines: [
          {
            pass: vi.fn(),
            getOutputTexture: () => outputTexture,
            updateParam: vi.fn(),
            destroy: vi.fn(),
          },
        ],
        outputTexture,
        outputDimensions: { width: 320, height: 180 },
        warmupSteps: 1,
        requiredModules: ['test:renderer-validation'],
      };
    });

    const canvas = document.createElement('canvas');
    const context = createMockCanvasContext(webgpu.device as unknown as GPUDevice);
    vi.spyOn(canvas, 'getContext').mockImplementation((type: string) => {
      if (type === 'webgpu') {
        return context;
      }
      return null;
    });

    const { Renderer } = await import('../../src/core/renderer');
    vi.spyOn(Renderer, 'detectWebGPUFeatures').mockResolvedValue(true);

    await expect(Renderer.create({
      video: videoHarness.video,
      canvas,
      effects: [],
      effectsSignature: 'test-validation-failure',
      targetDimensions: { width: 320, height: 180 },
    })).rejects.toThrow(/mock validation failure/);
  });

  it('requests the adapter workgroup storage limit during renderer initialization', async () => {
    installChromeMock();
    const webgpu = installWebGpuMock();
    const videoHarness = createMockVideo();
    const requestDeviceSpy = vi.spyOn(webgpu.adapter, 'requestDevice');
    const { plan } = createCompiledPlan(webgpu.device as unknown as GPUDevice);
    compileEffectChain.mockResolvedValue(plan);

    const canvas = document.createElement('canvas');
    const context = createMockCanvasContext(webgpu.device as unknown as GPUDevice);
    vi.spyOn(canvas, 'getContext').mockImplementation((type: string) => {
      if (type === 'webgpu') {
        return context;
      }
      return null;
    });

    const { Renderer } = await import('../../src/core/renderer');
    vi.spyOn(Renderer, 'detectWebGPUFeatures').mockResolvedValue(true);

    const renderer = await Renderer.create({
      video: videoHarness.video,
      canvas,
      effects: [],
      effectsSignature: 'test-required-limits',
      targetDimensions: { width: 320, height: 180 },
    });

    expect(requestDeviceSpy).toHaveBeenCalledWith(expect.objectContaining({
      requiredLimits: expect.objectContaining({
        maxComputeWorkgroupStorageSize: 32768,
      }),
    }));

    renderer.destroy();
  });

  it('keeps performance monitoring cold when disabled', async () => {
    const onPerformanceSnapshot = vi.fn();
    const { renderer, webgpu } = await createRendererHarness({ onPerformanceSnapshot });
    const requestDeviceSpy = vi.spyOn(webgpu.adapter, 'requestDevice');

    expect((renderer as any).performanceProfiler).toBeNull();
    expect(requestDeviceSpy).not.toHaveBeenCalledWith(expect.objectContaining({
      requiredFeatures: expect.arrayContaining(['timestamp-query']),
    }));

    await (renderer as any).processFrame();
    expect(onPerformanceSnapshot).not.toHaveBeenCalled();
  });

  it('collects lightweight performance snapshots when enabled', async () => {
    const onPerformanceSnapshot = vi.fn();
    const { renderer } = await createRendererHarness({
      performanceMonitorMode: 'lite',
      onPerformanceSnapshot,
    });

    (renderer as any).performanceProfiler.lastSnapshotAt = -1000;
    await (renderer as any).processFrame({ presentedFrames: 2 });

    expect(onPerformanceSnapshot).toHaveBeenCalledWith(expect.objectContaining({
      mode: 'lite',
      timingSource: 'cpu',
      gpuName: 'Mock GPU',
      uploadMethod: 'VideoFrame direct',
      modeName: 'Test Mode',
      frameMs: expect.any(Number),
      uploadMs: expect.any(Number),
      encodeMs: expect.any(Number),
      submitMs: expect.any(Number),
    }));
  });

  it('requests timestamp-query for GPU diagnostics when supported', async () => {
    installChromeMock();
    const webgpu = installWebGpuMock({ features: ['timestamp-query'] });
    const requestDeviceSpy = vi.spyOn(webgpu.adapter, 'requestDevice');
    const videoHarness = createMockVideo();
    const { plan } = createCompiledPlan(webgpu.device as unknown as GPUDevice);
    compileEffectChain.mockResolvedValue(plan);

    const canvas = document.createElement('canvas');
    const context = createMockCanvasContext(webgpu.device as unknown as GPUDevice);
    vi.spyOn(canvas, 'getContext').mockImplementation((type: string) => {
      if (type === 'webgpu') {
        return context;
      }
      return null;
    });

    const { Renderer } = await import('../../src/core/renderer');
    vi.spyOn(Renderer, 'detectWebGPUFeatures').mockResolvedValue(true);

    const renderer = await Renderer.create({
      video: videoHarness.video,
      canvas,
      effects: [],
      effectsSignature: 'test-gpu-monitor',
      targetDimensions: { width: 320, height: 180 },
      performanceMonitorMode: 'gpu',
      performanceModeName: 'Test Mode',
      performanceTier: 'balanced',
      onPerformanceSnapshot: vi.fn(),
    });

    expect(requestDeviceSpy).toHaveBeenCalledWith(expect.objectContaining({
      requiredFeatures: ['timestamp-query'],
    }));

    renderer.destroy();
  });

  it('adds asynchronous GPU timings to later diagnostics snapshots', async () => {
    const onPerformanceSnapshot = vi.fn();
    const { renderer } = await createRendererHarness({
      performanceMonitorMode: 'gpu',
      onPerformanceSnapshot,
      webgpuFeatures: ['timestamp-query'],
    });

    await (renderer as any).processFrame({ presentedFrames: 1 });
    await new Promise(resolve => setTimeout(resolve, 0));

    (renderer as any).performanceProfiler.lastSnapshotAt = -1000;
    await (renderer as any).processFrame({ presentedFrames: 2 });

    expect(onPerformanceSnapshot).toHaveBeenCalledWith(expect.objectContaining({
      mode: 'gpu',
      timingSource: 'mixed',
      timestampAvailable: true,
      groupEntries: expect.arrayContaining([
        expect.objectContaining({
          label: 'Final Blit',
          gpuMs: expect.any(Number),
          source: 'mixed',
        }),
      ]),
    }));

    renderer.destroy();
  });

  it('includes effect names in GPU validation errors during pipeline build', async () => {
    installChromeMock();
    const webgpu = installWebGpuMock();
    const { outputTexture } = createCompiledPlan(webgpu.device as unknown as GPUDevice);
    const videoHarness = createMockVideo();

    compileEffectChain.mockImplementation(async ({ device }: { device: GPUDevice }) => {
      (device as unknown as { emitUncapturedError: (error: { name?: string; message?: string }) => void }).emitUncapturedError({
        name: 'GPUValidationError',
        message: 'mock validation failure',
      });

      return {
        pipelines: [
          {
            pass: vi.fn(),
            getOutputTexture: () => outputTexture,
            updateParam: vi.fn(),
            destroy: vi.fn(),
          },
        ],
        outputTexture,
        outputDimensions: { width: 320, height: 180 },
        warmupSteps: 1,
        requiredModules: ['artcnn:C4F16'],
      };
    });

    const canvas = document.createElement('canvas');
    const context = createMockCanvasContext(webgpu.device as unknown as GPUDevice);
    vi.spyOn(canvas, 'getContext').mockImplementation((type: string) => {
      if (type === 'webgpu') {
        return context;
      }
      return null;
    });

    const { Renderer } = await import('../../src/core/renderer');
    vi.spyOn(Renderer, 'detectWebGPUFeatures').mockResolvedValue(true);

    await expect(Renderer.create({
      video: videoHarness.video,
      canvas,
      effects: [{ id: 'artcnn/Upscale/C4F16', backendId: 'artcnn', key: 'C4F16' }],
      effectsSignature: 'test-validation-artcnn',
      targetDimensions: { width: 320, height: 180 },
    })).rejects.toThrow(/Upscale ArtCNN x2 \(C4F16\)/);
  });

  it('skips frame submission when the video is not ready', async () => {
    const { renderer, webgpu, videoHarness } = await createRendererHarness();
    const queue = webgpu.device.queue as unknown as { submissions: number };
    const initialSubmissions = queue.submissions;

    videoHarness.setReadyState(1);

    await expect((renderer as any).processFrame()).resolves.toBe(false);
    expect(queue.submissions).toBe(initialSubmissions);
  });

  it('triggers source resize instead of submitting a frame when the video dimensions change', async () => {
    const { renderer, webgpu, videoHarness } = await createRendererHarness();
    const queue = webgpu.device.queue as unknown as { submissions: number };
    const initialSubmissions = queue.submissions;
    const resizeSpy = vi.spyOn(renderer as any, 'handleSourceResize').mockResolvedValue(undefined);

    videoHarness.setDimensions(640, 360);

    await expect((renderer as any).processFrame()).resolves.toBe(false);
    expect(resizeSpy).toHaveBeenCalledOnce();
    expect(queue.submissions).toBe(initialSubmissions);
  });

  it('coalesces concurrent source resize requests into one rebuild', async () => {
    const { renderer, videoHarness } = await createRendererHarness();
    let finishRebuild!: () => void;
    const buildPipelinesSpy = vi.spyOn(renderer as any, 'buildPipelines').mockImplementation(() =>
      new Promise<void>(resolve => {
        finishRebuild = resolve;
      }));
    const createResourcesSpy = vi.spyOn(renderer as any, 'createResources').mockImplementation(() => undefined);
    const createRenderBindGroupSpy = vi.spyOn(renderer as any, 'createRenderBindGroup').mockImplementation(() => undefined);

    videoHarness.setDimensions(640, 360);
    const firstResize = renderer.handleSourceResize();
    const secondResize = renderer.handleSourceResize();
    await new Promise(resolve => setTimeout(resolve, 0));

    expect(buildPipelinesSpy).toHaveBeenCalledOnce();

    finishRebuild();
    await Promise.all([firstResize, secondResize]);

    expect(createResourcesSpy).toHaveBeenCalledOnce();
    expect(createRenderBindGroupSpy).toHaveBeenCalledOnce();
  });

  it('skips rebuilds when updateConfiguration receives the same configuration', async () => {
    const { renderer } = await createRendererHarness();
    const buildPipelinesSpy = vi.spyOn(renderer as any, 'buildPipelines');
    const createResourcesSpy = vi.spyOn(renderer as any, 'createResources');

    await renderer.updateConfiguration({
      effects: [],
      effectsSignature: 'test',
      targetDimensions: { width: 320, height: 180 },
      sourceDimensions: { width: 320, height: 180 },
    });

    expect(buildPipelinesSpy).not.toHaveBeenCalled();
    expect(createResourcesSpy).not.toHaveBeenCalled();
  });

  it('rebuilds pipelines when updateConfiguration changes effects, target size, or source size', async () => {
    const { renderer } = await createRendererHarness();
    const buildPipelinesSpy = vi.spyOn(renderer as any, 'buildPipelines').mockResolvedValue(undefined);
    const createResourcesSpy = vi.spyOn(renderer as any, 'createResources').mockImplementation(() => undefined);
    const createRenderBindGroupSpy = vi.spyOn(renderer as any, 'createRenderBindGroup').mockImplementation(() => undefined);

    await renderer.updateConfiguration({
      effects: [{ id: 'effect-a', params: {} } as any],
      effectsSignature: 'changed',
      targetDimensions: { width: 640, height: 360 },
      sourceDimensions: { width: 640, height: 360 },
    });

    expect(buildPipelinesSpy).toHaveBeenCalledOnce();
    expect(createResourcesSpy).toHaveBeenCalledOnce();
    expect(createRenderBindGroupSpy).toHaveBeenCalledOnce();
    expect((renderer as any).targetDimensions).toEqual({ width: 640, height: 360 });
    expect((renderer as any).effectsSignature).toBe('changed');
  });

  it('defers resize when a new video source does not have metadata yet', async () => {
    const { renderer } = await createRendererHarness();
    const resizeSpy = vi.spyOn(renderer as any, 'handleSourceResize').mockResolvedValue(undefined);
    const newVideoHarness = createMockVideo({ readyState: 0, width: 0, height: 0 });

    await renderer.updateVideoSource(newVideoHarness.video);

    expect(resizeSpy).not.toHaveBeenCalled();
    expect((renderer as any).video).toBe(newVideoHarness.video);
  });

  it('resizes resources when a new video source has different dimensions', async () => {
    const { renderer } = await createRendererHarness();
    const resizeSpy = vi.spyOn(renderer as any, 'handleSourceResize').mockResolvedValue(undefined);
    const newVideoHarness = createMockVideo({ readyState: 4, width: 640, height: 360 });

    await renderer.updateVideoSource(newVideoHarness.video);

    expect(resizeSpy).toHaveBeenCalledOnce();
  });

  it('retries recoverable out-of-bounds copy failures once before surfacing the error', async () => {
    const onError = vi.fn();
    const { renderer } = await createRendererHarness({ onError });
    const resizeSpy = vi.spyOn(renderer as any, 'handleSourceResize').mockResolvedValue(undefined);
    vi.spyOn(renderer as any, 'copyVideoFrameToTexture').mockRejectedValue(
      Object.assign(new Error('copy out of bounds'), {
        name: 'OperationError',
        message: 'copy out of bounds',
      }),
    );
    const destroySpy = vi.spyOn(renderer, 'destroy');

    await (renderer as any).renderLoop();
    expect(resizeSpy).toHaveBeenCalledOnce();
    expect(onError).not.toHaveBeenCalled();

    await (renderer as any).renderLoop();
    expect(onError).toHaveBeenCalledOnce();
    expect(destroySpy).toHaveBeenCalledOnce();
  });

  it('recovers from device loss by rebuilding resources and restarting the render loop', async () => {
    const { renderer, videoHarness, context } = await createRendererHarness();
    const nextGpu = createWebGpuMock();
    const configureSpy = vi.spyOn(context, 'configure');
    const requestAdapterSpy = vi.spyOn(navigator.gpu, 'requestAdapter').mockResolvedValue(
      nextGpu.adapter as unknown as GPUAdapter,
    );
    const buildPipelinesSpy = vi.spyOn(renderer as any, 'buildPipelines').mockResolvedValue(undefined);
    const createRenderPipelineSpy = vi.spyOn(renderer as any, 'createRenderPipeline').mockResolvedValue(undefined);
    const createRenderBindGroupSpy = vi.spyOn(renderer as any, 'createRenderBindGroup').mockImplementation(() => undefined);
    const restartSpy = vi.spyOn(renderer as any, 'renderFirstFrameAndStartLoop').mockResolvedValue(undefined);
    (renderer as any).animationFrameId = 7;

    await (renderer as any).recoverFromDeviceLoss();

    expect(videoHarness.cancelSpy).toHaveBeenCalledWith(7);
    expect(requestAdapterSpy).toHaveBeenCalledOnce();
    expect(configureSpy).toHaveBeenCalled();
    expect(buildPipelinesSpy).toHaveBeenCalledOnce();
    expect(createRenderPipelineSpy).toHaveBeenCalledOnce();
    expect(createRenderBindGroupSpy).toHaveBeenCalledOnce();
    expect(restartSpy).toHaveBeenCalledOnce();
    expect((renderer as any).device).toBe(nextGpu.device);
    expect((renderer as any).isRecovering).toBe(false);
  });

  it('reports device loss recovery failures through onError', async () => {
    const onError = vi.fn();
    const { renderer } = await createRendererHarness({ onError });
    vi.spyOn(navigator.gpu, 'requestAdapter').mockResolvedValue(null as unknown as GPUAdapter);

    await (renderer as any).recoverFromDeviceLoss();

    expect(onError).toHaveBeenCalledOnce();
    expect(onError.mock.calls[0]?.[0]).toMatchObject({
      message: 'Failed to recover from device loss',
    });
    expect((renderer as any).isRecovering).toBe(false);
  });

  it('cleans up frame callbacks, GPU resources, and context state on destroy without double-disposing', async () => {
    const { renderer, context, webgpu, videoHarness, destroySpy } = await createRendererHarness();
    const unconfigureSpy = vi.spyOn(context, 'unconfigure');
    const deviceDestroySpy = vi.spyOn(webgpu.device, 'destroy');
    (renderer as any).animationFrameId = 9;

    renderer.destroy();
    renderer.destroy();

    expect(videoHarness.cancelSpy).toHaveBeenCalledWith(9);
    expect(unconfigureSpy).toHaveBeenCalledOnce();
    expect(deviceDestroySpy).toHaveBeenCalledOnce();
    expect(destroySpy).toHaveBeenCalledOnce();
  });
});
