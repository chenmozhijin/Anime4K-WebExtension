import { getSettingsSnapshot } from '../../utils/settings-snapshot';
import { Renderer } from '../renderer';
import { ANIME4K_APPLIED_ATTR } from '../../constants';
import type { Dimensions, Anime4KWebExtSettings } from '../../types';
import { EnhancerErrorNotifier } from './error-notifier';
import { OverlayManager } from '../overlay-manager';
import { VideoEnhancerGeometryController } from './geometry-controller';
import {
  buildAppliedRendererState,
  getAppliedRendererStateChanges,
  type AppliedRendererState,
  resolveRendererState,
} from './render-state';
import {
  attemptCrossOriginRecovery,
  shouldAttemptCrossOriginRecovery,
} from './cross-origin-recovery';
import { createLogger } from '../../utils/logger';

const logger = createLogger('video-enhancer');

/**
 * 视频增强器类，封装Anime4K处理逻辑
 * 负责管理单个视频元素的增强状态、渲染实例和资源清理
 */
export class VideoEnhancer {
  private renderer: Renderer | null = null;
  private currentModeId: string | null = null;
  private readonly overlay: OverlayManager;
  private readonly button: HTMLButtonElement;
  private readonly errorNotifier = new EnhancerErrorNotifier();
  private destroyed = false;
  private fixAttempted = false;
  private readonly geometryController: VideoEnhancerGeometryController;
  private appliedRendererState: AppliedRendererState | null = null;

  private constructor(private video: HTMLVideoElement) {
    this.overlay = OverlayManager.create(this.video);
    this.button = this.overlay.getButton();
    this.geometryController = new VideoEnhancerGeometryController(this.video, {
      getCurrentSettings: () => this.getCurrentSettings(),
      shouldHandleVideoChange: () => !!this.renderer && !this.destroyed && this.video.videoWidth > 0 && this.video.videoHeight > 0,
      processUpdate: (settings, reason) => this.updateRendererConfiguration(settings, reason),
    });
    this.initUI();
  }

  public static create(video: HTMLVideoElement): VideoEnhancer {
    return new VideoEnhancer(video);
  }

  private initUI(): void {
    this.button.onclick = (event) => {
      event.stopPropagation();
      void this.toggleEnhancement();
    };
  }

  private getCurrentSettings(): Anime4KWebExtSettings {
    return getSettingsSnapshot().settings;
  }

  private getSourceDimensions(): Dimensions {
    return {
      width: this.video.videoWidth,
      height: this.video.videoHeight,
    };
  }

  private async tryCrossOriginRecovery(context: 'proactive' | 'fallback'): Promise<boolean> {
    this.fixAttempted = true;
    const result = await attemptCrossOriginRecovery(this.video, {
      isDestroyed: () => this.destroyed,
    });

    if (result.status === 'recovered') {
      logger.info(`Cross-origin recovery succeeded during ${context}.`);
      return true;
    }

    if (result.status === 'failed') {
      logger.warn(`Cross-origin recovery failed during ${context}.`, result);
    } else {
      logger.debug(`Cross-origin recovery skipped during ${context}.`, result);
    }

    return false;
  }

