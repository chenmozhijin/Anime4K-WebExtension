import type { Anime4KWebExtSettings } from '../../types';

interface GeometryUpdateRequest {
  settings: Anime4KWebExtSettings;
  reason: string;
}

export class VideoEnhancerGeometryController {
  private video: HTMLVideoElement;
  private geometryUpdateInFlight: Promise<void> | null = null;
  private pendingGeometryRequest: GeometryUpdateRequest | null = null;
  private readonly boundHandleVideoGeometryChange = () => {
    if (!this.options.shouldHandleVideoChange()) {
      return;
    }

    void this.queue(this.options.getCurrentSettings(), 'video geometry change');
  };

  constructor(
    video: HTMLVideoElement,
    private readonly options: {
      getCurrentSettings: () => Anime4KWebExtSettings;
      shouldHandleVideoChange: () => boolean;
      processUpdate: (settings: Anime4KWebExtSettings, reason: string) => Promise<void>;
    },
  ) {
    this.video = video;
  }

  public bindVideo(newVideo: HTMLVideoElement): HTMLVideoElement {
    const previousVideo = this.video;
    this.detach(previousVideo);
    this.video = newVideo;
    return previousVideo;
  }

  public attach(): void {
    this.video.removeEventListener('resize', this.boundHandleVideoGeometryChange);
    this.video.removeEventListener('loadedmetadata', this.boundHandleVideoGeometryChange);
    this.video.addEventListener('resize', this.boundHandleVideoGeometryChange);
    this.video.addEventListener('loadedmetadata', this.boundHandleVideoGeometryChange);
  }

  public detach(video: HTMLVideoElement = this.video): void {
    video.removeEventListener('resize', this.boundHandleVideoGeometryChange);
    video.removeEventListener('loadedmetadata', this.boundHandleVideoGeometryChange);
  }

  public clearPending(): void {
    this.pendingGeometryRequest = null;
  }

  public queue(settings: Anime4KWebExtSettings, reason: string): Promise<void> {
    this.pendingGeometryRequest = { settings, reason };

    if (this.geometryUpdateInFlight) {
      return this.geometryUpdateInFlight;
    }

    this.geometryUpdateInFlight = (async () => {
      try {
        while (this.pendingGeometryRequest) {
          const request = this.pendingGeometryRequest;
          this.pendingGeometryRequest = null;
          await this.options.processUpdate(request.settings, request.reason);
        }
      } finally {
        this.geometryUpdateInFlight = null;
      }
    })();

    return this.geometryUpdateInFlight;
  }
}
