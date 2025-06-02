import { getSettings } from '../utils/settings';
import { createCanvasForVideo, createEnhanceButton, manageButtonVisibility } from '../utils/ui';
import { render, RendererInstance } from './renderer';
import { MODE_CLASSES, ANIME4K_INITIALIZED_ATTR } from '../constants';
import { Dimensions } from '../types';

/**
 * 视频增强器类，封装Anime4K处理逻辑
 * 负责管理单个视频元素的增强状态、渲染实例和资源清理
 */
export class VideoEnhancer {
  private instance?: RendererInstance;
  private resizeObserver?: ResizeObserver;
  private resizeHandler?: () => void;
  private canvas?: HTMLCanvasElement;
  public button: HTMLButtonElement;

  constructor(private video: HTMLVideoElement) {
    this.button = createEnhanceButton();
    console.log(`[Anime4KWebExt]创建按钮`);
    this.initUI();
  }

  /**
   * 初始化UI组件
   */
  private initUI() {
    manageButtonVisibility(this.button, this.video);
    this.button.onclick = (e) => {
      e.stopPropagation(); // 阻止事件冒泡
      this.toggleEnhancement();
    };
    document.body.appendChild(this.button);
  }

  /**
   * 切换超分状态
   */
  async toggleEnhancement() {
    if (this.video.getAttribute(ANIME4K_INITIALIZED_ATTR) === 'true') {
      console.log('[Anime4KWebExt] 取消视频超分');
      this.destroy();
      this.button.innerText = chrome.i18n.getMessage('enhanceButton');
      return;
    }

    this.video.setAttribute(ANIME4K_INITIALIZED_ATTR, 'true');
    console.log('[Anime4KWebExt] 开始视频超分处理');
    this.button.innerText = chrome.i18n.getMessage('enhancing');
    this.button.disabled = true;

    try {
      this.canvas = createCanvasForVideo(this.video);
      await this.initRenderer();
      this.button.innerText = chrome.i18n.getMessage('cancelEnhance');
    } catch (error) {
      console.error('[Anime4KWebExt] 超分初始化失败: ', error);
      this.destroy();
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
        this.destroy();
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
      this.destroyResources();
      this.canvas = createCanvasForVideo(this.video);
      await this.initRenderer();
    } catch (error) {
      console.error('重新初始化失败:', error);
      this.destroy();
      this.showErrorModal(chrome.i18n.getMessage('enhanceError') || '超分失败，请重试');
    }
  }

  /**
   * 销毁增强器实例和资源
   */
  destroy() {
    this.destroyResources();
    this.video.removeAttribute(ANIME4K_INITIALIZED_ATTR);
  }

  /**
   * 清理内部资源
   */
  private destroyResources() {
    console.log('[Anime4KWebExt] 清理渲染资源');
    this.instance?.destroy();
    this.resizeObserver?.disconnect();
    if (this.resizeHandler) {
      this.video.removeEventListener('resize', this.resizeHandler);
    }
    this.canvas?.remove();
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