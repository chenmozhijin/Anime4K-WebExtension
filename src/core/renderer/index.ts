import type {
  Dimensions,
  EnhancementEffect,
  FramePerformanceSnapshot,
  PerformanceMonitorMode,
  PerformanceTier,
} from '../../types';
import type { PipelinePass } from '../effects/backend-types';
import { compileEffectChain } from '../effects/chain-compiler';
import { getEffectDescriptor } from '../effects/registry';
import { RendererInitializationError, RendererRuntimeError } from '../errors';
import { getRequiredDeviceLimits } from '../gpu-device-limits';
import {
  createBindGroupChecked,
  clearGpuResourceCache,
  getGpuResourceCacheStats,
  getOrCreateBindGroupLayout,
  getOrCreateRenderPipeline,
  getOrCreateSampler,
  getOrCreateShaderModule,
} from '../gpu-resource-cache';
import { RendererGpuErrorMonitor } from './gpu-error-monitor';
import { clearTexturePool, getTexturePoolStats } from '../texture-pool';
import { VideoFrameUploader } from './frame-uploader';
import { createLogger } from '../../utils/logger';
import { waitForMediaReady } from '../media-wait';
import { PerformanceFrameProfiler, type PerformanceProfilerMetadata } from '../performance-monitor/profiler';
import { collectGpuCapabilities, type GpuCapabilities } from '../gpu-capabilities';
import {
  resolveOptimizationFeatureFlags,
  type OptimizationFeatureFlags,
} from '../optimization-flags';
import { acquireSharedGpuDevice, type SharedGpuDeviceLease } from '../shared-gpu-device';

const logger = createLogger('renderer');
const RENDERER_DEVICE_PROFILE_KEY = 'renderer-v1';

/**
 * 全屏纹理三角形顶点着色器
 * 定义顶点位置和UV坐标，用于渲染全屏纹理
 */
const fullscreenTexturedTriangleWGSL = `
struct VertexOutput {
  @builtin(position) Position : vec4<f32>,
  @location(0) fragUV : vec2<f32>,
}

@vertex
fn vert_main(@builtin(vertex_index) VertexIndex : u32) -> VertexOutput {
  const pos = array(
    vec2(-1.0, -1.0),
    vec2( 3.0, -1.0),
    vec2(-1.0,  3.0),
  );

  const uv = array(
    vec2(0.0, 1.0),
    vec2(2.0, 1.0),
    vec2(0.0, -1.0),
  );

  var output : VertexOutput;
  output.Position = vec4(pos[VertexIndex], 0.0, 1.0);
  output.fragUV = uv[VertexIndex];
  return output;
}
`;

/**
 * 纹理采样片段着色器
 * 从纹理中采样颜色值并输出到屏幕
 */
const sampleExternalTextureWGSL = `
@group(0) @binding(1) var mySampler: sampler;
@group(0) @binding(2) var myTexture: texture_2d<f32>;

@fragment
fn main(@location(0) fragUV : vec2f) -> @location(0) vec4f {
  // 使用基础边缘钳制采样纹理
  return textureSampleBaseClampToEdge(myTexture, mySampler, fragUV);
}
`;

/**
 * RendererOptions 定义了创建 Renderer 实例所需的配置项
 */
export interface RendererOptions {
  /** 视频播放器元素 */
  video: HTMLVideoElement;
  /** 用于渲染的 Canvas 元素 */
  canvas: HTMLCanvasElement;
  /** 要应用的增强效果数组 */
  effects: EnhancementEffect[];
  /** 效果链的稳定签名 */
  effectsSignature: string;
  /** 渲染的目标分辨率 */
  targetDimensions: Dimensions;
  /** 发生运行时错误时的回调函数 */
  onError?: (error: Error) => void;
  /** 成功渲染第一帧时的回调函数 */
  onFirstFrameRendered?: () => void;
  /** 初始化进度回调函数 */
  onProgress?: (stage: string, current?: number, total?: number) => void;
  performanceMonitorMode?: PerformanceMonitorMode;
  performanceModeName?: string;
  performanceTier?: PerformanceTier;
  onPerformanceSnapshot?: (snapshot: FramePerformanceSnapshot) => void;
  optimizationFlags?: Partial<OptimizationFeatureFlags>;
}

/**
 * Renderer 类封装了所有与 WebGPU 相关的渲染逻辑。
 * 它负责管理 GPU 设备、上下文、渲染管线、纹理和渲染循环。
 */
export class Renderer {
  // --- 核心属性 ---
  private video: HTMLVideoElement;
  private canvas: HTMLCanvasElement;
  private effects: EnhancementEffect[];
  private effectsSignature: string;
  private targetDimensions: Dimensions;
  private onError?: (error: Error) => void;
  private onFirstFrameRendered?: () => void;
  private onProgress?: (stage: string, current?: number, total?: number) => void;
  private performanceMonitorMode: PerformanceMonitorMode;
  private performanceModeName: string;
  private performanceTier: PerformanceTier;
  private onPerformanceSnapshot?: (snapshot: FramePerformanceSnapshot) => void;
  private readonly optimizationFlags: OptimizationFeatureFlags;
  private performanceProfiler: PerformanceFrameProfiler | null = null;
  private gpuName = 'Unknown GPU';
  private timestampQueryAvailable = false;
  private gpuCapabilities?: GpuCapabilities;
  private profilerPassCapacity = 1;
  private terminalPresentationActive = false;
  private externalClampHighlightsActive = false;
  private externalFallbackInProgress = false;
  private readonly finalBlitProfilePass: PipelinePass = {
    profileLabel: 'Final Blit',
    profileGroup: 'Final Blit',
    pass: () => undefined,
    getOutputTexture: () => this.finalOutputTexture,
  };

