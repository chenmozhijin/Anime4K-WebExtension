import { getEffectsForMode } from '../utils/settings';
import { getSettingsSnapshot } from '../utils/settings-snapshot';
import { createEffectSignature } from '../utils/effect-signature';
import { Renderer } from './renderer';
import { ANIME4K_APPLIED_ATTR } from '../constants';
import type { Dimensions, Anime4KWebExtSettings, EnhancementMode, PerformanceTier } from '../types';
import { OverlayManager } from './overlay-manager';

interface AppliedRendererState {
  selectedModeId: string;
  performanceTier: PerformanceTier;
  targetResolutionSetting: string;
  sourceDimensions: Dimensions;
  targetDimensions: Dimensions;
  effectsSignature: string;
}

/**
 * 视频增强器类，封装Anime4K处理逻辑
 * 负责管理单个视频元素的增强状态、渲染实例和资源清理
 */
export class VideoEnhancer {
  private renderer: Renderer | null = null;
  private currentModeId: string | null = null;
  private readonly overlay: OverlayManager;
  private readonly button: HTMLButtonElement;
  private destroyed = false;
  private fixAttempted = false;
  private geometryUpdateInFlight: Promise<void> | null = null;
  private pendingGeometryRequest: { settings: Anime4KWebExtSettings; reason: string } | null = null;
  private appliedRendererState: AppliedRendererState | null = null;
  private readonly boundHandleVideoGeometryChange = () => {
    if (!this.renderer || this.destroyed || this.video.videoWidth <= 0 || this.video.videoHeight <= 0) {
      return;
    }

    void this.queueGeometryUpdate(getSettingsSnapshot().settings, 'video geometry change');
  };

