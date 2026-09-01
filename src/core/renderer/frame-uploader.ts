import { createLogger } from '../../utils/logger';

const frameUploaderLogger = createLogger('frame-uploader');

type FrameUploadMode = 'native' | 'external' | 'canvas' | 'bitmap';

interface ExternalTexturePipelineResources {
  pipeline: GPURenderPipeline;
  bindGroupLayout: GPUBindGroupLayout;
}

interface ExternalTextureResources {
  copy?: ExternalTexturePipelineResources;
  clampHighlights?: ExternalTexturePipelineResources;
  sampler: GPUSampler;
}

const externalResourcesByDevice = new WeakMap<GPUDevice, ExternalTextureResources>();

const externalTextureWGSL = `
struct VertexOutput {
  @builtin(position) position: vec4f,
  @location(0) uv: vec2f,
}

@vertex
fn vertexMain(@builtin(vertex_index) vertexIndex: u32) -> VertexOutput {
  let positions = array(vec2f(-1.0, -1.0), vec2f(3.0, -1.0), vec2f(-1.0, 3.0));
  let uvs = array(vec2f(0.0, 1.0), vec2f(2.0, 1.0), vec2f(0.0, -1.0));
  var output: VertexOutput;
  output.position = vec4f(positions[vertexIndex], 0.0, 1.0);
  output.uv = uvs[vertexIndex];
  return output;
}

@group(0) @binding(0) var sourceSampler: sampler;
@group(0) @binding(1) var sourceTexture: texture_external;

@fragment
fn fragmentMain(input: VertexOutput) -> @location(0) vec4f {
  return textureSampleBaseClampToEdge(sourceTexture, sourceSampler, input.uv);
}
`;

const externalClampHighlightsWGSL = `
struct VertexOutput {
  @builtin(position) position: vec4f,
}

struct SourceInfo {
  size: vec2u,
  padding: vec2u,
}

@vertex
fn vertexMain(@builtin(vertex_index) vertexIndex: u32) -> VertexOutput {
  let positions = array(vec2f(-1.0, -1.0), vec2f(3.0, -1.0), vec2f(-1.0, 3.0));
  var output: VertexOutput;
  output.position = vec4f(positions[vertexIndex], 0.0, 1.0);
  return output;
}

@group(0) @binding(0) var sourceSampler: sampler;
@group(0) @binding(1) var sourceTexture: texture_external;
@group(0) @binding(2) var<uniform> sourceInfo: SourceInfo;

fn quantizeF16(value: f32) -> f32 {
  return unpack2x16float(pack2x16float(vec2f(value, 0.0))).x;
}

fn quantizeF16Color(value: vec4f) -> vec4f {
  // The copy baseline lands in rgba16float before ClampHighlights. External sampling
  // produces f32, so reproduce that storage boundary explicitly before any math.
  let rg = unpack2x16float(pack2x16float(value.rg));
  let ba = unpack2x16float(pack2x16float(value.ba));
  return vec4f(rg, ba);
}

fn loadExternal(coord: vec2i) -> vec4f {
  let size = vec2i(sourceInfo.size);
  if (coord.x < 0 || coord.y < 0 || coord.x >= size.x || coord.y >= size.y) {
    return vec4f(0.0);
  }
  // Sample exact decoded pixel centers. Filtering at arbitrary UVs would make this
  // path differ from copyExternalImageToTexture before the effect even runs.
  let uv = (vec2f(coord) + vec2f(0.5)) / vec2f(sourceInfo.size);
  return quantizeF16Color(textureSampleBaseClampToEdge(sourceTexture, sourceSampler, uv));
}

fn getLuma(color: vec4f) -> f32 {
  return dot(color, vec4f(0.299, 0.587, 0.114, 0.0));
}

@fragment
fn fragmentMain(input: VertexOutput) -> @location(0) vec4f {
  let pixel = vec2i(input.position.xy);
  var verticalMax = 0.0;
  for (var y = -2; y <= 2; y += 1) {
    var horizontalMax = 0.0;
    for (var x = -2; x <= 2; x += 1) {
      horizontalMax = max(horizontalMax, getLuma(loadExternal(pixel + vec2i(x, y))));
    }
    verticalMax = max(verticalMax, quantizeF16(horizontalMax));
  }
  verticalMax = quantizeF16(verticalMax);

  let color = loadExternal(pixel);
  let luma = getLuma(color);
  let difference = luma - min(luma, verticalMax);
  return color - vec4f(difference, difference, difference, 0.0);
}
`;

