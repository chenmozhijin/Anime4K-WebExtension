import { getSettings } from '../utils/settings';
import { render, RendererInstance } from './renderer';
import { MODE_CLASSES, ANIME4K_APPLIED_ATTR } from '../constants';
import { Dimensions } from '../types';
import { OverlayManager } from './overlay-manager';

/**
 * 视频增强器类，封装Anime4K处理逻辑
 * 负责管理单个视频元素的增强状态、渲染实例和资源清理
 */
export class VideoEnhancer {
  private instance?: RendererInstance;
  private canvas?: HTMLCanvasElement;
  private overlay: OverlayManager;
  private button: HTMLButtonElement;

  constructor(private video: HTMLVideoElement) {
    this.overlay = OverlayManager.create(this.video);
    this.button = this.overlay.getButton();
    this.initUI();
  }

  /**
   * 初始化UI组件
   */
  private initUI() {
    this.button.onclick = (e) => {
      e.stopPropagation(); // 阻止事件冒泡
      this.toggleEnhancement();
    };
    // 按钮可见性逻辑现在由 OverlayManager 的 CSS 控制
  }

  /**
   * 切换超分状态
   */
  async toggleEnhancement() {
    if (this.video.getAttribute(ANIME4K_APPLIED_ATTR) === 'true') {
      console.log('[Anime4KWebExt] 取消视频超分');
      this.disableEnhancement();
      this.button.innerText = chrome.i18n.getMessage('enhanceButton');
      return;
    }

    this.video.setAttribute(ANIME4K_APPLIED_ATTR, 'true');
    console.log('[Anime4KWebExt] 开始视频超分处理');
    this.button.innerText = chrome.i18n.getMessage('enhancing');
    this.button.disabled = true;

    try {
      this.canvas = this.overlay.showCanvas();
      await this.initRenderer();
      this.button.innerText = chrome.i18n.getMessage('cancelEnhance');
    } catch (error) {
      console.error('[Anime4KWebExt] 超分初始化失败: ', error);
      this.disableEnhancement();
      this.button.innerText = chrome.i18n.getMessage('retryEnhance');
      this.showErrorModal(chrome.i18n.getMessage('enhanceError') || '超分失败，请重试');
    } finally {
      this.button.disabled = false;
    }
  }

  /**
   * 初始化渲染器
   */
  private async initRenderer() {
    const { selectedModeName, targetResolutionSetting } = await getSettings();
    console.log(`[Anime4KWebExt] 初始化渲染器 - 模式: ${selectedModeName}, 目标分辨率: ${targetResolutionSetting}`);
    const SelectedModeClass = MODE_CLASSES[selectedModeName as keyof typeof MODE_CLASSES] || MODE_CLASSES.ModeA;

    if (!navigator.gpu) {
      throw new Error('WebGPU not supported');
    }

    const targetDimensions = this.calculateTargetDimensions(
      this.video.videoWidth,
      this.video.videoHeight,
      targetResolutionSetting
    );
    console.log(`[Anime4KWebExt] 视频原始尺寸: ${this.video.videoWidth}x${this.video.videoHeight}, 目标尺寸: ${targetDimensions.width}x${targetDimensions.height}`);

    this.instance = await render({
      video: this.video,
      canvas: this.canvas!,
      pipelineBuilder: (device: GPUDevice, inputTexture: GPUTexture) => {
        const preset = new SelectedModeClass({
          device,
          inputTexture,
          nativeDimensions: {
            width: this.video.videoWidth,
            height: this.video.videoHeight,
          },
          targetDimensions
        });
        this.canvas!.width = targetDimensions.width;
        this.canvas!.height = targetDimensions.height;
        return [preset];
      },
      onResolutionChanged: () => {
        console.log('[Anime4KWebExt] 收到分辨率变化通知，重新初始化渲染器');
        this.reinitialize();
      },
      onError: (error) => {
        console.error('[Anime4KWebExt] 渲染器错误: ', error);
        this.showErrorModal(chrome.i18n.getMessage('renderError') || '渲染失败，请重试');
        this.disableEnhancement();
        this.button.innerText = chrome.i18n.getMessage('retryEnhance');
      }
    });
    console.log('[Anime4KWebExt] 渲染器初始化成功');
  }