  // --- 状态标志 ---
  private destroyed = false;
  private animationFrameId: number | null = null;
  private readonly frameUploader = new VideoFrameUploader();
  /** 在单次渲染循环中是否已尝试过自动修复 */
  private fixAttempted = false;
  private lastError: Error | null = null;
  /** 是否正在恢复设备（设备丢失后的自动恢复） */
  private isRecovering = false;
  private gpuErrorMonitor: RendererGpuErrorMonitor | null = null;
  private reconfigurationTail: Promise<void> = Promise.resolve();
  private sourceResizeInFlight: Promise<void> | null = null;
  private reconfigurationRunning = false;

  // --- WebGPU 对象 ---
  private device!: GPUDevice;
  private deviceLease?: SharedGpuDeviceLease;
  private context!: GPUCanvasContext;
  private presentationFormat!: GPUTextureFormat;
  /** 用于从视频帧复制图像数据的中间纹理 */
  private videoFrameTexture!: GPUTexture;
  /** 效果处理管线链 */
  private pipelines: PipelinePass[] = [];
  private finalOutputTexture!: GPUTexture;

  // --- 最终渲染阶段的对象 ---
  private renderBindGroupLayout!: GPUBindGroupLayout;
  private renderPipeline!: GPURenderPipeline;
  private sampler!: GPUSampler;
  private renderBindGroup!: GPUBindGroup;

  // VideoFrame upload support can vary by device, so never share a probe across
  // device generations or across different GPU sessions.
  private static readonly webgpuFeatureProbeByDevice = new WeakMap<GPUDevice, Promise<boolean>>();
  /**
   * Renderer 的构造函数是私有的，请使用 `Renderer.create()` 静态方法来创建实例。
   * @param options - 初始化渲染器所需的配置
   */
  private constructor(options: RendererOptions) {
    this.video = options.video;
    this.canvas = options.canvas;
    this.effects = options.effects;
    this.effectsSignature = options.effectsSignature;
    this.targetDimensions = options.targetDimensions;
    this.onError = options.onError;
    this.onFirstFrameRendered = options.onFirstFrameRendered;
    this.onProgress = options.onProgress;
    this.performanceMonitorMode = options.performanceMonitorMode ?? 'off';
    this.performanceModeName = options.performanceModeName ?? 'Unknown';
    this.performanceTier = options.performanceTier ?? 'balanced';
    this.onPerformanceSnapshot = options.onPerformanceSnapshot;
    this.optimizationFlags = resolveOptimizationFeatureFlags(options.optimizationFlags);
  }

  /**
   * 创建并异步初始化一个新的 Renderer 实例。
   * 这是实例化 Renderer 的首选方法。
   * @param options - 初始化渲染器所需的配置
   * @returns 返回一个 Promise，解析为一个完全初始化的 Renderer 实例
   */
  public static async create(options: RendererOptions): Promise<Renderer> {
    const renderer = new Renderer(options);
    await renderer.initialize();
    return renderer;
  }

  /**
   * 初始化 WebGPU 设备、上下文和所有必要的渲染资源。
   */
  private async initialize(): Promise<void> {
    try {
      // 等待视频数据加载完成
      await waitForMediaReady(this.video, this.video.HAVE_FUTURE_DATA, {
        readinessEvents: ['loadeddata', 'canplay'],
        interruptionEvents: ['error', 'abort', 'emptied'],
      });

      // 请求 GPU 适配器，并根据平台设置能效偏好
      this.onProgress?.(chrome.i18n.getMessage('initGpu'));
      const adapterOptions = this.createAdapterOptions();
      const lease = await acquireSharedGpuDevice({
        gpu: navigator.gpu,
        adapterOptions,
        deviceProfileKey: RENDERER_DEVICE_PROFILE_KEY,
        descriptorFactory: adapter => ({
          ...(adapter.features?.has('timestamp-query')
            ? { requiredFeatures: ['timestamp-query' as GPUFeatureName] }
            : {}),
          requiredLimits: getRequiredDeviceLimits(adapter),
        }),
      });
      this.deviceLease = lease;
      const { adapter } = lease;
      this.gpuName = this.describeAdapter(adapter);

      // 请求 GPU 设备并配置 Canvas 上下文
      // 根据适配器支持的限制请求更高的缓冲区和 workgroup storage 上限，
      // 以支持高分辨率视频处理和更重的 ArtCNN C4F32 shader。
      this.device = lease.device;
      this.timestampQueryAvailable = Boolean(this.device.features?.has('timestamp-query'));
      this.setupGpuErrorMonitoring(this.device);
      this.presentationFormat = navigator.gpu.getPreferredCanvasFormat();
      this.gpuCapabilities = collectGpuCapabilities({
        adapter,
        device: this.device,
        presentationFormat: this.presentationFormat,
      });
      // 监听设备丢失事件并尝试自动恢复
      this.device.lost.then((info) => {
        // 如果渲染器已销毁，不需要处理
        if (this.destroyed) return;

        logger.warn(`GPU device lost: ${info.reason} - ${info.message}`);

        // 尝试自动恢复（仅在非主动销毁的情况下）
        if (info.reason !== 'destroyed' && !this.isRecovering) {
          logger.warn('Attempting to recover from device loss.');
          this.recoverFromDeviceLoss();
        }
      });

      // 检查是否需要使用回退上传路径
      const supportsVideoTexture = await Renderer.detectWebGPUFeatures(this.device);
      this.frameUploader.setFallbackEnabled(!supportsVideoTexture);
      this.frameUploader.setExternalTextureEnabled(
        this.optimizationFlags.externalTexture && Boolean(this.gpuCapabilities?.externalTexture),
      );
      if (this.frameUploader.isFallbackEnabled()) {
        logger.info('Using fallback uploader for copying video frames.');
      }
      this.configurePerformanceProfiler();

      this.context = this.canvas.getContext('webgpu')!;
      if (!this.context) {
        throw new RendererInitializationError('Failed to get WebGPU context from canvas.');
      }
      this.context.configure({
        device: this.device,
        format: this.presentationFormat,
        alphaMode: 'opaque',
      });

      // 创建初始资源
      this.createResources();
      await this.buildPipelines();
      await this.createRenderPipeline();
      this.createRenderBindGroup();
      this.logGeometryState('Renderer initialized');

      // 启动渲染循环，尝试渲染第一帧并启动持续渲染
      this.renderFirstFrameAndStartLoop();
    } catch (error) {
      this.releaseDeviceLease(true);
      if (error instanceof RendererInitializationError) {
        throw error;
      }
      const message = error instanceof Error
        ? error.message
        : 'An unexpected error occurred during renderer initialization.';
      throw new RendererInitializationError(`Renderer initialization failed: ${message}`, { cause: error as Error });
    }
  }