  public async toggleEnhancement(): Promise<void> {
    if (this.destroyed) {
      return;
    }

    if (this.renderer) {
      logger.debug('Disabling video enhancement.');
      this.disableEnhancement();
      return;
    }

    this.button.innerText = chrome.i18n.getMessage('enhancing');
    this.button.disabled = true;
    this.fixAttempted = false;

    const settings = this.getCurrentSettings();

    try {
      if (settings.enableCrossOriginFix && shouldAttemptCrossOriginRecovery(this.video)) {
        await this.tryCrossOriginRecovery('proactive');
      }

      await this.initRenderer(settings);
      if (this.destroyed) {
        return;
      }

      this.video.setAttribute(ANIME4K_APPLIED_ATTR, 'true');
      this.button.innerText = chrome.i18n.getMessage('cancelEnhance');
    } catch (error) {
      const currentError = error as Error;
      const isCrossOriginError = currentError.name === 'SecurityError' && currentError.message.includes('tainted');

      if (isCrossOriginError && settings.enableCrossOriginFix && !this.fixAttempted) {
        logger.warn('Caught cross-origin SecurityError. Attempting recovery.');
        try {
          const recovered = await this.tryCrossOriginRecovery('fallback');
          if (!recovered) {
            throw currentError;
          }
          await this.initRenderer(settings);
          if (this.destroyed) {
            return;
          }

          this.video.setAttribute(ANIME4K_APPLIED_ATTR, 'true');
          this.button.innerText = chrome.i18n.getMessage('cancelEnhance');
        } catch (retryError) {
          logger.error('Enhancer failed after cross-origin retry.', retryError);
          this.disableEnhancement();
          this.errorNotifier.present(retryError, 'enhance', {
            enableCrossOriginFix: this.getCurrentSettings().enableCrossOriginFix,
          });
        }
      } else if (isCrossOriginError && !settings.enableCrossOriginFix) {
        logger.warn('Cross-origin error detected, but compatibility mode is disabled.');
        this.disableEnhancement();
        this.errorNotifier.present(currentError, 'enhance', {
          enableCrossOriginFix: this.getCurrentSettings().enableCrossOriginFix,
        });
      } else {
        logger.error('Failed to initialize enhancer.', currentError);
        this.disableEnhancement();
        this.errorNotifier.present(currentError, 'enhance', {
          enableCrossOriginFix: this.getCurrentSettings().enableCrossOriginFix,
        });
      }
    } finally {
      this.button.disabled = false;
    }
  }

  private async initRenderer(settings: Anime4KWebExtSettings): Promise<void> {
    await this.waitForVideoMetadata();
    if (this.destroyed) {
      return;
    }

    if (!navigator.gpu) {
      throw new Error('WebGPU is not supported on this browser.');
    }

    const sourceDimensions = this.getSourceDimensions();
    const { selectedMode, effects, effectsSignature, targetDimensions } = resolveRendererState(settings, sourceDimensions);
    const canvas = this.prepareCanvas(targetDimensions, 'initialization');
    this.currentModeId = selectedMode.id;

    this.renderer = await Renderer.create({
      video: this.video,
      canvas,
      effects,
      effectsSignature,
      targetDimensions,
      onError: async (error: Error) => {
        if (this.destroyed) {
          return;
        }

        logger.error('Renderer runtime error.', error);
        this.errorNotifier.present(error, 'render', {
          enableCrossOriginFix: this.getCurrentSettings().enableCrossOriginFix,
        });

        this.disableEnhancement();
      },
      onFirstFrameRendered: () => {
        if (!this.destroyed) {
          this.overlay.showCanvas();
        }
      },
      onProgress: (stage: string | null) => {
        if (this.destroyed) {
          return;
        }

        this.button.innerText = stage === null
          ? chrome.i18n.getMessage('cancelEnhance')
          : stage;
      },
    });

    this.geometryController.attach();
    this.appliedRendererState = buildAppliedRendererState(
      settings,
      selectedMode.id,
      sourceDimensions,
      targetDimensions,
      effectsSignature,
    );
    logger.debug(`Renderer initialized with mode: ${selectedMode.name}`);
  }

  public async updateSettings(newSettings: Anime4KWebExtSettings): Promise<void> {
    if (!this.renderer || this.destroyed) {
      return;
    }

    try {
      await this.geometryController.queue(newSettings, 'settings update');
    } catch (error) {
      logger.error('Failed to update renderer settings.', error);
      this.errorNotifier.present(error, 'update', {
        enableCrossOriginFix: this.getCurrentSettings().enableCrossOriginFix,
      });
      this.disableEnhancement();
      throw error;
    }
  }

  public getCurrentModeId(): string | null {
    return this.currentModeId;
  }

  public getVideoElement(): HTMLVideoElement {
    return this.video;
  }

  public detach(): void {
    logger.debug('Detaching enhancer from video.');
    this.overlay.detach();
    this.video.removeAttribute(ANIME4K_APPLIED_ATTR);
  }

  public async reattach(newVideo: HTMLVideoElement): Promise<void> {
    if (this.destroyed) {
      return;
    }

    logger.debug('Re-attaching enhancer to new video.');
    this.geometryController.bindVideo(newVideo);
    this.video = newVideo;
    this.overlay.reattach(newVideo);

    if (this.renderer) {
      try {
        await this.waitForVideoMetadata();
        if (this.destroyed) {
          return;
        }

        this.geometryController.attach();
        await this.renderer.updateVideoSource(newVideo);
        await this.geometryController.queue(this.getCurrentSettings(), 'video reattach');
        if (!this.destroyed) {
          this.video.setAttribute(ANIME4K_APPLIED_ATTR, 'true');
        }
      } catch (error) {
        logger.error('Failed to reattach renderer to new video source.', error);
        this.errorNotifier.present(error, 'reattach', {
          enableCrossOriginFix: this.getCurrentSettings().enableCrossOriginFix,
        });
        this.disableEnhancement();
      }
    } else {
      this.disableEnhancement();
    }
  }