  /**
   * 计算目标渲染尺寸
   * @param videoWidth 视频原始宽度
   * @param videoHeight 视频原始高度
   * @param resolutionSetting 分辨率设置
   * @returns 目标尺寸对象
   */
  private calculateTargetDimensions(
    videoWidth: number,
    videoHeight: number,
    resolutionSetting: string
  ): Dimensions {
    const multipliers: Record<string, number> = {
      'x2': 2, 'x4': 4, 'x8': 8,
    };
    
    const fixedResolutions: Record<string, Dimensions> = {
      '720p': { width: 1280, height: 720 },
      '1080p': { width: 1920, height: 1080 },
      '2k': { width: 2560, height: 1440 },
      '4k': { width: 3840, height: 2160 },
    };

    if (multipliers[resolutionSetting]) {
      return {
        width: videoWidth * multipliers[resolutionSetting],
        height: videoHeight * multipliers[resolutionSetting]
      };
    } else if (fixedResolutions[resolutionSetting]) {
      return fixedResolutions[resolutionSetting];
    }
    
    return { width: videoWidth, height: videoHeight };
  }



  /**
   * 重新初始化渲染器
   */
  private async reinitialize() {
    try {
      console.log('[Anime4KWebExt] 重新初始化渲染器...');
      this.releaseWebGPUResources();
      this.canvas = this.overlay.showCanvas();
      await this.initRenderer();
    } catch (error) {
      console.error('重新初始化失败:', error);
      this.disableEnhancement();
      this.showErrorModal(chrome.i18n.getMessage('enhanceError') || '超分失败，请重试');
    }
  }

  /**
   * 销毁整个增强器实例（包括UI元素和内部资源）
   */
  destroy() {
    console.log('[Anime4KWebExt] 销毁增强器实例和资源');
    this.disableEnhancement();
    this.overlay.destroy();
  }

  /**
   * 禁用视频增强效果（释放资源并重置视频状态）
   */
  private disableEnhancement() {
    this.releaseWebGPUResources();
    this.overlay.hideCanvas(); // 隐藏画布
    this.video.removeAttribute(ANIME4K_APPLIED_ATTR);
  }

  /**
   * 释放WebGPU相关资源（渲染器实例、观察者、画布等）
   */
  private releaseWebGPUResources() {
    console.log('[Anime4KWebExt] 清理渲染资源');
    this.instance?.destroy();
  }

  /**
   * 显示错误提示框（右上角）
   * @param message 错误消息
   */
  private showErrorModal(message: string): void {
    const notification = document.createElement('div');
    notification.style.position = 'fixed';
    notification.style.top = '20px';
    notification.style.right = '20px';
    notification.style.backgroundColor = '#333';
    notification.style.color = '#fff';
    notification.style.padding = '15px 20px';
    notification.style.borderRadius = '4px';
    notification.style.boxShadow = '0 2px 10px rgba(0,0,0,0.2)';
    notification.style.zIndex = '10000';
    notification.style.maxWidth = '300px';
    notification.style.fontFamily = 'Arial, sans-serif';
    notification.style.fontSize = '14px';
    notification.style.lineHeight = '1.5';

    const messageText = document.createElement('div');
    messageText.textContent = `[Anime4K WebExtension] ${message}`;
    messageText.style.marginBottom = '10px';
    messageText.style.fontWeight = 'bold';

    const closeButton = document.createElement('button');
    closeButton.textContent = chrome.i18n.getMessage('closeButton') || '关闭';
    closeButton.style.backgroundColor = 'transparent';
    closeButton.style.color = '#fff';
    closeButton.style.border = '1px solid #fff';
    closeButton.style.padding = '4px 8px';
    closeButton.style.borderRadius = '3px';
    closeButton.style.cursor = 'pointer';
    closeButton.style.float = 'right';
    closeButton.onclick = () => notification.remove();

    notification.appendChild(messageText);
    notification.appendChild(closeButton);
    document.body.appendChild(notification);

    // 5秒后自动关闭
    setTimeout(() => {
      if (document.body.contains(notification)) {
        notification.remove();
      }
    }, 5000);
  }
}