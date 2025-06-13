import { ANIME4K_BUTTON_CLASS } from '../constants';

/**
 * OverlayManager
 * 唯一负责创建、管理和销毁所有与特定视频关联的UI元素的模块。
 * 这包括UI覆盖层 (Host + Shadow DOM + Button) 和渲染目标 Canvas。
 */
export class OverlayManager {
  private video: HTMLVideoElement;
  private host: HTMLElement;
  private shadowRoot: ShadowRoot;
  private button: HTMLButtonElement;
  private canvas?: HTMLCanvasElement;
  private hideButtonTimeout?: number;

  private resizeObserver: ResizeObserver;
  private mutationObserver: MutationObserver;

  /**
   * 创建并返回一个 OverlayManager 实例。
   * @param video 目标视频元素
   */
  public static create(video: HTMLVideoElement): OverlayManager {
    return new OverlayManager(video);
  }

  private constructor(video: HTMLVideoElement) {
    this.video = video;

    // 1. 创建 Host 元素并插入为视频的兄弟节点
    this.host = document.createElement('div');
    this.host.style.position = 'absolute';
    this.host.style.pointerEvents = 'none'; // 默认不拦截事件
    this.host.style.zIndex = '2147483646'; // 略低于按钮
    this.video.parentElement?.insertBefore(this.host, this.video);

    // 2. 创建 Shadow DOM
    this.shadowRoot = this.host.attachShadow({ mode: 'closed' });

    // 3. 在 Shadow DOM 内创建按钮和样式
    this.button = this.createButtonInShadow();
    this.injectStyles();

    // 4. 初始化监听器
    this.resizeObserver = new ResizeObserver(() => this.updatePosition());
    this.resizeObserver.observe(this.video);

    // 监听样式变化
    this.mutationObserver = new MutationObserver(() => this.updatePosition());
    this.mutationObserver.observe(this.video, {
      attributes: true,
      attributeFilter: ['style', 'class'],
    });

    // 立即执行一次以确定初始位置
    this.updatePosition();
  }

  /**
   * 统一更新 Host 和 Canvas 的位置
   */
  private updatePosition(): void {
    const videoStyle = window.getComputedStyle(this.video);
    const commonStyles = {
      top: `${this.video.offsetTop}px`,
      left: `${this.video.offsetLeft}px`,
      width: `${this.video.offsetWidth}px`,
      height: `${this.video.offsetHeight}px`,
      transform: videoStyle.transform,
      transformOrigin: videoStyle.transformOrigin,
    };

    // 更新 Host
    Object.assign(this.host.style, commonStyles);

    // 如果 Canvas 存在，同步更新
    if (this.canvas) {
      Object.assign(this.canvas.style, {
        ...commonStyles,
        position: 'absolute',
        objectFit: videoStyle.objectFit,
        objectPosition: videoStyle.objectPosition,
        zIndex: videoStyle.zIndex === 'auto' ? '1' : (parseInt(videoStyle.zIndex, 10) + 1).toString(),
      });
    }

    // 每次位置更新时，都短暂显示按钮
    if (this.hideButtonTimeout) {
      clearTimeout(this.hideButtonTimeout);
    }
    this.button.classList.add('show-initially');
    this.hideButtonTimeout = window.setTimeout(() => {
      this.button.classList.remove('show-initially');
    }, 3000);
  }

  /**
   * 返回 Shadow DOM 中的按钮元素
   */
  public getButton(): HTMLButtonElement {
    return this.button;
  }

  /**
   * 创建（如果不存在）并显示 Canvas，然后返回该元素。
   */
  public showCanvas(): HTMLCanvasElement {
    if (this.canvas) {
      return this.canvas;
    }

    this.canvas = document.createElement('canvas');
    this.canvas.width = this.video.videoWidth;
    this.canvas.height = this.video.videoHeight;
    this.canvas.style.pointerEvents = 'none';

    // 插入到视频同级，以继承CSS变换上下文
    this.video.parentElement?.insertBefore(this.canvas, this.video);
    this.updatePosition(); // 确保位置正确

    return this.canvas;
  }

  /**
   * 隐藏并销毁 Canvas。
   */
  public hideCanvas(): void {
    this.canvas?.remove();
    this.canvas = undefined;
  }

  /**
   * 销毁实例，清理所有资源。
   */
  public destroy(): void {
    this.resizeObserver.disconnect();
    this.mutationObserver.disconnect();
    this.host.remove();
    this.hideCanvas();
    if (this.hideButtonTimeout) {
      clearTimeout(this.hideButtonTimeout);
    }
  }

  // --- 私有辅助方法 ---

  private createButtonInShadow(): HTMLButtonElement {
    const button = document.createElement('button');
    button.innerText = chrome.i18n.getMessage('enhanceButton');
    button.classList.add(ANIME4K_BUTTON_CLASS);
    button.part = 'button'; // 暴露给外部样式 (如果需要)
    this.shadowRoot.appendChild(button);
    return button;
  }

  private injectStyles(): void {
    const style = document.createElement('style');
    style.textContent = `
      :host {
        pointer-events: none;
      }
      
      .${ANIME4K_BUTTON_CLASS} {
        position: absolute;
        top: 50%;
        left: 10px;
        transform: translateY(-50%);
        z-index: 2147483647;
        padding: 8px 12px;
        opacity: 0;
        transition: opacity 0.3s ease-in-out;
        background-color: #6A0DAD;
        color: white;
        border: none;
        border-radius: 4px;
        cursor: pointer;
        font-size: 14px;
        box-shadow: 0 2px 5px rgba(0,0,0,0.2);
        pointer-events: auto; /* 使按钮可点击 */
        isolation: isolate;
      }

      .${ANIME4K_BUTTON_CLASS}.show-initially {
        opacity: 1;
      }

      .${ANIME4K_BUTTON_CLASS}:hover {
        opacity: 1 !important;
      }
    `;
    this.shadowRoot.appendChild(style);
  }

}