  private constructor(private video: HTMLVideoElement) {
    this.overlay = OverlayManager.create(this.video);
    this.button = this.overlay.getButton();
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

  private buildAppliedRendererState(
    settings: Anime4KWebExtSettings,
    selectedModeId: string,
    targetDimensions: Dimensions,
    effectsSignature: string,
  ): AppliedRendererState {
    return {
      selectedModeId,
      performanceTier: settings.performanceTier,
      targetResolutionSetting: settings.targetResolutionSetting,
      sourceDimensions: this.getSourceDimensions(),
      targetDimensions,
      effectsSignature,
    };
  }

  private async fixCrossOrigin(isFallback = false): Promise<void> {
    if (this.destroyed) {
      throw new Error('Enhancer destroyed during cross-origin recovery.');
    }

    console.log(`[Anime4KWebExt] Executing cross-origin fix. Is fallback: ${isFallback}`);
    this.fixAttempted = true;
    this.video.crossOrigin = 'anonymous';

    const currentTime = this.video.currentTime;
    const originalSrc = this.video.src;
    const isPaused = this.video.paused;

    return new Promise<void>((resolve, reject) => {
      const cleanup = () => {
        this.video.oncanplay = null;
        this.video.onerror = null;
      };

      this.video.oncanplay = () => {
        cleanup();
        if (this.destroyed) {
          reject(new Error('Enhancer destroyed during cross-origin recovery.'));
          return;
        }

        this.video.currentTime = currentTime;
        if (!isPaused) {
          this.video.play().catch(error => console.warn('[Anime4KWebExt] Autoplay after reload was blocked.', error));
        }
        console.log('[Anime4KWebExt] Video reloaded successfully with crossOrigin attribute.');
        resolve();
      };

      this.video.onerror = (error) => {
        cleanup();
        console.error('[Anime4KWebExt] Failed to reload video after setting crossOrigin.', error);
        reject(new Error('Failed to reload video with cross-origin attribute.'));
      };

      this.video.src = '';
      this.video.src = originalSrc;
      this.video.load();
    });
  }

  public async toggleEnhancement(): Promise<void> {
    if (this.destroyed) {
      return;
    }

    if (this.renderer) {
      console.log('[Anime4KWebExt] Disabling video enhancement.');
      this.disableEnhancement();
      return;
    }

    this.button.innerText = chrome.i18n.getMessage('enhancing');
    this.button.disabled = true;
    this.fixAttempted = false;

    const settings = this.getCurrentSettings();

    try {
      if (settings.enableCrossOriginFix) {
        const videoUrl = this.video.src;
        if (videoUrl && videoUrl.startsWith('http') && !this.video.crossOrigin) {
          try {
            const videoOrigin = new URL(videoUrl).origin;
            if (videoOrigin !== window.location.origin) {
              console.log('[Anime4KWebExt] Proactive check: Cross-origin video detected. Applying fix...');
              await this.fixCrossOrigin();
            }
          } catch (error) {
            console.warn('[Anime4KWebExt] Could not parse video src URL for proactive check.', error);
          }
        }
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
        console.warn('[Anime4KWebExt] Fallback: Caught a SecurityError. Attempting to fix and retry...');
        try {
          await this.fixCrossOrigin(true);
          await this.initRenderer(settings);
          if (this.destroyed) {
            return;
          }

          this.video.setAttribute(ANIME4K_APPLIED_ATTR, 'true');
          this.button.innerText = chrome.i18n.getMessage('cancelEnhance');
        } catch (retryError) {
          console.error('[Anime4KWebExt] Enhancer failed even after retry:', retryError);
          this.disableEnhancement();
          this.showErrorModal((retryError as Error).message || chrome.i18n.getMessage('enhanceError'));
        }
      } else if (isCrossOriginError && !settings.enableCrossOriginFix) {
        console.warn('[Anime4KWebExt] Cross-origin error detected, but fix is disabled. Prompting user.');
        this.disableEnhancement();
        this.showErrorModal(
          chrome.i18n.getMessage('crossOriginHint')
          || 'Enhancement failed due to cross-origin restrictions. Please enable Compatibility Mode in the options.',
          true,
        );
      } else {
        console.error('[Anime4KWebExt] Failed to initialize enhancer:', currentError);
        this.disableEnhancement();
        this.showErrorModal(currentError.message || chrome.i18n.getMessage('enhanceError'));
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

    const { selectedMode, effects, effectsSignature, targetDimensions } = this.resolveRendererState(settings);
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

        console.error('[Anime4KWebExt] Renderer runtime error:', error);
        const isCrossOriginError = error.name === 'SecurityError' && error.message.includes('tainted');
        const currentSettings = this.getCurrentSettings();

        if (isCrossOriginError && !currentSettings.enableCrossOriginFix) {
          this.showErrorModal(
            chrome.i18n.getMessage('crossOriginHint')
            || 'Enhancement failed due to cross-origin restrictions. Please enable Compatibility Mode in the options.',
            true,
          );
        } else {
          this.showErrorModal(chrome.i18n.getMessage('renderError') || 'A rendering error occurred.');
        }

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

    this.attachVideoGeometryListeners();
    this.appliedRendererState = this.buildAppliedRendererState(
      settings,
      selectedMode.id,
      targetDimensions,
      effectsSignature,
    );
    console.log(`[Anime4KWebExt] Renderer initialized with mode: ${selectedMode.name}`);
  }

  public async updateSettings(newSettings: Anime4KWebExtSettings): Promise<void> {
    if (!this.renderer || this.destroyed) {
      return;
    }

    await this.queueGeometryUpdate(newSettings, 'settings update');
  }

  private calculateTargetDimensions(
    videoWidth: number,
    videoHeight: number,
    resolutionSetting: string,
  ): Dimensions {
    const multipliers: Record<string, number> = { x2: 2, x4: 4, x8: 8 };
    const fixedResolutionHeights: Record<string, number> = {
      '720p': 720,
      '1080p': 1080,
      '2k': 1440,
      '4k': 2160,
    };

    if (multipliers[resolutionSetting]) {
      return {
        width: Math.max(1, Math.round(videoWidth * multipliers[resolutionSetting])),
        height: Math.max(1, Math.round(videoHeight * multipliers[resolutionSetting])),
      };
    }

    if (fixedResolutionHeights[resolutionSetting]) {
      const height = fixedResolutionHeights[resolutionSetting];
      const sourceAspect = videoHeight > 0 ? videoWidth / videoHeight : 1;
      return {
        width: Math.max(1, Math.round(height * sourceAspect)),
        height,
      };
    }

    return { width: videoWidth, height: videoHeight };
  }

  public getCurrentModeId(): string | null {
    return this.currentModeId;
  }

  public getVideoElement(): HTMLVideoElement {
    return this.video;
  }

  public detach(): void {
    console.log('[Anime4KWebExt] Detaching enhancer from video.');
    this.overlay.detach();
    this.video.removeAttribute(ANIME4K_APPLIED_ATTR);
  }

  public async reattach(newVideo: HTMLVideoElement): Promise<void> {
    if (this.destroyed) {
      return;
    }

    console.log('[Anime4KWebExt] Re-attaching enhancer to new video.');
    const previousVideo = this.video;
    this.detachVideoGeometryListeners(previousVideo);
    this.video = newVideo;
    this.overlay.reattach(newVideo);

    if (this.renderer) {
      await this.waitForVideoMetadata();
      if (this.destroyed) {
        return;
      }

      this.attachVideoGeometryListeners();
      await this.renderer.updateVideoSource(newVideo);
      await this.queueGeometryUpdate(this.getCurrentSettings(), 'video reattach');
      if (!this.destroyed) {
        this.video.setAttribute(ANIME4K_APPLIED_ATTR, 'true');
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
    this.pendingGeometryRequest = null;
    console.log('[Anime4KWebExt] Destroying enhancer instance:', this);
    this.disableEnhancement();
    this.overlay.destroy();
    console.log('[Anime4KWebExt] Enhancer destroyed');
  }

  private disableEnhancement(): void {
    console.log('[Anime4KWebExt] disableEnhancement called. Current renderer:', this.renderer);
    console.log('[Anime4KWebExt] Video opacity before:', this.video.style.opacity);
    this.detachVideoGeometryListeners();
    this.releaseWebGPUResources();
    this.overlay.hideCanvas();
    console.log('[Anime4KWebExt] Video opacity after hideCanvas:', this.video.style.opacity);
    this.video.removeAttribute(ANIME4K_APPLIED_ATTR);
    this.button.innerText = chrome.i18n.getMessage('enhanceButton');
    this.currentModeId = null;
    this.appliedRendererState = null;
    console.log('[Anime4KWebExt] disableEnhancement completed.');
  }

  private releaseWebGPUResources(): void {
    if (!this.renderer) {
      return;
    }

    console.log('[Debug] Releasing WebGPU resources. Entering release block.');
    try {
      this.renderer.destroy();
      console.log('[Debug] renderer.destroy() completed.');
    } catch (error) {
      console.error('[Debug] Error caught during renderer.destroy():', error);
    } finally {
      this.renderer = null;
      console.log('[Debug] renderer set to null.');
    }
  }

  private showErrorModal(message: string, showOptionsLink = false): void {
    const notification = document.createElement('div');
    Object.assign(notification.style, {
      position: 'fixed',
      top: '20px',
      right: '20px',
      backgroundColor: '#333',
      color: '#fff',
      padding: '15px 20px',
      borderRadius: '4px',
      boxShadow: '0 2px 10px rgba(0,0,0,0.2)',
      zIndex: '10000',
      maxWidth: '350px',
      fontFamily: 'Arial, sans-serif',
      fontSize: '14px',
      lineHeight: '1.5',
    });

    const messageNode = document.createElement('p');
    messageNode.textContent = `[Anime4K WebExtension] ${message}`;
    messageNode.style.margin = '0';
    notification.appendChild(messageNode);

    if (showOptionsLink) {
      const link = document.createElement('a');
      link.textContent = chrome.i18n.getMessage('goToOptions') || 'Go to Options';
      link.href = '#';
      link.style.color = '#8ab4f8';
      link.style.marginTop = '8px';
      link.style.display = 'block';
      link.onclick = (event) => {
        event.preventDefault();
        chrome.runtime.sendMessage({ type: 'OPEN_OPTIONS_PAGE' });
      };
      notification.appendChild(link);
    }

    document.body.appendChild(notification);
    setTimeout(() => notification.remove(), 8000);
  }

  private async waitForVideoMetadata(): Promise<void> {
    if (this.video.readyState >= this.video.HAVE_METADATA) {
      return;
    }

    this.button.innerText = chrome.i18n.getMessage('waitingVideoLoad') || '⏳ Waiting for video...';
    await new Promise<void>(resolve => {
      this.video.addEventListener('loadedmetadata', () => resolve(), { once: true });
    });
  }

  private queueGeometryUpdate(settings: Anime4KWebExtSettings, reason: string): Promise<void> {
    this.pendingGeometryRequest = { settings, reason };

    if (this.geometryUpdateInFlight) {
      return this.geometryUpdateInFlight;
    }

    this.geometryUpdateInFlight = (async () => {
      try {
        while (this.pendingGeometryRequest) {
          const request = this.pendingGeometryRequest;
          this.pendingGeometryRequest = null;
          await this.updateRendererConfiguration(request.settings, request.reason);
        }
      } finally {
        this.geometryUpdateInFlight = null;
      }
    })();

    return this.geometryUpdateInFlight;
  }

  private attachVideoGeometryListeners(): void {
    this.video.removeEventListener('resize', this.boundHandleVideoGeometryChange);
    this.video.removeEventListener('loadedmetadata', this.boundHandleVideoGeometryChange);
    this.video.addEventListener('resize', this.boundHandleVideoGeometryChange);
    this.video.addEventListener('loadedmetadata', this.boundHandleVideoGeometryChange);
  }

  private detachVideoGeometryListeners(video: HTMLVideoElement = this.video): void {
    video.removeEventListener('resize', this.boundHandleVideoGeometryChange);
    video.removeEventListener('loadedmetadata', this.boundHandleVideoGeometryChange);
  }

  private resolveRendererState(settings: Anime4KWebExtSettings): {
    selectedMode: EnhancementMode;
    effects: ReturnType<typeof getEffectsForMode>;
    effectsSignature: string;
    targetDimensions: Dimensions;
  } {
    const { selectedModeId, enhancementModes, targetResolutionSetting } = settings;
    const selectedMode =
      enhancementModes.find((mode: EnhancementMode) => mode.id === selectedModeId)
      || enhancementModes.find((mode: EnhancementMode) => mode.isBuiltIn)!;
    const effects = getEffectsForMode(selectedMode, settings.performanceTier);

    return {
      selectedMode,
      effects,
      effectsSignature: createEffectSignature(effects),
      targetDimensions: this.calculateTargetDimensions(
        this.video.videoWidth,
        this.video.videoHeight,
        targetResolutionSetting,
      ),
    };
  }

  private prepareCanvas(targetDimensions: Dimensions, reason: string): HTMLCanvasElement {
    const canvas = this.overlay.getCanvas();
    if (canvas.width !== targetDimensions.width || canvas.height !== targetDimensions.height) {
      console.log(`[Anime4KWebExt] Resizing canvas for ${reason}: ${canvas.width}x${canvas.height} -> ${targetDimensions.width}x${targetDimensions.height}.`);
      canvas.width = targetDimensions.width;
      canvas.height = targetDimensions.height;
    }

    this.overlay.updateLayout();
    console.log(
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

    const { selectedMode, effects, effectsSignature, targetDimensions } = this.resolveRendererState(settings);
    const nextAppliedState = this.buildAppliedRendererState(
      settings,
      selectedMode.id,
      targetDimensions,
      effectsSignature,
    );
    const previousState = this.appliedRendererState;

    const sourceChanged = !previousState
      || previousState.sourceDimensions.width !== nextAppliedState.sourceDimensions.width
      || previousState.sourceDimensions.height !== nextAppliedState.sourceDimensions.height;
    const targetChanged = !previousState
      || previousState.targetDimensions.width !== nextAppliedState.targetDimensions.width
      || previousState.targetDimensions.height !== nextAppliedState.targetDimensions.height;
    const effectsChanged = !previousState
      || previousState.effectsSignature !== nextAppliedState.effectsSignature;
    const modeChanged = !previousState || previousState.selectedModeId !== nextAppliedState.selectedModeId;
    const tierChanged = !previousState || previousState.performanceTier !== nextAppliedState.performanceTier;
    const resolutionChanged = !previousState
      || previousState.targetResolutionSetting !== nextAppliedState.targetResolutionSetting;

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
    console.log(`[Anime4KWebExt] Renderer updated to mode: ${selectedMode.name}`);
  }
}