function getExternalTextureResources(device: GPUDevice): ExternalTextureResources {
  const cached = externalResourcesByDevice.get(device);
  if (cached) {
    return cached;
  }
  const resources = {
    sampler: device.createSampler({
      addressModeU: 'clamp-to-edge',
      addressModeV: 'clamp-to-edge',
      magFilter: 'linear',
      minFilter: 'linear',
    }),
  };
  externalResourcesByDevice.set(device, resources);
  return resources;
}

function getExternalTexturePipelineResources(
  device: GPUDevice,
  clampHighlights: boolean,
): ExternalTexturePipelineResources {
  const resources = getExternalTextureResources(device);
  const cached = clampHighlights ? resources.clampHighlights : resources.copy;
  if (cached) {
    return cached;
  }

  // Pipeline creation is synchronous here, so compile only the path the current
  // effect chain actually uses. Eagerly compiling both variants delays first frame.
  const label = clampHighlights
    ? 'frame uploader external ClampHighlights'
    : 'frame uploader external texture';
  const shader = device.createShaderModule({
    label: `${label} shader`,
    code: clampHighlights ? externalClampHighlightsWGSL : externalTextureWGSL,
  });
  const entries: GPUBindGroupLayoutEntry[] = [{
    binding: 0,
    visibility: GPUShaderStage.FRAGMENT,
    sampler: { type: 'filtering' },
  }, {
    binding: 1,
    visibility: GPUShaderStage.FRAGMENT,
    externalTexture: {},
  }];
  if (clampHighlights) {
    entries.push({
      binding: 2,
      visibility: GPUShaderStage.FRAGMENT,
      buffer: { type: 'uniform' },
    });
  }
  const bindGroupLayout = device.createBindGroupLayout({
    label: `${label} layout`,
    entries,
  });
  const pipelineResources = {
    bindGroupLayout,
    pipeline: device.createRenderPipeline({
      label: `${label} pipeline`,
      layout: device.createPipelineLayout({ bindGroupLayouts: [bindGroupLayout] }),
      vertex: { module: shader, entryPoint: 'vertexMain' },
      fragment: {
        module: shader,
        entryPoint: 'fragmentMain',
        targets: [{ format: 'rgba16float' }],
      },
      primitive: { topology: 'triangle-list' },
    }),
  };
  if (clampHighlights) {
    resources.clampHighlights = pipelineResources;
  } else {
    resources.copy = pipelineResources;
  }
  return pipelineResources;
}

export class VideoFrameUploader {
  private useImageBitmapFallback = false;
  private externalTextureEnabled = false;
  private externalClampHighlightsEnabled = false;
  private mode: FrameUploadMode = 'native';
  private fallbackCanvas: OffscreenCanvas | HTMLCanvasElement | null = null;
  private fallbackContext: OffscreenCanvasRenderingContext2D | CanvasRenderingContext2D | null = null;
  private externalTargetTexture: GPUTexture | null = null;
  private externalPassDescriptor: GPURenderPassDescriptor | null = null;
  private externalSourceInfoBuffer: GPUBuffer | null = null;
  private externalSourceInfoDevice: GPUDevice | null = null;
  private readonly externalSourceInfoData = new Uint32Array(4);
  private readonly logger = frameUploaderLogger;