  /**
   * 创建处理所需的 GPU 资源，主要是用于接收视频帧的纹理。
   * 当视频源分辨率变化时，此方法会被调用以重新创建纹理。
   */
  private createResources(): void {
    this.videoFrameTexture?.destroy(); // 销毁旧纹理
    this.videoFrameTexture = this.device.createTexture({
      size: [this.video.videoWidth, this.video.videoHeight, 1],
      format: 'rgba16float', // 使用 float 格式以获得更高精度
      usage:
        GPUTextureUsage.TEXTURE_BINDING | // 可以作为着色器输入
        GPUTextureUsage.COPY_DST |        // 可以作为拷贝目的地
        GPUTextureUsage.RENDER_ATTACHMENT, // 可以作为渲染目标
    });

    this.frameUploader.sync(this.video);
  }

  private copyVideoFrameToTexture(encoder: GPUCommandEncoder): void | Promise<void> {
    return this.frameUploader.copyFrame(this.device, this.video, this.videoFrameTexture, encoder);
  }

  private destroyPipelines(): void {
    for (const pipeline of this.pipelines) {
      try {
        pipeline.destroy?.();
      } catch {
        // Ignore individual pipeline teardown failures.
      }
    }
    this.pipelines = [];
  }

  private clearDeviceScopedCaches(device: GPUDevice | undefined): void {
    if (!device) {
      return;
    }

    clearTexturePool(device);
    clearGpuResourceCache(device);
  }

  private createAdapterOptions(): GPURequestAdapterOptions {
    const adapterOptions: GPURequestAdapterOptions = {};
    // Windows browsers currently warn when powerPreference is specified.
    if (!navigator.platform.startsWith('Win')) {
      adapterOptions.powerPreference = 'high-performance';
    }
    return adapterOptions;
  }

  private releaseDeviceLease(destroyIfLast: boolean, invalidate = false): void {
    const lease = this.deviceLease;
    if (!lease) {
      return;
    }
    this.deviceLease = undefined;
    if (invalidate) {
      lease.invalidate();
    }
    if (!lease.release()) {
      return;
    }
    this.clearDeviceScopedCaches(lease.device);
    if (destroyIfLast) {
      lease.device.destroy();
    }
  }

  private setupGpuErrorMonitoring(device: GPUDevice): void {
    this.gpuErrorMonitor?.dispose();
    this.gpuErrorMonitor = new RendererGpuErrorMonitor(device);
  }

  private teardownGpuErrorMonitoring(): void {
    this.gpuErrorMonitor?.dispose();
    this.gpuErrorMonitor = null;
  }

  private resetCapturedGpuErrors(): void {
    this.gpuErrorMonitor?.reset();
  }

  private async throwIfCapturedGpuErrors(stage: string): Promise<void> {
    await this.gpuErrorMonitor?.throwIfCaptured(stage);
  }

  private throwIfKnownGpuErrors(stage: string): void {
    this.gpuErrorMonitor?.throwIfKnown(stage);
  }

