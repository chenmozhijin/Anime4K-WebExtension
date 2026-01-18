import type { Anime4KPipeline } from 'anime4k-webgpu';
import type { Dimensions, EnhancementEffect } from '../types';
import { RendererInitializationError, RendererRuntimeError } from './errors';

/**
 * 全屏纹理四边形顶点着色器
 * 定义顶点位置和UV坐标，用于渲染全屏纹理
 */
const fullscreenTexturedQuadWGSL = `
struct VertexOutput {
  @builtin(position) Position : vec4<f32>,
  @location(0) fragUV : vec2<f32>,
}

@vertex
fn vert_main(@builtin(vertex_index) VertexIndex : u32) -> VertexOutput {
  const pos = array(
    vec2( 1.0,  1.0),  // 右上
    vec2( 1.0, -1.0),  // 右下
    vec2(-1.0, -1.0),  // 左下
    vec2( 1.0,  1.0),  // 右上 (重复)
    vec2(-1.0, -1.0),  // 左下 (重复)
    vec2(-1.0,  1.0),  // 左上
  );

  const uv = array(
    vec2(1.0, 0.0),  // 右上UV
    vec2(1.0, 1.0),  // 右下UV
    vec2(0.0, 1.0),  // 左下UV
    vec2(1.0, 0.0),  // 右上UV (重复)
    vec2(0.0, 1.0),  // 左下UV (重复)
    vec2(0.0, 0.0),  // 左上UV
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
  /** 渲染的目标分辨率 */
  targetDimensions: Dimensions;
  /** 发生运行时错误时的回调函数 */
  onError?: (error: Error) => void;
  /** 成功渲染第一帧时的回调函数 */
  onFirstFrameRendered?: () => void;
  /** 初始化进度回调函数 */
  onProgress?: (stage: string, current?: number, total?: number) => void;
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
  private targetDimensions: Dimensions;
  private onError?: (error: Error) => void;
  private onFirstFrameRendered?: () => void;
  private onProgress?: (stage: string, current?: number, total?: number) => void;

  // --- 状态标志 ---
  private destroyed = false;
  private animationFrameId: number | null = null;
  /** 是否使用 ImageBitmap 作为回退方案来复制视频帧 */
  private useImageBitmapFallback = false;
  /** 在单次渲染循环中是否已尝试过自动修复 */
  private fixAttempted = false;
  private lastError: Error | null = null;
  /** 是否正在恢复设备（设备丢失后的自动恢复） */
  private isRecovering = false;

  // --- WebGPU 对象 ---
  private device!: GPUDevice;
  private context!: GPUCanvasContext;
  private presentationFormat!: GPUTextureFormat;
  /** 用于从视频帧复制图像数据的中间纹理 */
  private videoFrameTexture!: GPUTexture;
  /** 效果处理管线链 */
  private pipelines: Anime4KPipeline[] = [];

  // --- 最终渲染阶段的对象 ---
  private renderBindGroupLayout!: GPUBindGroupLayout;
  private renderPipeline!: GPURenderPipeline;
  private sampler!: GPUSampler;
  private renderBindGroup!: GPUBindGroup;

  // --- 静态属性，用于确保只检测一次 ---
  private static hasCheckedWebGPUFeatures = false;
  private static webgpuFeatureCheckPromise: Promise<boolean> | null = null;
  /** 缓存的 anime4k-webgpu 模块（避免重复动态导入） */
  private static cachedAnime4KModule: typeof import('anime4k-webgpu') | null = null;

  /**
   * Renderer 的构造函数是私有的，请使用 `Renderer.create()` 静态方法来创建实例。
   * @param options - 初始化渲染器所需的配置
   */
  private constructor(options: RendererOptions) {
    this.video = options.video;
    this.canvas = options.canvas;
    this.effects = options.effects;
    this.targetDimensions = options.targetDimensions;
    this.onError = options.onError;
    this.onFirstFrameRendered = options.onFirstFrameRendered;
    this.onProgress = options.onProgress;
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
      if (this.video.readyState < this.video.HAVE_FUTURE_DATA) {
        await new Promise((resolve) => {
          this.video.onloadeddata = resolve;
        });
      }

      // 请求 GPU 适配器，并根据平台设置能效偏好
      this.onProgress?.(chrome.i18n.getMessage('initGpu') || '⏳ Initializing GPU...');
      const adapterOptions: GPURequestAdapterOptions = {};
      // 在 Windows 上设置 powerPreference 会产生警告，因此仅在非 Windows 平台使用
      if (!navigator.platform.startsWith('Win')) {
        adapterOptions.powerPreference = 'high-performance';
      }
      const adapter = await navigator.gpu.requestAdapter(adapterOptions);
      if (!adapter) {
        throw new RendererInitializationError('WebGPU not supported: No adapter found.');
      }

      // 请求 GPU 设备并配置 Canvas 上下文
      // 根据适配器支持的限制请求更高的 maxBufferSize，以支持高分辨率视频处理
      const adapterLimits = adapter.limits;
      this.device = await adapter.requestDevice({
        requiredLimits: {
          maxBufferSize: adapterLimits.maxBufferSize,
          maxStorageBufferBindingSize: adapterLimits.maxStorageBufferBindingSize,
        },
      });

      // 监听设备丢失事件并尝试自动恢复
      this.device.lost.then((info) => {
        // 如果渲染器已销毁，不需要处理
        if (this.destroyed) return;

        console.warn(`[Anime4KWebExt] GPU device lost: ${info.reason} - ${info.message}`);

        // 尝试自动恢复（仅在非主动销毁的情况下）
        if (info.reason !== 'destroyed' && !this.isRecovering) {
          console.log('[Anime4KWebExt] Attempting to recover from device loss...');
          this.recoverFromDeviceLoss();
        }
      });

      // 检查是否需要使用 ImageBitmap 回退方案
      const supportsVideoTexture = await Renderer.detectWebGPUFeatures();
      this.useImageBitmapFallback = !supportsVideoTexture;
      if (this.useImageBitmapFallback) {
        console.log('[Anime4KWebExt] Renderer: Using ImageBitmap fallback for copying video frames.');
      }

      this.context = this.canvas.getContext('webgpu')!;
      if (!this.context) {
        throw new RendererInitializationError('Failed to get WebGPU context from canvas.');
      }
      this.presentationFormat = navigator.gpu.getPreferredCanvasFormat();
      this.context.configure({
        device: this.device,
        format: this.presentationFormat,
        alphaMode: 'premultiplied',
      });

      // 创建初始资源
      this.createResources();
      await this.buildPipelines();
      await this.createRenderPipeline();
      this.createRenderBindGroup();

      // 启动渲染循环，尝试渲染第一帧并启动持续渲染
      this.renderFirstFrameAndStartLoop();
    } catch (error) {
      if (error instanceof RendererInitializationError) {
        throw error;
      }
      throw new RendererInitializationError('An unexpected error occurred during renderer initialization.', { cause: error as Error });
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

    // 安全销毁旧管道
    for (const p of this.pipelines) {
      try {
        (p as any).destroy?.();
      } catch {
        // 忽略单个管道销毁错误
      }
    }

    const pipelines: Anime4KPipeline[] = [];
    let currentTexture = this.videoFrameTexture;
    let curWidth = this.video.videoWidth;
    let curHeight = this.video.videoHeight;

    // 使用缓存的模块，避免重复动态导入
    if (!Renderer.cachedAnime4KModule) {
      Renderer.cachedAnime4KModule = await import('anime4k-webgpu');
    }
    const anime4kModule = Renderer.cachedAnime4KModule;

    // 如果需要，获取 Downscale 类
    const needsDownscaling = this.effects.some((effect, i) => {
      const remainingFactor = this.effects.slice(i + 1).reduce((acc, val) => acc * (val.upscaleFactor ?? 1), 1);
      return (effect.upscaleFactor ?? 1) > 1 && remainingFactor > 1;
    });
    const DownscaleClass = needsDownscaling ? anime4kModule.Downscale : null;

    const upscaleFactors = this.effects.map(e => e.upscaleFactor ?? 1);
    const remainingUpscaleFactors = upscaleFactors.map((_, i) =>
      upscaleFactors.slice(i + 1).reduce((acc, val) => acc * val, 1)
    );

    for (let i = 0; i < this.effects.length; i++) {
      // 报告预热进度
      const loadingMsg = chrome.i18n.getMessage('loadingEffect', [String(i + 1), String(this.effects.length)])
        || `⏳ Loading effect ${i + 1}/${this.effects.length}...`;
      this.onProgress?.(loadingMsg, i + 1, this.effects.length);

      // 让出主线程，避免界面冻结
      await new Promise(resolve => setTimeout(resolve, 0));

      const effect = this.effects[i];
      // 从缓存的模块获取效果类
      const EffectClass = (anime4kModule as Record<string, any>)[effect.className];

      if (EffectClass) {
        const pipeline = new EffectClass({
          device: this.device,
          inputTexture: currentTexture,
          nativeDimensions: { width: curWidth, height: curHeight },
          targetDimensions: this.targetDimensions,
        });
        pipelines.push(pipeline);

        // === 逐个效果预热：编译着色器并运行一帧 ===
        try {
          const commandEncoder = this.device.createCommandEncoder();
          pipeline.pass(commandEncoder);
          this.device.queue.submit([commandEncoder.finish()]);
          await this.device.queue.onSubmittedWorkDone();
        } catch (e) {
          console.warn(`[Anime4KWebExt] Failed to warmup effect ${effect.className}:`, e);
        }

        currentTexture = pipeline.getOutputTexture();

        if (effect.upscaleFactor) {
          curWidth *= effect.upscaleFactor;
          curHeight *= effect.upscaleFactor;

          const remainingFactor = remainingUpscaleFactors[i];
          if (DownscaleClass && remainingFactor > 1) {
            const idealIntermediateWidth = this.targetDimensions.width / remainingFactor;
            const idealIntermediateHeight = this.targetDimensions.height / remainingFactor;

            if (curWidth > idealIntermediateWidth * 1.1) {
              // 再次让出主线程
              await new Promise(resolve => setTimeout(resolve, 0));

              const intermediateDownscale = new DownscaleClass({
                device: this.device,
                inputTexture: currentTexture,
                targetDimensions: {
                  width: Math.ceil(idealIntermediateWidth),
                  height: Math.ceil(idealIntermediateHeight),
                },
              });
              pipelines.push(intermediateDownscale);

              // 预热 Downscale 效果
              try {
                const commandEncoder = this.device.createCommandEncoder();
                intermediateDownscale.pass(commandEncoder);
                this.device.queue.submit([commandEncoder.finish()]);
                await this.device.queue.onSubmittedWorkDone();
              } catch (e) {
                console.warn('[Anime4KWebExt] Failed to warmup Downscale:', e);
              }

              currentTexture = intermediateDownscale.getOutputTexture();
              curWidth = Math.ceil(idealIntermediateWidth);
              curHeight = Math.ceil(idealIntermediateHeight);
            }
          }
        }
      } else {
        console.warn(`[Anime4KWebExt] Effect class "${effect.className}" not found in anime4k-webgpu module.`);
      }
    }

    if (pipelines.length === 0) {
      // 如果没有应用任何效果，则创建一个虚拟管道
      pipelines.push({
        pass: () => { },
        getOutputTexture: () => this.videoFrameTexture,
        updateParam: () => { },
      } as unknown as Anime4KPipeline);
    }
    this.pipelines = pipelines;

    // 通知预热完成
    this.onProgress?.(null as unknown as string);

    console.log(`[Anime4KWebExt] Built ${pipelines.length} pipelines with warmup complete.`);
  }

  /**
   * 检测当前环境的 WebGPU 实现是否支持直接从 VideoFrame 复制纹理。
   */
  public static async detectWebGPUFeatures(): Promise<boolean> {
    // 如果已经检测过，直接返回结果
    if (Renderer.hasCheckedWebGPUFeatures) {
      return Renderer.webgpuFeatureCheckPromise ?? false;
    }

    // 如果正在检测中，等待检测完成
    if (Renderer.webgpuFeatureCheckPromise) {
      return Renderer.webgpuFeatureCheckPromise;
    }

    // 开始检测
    Renderer.webgpuFeatureCheckPromise = (async () => {
      try {
        // 在 initialize() 中已经检测了基本的 WebGPU 支持，这里只需要检测 VideoFrame 支持

        const adapter = await navigator.gpu.requestAdapter();
        const device = await adapter?.requestDevice();
        if (!device) {
          throw new Error('Failed to get GPU device.');
        }

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
        const frame = new VideoFrame(offscreenCanvas, { timestamp: 0 });
        const texture = device.createTexture({
          size: [1, 1],
          format: 'rgba8unorm',
          usage: GPUTextureUsage.COPY_DST | GPUTextureUsage.RENDER_ATTACHMENT,
        });

        // 核心测试：此操作如果不支持会抛出异常
        device.queue.copyExternalImageToTexture({ source: frame }, { texture }, [1, 1]);

        // 清理资源
        frame.close();
        texture.destroy();
        device.destroy();

        // 如果成功，则说明支持
        console.log('[Anime4KWebExt] WebGPU feature detection: VideoFrame as texture source is SUPPORTED.');
        Renderer.hasCheckedWebGPUFeatures = true;
        return true;
      } catch (error) {
        // 任何步骤失败都意味着不支持
        console.log('[Anime4KWebExt] WebGPU feature detection: VideoFrame as texture source is NOT SUPPORTED.', error);
        Renderer.hasCheckedWebGPUFeatures = true;
        return false;
      }
    })();

    return Renderer.webgpuFeatureCheckPromise;
  }

  /**
   * 创建最终的渲染管线，该管线负责将处理完成的纹理绘制到 Canvas 上。
   */
  private async createRenderPipeline(): Promise<void> {
    // 定义绑定组布局，描述着色器所需的资源
    this.renderBindGroupLayout = this.device.createBindGroupLayout({
      entries: [
        { binding: 1, visibility: GPUShaderStage.FRAGMENT, sampler: {} }, // 采样器
        { binding: 2, visibility: GPUShaderStage.FRAGMENT, texture: {} }, // 输入纹理
      ],
    });

    // 异步创建渲染管线以提高性能
    this.renderPipeline = await this.device.createRenderPipelineAsync({
      layout: this.device.createPipelineLayout({ bindGroupLayouts: [this.renderBindGroupLayout] }),
      vertex: {
        module: this.device.createShaderModule({ code: fullscreenTexturedQuadWGSL }),
        entryPoint: 'vert_main',
      },
      fragment: {
        module: this.device.createShaderModule({ code: sampleExternalTextureWGSL }),
        entryPoint: 'main',
        targets: [{ format: this.presentationFormat }],
      },
      primitive: { topology: 'triangle-list' },
    });

    this.sampler = this.device.createSampler({ magFilter: 'linear', minFilter: 'linear' });
  }

  /**
   * 创建渲染绑定组，它将实际的资源（采样器和最终纹理）绑定到渲染管线。
   */
  private createRenderBindGroup(): void {
    this.renderBindGroup = this.device.createBindGroup({
      layout: this.renderBindGroupLayout,
      entries: [
        { binding: 1, resource: this.sampler },
        // 获取效果链中最后一个管线的输出纹理作为最终渲染的输入
        { binding: 2, resource: this.pipelines.at(-1)!.getOutputTexture().createView() },
      ],
    });
  }

  /**
   * 处理单帧渲染的核心逻辑。
   * @returns {boolean} 如果成功渲染了一帧则返回 true，否则返回 false。
   */
  private async processFrame(): Promise<boolean> {
    if (this.destroyed) return false;

    try {
      if (this.video.readyState < this.video.HAVE_CURRENT_DATA) {
        return false; // 视频未准备好，跳过此帧
      }

      // 检查分辨率是否变化
      if (this.video.videoWidth !== this.videoFrameTexture.width || this.video.videoHeight !== this.videoFrameTexture.height) {
        console.log(`[Anime4KWebExt] Resolution changed: ${this.videoFrameTexture.width}x${this.videoFrameTexture.height} -> ${this.video.videoWidth}x${this.video.videoHeight}`);
        this.handleSourceResize();
        return false; // 分辨率已变，跳过此帧的渲染，等待下一帧
      }

      // 将视频帧复制到纹理
      if (this.useImageBitmapFallback) {
        // 使用 ImageBitmap 回退方案（用于兼容 Firefox 等不支持直接从 video 复制的浏览器）
        const bitmap = await createImageBitmap(this.video);
        this.device.queue.copyExternalImageToTexture(
          { source: bitmap },
          { texture: this.videoFrameTexture },
          [this.video.videoWidth, this.video.videoHeight]
        );
        bitmap.close(); // 复制完成后立即关闭，无需缓存
      } else {
        this.device.queue.copyExternalImageToTexture(
          { source: this.video },
          { texture: this.videoFrameTexture },
          [this.video.videoWidth, this.video.videoHeight]
        );
      }



      const commandEncoder = this.device.createCommandEncoder();
      this.pipelines.forEach((pipeline) => pipeline.pass(commandEncoder));
      const passEncoder = commandEncoder.beginRenderPass({
        colorAttachments: [{
          view: this.context.getCurrentTexture().createView(),
          clearValue: { r: 0.0, g: 0.0, b: 0.0, a: 1.0 },
          loadOp: 'clear',
          storeOp: 'store',
        }],
      });
      passEncoder.setPipeline(this.renderPipeline);
      passEncoder.setBindGroup(0, this.renderBindGroup);
      passEncoder.draw(6);
      passEncoder.end();
      this.device.queue.submit([commandEncoder.finish()]);

      return true; // 成功渲染

    } catch (error) {
      console.error('[Anime4KWebExt] Frame processing failed:', error);

      // 检查是否是可恢复的尺寸不匹配错误
      if (error instanceof Error && error.name === 'OperationError' && error.message.includes('out of bounds')) {
        // 这是一个潜在可恢复的错误
        this.lastError = new RendererRuntimeError('Texture copy failed due to size mismatch.', { cause: error, recoverable: true });
        // 仅在第一次尝试时进行修复
        if (!this.fixAttempted) {
          console.warn('[Anime4KWebExt] Caught out-of-bounds error. Attempting to recover by resizing resources...');
          this.handleSourceResize();
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
  private renderFirstFrameAndStartLoop = async (): Promise<void> => {
    if (this.destroyed) return;

    if (await this.processFrame()) {
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
          console.log('[Anime4KWebExt] Retrying first frame render after recovery attempt...');
        } else {
          console.error('[Anime4KWebExt] Unrecoverable error on first frame. Destroying renderer.');
          if (this.onError) this.onError(error);
          this.destroy();
          return; // 停止
        }
      } else {
        // 如果没有错误，说明是良性跳帧（如分辨率调整），直接重试
        console.log('[Anime4KWebExt] First frame skipped (e.g. resolution change), retrying...');
      }

      if (!this.destroyed) {
        this.animationFrameId = this.video.requestVideoFrameCallback(this.renderFirstFrameAndStartLoop);
      }
    }
  };

  /**
   * 常规渲染循环，处理第一帧之后的所有帧。
   */
  private renderLoop = async (): Promise<void> => {
    if (this.destroyed) return;

    if (await this.processFrame()) {
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
          console.log('[Anime4KWebExt] Retrying frame render after recovery attempt...');
        } else {
          console.error(`[Anime4KWebExt] Unrecoverable error in render loop. Destroying renderer. Error: ${error.message}`);
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
    console.log('[Anime4KWebExt] Resizing renderer due to video source dimension change...');
    this.createResources();
    await this.buildPipelines();
    this.createRenderBindGroup();
    console.log('[Anime4KWebExt] Renderer resized for source.');
  }

  /**
   * 根据用户设置（效果或目标分辨率）更新渲染器配置
   * @param options 包含新效果和目标尺寸的对象
   */
  public async updateConfiguration(options: { effects: EnhancementEffect[], targetDimensions: Dimensions }): Promise<void> {
    if (this.destroyed) return;

    const { effects, targetDimensions } = options;

    // 使用JSON字符串比较来检测效果数组是否有实质性变化
    const effectsChanged = JSON.stringify(this.effects) !== JSON.stringify(effects);
    const dimensionsChanged = this.targetDimensions.width !== targetDimensions.width || this.targetDimensions.height !== targetDimensions.height;

    if (!effectsChanged && !dimensionsChanged) {
      console.log('[Anime4KWebExt] Configuration unchanged, skipping pipeline rebuild.');
      return;
    }

    if (dimensionsChanged) {
      console.log(`[Anime4KWebExt] Updating target dimensions to ${targetDimensions.width}x${targetDimensions.height}.`);
      this.targetDimensions = targetDimensions;
    }

    if (effectsChanged) {
      console.log('[Anime4KWebExt] Updating effects.');
      this.effects = effects;
    }

    console.log('[Anime4KWebExt] Rebuilding pipeline due to configuration update.');
    await this.buildPipelines();
    this.createRenderBindGroup();
    console.log('[Anime4KWebExt] Renderer configuration updated.');
  }

  /**
   * 更新渲染器使用的视频源。
   * @param newVideo - 新的 HTMLVideoElement
   */
  public async updateVideoSource(newVideo: HTMLVideoElement): Promise<void> {
    console.log('[Anime4KWebExt] Renderer video source updated.');
    if (newVideo.videoWidth !== this.videoFrameTexture.width || newVideo.videoHeight !== this.videoFrameTexture.height) {
      console.log('[Anime4KWebExt] Video dimensions changed on reattach. Updating renderer.');
      await this.handleSourceResize();
    }
    this.video = newVideo;
  }

  /**
   * 从设备丢失中恢复
   * 尝试重新初始化 GPU 资源并恢复渲染
   */
  private async recoverFromDeviceLoss(): Promise<void> {
    if (this.destroyed || this.isRecovering) return;

    this.isRecovering = true;
    console.log('[Anime4KWebExt] Starting device recovery...');

    try {
      // 停止当前渲染循环
      if (this.animationFrameId) {
        this.video.cancelVideoFrameCallback(this.animationFrameId);
        this.animationFrameId = null;
      }

      // 重新请求 GPU 适配器和设备
      const adapter = await navigator.gpu.requestAdapter();
      if (!adapter) {
        throw new Error('Failed to get GPU adapter during recovery');
      }

      const adapterLimits = adapter.limits;
      this.device = await adapter.requestDevice({
        requiredLimits: {
          maxBufferSize: adapterLimits.maxBufferSize,
          maxStorageBufferBindingSize: adapterLimits.maxStorageBufferBindingSize,
        },
      });

      // 设置新设备的丢失监听
      this.device.lost.then((info) => {
        if (this.destroyed) return;
        console.warn(`[Anime4KWebExt] GPU device lost: ${info.reason} - ${info.message}`);
        if (info.reason !== 'destroyed' && !this.isRecovering) {
          this.recoverFromDeviceLoss();
        }
      });

      // 重新配置上下文
      this.context.configure({
        device: this.device,
        format: this.presentationFormat,
        alphaMode: 'premultiplied',
      });

      // 重建资源和管道
      this.createResources();
      await this.buildPipelines();
      await this.createRenderPipeline();
      this.createRenderBindGroup();

      // 重启渲染循环
      this.isRecovering = false;
      this.renderFirstFrameAndStartLoop();

      console.log('[Anime4KWebExt] Device recovery successful!');
    } catch (error) {
      this.isRecovering = false;
      console.error('[Anime4KWebExt] Device recovery failed:', error);
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
      this.pipelines.forEach(pipeline => {
        if (typeof (pipeline as any).destroy === 'function') {
          (pipeline as any).destroy();
        }
      });
      this.videoFrameTexture?.destroy();
      // 解除画布与GPU设备的关联，这对于后续重新初始化至关重要
      this.context?.unconfigure();
      // 主动销毁设备，这将触发 device.lost Promise
      this.device?.destroy();
      console.log('[Anime4KWebExt] Renderer destroyed.');
    } catch (error) {
      console.error('[Anime4KWebExt] Error during renderer destruction:', error);
    }
  }
}