  /**
   * Execute the same external-texture upload used by playback against a tiny
   * render target. Some implementations expose importExternalTexture() but
   * only report the real limitation when the external binding is validated or
   * submitted, so checking the method alone is not sufficient.
   */
  public static async probeExternalTexture(
    device: GPUDevice,
    video: HTMLVideoElement,
  ): Promise<boolean> {
    if (typeof device.importExternalTexture !== 'function') {
      return false;
    }

    const uploader = new VideoFrameUploader();
    let targetTexture: GPUTexture | undefined;
    let errorScopePushed = false;
    try {
      targetTexture = device.createTexture({
        label: 'frame uploader external texture probe target',
        size: [1, 1, 1],
        format: 'rgba16float',
        usage:
          GPUTextureUsage.TEXTURE_BINDING
          | GPUTextureUsage.COPY_DST
          | GPUTextureUsage.RENDER_ATTACHMENT,
      });

      device.pushErrorScope('validation');
      errorScopePushed = true;
      uploader.setExternalTextureEnabled(true);
      const commandEncoder = device.createCommandEncoder();
      await uploader.copyFrame(device, video, targetTexture, commandEncoder);
      device.queue.submit([commandEncoder.finish()]);
      await device.queue.onSubmittedWorkDone();

      const validationError = await device.popErrorScope();
      errorScopePushed = false;
      if (validationError) {
        frameUploaderLogger.debug('External texture probe failed validation.', validationError);
        return false;
      }
      return true;
    } catch (error) {
      frameUploaderLogger.debug('External texture probe failed.', error);
      if (errorScopePushed) {
        try {
          await device.popErrorScope();
        } catch {
          // Preserve the original probe failure.
        }
      }
      return false;
    } finally {
      uploader.dispose();
      targetTexture?.destroy();
    }
  }

  public setFallbackEnabled(enabled: boolean): void {
    this.useImageBitmapFallback = enabled;
    this.refreshMode();
    if (!enabled) {
      this.disposeFallbackResources();
    }
  }

  public setExternalTextureEnabled(enabled: boolean): void {
    this.externalTextureEnabled = enabled;
    this.refreshMode();
  }

  public setExternalClampHighlightsEnabled(enabled: boolean): void {
    this.externalClampHighlightsEnabled = enabled;
  }

  public isFallbackEnabled(): boolean {
    return this.mode === 'canvas' || this.mode === 'bitmap';
  }

  public sync(video: HTMLVideoElement): void {
    if (this.mode === 'native' || this.mode === 'external') {
      this.disposeFallbackResources();
      return;
    }

    if (this.mode === 'bitmap') {
      return;
    }

    if (!this.fallbackCanvas) {
      this.fallbackCanvas = typeof OffscreenCanvas !== 'undefined'
        ? new OffscreenCanvas(video.videoWidth, video.videoHeight)
        : document.createElement('canvas');
    }

    if (!this.fallbackContext) {
      this.fallbackContext = this.fallbackCanvas.getContext('2d', { alpha: false });
    }

    if (!this.fallbackContext) {
      this.mode = 'bitmap';
      this.logger.warn('Failed to create fallback 2D canvas context, using ImageBitmap mode.');
      return;
    }

    if (this.fallbackCanvas.width !== video.videoWidth) {
      this.fallbackCanvas.width = video.videoWidth;
    }
    if (this.fallbackCanvas.height !== video.videoHeight) {
      this.fallbackCanvas.height = video.videoHeight;
    }
  }

  public copyFrame(
    device: GPUDevice,
    video: HTMLVideoElement,
    targetTexture: GPUTexture,
    encoder?: GPUCommandEncoder,
  ): void | Promise<void> {
    if (this.mode === 'external') {
      if (!encoder) {
        throw new Error('External texture upload requires a command encoder.');
      }
      this.encodeExternalTexture(device, encoder, video, targetTexture);
      return;
    }

    if (this.mode === 'native') {
      device.queue.copyExternalImageToTexture(
        { source: video },
        { texture: targetTexture },
        [video.videoWidth, video.videoHeight],
      );
      return;
    }

    this.sync(video);
    if (this.mode === 'canvas' && this.fallbackCanvas && this.fallbackContext) {
      try {
        this.fallbackContext.drawImage(video, 0, 0, video.videoWidth, video.videoHeight);
        device.queue.copyExternalImageToTexture(
          { source: this.fallbackCanvas },
          { texture: targetTexture },
          [video.videoWidth, video.videoHeight],
        );
        return;
      } catch (error) {
        this.mode = 'bitmap';
        this.logger.warn('Canvas fallback upload failed, using ImageBitmap mode.', error);
      }
    }

    return this.copyViaBitmap(device, video, targetTexture);
  }

