import { getSettingsSnapshot } from '../../utils/settings-snapshot';
import { saveSettings } from '../../utils/settings';
import { Renderer } from '../renderer';
import { NIJILUCID_APPLIED_ATTR } from '../../constants';
import type { Dimensions, NijiLucidSettings, EnhancementMode, FramePerformanceSnapshot } from '../../types';
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
import { waitForMediaReady } from '../media-wait';

const logger = createLogger('video-enhancer');

/**
 * 视频增强器类，封装 NijiLucid 视频增强逻辑
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
  private readonly lifecycleAbortController = new AbortController();

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

  private getCurrentSettings(): NijiLucidSettings {
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
      signal: this.lifecycleAbortController.signal,
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

      this.video.setAttribute(NIJILUCID_APPLIED_ATTR, 'true');
      this.button.innerText = chrome.i18n.getMessage('cancelEnhance');
    } catch (error) {
      if (this.destroyed) {
        return;
      }

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

          this.video.setAttribute(NIJILUCID_APPLIED_ATTR, 'true');
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

  private async initRenderer(settings: NijiLucidSettings): Promise<void> {
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
      performanceMonitorMode: settings.performanceMonitorMode,
      performanceModeName: selectedMode.name,
      performanceTier: settings.performanceTier,
      onPerformanceSnapshot: snapshot => this.presentPerformanceSnapshot(snapshot),
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

  public async updateSettings(newSettings: NijiLucidSettings): Promise<void> {
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
    this.video.removeAttribute(NIJILUCID_APPLIED_ATTR);
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
          this.video.setAttribute(NIJILUCID_APPLIED_ATTR, 'true');
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
    this.lifecycleAbortController.abort();
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
    this.overlay.hidePerformanceHud();
    this.video.removeAttribute(NIJILUCID_APPLIED_ATTR);
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
    this.button.innerText = chrome.i18n.getMessage('waitingVideoLoad');
    await waitForMediaReady(this.video, this.video.HAVE_METADATA, {
      signal: this.lifecycleAbortController.signal,
      readinessEvents: ['loadedmetadata'],
      interruptionEvents: ['error', 'abort', 'emptied'],
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
      `[NijiLucid] Geometry for ${reason}: source=${this.video.videoWidth}x${this.video.videoHeight}, `
      + `renderTarget=${targetDimensions.width}x${targetDimensions.height}.`,
    );

    return canvas;
  }

  private async updateRendererConfiguration(
    settings: NijiLucidSettings,
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
      await this.updatePerformanceMonitor(settings, selectedMode, sourceDimensions, targetDimensions);
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

    await this.updatePerformanceMonitor(settings, selectedMode, sourceDimensions, targetDimensions);

    if (this.destroyed) {
      return;
    }

    this.currentModeId = selectedMode.id;
    this.appliedRendererState = nextAppliedState;
    logger.debug(`Renderer updated to mode: ${selectedMode.name}`);
  }

  private async updatePerformanceMonitor(
    settings: NijiLucidSettings,
    selectedMode: EnhancementMode,
    sourceDimensions: Dimensions,
    targetDimensions: Dimensions,
  ): Promise<void> {
    if (!this.renderer) {
      this.overlay.hidePerformanceHud();
      return;
    }

    this.renderer.updatePerformanceMonitor({
      mode: settings.performanceMonitorMode,
      modeName: selectedMode.name,
      tier: settings.performanceTier,
      sourceDimensions,
      targetDimensions,
      onSnapshot: settings.performanceMonitorMode === 'off'
        ? undefined
        : snapshot => this.presentPerformanceSnapshot(snapshot),
    });

    if (settings.performanceMonitorMode === 'off') {
      this.overlay.hidePerformanceHud();
    }
  }

  private presentPerformanceSnapshot(snapshot: FramePerformanceSnapshot): void {
    if (this.destroyed || snapshot.mode === 'off') {
      return;
    }

    const settings = this.getCurrentSettings();
    this.overlay.showPerformanceHud(snapshot, {
      collapsed: settings.performanceMonitorHudCollapsed,
      position: settings.performanceMonitorHudPosition,
      width: settings.performanceMonitorHudWidth,
      onClose: () => {
        this.overlay.hidePerformanceHud();
        this.renderer?.updatePerformanceMonitor({
          mode: 'off',
          modeName: snapshot.modeName,
          tier: snapshot.tier,
          sourceDimensions: snapshot.sourceDimensions,
          targetDimensions: snapshot.targetDimensions,
        });
        void saveSettings({ performanceMonitorMode: 'off' }).catch(error => {
          logger.error('Failed to save performance monitor close action.', error);
        });
      },
      onToggleCollapsed: collapsed => {
        void saveSettings({ performanceMonitorHudCollapsed: collapsed }).catch(error => {
          logger.error('Failed to save performance HUD collapsed state.', error);
        });
      },
      onPositionChange: position => {
        void saveSettings({ performanceMonitorHudPosition: position }).catch(error => {
          logger.error('Failed to save performance HUD position.', error);
        });
      },
      onWidthChange: width => {
        void saveSettings({ performanceMonitorHudWidth: width }).catch(error => {
          logger.error('Failed to save performance HUD width.', error);
        });
      },
      onCopy: text => {
        const copyPromise = navigator.clipboard?.writeText(text);
        void copyPromise?.catch(error => {
          logger.error('Failed to copy performance snapshot.', error);
        });
      },
    });
  }
}
