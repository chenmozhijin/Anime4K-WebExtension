import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { VideoFrameUploader } from '../../src/core/renderer/frame-uploader';
import { createWebGpuMock } from '../support/webgpu';

function createVideo(width: number, height: number): HTMLVideoElement {
  const video = document.createElement('video');
  Object.defineProperties(video, {
    videoWidth: {
      configurable: true,
      value: width,
    },
    videoHeight: {
      configurable: true,
      value: height,
    },
  });
  return video;
}

describe('VideoFrameUploader', () => {
  beforeEach(() => {
    Reflect.deleteProperty(globalThis, 'OffscreenCanvas');
    Reflect.deleteProperty(globalThis, 'createImageBitmap');
  });

  afterEach(() => {
    Reflect.deleteProperty(globalThis, 'OffscreenCanvas');
    Reflect.deleteProperty(globalThis, 'createImageBitmap');
  });

  it('uses the native upload path by default', async () => {
    const copyExternalImageToTexture = vi.fn();
    const uploader = new VideoFrameUploader();
    const video = createVideo(320, 180);
    const texture = { label: 'target' } as GPUTexture;

    await uploader.copyFrame(
      { queue: { copyExternalImageToTexture } } as unknown as GPUDevice,
      video,
      texture,
    );

    expect(copyExternalImageToTexture).toHaveBeenCalledWith(
      { source: video },
      { texture },
      [320, 180],
    );
    expect(uploader.getMode()).toBe('native');
  });

  it('uses the canvas fallback path when enabled and available', async () => {
    const drawImage = vi.fn();
    const copyExternalImageToTexture = vi.fn();
    const offscreenCanvas = class {
      public width: number;
      public height: number;

      constructor(width: number, height: number) {
        this.width = width;
        this.height = height;
      }

      getContext() {
        return { drawImage };
      }
    };
    Object.assign(globalThis, {
      OffscreenCanvas: offscreenCanvas,
    });

    const uploader = new VideoFrameUploader();
    const video = createVideo(640, 360);
    const texture = { label: 'target' } as GPUTexture;
    uploader.setFallbackEnabled(true);

    await uploader.copyFrame(
      { queue: { copyExternalImageToTexture } } as unknown as GPUDevice,
      video,
      texture,
    );

    expect(drawImage).toHaveBeenCalledWith(video, 0, 0, 640, 360);
    expect(copyExternalImageToTexture).toHaveBeenCalledTimes(1);
    expect(copyExternalImageToTexture.mock.calls[0]?.[0].source).toBeInstanceOf(offscreenCanvas);
    expect(uploader.getMode()).toBe('canvas');
    expect(uploader.isFallbackEnabled()).toBe(true);
  });

  it('falls back to ImageBitmap when canvas upload throws', async () => {
    const copyExternalImageToTexture = vi.fn();
    const bitmap = {
      close: vi.fn(),
    };
    const drawImage = vi.fn(() => {
      throw new Error('canvas upload failed');
    });
    Object.assign(globalThis, {
      OffscreenCanvas: class {
        public width: number;
        public height: number;

        constructor(width: number, height: number) {
          this.width = width;
          this.height = height;
        }

        getContext() {
          return { drawImage };
        }
      },
      createImageBitmap: vi.fn(async () => bitmap),
    });

    const uploader = new VideoFrameUploader();
    const video = createVideo(1280, 720);
    const texture = { label: 'target' } as GPUTexture;
    uploader.setFallbackEnabled(true);

    await uploader.copyFrame(
      { queue: { copyExternalImageToTexture } } as unknown as GPUDevice,
      video,
      texture,
    );

    expect(globalThis.createImageBitmap).toHaveBeenCalledWith(video);
    expect(copyExternalImageToTexture).toHaveBeenCalledTimes(1);
    expect(copyExternalImageToTexture.mock.calls[0]?.[0].source).toBe(bitmap);
    expect(bitmap.close).toHaveBeenCalledTimes(1);
    expect(uploader.getMode()).toBe('bitmap');
  });

  it('restores mode state when fallback is disabled or disposed', () => {
    Object.assign(globalThis, {
      OffscreenCanvas: class {
        public width: number;
        public height: number;

        constructor(width: number, height: number) {
          this.width = width;
          this.height = height;
        }

        getContext() {
          return { drawImage: vi.fn() };
        }
      },
    });

    const uploader = new VideoFrameUploader();
    const video = createVideo(1920, 1080);

    uploader.setFallbackEnabled(true);
    uploader.sync(video);
    expect(uploader.getMode()).toBe('canvas');

    uploader.setFallbackEnabled(false);
    expect(uploader.getMode()).toBe('native');
    expect(uploader.isFallbackEnabled()).toBe(false);

    uploader.setFallbackEnabled(true);
    uploader.dispose();
    expect(uploader.getMode()).toBe('canvas');
    expect(uploader.isFallbackEnabled()).toBe(true);
  });

  it('encodes the external texture path into the caller command buffer', () => {
    const externalTexture = {} as GPUExternalTexture;
    const bindGroupLayout = {} as GPUBindGroupLayout;
    const pipeline = {} as GPURenderPipeline;
    const sampler = {} as GPUSampler;
    const bindGroup = {} as GPUBindGroup;
    const draw = vi.fn();
    const pass = {
      setPipeline: vi.fn(),
      setBindGroup: vi.fn(),
      draw,
      end: vi.fn(),
    };
    const beginRenderPass = vi.fn(() => pass);
    const device = {
      queue: { copyExternalImageToTexture: vi.fn() },
      importExternalTexture: vi.fn(() => externalTexture),
      createShaderModule: vi.fn(() => ({})),
      createBindGroupLayout: vi.fn(() => bindGroupLayout),
      createPipelineLayout: vi.fn(() => ({})),
      createRenderPipeline: vi.fn(() => pipeline),
      createSampler: vi.fn(() => sampler),
      createBindGroup: vi.fn(() => bindGroup),
    } as unknown as GPUDevice;
    const video = createVideo(1920, 1080);
    const texture = { createView: vi.fn(() => ({})) } as unknown as GPUTexture;
    const uploader = new VideoFrameUploader();
    uploader.setExternalTextureEnabled(true);

    uploader.copyFrame(device, video, texture, { beginRenderPass } as unknown as GPUCommandEncoder);
    uploader.copyFrame(device, video, texture, { beginRenderPass } as unknown as GPUCommandEncoder);

    expect(uploader.getMode()).toBe('external');
    expect(device.importExternalTexture).toHaveBeenCalledWith({ source: video });
    expect(device.queue.copyExternalImageToTexture).not.toHaveBeenCalled();
    expect(pass.setPipeline).toHaveBeenCalledWith(pipeline);
    expect(pass.setBindGroup).toHaveBeenCalledWith(0, bindGroup);
    expect(draw).toHaveBeenCalledWith(3);
    expect(texture.createView).toHaveBeenCalledOnce();
    expect(device.createShaderModule).toHaveBeenCalledOnce();
    expect(device.createRenderPipeline).toHaveBeenCalledOnce();
    const descriptors = beginRenderPass.mock.calls as unknown as Array<[GPURenderPassDescriptor]>;
    expect(descriptors[0][0]).toBe(descriptors[1][0]);
  });

  it('fuses external texture upload with ClampHighlights using explicit source dimensions', () => {
    const clampPipeline = { label: 'clamp' } as GPURenderPipeline;
    const bindGroupLayout = {} as GPUBindGroupLayout;
    const uniformBuffer = { destroy: vi.fn() } as unknown as GPUBuffer;
    const bindGroup = {} as GPUBindGroup;
    const writeBuffer = vi.fn();
    const createBindGroup = vi.fn((_descriptor: GPUBindGroupDescriptor) => bindGroup);
    const pass = {
      setPipeline: vi.fn(),
      setBindGroup: vi.fn(),
      draw: vi.fn(),
      end: vi.fn(),
    };
    const device = {
      queue: {
        copyExternalImageToTexture: vi.fn(),
        writeBuffer,
      },
      importExternalTexture: vi.fn(() => ({})),
      createShaderModule: vi.fn(() => ({})),
      createBindGroupLayout: vi.fn(() => bindGroupLayout),
      createPipelineLayout: vi.fn(() => ({})),
      createRenderPipeline: vi.fn(() => clampPipeline),
      createSampler: vi.fn(() => ({})),
      createBuffer: vi.fn(() => uniformBuffer),
      createBindGroup,
    } as unknown as GPUDevice;
    const uploader = new VideoFrameUploader();
    const video = createVideo(1920, 1080);
    const texture = { createView: vi.fn(() => ({})) } as unknown as GPUTexture;
    uploader.setExternalTextureEnabled(true);
    uploader.setExternalClampHighlightsEnabled(true);

    uploader.copyFrame(device, video, texture, {
      beginRenderPass: vi.fn(() => pass),
    } as unknown as GPUCommandEncoder);

    expect(pass.setPipeline).toHaveBeenCalledWith(clampPipeline);
    expect(device.createShaderModule).toHaveBeenCalledOnce();
    expect(device.createRenderPipeline).toHaveBeenCalledOnce();
    expect(device.createBuffer).toHaveBeenCalledWith(expect.objectContaining({
      size: 16,
      usage: GPUBufferUsage.UNIFORM | GPUBufferUsage.COPY_DST,
    }));
    expect(writeBuffer).toHaveBeenCalledOnce();
    expect(Array.from(writeBuffer.mock.calls[0][2] as Uint32Array))
      .toEqual([1920, 1080, 0, 0]);
    const descriptor = createBindGroup.mock.calls[0][0] as GPUBindGroupDescriptor;
    expect(descriptor.entries).toHaveLength(3);
    expect(descriptor.entries[2]).toMatchObject({ binding: 2, resource: { buffer: uniformBuffer } });

    uploader.dispose();
    expect(uniformBuffer.destroy).toHaveBeenCalledOnce();
  });

  it('probes the real external texture upload path', async () => {
    const webgpu = createWebGpuMock();
    const importExternalTexture = vi.fn(() => ({} as GPUExternalTexture));
    Object.assign(webgpu.device, { importExternalTexture });

    const result = await VideoFrameUploader.probeExternalTexture(
      webgpu.device as unknown as GPUDevice,
      createVideo(320, 180),
    );

    expect(result).toBe(true);
    expect(importExternalTexture).toHaveBeenCalledWith({ source: expect.any(HTMLVideoElement) });
    expect((webgpu.device.queue as unknown as { submissions: number }).submissions).toBe(1);
  });

  it('rejects an external texture path that throws during import', async () => {
    const webgpu = createWebGpuMock();
    const importExternalTexture = vi.fn(() => {
      throw new Error('external texture unavailable');
    });
    Object.assign(webgpu.device, { importExternalTexture });

    const result = await VideoFrameUploader.probeExternalTexture(
      webgpu.device as unknown as GPUDevice,
      createVideo(320, 180),
    );

    expect(result).toBe(false);
  });
});