  /**
   * 根据当前的效果链（this.effects）构建 Anime4K 处理管线。
   * 此方法会销毁旧管线并创建新管线。
   */
  private async buildPipelines(): Promise<void> {
    // 等待 GPU 队列完成后再销毁旧管道，避免资源竞争
    try {
      await this.device.queue.onSubmittedWorkDone();
    } catch {
      // 忽略错误，设备可能已丢失
    }

    this.destroyPipelines();
    this.resetCapturedGpuErrors();

    for (let i = 0; i < this.effects.length; i++) {
      // 报告预热进度
      const loadingMsg = chrome.i18n.getMessage('loadingEffect', [String(i + 1), String(this.effects.length)]);
      this.onProgress?.(loadingMsg, i + 1, this.effects.length);

      // 让出主线程，避免界面冻结
      await new Promise(resolve => setTimeout(resolve, 0));

    }

    const effectChainLabel = this.getEffectChainLabel();
    this.externalClampHighlightsActive = Boolean(
      this.optimizationFlags.externalTexture
      && this.gpuCapabilities?.externalTexture
      && this.frameUploader.getMode() === 'external'
      && this.effects[0]?.id === 'anime4k/Helper/ClampHighlights'
    );
    this.frameUploader.setExternalClampHighlightsEnabled(this.externalClampHighlightsActive);
    // Remove only a leading ClampHighlights while the uploader executes the certified
    // equivalent. A later Clamp remains in the chain because its input is no longer video.
    const compiledEffects = this.externalClampHighlightsActive
      ? this.effects.slice(1)
      : this.effects;
    const compileStartedAt = performance.now();
    const compiledPlan = await compileEffectChain({
      device: this.device,
      inputTexture: this.videoFrameTexture,
      effects: compiledEffects,
      sourceDimensions: {
        width: this.video.videoWidth,
        height: this.video.videoHeight,
      },
      targetDimensions: this.targetDimensions,
      capabilities: this.gpuCapabilities,
      optimizationFlags: this.optimizationFlags,
      terminalTarget: {
        width: this.targetDimensions.width,
        height: this.targetDimensions.height,
        format: this.presentationFormat,
        getCurrentView: () => this.context.getCurrentTexture().createView(),
      },
    });
    const compileTime = performance.now() - compileStartedAt;
    let compiledPlanAccepted = false;

    try {
      await this.throwIfCapturedGpuErrors(this.buildGpuStageLabel('effect compilation', effectChainLabel));

      this.pipelines = compiledPlan.pipelines;
      this.finalOutputTexture = compiledPlan.outputTexture;
      this.terminalPresentationActive = Boolean(compiledPlan.terminalPresenter);
      // Query capacity includes passes outside the compiled plan: fallback presentation
      // and the external uploader's fused leading ClampHighlights render pass.
      this.profilerPassCapacity = (compiledPlan.passCount ?? this.pipelines.length)
        + (this.terminalPresentationActive ? 0 : 1)
        + (this.externalClampHighlightsActive ? 1 : 0);
      this.configurePerformanceProfiler(undefined, this.profilerPassCapacity);
      compiledPlanAccepted = true;

      const warmupStartedAt = performance.now();
      let warmupError: unknown = null;
      try {
      const commandEncoder = this.device.createCommandEncoder();
      this.pipelines.forEach((pipeline) => pipeline.pass(commandEncoder));
      this.device.queue.submit([commandEncoder.finish()]);
      // Initialization may synchronize to surface validation errors before playback.
      // The frame loop deliberately never waits for queue completion.
      await this.device.queue.onSubmittedWorkDone();
      } catch (error) {
        warmupError = error;
      }
      await this.throwIfCapturedGpuErrors(this.buildGpuStageLabel('effect warmup', effectChainLabel));
      if (warmupError) {
        throw new RendererRuntimeError('Failed to warmup compiled effect plan.', { cause: warmupError as Error });
      }
      const warmupTime = performance.now() - warmupStartedAt;

      // 通知预热完成
      this.onProgress?.(null as unknown as string);

      const cacheStats = getGpuResourceCacheStats(this.device);
      const texturePoolStats = getTexturePoolStats(this.device);
      logger.debug(
        `Built ${compiledPlan.passCount ?? this.pipelines.length} passes `
        + `(warmupSteps=${compiledPlan.warmupSteps}, modules=${compiledPlan.requiredModules.join(', ') || 'none'})`
      );
      logger.debug(
        `buildPipelines stats: compile=${compileTime.toFixed(2)}ms, `
        + `warmup=${warmupTime.toFixed(2)}ms, `
        + `cache(shader h/m=${cacheStats.shaderHits}/${cacheStats.shaderMisses}, `
        + `pipeline h/m=${cacheStats.pipelineHits}/${cacheStats.pipelineMisses}), `
        + `texturePool(h/m=${texturePoolStats.hits}/${texturePoolStats.misses}, `
        + `active=${texturePoolStats.active}, available=${texturePoolStats.available}, `
        + `cachedBytes=${texturePoolStats.cachedBytes}), `
        + `planTextures(slots=${compiledPlan.textureSlotCount ?? 'unknown'}, `
        + `peakBytes=${compiledPlan.peakTextureBytes ?? 'unknown'})`
      );
    } catch (error) {
      if (compiledPlanAccepted) {
        this.destroyPipelines();
      } else {
        for (const pipeline of compiledPlan.pipelines) {
          try {
            pipeline.destroy?.();
          } catch {
            // Ignore teardown failures from a rejected compiled plan.
          }
        }
      }
      clearGpuResourceCache(this.device);
      throw error;
    }
  }

  /**
   * 检测当前环境的 WebGPU 实现是否支持直接从 VideoFrame 复制纹理。
   */
  public static async detectWebGPUFeatures(device: GPUDevice): Promise<boolean> {
    const existingProbe = Renderer.webgpuFeatureProbeByDevice.get(device);
    if (existingProbe) {
      return existingProbe;
    }

    const probe = (async () => {
      let frame: VideoFrame | undefined;
      let texture: GPUTexture | undefined;
      try {
        // 在 initialize() 中已经检测了基本的 WebGPU 支持，这里只需要检测 VideoFrame 支持

        // 创建一个 OffscreenCanvas
        const offscreenCanvas = new OffscreenCanvas(1, 1);
        // 获取 2D 上下文
        const context = offscreenCanvas.getContext('2d');
        if (!context) {
          throw new Error('Failed to get 2d context from OffscreenCanvas');
        }
        // context.fillStyle = 'black';
        context.fillRect(0, 0, 1, 1);
        // 创建一个最小化的 VideoFrame 和 GPUTexture 用于测试
        frame = new VideoFrame(offscreenCanvas, { timestamp: 0 });
        texture = device.createTexture({
          size: [1, 1],
          format: 'rgba8unorm',
          usage: GPUTextureUsage.COPY_DST | GPUTextureUsage.RENDER_ATTACHMENT,
        });

        // 核心测试：此操作如果不支持会抛出异常
        device.queue.copyExternalImageToTexture({ source: frame }, { texture }, [1, 1]);

        // 如果成功，则说明支持
        logger.debug('WebGPU feature detection: VideoFrame as texture source is supported.');
        return true;
      } catch (error) {
        // 任何步骤失败都意味着不支持
        logger.debug('WebGPU feature detection: VideoFrame as texture source is not supported.', error);
        return false;
      } finally {
        frame?.close();
        texture?.destroy();
      }
    })();

    Renderer.webgpuFeatureProbeByDevice.set(device, probe);
    return probe;
  }