  public dispose(): void {
    this.disposeFallbackResources();
    this.externalTargetTexture = null;
    this.externalPassDescriptor = null;
    this.externalSourceInfoBuffer?.destroy();
    this.externalSourceInfoBuffer = null;
    this.externalSourceInfoDevice = null;
    this.refreshMode();
  }

  public getMode(): FrameUploadMode {
    return this.mode;
  }

  private encodeExternalTexture(
    device: GPUDevice,
    encoder: GPUCommandEncoder,
    video: HTMLVideoElement,
    targetTexture: GPUTexture,
  ): void {
    const resources = getExternalTextureResources(device);
    const pipelineResources = getExternalTexturePipelineResources(
      device,
      this.externalClampHighlightsEnabled,
    );
    if (this.externalTargetTexture !== targetTexture || !this.externalPassDescriptor) {
      // The target view is stable for the lifetime of the upload texture. Rebuild the
      // descriptor after resize/reallocation, but not for every video frame.
      this.externalTargetTexture = targetTexture;
      this.externalPassDescriptor = {
        label: 'frame uploader external texture pass',
        colorAttachments: [{
          view: targetTexture.createView(),
          clearValue: { r: 0, g: 0, b: 0, a: 1 },
          loadOp: 'clear',
          storeOp: 'store',
        }],
      };
    }
    // GPUExternalTexture and any bind group referencing it are frame-scoped. Caching
    // either across VideoFrame updates can display stale or invalid decoder surfaces.
    const externalTexture = device.importExternalTexture({ source: video });
    const bindGroup = device.createBindGroup({
      label: 'frame uploader external texture bind group',
      layout: pipelineResources.bindGroupLayout,
      entries: [
        { binding: 0, resource: resources.sampler },
        { binding: 1, resource: externalTexture },
        ...(this.externalClampHighlightsEnabled ? [{
          binding: 2,
          resource: { buffer: this.getExternalSourceInfoBuffer(device, video) },
        }] : []),
      ],
    });
    const pass = encoder.beginRenderPass(this.externalPassDescriptor);
    pass.setPipeline(pipelineResources.pipeline);
    pass.setBindGroup(0, bindGroup);
    pass.draw(3);
    pass.end();
  }

  private getExternalSourceInfoBuffer(device: GPUDevice, video: HTMLVideoElement): GPUBuffer {
    if (!this.externalSourceInfoBuffer || this.externalSourceInfoDevice !== device) {
      this.externalSourceInfoBuffer?.destroy();
      this.externalSourceInfoBuffer = device.createBuffer({
        label: 'frame uploader external source info',
        size: 16,
        usage: GPUBufferUsage.UNIFORM | GPUBufferUsage.COPY_DST,
      });
      this.externalSourceInfoDevice = device;
    }
    this.externalSourceInfoData[0] = video.videoWidth;
    this.externalSourceInfoData[1] = video.videoHeight;
    // Reuse the typed array; allocating one per frame showed up in long video sessions.
    device.queue.writeBuffer(
      this.externalSourceInfoBuffer,
      0,
      this.externalSourceInfoData,
    );
    return this.externalSourceInfoBuffer;
  }

  private async copyViaBitmap(
    device: GPUDevice,
    video: HTMLVideoElement,
    targetTexture: GPUTexture,
  ): Promise<void> {
    const bitmap = await createImageBitmap(video);
    try {
      device.queue.copyExternalImageToTexture(
        { source: bitmap },
        { texture: targetTexture },
        [video.videoWidth, video.videoHeight],
      );
    } finally {
      bitmap.close();
    }
  }

  private refreshMode(): void {
    this.mode = this.externalTextureEnabled
      ? 'external'
      : this.useImageBitmapFallback
        ? 'canvas'
        : 'native';
  }

  private disposeFallbackResources(): void {
    this.fallbackCanvas = null;
    this.fallbackContext = null;
  }
}
