import { getSettings } from '../utils/settings';
import { Renderer } from './renderer';
import { ANIME4K_APPLIED_ATTR } from '../constants';
import { Dimensions, EnhancementEffect, ModeClasses, Anime4KWebExtSettings, EnhancementMode } from '../types';
import { OverlayManager } from './overlay-manager';

/**
 * 视频增强器类，封装Anime4K处理逻辑
 * 负责管理单个视频元素的增强状态、渲染实例和资源清理
 */
export class VideoEnhancer {
  private static modeClassesPromise: Promise<ModeClasses> | null = null;

  private renderer: Renderer | null = null;
  private currentModeId: string | null = null;
  private overlay: OverlayManager;
  private button: HTMLButtonElement;

  constructor(private video: HTMLVideoElement) {
    this.overlay = OverlayManager.create(this.video);
    this.button = this.overlay.getButton();
    this.initUI();
  }

  /**
   * 初始化UI组件和事件监听
   */
  private initUI(): void {
    this.button.onclick = (e) => {
      e.stopPropagation();
      this.toggleEnhancement();
    };
  }

  private fixAttempted = false;

  /**
   * 检查并修复视频的跨域问题。
   * @param isFallback - 是否作为错误后的兜底方案调用
   * @returns {Promise<void>}
   */
  private async fixCrossOrigin(isFallback = false): Promise<void> {
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
        this.video.currentTime = currentTime;
        if (!isPaused) {
          this.video.play().catch(e => console.warn('[Anime4KWebExt] Autoplay after reload was blocked.', e));
        }
        console.log('[Anime4KWebExt] Video reloaded successfully with crossOrigin attribute.');
        resolve();
      };

      this.video.onerror = (e) => {
        cleanup();
        console.error('[Anime4KWebExt] Failed to reload video after setting crossOrigin.', e);
        reject(new Error('Failed to reload video with cross-origin attribute.'));
      };

