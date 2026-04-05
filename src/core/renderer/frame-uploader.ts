import { createLogger } from '../../utils/logger';

type FrameUploadMode = 'native' | 'canvas' | 'bitmap';

export class VideoFrameUploader {
  private useImageBitmapFallback = false;
  private mode: FrameUploadMode = 'native';
  private fallbackCanvas: OffscreenCanvas | HTMLCanvasElement | null = null;
  private fallbackContext: OffscreenCanvasRenderingContext2D | CanvasRenderingContext2D | null = null;
  private readonly logger = createLogger('frame-uploader');

  public setFallbackEnabled(enabled: boolean): void {
    this.useImageBitmapFallback = enabled;
    this.mode = enabled ? 'canvas' : 'native';
    if (!enabled) {
      this.dispose();
    }
  }

  public isFallbackEnabled(): boolean {
    return this.useImageBitmapFallback;
  }

  public sync(video: HTMLVideoElement): void {
    if (!this.useImageBitmapFallback) {
      this.dispose();
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

  public async copyFrame(
    device: GPUDevice,
    video: HTMLVideoElement,
    targetTexture: GPUTexture,
  ): Promise<void> {
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

  public dispose(): void {
    this.fallbackCanvas = null;
    this.fallbackContext = null;
    this.mode = this.useImageBitmapFallback ? 'canvas' : 'native';
  }

  public getMode(): FrameUploadMode {
    return this.mode;
  }
}
