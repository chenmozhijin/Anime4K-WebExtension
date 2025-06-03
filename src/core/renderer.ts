import { Anime4KPipeline } from 'anime4k-webgpu';

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
 * 渲染器选项接口
 * 定义渲染器初始化所需的参数
 */
export interface RendererOptions {
  video: HTMLVideoElement;  // 输入视频元素
  canvas: HTMLCanvasElement; // 输出画布元素
  pipelineBuilder: (device: GPUDevice, inputTexture: GPUTexture) =>
  [...Anime4KPipeline[], Anime4KPipeline]; // 流水线构建函数
  onResolutionChanged?: () => void; // 分辨率变化回调
  onError?: (error: Error) => void; // 错误回调
}

/**
 * 渲染器实例接口
 * 定义渲染器实例的方法
 */
export interface RendererInstance {
  destroy: () => void; // 销毁渲染器的方法
}

/**
 * 渲染函数
 * 初始化WebGPU渲染管道并开始渲染循环
 * @param options 渲染器选项
 * @returns 渲染器实例
 */
export async function render(options: RendererOptions): Promise<RendererInstance> {
  const { video, canvas, pipelineBuilder, onResolutionChanged, onError } = options;
  let destroyed = false;
  
  // 确保视频元数据已加载
  if (video.readyState < video.HAVE_FUTURE_DATA) {
    await new Promise((resolve) => {
      video.onloadeddata = resolve;
    });
  }
  
  // 获取视频原始尺寸
  const WIDTH = video.videoWidth;
  const HEIGHT = video.videoHeight;

  // 请求WebGPU适配器
  // 在Windows上忽略powerPreference选项（crbug.com/369219127）
  const isWindows = navigator.userAgent.includes('Windows');
  const adapterOptions = isWindows ? {} : { powerPreference: 'high-performance' as GPUPowerPreference };
  const adapter = await navigator.gpu.requestAdapter(adapterOptions);
  if (!adapter) {
    throw new Error('WebGPU not supported');
  }
  
  // 请求GPU设备
  const device = await adapter.requestDevice();
  
  // 配置画布上下文
  const context = canvas.getContext('webgpu') ?? (() => { 
  throw new Error('WebGPU context not available') 
  })();
  const presentationFormat = navigator.gpu.getPreferredCanvasFormat();
  context.configure({
    device,
    format: presentationFormat,
    alphaMode: 'premultiplied', // 使用预乘alpha混合
  });

  // 创建视频帧纹理
  const videoFrameTexture = device.createTexture({
    size: [WIDTH, HEIGHT, 1],
    format: 'rgba16float', // 16位浮点格式提供更宽的色域
    usage: GPUTextureUsage.TEXTURE_BINDING |
      GPUTextureUsage.COPY_DST |
      GPUTextureUsage.RENDER_ATTACHMENT,
  });
  console.log(`[Anime4KWebExt] 视频帧纹理已创建, 纹理大小: ${WIDTH}x${HEIGHT} | ${videoFrameTexture.width}x${videoFrameTexture.height}`);



  // 构建Anime4K处理流水线
  const pipelines = pipelineBuilder(device, videoFrameTexture);
  let animationFrameId: number | null = null;

  /**
   * 更新视频帧纹理
   * 将当前视频帧复制到GPU纹理
   */
  function updateVideoFrameTexture() {
    
    // 检查分辨率是否变化
    if (video.videoWidth !== videoFrameTexture.width || video.videoHeight !== videoFrameTexture.height) {
      console.log(`[Anime4KWebExt] 检测到视频分辨率变化: ${videoFrameTexture.width}x${videoFrameTexture.height} -> ${video.videoWidth}x${video.videoHeight}`);
      
      // 销毁当前实例
      destroy();
      
      // 通知外层需要重新初始化渲染器
      if (onResolutionChanged) {
        onResolutionChanged();
      }
      return;
    }

    device.queue.copyExternalImageToTexture(
      { source: video },
      { texture: videoFrameTexture },
      [WIDTH, HEIGHT],
    );
    return;
  }

  // 创建渲染绑定组布局
  const renderBindGroupLayout = device.createBindGroupLayout({
    entries: [
      {
        binding: 1,
        visibility: GPUShaderStage.FRAGMENT,
        sampler: {}, // 采样器绑定
      },
      {
        binding: 2,
        visibility: GPUShaderStage.FRAGMENT,
        texture: {}, // 纹理绑定
      },
    ],
  });

  // 创建渲染流水线布局
  const renderPipelineLayout = device.createPipelineLayout({
    bindGroupLayouts: [renderBindGroupLayout],
  });

  // 创建渲染流水线
  const renderPipeline = device.createRenderPipeline({
    layout: renderPipelineLayout,
    vertex: {
      module: device.createShaderModule({
        code: fullscreenTexturedQuadWGSL, // 使用顶点着色器
      }),
      entryPoint: 'vert_main',
    },
    fragment: {
      module: device.createShaderModule({
        code: sampleExternalTextureWGSL, // 使用片段着色器
      }),
      entryPoint: 'main',
      targets: [
        {
          format: presentationFormat,
        },
      ],
    },
    primitive: {
      topology: 'triangle-list', // 三角形列表图元
    },
  });

  // 创建纹理采样器
  const sampler = device.createSampler({
    magFilter: 'linear', // 放大时使用线性过滤
    minFilter: 'linear', // 缩小时使用线性过滤
  });

  // 创建渲染绑定组
  const renderBindGroup = device.createBindGroup({
    layout: renderBindGroupLayout,
    entries: [
      {
        binding: 1,
        resource: sampler, // 采样器资源
      },
      {
        binding: 2,
        resource: pipelines.at(-1)!.getOutputTexture().createView(), // 最终输出纹理视图
      },
    ],
  });

  /**
   * 渲染帧函数
   * 每帧执行的主要渲染逻辑
   */
  function frame() {
    if (destroyed) return;
    
    try {
      // 仅在视频播放时处理帧
      if (!video.paused) {
        // 更新纹理
        updateVideoFrameTexture();
        
        // 创建命令编码器
        const commandEncoder = device.createCommandEncoder();
        
        // 执行所有Anime4K处理流水线
        pipelines.forEach((pipeline) => {
          pipeline.pass(commandEncoder);
        });
        
        // 开始渲染通道
        const passEncoder = commandEncoder.beginRenderPass({
          colorAttachments: [
            {
              view: context.getCurrentTexture().createView(),
              clearValue: { r: 0.0, g: 0.0, b: 0.0, a: 1.0 },
              loadOp: 'clear',
              storeOp: 'store',
            },
          ],
        });
        
        // 设置渲染流水线和绑定组
        passEncoder.setPipeline(renderPipeline);
        passEncoder.setBindGroup(0, renderBindGroup);
        
        // 绘制
        passEncoder.draw(6);
        
        // 结束渲染通道并提交命令
        passEncoder.end();
        device.queue.submit([commandEncoder.finish()]);
      }
    } catch (error) {
      console.error('[Anime4KWebExt] 渲染帧处理失败: ', error);
      // 通知上层错误
      if (onError) {
        onError(error instanceof Error ? error : new Error(String(error)));
      }
      // 避免频繁错误导致控制台溢出
      if (!destroyed) {
        destroy();
      }
      return;
    }
    
    // 请求下一帧（无论是否暂停都需要继续监听）
    if (!destroyed) {
      animationFrameId = video.requestVideoFrameCallback(frame);
    }
  }
  
  

  function destroy() {
    try {
      if (destroyed) {
        console.log('[Anime4KWebExt] 渲染器已销毁，跳过重复销毁');
        return;
      }
      destroyed = true;

      // 取消动画帧回调
      if (animationFrameId) {
        video.cancelVideoFrameCallback(animationFrameId);
      }
      
      // 销毁所有处理流水线
      pipelines.forEach(pipeline => {
        if (typeof (pipeline as any).destroy === 'function') {
          (pipeline as any).destroy();
        }
      });
      
      // 销毁纹理和GPU设备
      videoFrameTexture.destroy();
      device.destroy();
      // 清理引用
      animationFrameId = null;
      console.log('[Anime4KWebExt] 渲染器已销毁');
    } catch (error) {
      console.error('[Anime4KWebExt] 销毁渲染器时发生错误: ', error);
    }
  }
    // 启动渲染循环
  animationFrameId = video.requestVideoFrameCallback(frame);

  // 返回渲染器实例
  return {destroy};
}