      this.video.src = '';
      this.video.src = originalSrc;
      this.video.load();
    });
  }

  /**
   * 切换视频增强的开关状态
   */
  async toggleEnhancement(): Promise<void> {
    if (this.renderer) {
      console.log('[Anime4KWebExt] Disabling video enhancement.');
      this.disableEnhancement();
      return;
    }

    this.button.innerText = chrome.i18n.getMessage('enhancing');
    this.button.disabled = true;
    this.fixAttempted = false; // Reset fix attempt flag

    const settings = await getSettings();

    try {
      if (settings.enableCrossOriginFix) {
        // --- 第一道防线：前置检查 ---
        const videoUrl = this.video.src;
        if (videoUrl && videoUrl.startsWith('http') && !this.video.crossOrigin) {
          try {
            const videoOrigin = new URL(videoUrl).origin;
            if (videoOrigin !== window.location.origin) {
              console.log('[Anime4KWebExt] Proactive check: Cross-origin video detected. Applying fix...');
              await this.fixCrossOrigin();
            }
          } catch (e) {
            console.warn('[Anime4KWebExt] Could not parse video src URL for proactive check.', e);
          }
        }
      }

      // --- 核心操作 ---
      await this.initRenderer();
      this.video.setAttribute(ANIME4K_APPLIED_ATTR, 'true');
      this.button.innerText = chrome.i18n.getMessage('cancelEnhance');

    } catch (error) {
      const err = error as Error;
      const isCrossOriginError = err.name === 'SecurityError' && err.message.includes('tainted');

      if (isCrossOriginError && settings.enableCrossOriginFix && !this.fixAttempted) {
        // --- 第二道防线：错误兜底 ---
        console.warn('[Anime4KWebExt] Fallback: Caught a SecurityError. Attempting to fix and retry...');
        try {
          await this.fixCrossOrigin();
          await this.initRenderer(); // 重试
          this.video.setAttribute(ANIME4K_APPLIED_ATTR, 'true');
          this.button.innerText = chrome.i18n.getMessage('cancelEnhance');
        } catch (retryError) {
          console.error('[Anime4KWebExt] Enhancer failed even after retry:', retryError);
          this.disableEnhancement();
          this.showErrorModal((retryError as Error).message || chrome.i18n.getMessage('enhanceError'));
        }
      } else if (isCrossOriginError && !settings.enableCrossOriginFix) {
        // --- 用户提示 ---
        console.warn('[Anime4KWebExt] Cross-origin error detected, but fix is disabled. Prompting user.');
        this.disableEnhancement();
        this.showErrorModal(chrome.i18n.getMessage('crossOriginHint') || 'Enhancement failed due to cross-origin restrictions. Please enable Compatibility Mode in the options.', true);
      } else {
        // --- 其他错误 ---
        console.error('[Anime4KWebExt] Failed to initialize enhancer:', err);
        this.disableEnhancement();
        this.showErrorModal(err.message || chrome.i18n.getMessage('enhanceError'));
      }
    } finally {
      this.button.disabled = false;
    }
  }

  /**
   * 动态加载 Anime4K 模块并缓存结果
   */
  private static loadAnime4KModule(): Promise<ModeClasses> {
    if (this.modeClassesPromise) {
      return this.modeClassesPromise;
    }
    this.modeClassesPromise = new Promise((resolve, reject) => {
      const timeoutId = setTimeout(() => {
        document.removeEventListener('anime4k-module-loaded', handleModuleLoaded);
        this.modeClassesPromise = null;
        reject(new Error('Anime4K module loading timed out.'));
      }, 5000);

      const handleModuleLoaded = (event: Event) => {
        clearTimeout(timeoutId);
        const customEvent = event as CustomEvent<ModeClasses>;
        if (customEvent.detail) {
          resolve(customEvent.detail);
        } else {
          this.modeClassesPromise = null;
          reject(new Error('Module loaded successfully but no content was provided.'));
        }
      };
      document.addEventListener('anime4k-module-loaded', handleModuleLoaded, { once: true });

      chrome.runtime.sendMessage({ type: 'LOAD_DYNAMIC_MODULE', chunk: 'anime4k-module' })
        .then(response => {
          if (!response?.success) {
            clearTimeout(timeoutId);
            document.removeEventListener('anime4k-module-loaded', handleModuleLoaded);
            const errorMsg = `Background script failed to load module: ${response?.error || 'Unknown error'}`;
            this.modeClassesPromise = null;
            reject(new Error(errorMsg));
          }
        }).catch(error => {
          clearTimeout(timeoutId);
          document.removeEventListener('anime4k-module-loaded', handleModuleLoaded);
          this.modeClassesPromise = null;
          reject(error);
        });
    });
    return this.modeClassesPromise;
  }

  /**
   * 初始化渲染器，包括获取设置、加载模块和创建Renderer实例
   */
  private async initRenderer(): Promise<void> {
    if (!navigator.gpu) {
      throw new Error('WebGPU is not supported on this browser.');
    }

    const [settings, modeClasses] = await Promise.all([
      getSettings(),
      VideoEnhancer.loadAnime4KModule()
    ]);

    const { selectedModeId, enhancementModes, targetResolutionSetting } = settings;
    const selectedMode = enhancementModes.find((m: EnhancementMode) => m.id === selectedModeId) || enhancementModes.find((m: EnhancementMode) => m.isBuiltIn)!;
    this.currentModeId = selectedMode.id;

    const targetDimensions = this.calculateTargetDimensions(
      this.video.videoWidth,
      this.video.videoHeight,
      targetResolutionSetting
    );

    const canvas = this.overlay.getCanvas();
    canvas.width = targetDimensions.width;
    canvas.height = targetDimensions.height;

    this.renderer = await Renderer.create({
      video: this.video,
      canvas: canvas,
      effects: selectedMode.effects,
      modeClasses,
      targetDimensions,
      onError: async (error: Error) => {
        console.error('[Anime4KWebExt] Renderer runtime error:', error);
        const isCrossOriginError = error.name === 'SecurityError' && error.message.includes('tainted');
        const settings = await getSettings();

        if (isCrossOriginError && !settings.enableCrossOriginFix) {
          this.showErrorModal(chrome.i18n.getMessage('crossOriginHint') || 'Enhancement failed due to cross-origin restrictions. Please enable Compatibility Mode in the options.', true);
        } else {
          this.showErrorModal(chrome.i18n.getMessage('renderError') || 'A rendering error occurred.');
        }
        this.disableEnhancement();
      },
      onFirstFrameRendered: () => {
        this.overlay.showCanvas();
      },
    });

    console.log(`[Anime4KWebExt] Renderer initialized with mode: ${selectedMode.name}`);
  }

  /**
   * 根据新设置更新渲染器。
   * 这比完全重新初始化要高效得多。
   * @param newSettings - 最新的设置对象
   */
  public async updateSettings(newSettings: Anime4KWebExtSettings): Promise<void> {
    if (!this.renderer) return;

    console.log('[Anime4KWebExt] Updating renderer with new settings...');
    const { selectedModeId, enhancementModes, targetResolutionSetting } = newSettings;
    const selectedMode = enhancementModes.find((m: EnhancementMode) => m.id === selectedModeId) || enhancementModes.find((m: EnhancementMode) => m.isBuiltIn)!;

    const newTargetDimensions = this.calculateTargetDimensions(
      this.video.videoWidth,
      this.video.videoHeight,
      targetResolutionSetting
    );

    // 如果目标尺寸变化，更新canvas的大小。这必须在调用渲染器更新之前完成。
    const canvas = this.overlay.getCanvas();
    if (newTargetDimensions.width !== canvas.width || newTargetDimensions.height !== canvas.height) {
      console.log(`[Anime4KWebExt] Target resolution changed, resizing canvas to ${newTargetDimensions.width}x${newTargetDimensions.height}.`);
      canvas.width = newTargetDimensions.width;
      canvas.height = newTargetDimensions.height;
    }

    // 调用渲染器统一的配置更新方法，它会智能地处理变更
    this.renderer.updateConfiguration({
      effects: selectedMode.effects,
      targetDimensions: newTargetDimensions
    });

    this.currentModeId = selectedMode.id;
    console.log(`[Anime4KWebExt] Renderer updated to mode: ${selectedMode.name}`);
  }

  /**
   * 计算目标渲染尺寸
   */
  private calculateTargetDimensions(videoWidth: number, videoHeight: number, resolutionSetting: string): Dimensions {
    const multipliers: Record<string, number> = { 'x2': 2, 'x4': 4, 'x8': 8 };
    const fixedResolutions: Record<string, Dimensions> = {
      '720p': { width: 1280, height: 720 },
      '1080p': { width: 1920, height: 1080 },
      '2k': { width: 2560, height: 1440 },
      '4k': { width: 3840, height: 2160 },
    };

    if (multipliers[resolutionSetting]) {
      return { width: videoWidth * multipliers[resolutionSetting], height: videoHeight * multipliers[resolutionSetting] };
    } else if (fixedResolutions[resolutionSetting]) {
      return fixedResolutions[resolutionSetting];
    }
    return { width: videoWidth, height: videoHeight };
  }

  /**
   * 获取当前正在使用的模式ID
   */
  public getCurrentModeId(): string | null {
    return this.currentModeId;
  }

  /**
   * 销毁整个增强器实例（包括UI元素和内部资源）
   */
  public destroy(): void {
    console.log('[Anime4KWebExt] Destroying enhancer instance.');
    this.disableEnhancement();
    this.overlay.destroy();
  }

  /**
   * 禁用视频增强效果（释放资源并重置视频状态）
   */
  private disableEnhancement(): void {
    this.releaseWebGPUResources();
    this.overlay.hideCanvas();
    this.video.removeAttribute(ANIME4K_APPLIED_ATTR);
    this.button.innerText = chrome.i18n.getMessage('enhanceButton');
    this.currentModeId = null;
  }

  /**
   * 释放WebGPU相关资源
   */
  private releaseWebGPUResources(): void {
    if (this.renderer) {
      console.log('[Debug] Releasing WebGPU resources. Entering release block.');
      try {
        this.renderer.destroy();
        console.log('[Debug] renderer.destroy() completed.');
      } catch (e) {
        console.error('[Debug] Error caught during renderer.destroy():', e);
      } finally {
        this.renderer = null;
        console.log('[Debug] renderer set to null.');
      }
    }
  }

  /**
   * 显示错误提示框
   */
  private showErrorModal(message: string, showOptionsLink = false): void {
    const notification = document.createElement('div');
    Object.assign(notification.style, {
      position: 'fixed', top: '20px', right: '20px',
      backgroundColor: '#333', color: '#fff', padding: '15px 20px',
      borderRadius: '4px', boxShadow: '0 2px 10px rgba(0,0,0,0.2)',
      zIndex: '10000', maxWidth: '350px', fontFamily: 'Arial, sans-serif',
      fontSize: '14px', lineHeight: '1.5'
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
      link.onclick = (e) => {
        e.preventDefault();
        chrome.runtime.sendMessage({ type: 'OPEN_OPTIONS_PAGE' });
      };
      notification.appendChild(link);
    }

    document.body.appendChild(notification);

    setTimeout(() => notification.remove(), 8000);
  }
}