  public destroy(): void {
    if (this.destroyed) {
      return;
    }

    this.destroyed = true;
    this.geometryController.clearPending();
    logger.debug('Destroying enhancer instance.');
    this.disableEnhancement();
    this.errorNotifier.clear();
    this.overlay.destroy();
    logger.debug('Enhancer destroyed.');
  }

  private disableEnhancement(): void {
    this.geometryController.detach();
    this.releaseWebGPUResources();
    this.overlay.hideCanvas();
    this.video.removeAttribute(ANIME4K_APPLIED_ATTR);
    this.button.innerText = chrome.i18n.getMessage('enhanceButton');
    this.currentModeId = null;
    this.appliedRendererState = null;
  }

  private releaseWebGPUResources(): void {
    if (!this.renderer) {
      return;
    }

    try {
      this.renderer.destroy();
    } catch (error) {
      logger.error('Error during renderer destruction.', error);
    } finally {
      this.renderer = null;
    }
  }

  private async waitForVideoMetadata(): Promise<void> {
    if (this.video.readyState >= this.video.HAVE_METADATA) {
      return;
    }

    this.button.innerText = chrome.i18n.getMessage('waitingVideoLoad');
    await new Promise<void>(resolve => {
      this.video.addEventListener('loadedmetadata', () => resolve(), { once: true });
    });
  }

  private prepareCanvas(targetDimensions: Dimensions, reason: string): HTMLCanvasElement {
    const canvas = this.overlay.getCanvas();
    if (canvas.width !== targetDimensions.width || canvas.height !== targetDimensions.height) {
      logger.debug(`Resizing canvas for ${reason}: ${canvas.width}x${canvas.height} -> ${targetDimensions.width}x${targetDimensions.height}.`);
      canvas.width = targetDimensions.width;
      canvas.height = targetDimensions.height;
    }

    this.overlay.updateLayout();
    logger.debug(
      `[Anime4KWebExt] Geometry for ${reason}: source=${this.video.videoWidth}x${this.video.videoHeight}, `
      + `renderTarget=${targetDimensions.width}x${targetDimensions.height}.`,
    );

    return canvas;
  }

  private async updateRendererConfiguration(
    settings: Anime4KWebExtSettings,
    reason: string,
  ): Promise<void> {
    if (!this.renderer || this.destroyed) {
      return;
    }

    if (this.video.videoWidth <= 0 || this.video.videoHeight <= 0) {
      this.overlay.updateLayout();
      return;
    }

    const sourceDimensions = this.getSourceDimensions();
    const { selectedMode, effects, effectsSignature, targetDimensions } = resolveRendererState(settings, sourceDimensions);
    const nextAppliedState = buildAppliedRendererState(
      settings,
      selectedMode.id,
      sourceDimensions,
      targetDimensions,
      effectsSignature,
    );
    const previousState = this.appliedRendererState;
    const {
      sourceChanged,
      targetChanged,
      effectsChanged,
      modeChanged,
      tierChanged,
      resolutionChanged,
    } = getAppliedRendererStateChanges(previousState, nextAppliedState);

    if (!sourceChanged && !targetChanged && !effectsChanged && !modeChanged && !tierChanged && !resolutionChanged) {
      this.overlay.updateLayout();
      return;
    }

    this.prepareCanvas(targetDimensions, reason);

    if (sourceChanged && !targetChanged && !effectsChanged) {
      await this.renderer.handleSourceResize();
    } else {
      await this.renderer.updateConfiguration({
        effects,
        effectsSignature,
        targetDimensions,
        sourceDimensions: nextAppliedState.sourceDimensions,
      });
    }

    if (this.destroyed) {
      return;
    }

    this.currentModeId = selectedMode.id;
    this.appliedRendererState = nextAppliedState;
    logger.debug(`Renderer updated to mode: ${selectedMode.name}`);
  }
}