  /**
   * 创建最终的渲染管线，该管线负责将处理完成的纹理绘制到 Canvas 上。
   */
  private async createRenderPipeline(): Promise<void> {
    const vertexModule = getOrCreateShaderModule(this.device, 'core/renderer/final-blit/shader/vertex', () => ({
      label: 'renderer final blit vertex module',
      code: fullscreenTexturedTriangleWGSL,
    }));
    const fragmentModule = getOrCreateShaderModule(this.device, 'core/renderer/final-blit/shader/fragment', () => ({
      label: 'renderer final blit fragment module',
      code: sampleExternalTextureWGSL,
    }));

    this.renderBindGroupLayout = getOrCreateBindGroupLayout(this.device, 'core/renderer/final-blit/layout/default', () => ({
      label: 'renderer final blit bind group layout',
      entries: [
        { binding: 1, visibility: GPUShaderStage.FRAGMENT, sampler: {} },
        { binding: 2, visibility: GPUShaderStage.FRAGMENT, texture: {} },
      ],
    }));

    this.renderPipeline = getOrCreateRenderPipeline(
      this.device,
      `core/renderer/final-blit/pipeline/${this.presentationFormat}`,
      () => ({
        label: 'renderer final blit pipeline',
        layout: this.device.createPipelineLayout({
          label: 'renderer final blit pipeline layout',
          bindGroupLayouts: [this.renderBindGroupLayout],
        }),
        vertex: {
          module: vertexModule,
          entryPoint: 'vert_main',
        },
        fragment: {
          module: fragmentModule,
          entryPoint: 'main',
          targets: [{ format: this.presentationFormat }],
        },
        primitive: { topology: 'triangle-list' },
      }),
    );

    this.sampler = getOrCreateSampler(this.device, 'core/renderer/final-blit/sampler/linear-linear', () => ({
      magFilter: 'linear',
      minFilter: 'linear',
    }));
  }

  /**
   * 创建渲染绑定组，它将实际的资源（采样器和最终纹理）绑定到渲染管线。
   */
  private createRenderBindGroup(): void {
    if (this.terminalPresentationActive) {
      return;
    }
    this.renderBindGroup = createBindGroupChecked(this.device, 'core/renderer/final-blit', () => ({
      layout: this.renderBindGroupLayout,
      entries: [
        { binding: 1, resource: this.sampler },
        { binding: 2, resource: this.finalOutputTexture.createView() },
      ],
    }));
  }

  /**
   * 处理单帧渲染的核心逻辑。
   * @returns {boolean} 如果成功渲染了一帧则返回 true，否则返回 false。
   */
  private async processFrame(videoFrameMetadata?: VideoFrameCallbackMetadata): Promise<boolean> {
    if (this.destroyed) return false;

    try {
      const frameStartedAt = performance.now();
      const profiler = this.performanceProfiler;
      profiler?.beginFrame(videoFrameMetadata);

      if (this.reconfigurationRunning) {
        return false;
      }

      if (this.video.readyState < this.video.HAVE_CURRENT_DATA) {
        return false; // 视频未准备好，跳过此帧
      }

      // 检查分辨率是否变化
      if (this.video.videoWidth !== this.videoFrameTexture.width || this.video.videoHeight !== this.videoFrameTexture.height) {
        logger.debug(`Resolution changed: ${this.videoFrameTexture.width}x${this.videoFrameTexture.height} -> ${this.video.videoWidth}x${this.video.videoHeight}`);
        void this.handleSourceResize();
        return false; // 分辨率已变，跳过此帧的渲染，等待下一帧
      }

      // 将视频帧复制到纹理
      const uploadStartedAt = performance.now();
      const commandEncoder = this.device.createCommandEncoder();
      const upload = this.copyVideoFrameToTexture(commandEncoder);
      if (upload) {
        await upload;
      }
      const uploadMs = performance.now() - uploadStartedAt;
      profiler?.addInstantEntry('Upload', 'Upload', uploadMs);

      const encodeStartedAt = performance.now();
      this.pipelines.forEach((pipeline) => pipeline.pass(commandEncoder, profiler ?? undefined));
      const encodeFinalBlit = () => {
        const descriptor: GPURenderPassDescriptor = {
          colorAttachments: [{
            view: this.context.getCurrentTexture().createView(),
            clearValue: { r: 0.0, g: 0.0, b: 0.0, a: 1.0 },
            loadOp: 'clear',
            storeOp: 'store',
          }],
        };
        const passEncoder = commandEncoder.beginRenderPass(
          profiler?.createRenderPassDescriptor?.(this.finalBlitProfilePass, descriptor) ?? descriptor,
        );
        passEncoder.setPipeline(this.renderPipeline);
        passEncoder.setBindGroup(0, this.renderBindGroup);
        passEncoder.draw(3);
        passEncoder.end();
      };
      if (!this.terminalPresentationActive) {
        if (profiler) {
          profiler.recordNamedPass('Final Blit', 'Final Blit', encodeFinalBlit);
        } else {
          encodeFinalBlit();
        }
      }
      profiler?.resolveGpuQueries?.(commandEncoder);
      const commandBuffer = commandEncoder.finish();
      const encodeMs = performance.now() - encodeStartedAt;
      const submitStartedAt = performance.now();
      this.device.queue.submit([commandBuffer]);
      profiler?.collectGpuResultsAsync?.();
      const submitMs = performance.now() - submitStartedAt;
      this.throwIfKnownGpuErrors('frame submission');
      profiler?.completeFrame({
        frameMs: performance.now() - frameStartedAt,
        uploadMs,
        encodeMs,
        submitMs,
      });

      return true; // 成功渲染

    } catch (error) {
      logger.error('Frame processing failed.', error);

      if (this.frameUploader.getMode() === 'external' && !this.externalFallbackInProgress) {
        // Disable both external upload and its fused leading Clamp, then rebuild from
        // the original effects list. Falling back without rebuilding would skip Clamp.
        this.externalFallbackInProgress = true;
        this.externalClampHighlightsActive = false;
        this.optimizationFlags.externalTexture = false;
        this.frameUploader.setExternalClampHighlightsEnabled(false);
        this.frameUploader.setExternalTextureEnabled(false);
        logger.warn('External texture path failed; rebuilding the copy-based chain.', error);
        void this.handleSourceResize().finally(() => {
          this.externalFallbackInProgress = false;
        });
        return false;
      }

      // 检查是否是可恢复的尺寸不匹配错误
      if (error instanceof Error && error.name === 'OperationError' && error.message.includes('out of bounds')) {
        // 这是一个潜在可恢复的错误
        this.lastError = new RendererRuntimeError('Texture copy failed due to size mismatch.', { cause: error, recoverable: true });
        // 仅在第一次尝试时进行修复
        if (!this.fixAttempted) {
          logger.warn('Caught out-of-bounds error. Attempting to recover by resizing resources.');
          void this.handleSourceResize();
        }
      } else {
        // 对于所有其他错误，视为不可恢复，并包含原始错误信息
        const errorMessage = error instanceof Error ? error.message : String(error);
        this.lastError = new RendererRuntimeError(`Frame processing failed: ${errorMessage}`, { cause: error as Error });
      }
      // 返回 false，让渲染循环决定下一步操作
      return false;
    }
  }

