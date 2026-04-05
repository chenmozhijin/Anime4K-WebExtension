import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { VideoFrameUploader } from '../../src/core/renderer/frame-uploader';

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
});