  /**
   * 尝试渲染第一帧。成功后，调用回调并切换到常规渲染循环。
   * 如果不成功（例如视频暂停），则重新调度自身。
   */
  private renderFirstFrameAndStartLoop = async (_now?: DOMHighResTimeStamp, metadata?: VideoFrameCallbackMetadata): Promise<void> => {
    if (this.destroyed) return;

    if (await this.processFrame(metadata)) {
      // 第一帧成功渲染
      this.onFirstFrameRendered?.();
      this.fixAttempted = false;
      this.lastError = null;
      // 切换到常规渲染循环
      this.animationFrameId = this.video.requestVideoFrameCallback(this.renderLoop);
    } else {
      // 第一帧渲染失败或被跳过
      const error = this.lastError;
      if (error) {
        // 这是一个真正的错误
        if (error instanceof RendererRuntimeError && error.recoverable && !this.fixAttempted) {
          this.fixAttempted = true; // 标记已尝试修复
          logger.warn('Retrying first frame render after recovery attempt.');
        } else {
          logger.error('Unrecoverable error on first frame. Destroying renderer.');
          if (this.onError) this.onError(error);
          this.destroy();
          return; // 停止
        }
      } else {
        // 如果没有错误，说明是良性跳帧（如分辨率调整），直接重试
        logger.debug('First frame skipped, retrying.');
      }

      if (!this.destroyed) {
        this.animationFrameId = this.video.requestVideoFrameCallback(this.renderFirstFrameAndStartLoop);
      }
    }
  };

  /**
   * 常规渲染循环，处理第一帧之后的所有帧。
   */
  private renderLoop = async (_now?: DOMHighResTimeStamp, metadata?: VideoFrameCallbackMetadata): Promise<void> => {
    if (this.destroyed) return;

    if (await this.processFrame(metadata)) {
      // 帧渲染成功
      this.fixAttempted = false;
      this.lastError = null;
    } else {
      // 帧渲染失败或被跳过
      const error = this.lastError;
      if (error) {
        // 这是一个真正的错误
        if (error instanceof RendererRuntimeError && error.recoverable && !this.fixAttempted) {
          this.fixAttempted = true; // 标记已尝试修复，下一帧将是第二次尝试
          logger.warn('Retrying frame render after recovery attempt.');
        } else {
          logger.error(`Unrecoverable error in render loop. Destroying renderer. Error: ${error.message}`);
          if (this.onError) this.onError(error);
          this.destroy();
          return; // 停止循环
        }
      }
      // 如果没有错误，说明是良性跳帧（如分辨率调整），则什么都不做，等待下一帧
    }

    // 持续调度自身
    if (!this.destroyed) {
      this.animationFrameId = this.video.requestVideoFrameCallback(this.renderLoop);
    }
  };

  /**
   * 当视频源本身的分辨率发生变化时调用（例如，用户在视频播放器中切换了清晰度）
   * 这将重新创建基于视频原始尺寸的资源
   */
  public async handleSourceResize(): Promise<void> {
    if (this.destroyed) return;
    if (this.sourceResizeInFlight) {
      return this.sourceResizeInFlight;
    }

    this.sourceResizeInFlight = this.enqueueReconfiguration(async () => {
      await this.performSourceResize();
    }).finally(() => {
      this.sourceResizeInFlight = null;
    });

    return this.sourceResizeInFlight;
  }

  private async performSourceResize(): Promise<void> {
    if (this.destroyed) return;
    if (this.video.videoWidth <= 0 || this.video.videoHeight <= 0) {
      logger.debug('Skipping source resize because metadata is not ready.');
      return;
    }

    logger.debug('Resizing renderer due to video source dimension change.');
    this.createResources();
    this.configurePerformanceProfiler();
    await this.buildPipelines();
    this.createRenderBindGroup();
    this.logGeometryState('Renderer source resized');
    logger.debug('Renderer resized for source.');
  }

  /**
   * 根据用户设置（效果或目标分辨率）更新渲染器配置
   * @param options 包含新效果和目标尺寸的对象
   */
  public async updateConfiguration(options: {
    effects: EnhancementEffect[];
    effectsSignature: string;
    targetDimensions: Dimensions;
    sourceDimensions: Dimensions;
  }): Promise<void> {
    if (this.destroyed) return;

    return this.enqueueReconfiguration(async () => {
      await this.performUpdateConfiguration(options);
    });
  }

  public updatePerformanceMonitor(options: {
    mode: PerformanceMonitorMode;
    modeName: string;
    tier: PerformanceTier;
    sourceDimensions: Dimensions;
    targetDimensions: Dimensions;
    onSnapshot?: (snapshot: FramePerformanceSnapshot) => void;
  }): void {
    this.performanceMonitorMode = options.mode;
    this.performanceModeName = options.modeName;
    this.performanceTier = options.tier;
    this.targetDimensions = options.targetDimensions;
    this.onPerformanceSnapshot = options.onSnapshot;

    if (options.mode === 'off' || !options.onSnapshot) {
      this.performanceProfiler?.destroy();
      this.performanceProfiler = null;
      return;
    }

    this.configurePerformanceProfiler(options.sourceDimensions);
  }

  private async performUpdateConfiguration(options: {
    effects: EnhancementEffect[];
    effectsSignature: string;
    targetDimensions: Dimensions;
    sourceDimensions: Dimensions;
  }): Promise<void> {
    if (this.destroyed) return;

    const { effects, effectsSignature, targetDimensions, sourceDimensions } = options;

    const effectsChanged = this.effectsSignature !== effectsSignature;
    const dimensionsChanged = this.targetDimensions.width !== targetDimensions.width || this.targetDimensions.height !== targetDimensions.height;
    const sourceDimensionsChanged =
      this.videoFrameTexture.width !== sourceDimensions.width
      || this.videoFrameTexture.height !== sourceDimensions.height;

    if (!effectsChanged && !dimensionsChanged && !sourceDimensionsChanged) {
      logger.debug('Configuration unchanged, skipping pipeline rebuild.');
      return;
    }

    if (dimensionsChanged) {
      logger.debug(`Updating target dimensions to ${targetDimensions.width}x${targetDimensions.height}.`);
      this.targetDimensions = targetDimensions;
    }

    if (effectsChanged) {
      logger.debug('Updating effects.');
      this.effects = effects;
      this.effectsSignature = effectsSignature;
    }

    if (sourceDimensionsChanged) {
      logger.debug(`Updating source dimensions to ${this.video.videoWidth}x${this.video.videoHeight}.`);
      this.createResources();
    }

    logger.debug('Rebuilding pipeline due to configuration update.');
    await this.buildPipelines();
    this.createRenderBindGroup();
    this.logGeometryState('Renderer configuration updated');
    logger.debug('Renderer configuration updated.');
  }

  /**
   * 更新渲染器使用的视频源。
   * @param newVideo - 新的 HTMLVideoElement
   */
  public async updateVideoSource(newVideo: HTMLVideoElement): Promise<void> {
    logger.debug('Renderer video source updated.');
    this.video = newVideo;
    this.logGeometryState('Renderer video source rebound');

    if (newVideo.videoWidth <= 0 || newVideo.videoHeight <= 0) {
      logger.debug('New video metadata is not ready yet. Deferring source resize.');
      return;
    }

    if (newVideo.videoWidth !== this.videoFrameTexture.width || newVideo.videoHeight !== this.videoFrameTexture.height) {
      logger.debug('Video dimensions changed on reattach. Updating renderer.');
      await this.handleSourceResize();
    }
  }

  private enqueueReconfiguration(task: () => Promise<void>): Promise<void> {
    const run = this.reconfigurationTail
      .catch(() => undefined)
      .then(async () => {
        if (this.destroyed) {
          return;
        }

        this.reconfigurationRunning = true;
        try {
          await task();
        } finally {
          this.reconfigurationRunning = false;
        }
      });
    this.reconfigurationTail = run;
    return run;
  }

  /**
   * 从设备丢失中恢复
   * 尝试重新初始化 GPU 资源并恢复渲染
   */
  private async recoverFromDeviceLoss(): Promise<void> {
    if (this.destroyed || this.isRecovering) return;

    this.isRecovering = true;
    logger.warn('Starting device recovery.');

    try {
      // 停止当前渲染循环
      if (this.animationFrameId) {
        this.video.cancelVideoFrameCallback(this.animationFrameId);
        this.animationFrameId = null;
      }

      this.destroyPipelines();
      this.videoFrameTexture?.destroy();
      this.teardownGpuErrorMonitoring();
      this.releaseDeviceLease(true, true);

      // 重新请求 GPU 适配器和设备
      const lease = await acquireSharedGpuDevice({
        gpu: navigator.gpu,
        adapterOptions: this.createAdapterOptions(),
        deviceProfileKey: RENDERER_DEVICE_PROFILE_KEY,
        descriptorFactory: adapter => ({
          ...(adapter.features?.has('timestamp-query')
            ? { requiredFeatures: ['timestamp-query' as GPUFeatureName] }
            : {}),
          requiredLimits: getRequiredDeviceLimits(adapter),
        }),
      });
      this.deviceLease = lease;
      const { adapter } = lease;
      this.device = lease.device;
      this.gpuName = this.describeAdapter(adapter);
      this.timestampQueryAvailable = Boolean(this.device.features?.has('timestamp-query'));
      this.setupGpuErrorMonitoring(this.device);
      this.gpuCapabilities = collectGpuCapabilities({
        adapter,
        device: this.device,
        presentationFormat: this.presentationFormat,
      });

      this.frameUploader.setExternalTextureEnabled(
        this.optimizationFlags.externalTexture && this.gpuCapabilities.externalTexture,
      );

      // 设置新设备的丢失监听
      this.device.lost.then((info) => {
        if (this.destroyed) return;
        logger.warn(`GPU device lost: ${info.reason} - ${info.message}`);
        if (info.reason !== 'destroyed' && !this.isRecovering) {
          this.recoverFromDeviceLoss();
        }
      });

      const supportsVideoTexture = await Renderer.detectWebGPUFeatures(this.device);
      this.frameUploader.setFallbackEnabled(!supportsVideoTexture);

      // 重新配置上下文
      this.context.configure({
        device: this.device,
        format: this.presentationFormat,
        alphaMode: 'opaque',
      });

      // 重建资源和管道
      this.createResources();
      this.configurePerformanceProfiler();
      await this.buildPipelines();
      await this.createRenderPipeline();
      this.createRenderBindGroup();
      this.logGeometryState('Renderer recovered from device loss');

      // 重启渲染循环
      this.isRecovering = false;
      this.renderFirstFrameAndStartLoop();

      logger.warn('Device recovery successful.');
    } catch (error) {
      this.isRecovering = false;
      logger.error('Device recovery failed.', error);
      if (this.onError) {
        this.onError(new RendererRuntimeError('Failed to recover from device loss', { cause: error as Error }));
      }
    }
  }

  /**
   * 销毁渲染器并释放所有 WebGPU 资源。
   * 这是一个关键的清理方法，以防止内存和 GPU 资源泄漏。
   */
  public destroy(): void {
    if (this.destroyed) return;
    // 立即设置销毁标志，以防止任何异步操作（如 device.lost）在销毁过程中执行不必要的操作
    this.destroyed = true;
    // 停止渲染循环
    if (this.animationFrameId) {
      this.video.cancelVideoFrameCallback(this.animationFrameId);
      this.animationFrameId = null;
    }

    // 安全地销毁所有 GPU 资源
    try {
      this.destroyPipelines();
      this.videoFrameTexture?.destroy();
      this.teardownGpuErrorMonitoring();
      this.performanceProfiler?.destroy();
      this.performanceProfiler = null;
      // 解除画布与GPU设备的关联，这对于后续重新初始化至关重要
      this.context?.unconfigure();
      // The final owner clears shared caches and destroys the shared device.
      this.releaseDeviceLease(true);
      this.frameUploader.dispose();
      logger.debug('Renderer destroyed.');
    } catch (error) {
      logger.error('Error during renderer destruction.', error);
    }
  }

  private logGeometryState(context: string): void {
    const canvasRect = this.canvas.getBoundingClientRect();
    logger.debug(
      `${context}: `
      + `source=${this.video.videoWidth}x${this.video.videoHeight}, `
      + `renderTarget=${this.targetDimensions.width}x${this.targetDimensions.height}, `
      + `videoBox=${this.video.offsetWidth}x${this.video.offsetHeight}, `
      + `canvasRect=${canvasRect.left.toFixed(2)},${canvasRect.top.toFixed(2)} `
      + `${canvasRect.width.toFixed(2)}x${canvasRect.height.toFixed(2)}.`
    );
  }

  private getEffectChainLabel(): string | null {
    if (this.effects.length === 0) {
      return null;
    }

    const names = this.effects.map((effect) => {
      const descriptor = getEffectDescriptor(effect);
      return descriptor?.name ?? effect.id;
    });

    return names.join(' -> ');
  }

  private buildGpuStageLabel(stage: string, effectChainLabel: string | null): string {
    return effectChainLabel ? `${stage} (${effectChainLabel})` : stage;
  }

  private configurePerformanceProfiler(
    sourceDimensions: Dimensions | undefined = undefined,
    passCapacity = this.profilerPassCapacity,
  ): void {
    const resolvedSourceDimensions = sourceDimensions ?? {
      width: this.video.videoWidth,
      height: this.video.videoHeight,
    };
    if (this.performanceMonitorMode === 'off' || !this.onPerformanceSnapshot) {
      this.performanceProfiler?.destroy();
      this.performanceProfiler = null;
      return;
    }

    const metadata: PerformanceProfilerMetadata = {
      mode: this.performanceMonitorMode,
      gpuName: this.gpuName,
      uploadMethod: this.frameUploader.getMode() === 'external'
        ? 'GPUExternalTexture'
        : this.frameUploader.isFallbackEnabled()
          ? 'Fallback canvas'
          : 'VideoFrame direct',
      modeName: this.performanceModeName,
      tier: this.performanceTier,
      sourceDimensions: resolvedSourceDimensions,
      targetDimensions: this.targetDimensions,
      timestampAvailable: this.performanceMonitorMode === 'gpu' && this.timestampQueryAvailable,
    };

    if (!this.performanceProfiler) {
      this.performanceProfiler = new PerformanceFrameProfiler(metadata, this.onPerformanceSnapshot, {
        device: this.device,
        passCapacity,
      });
      return;
    }

    this.performanceProfiler.updateMetadata(metadata, {
      device: this.device,
      passCapacity,
    });
  }

  private describeAdapter(adapter: GPUAdapter): string {
    const info = adapter.info;
    const description = info?.description?.trim();
    if (description) {
      return description;
    }

    const parts = [info?.vendor, info?.architecture, info?.device]
      .map(part => part?.trim())
      .filter((part): part is string => Boolean(part));
    return parts.join(' ') || 'Unknown GPU';
  }
}
