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

  private attachmentStrategy: 'sibling' | 'body' = 'sibling';
  private boundUpdatePosition?: () => void;
  private boundHandleFullscreenChange?: () => void;

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

    // 延迟检测，确保初始渲染完成
    setTimeout(() => this.detectAndSwitchStrategy(), 100);
  }

  /**
   * 统一更新 Host 和 Canvas 的位置
   */
  private updatePosition(): void {
    // 当视频从 DOM 中移除或不可见时，隐藏覆盖层
    if (!this.video.isConnected || (this.video.offsetWidth === 0 && this.video.offsetHeight === 0)) {
      this.host.style.display = 'none';
      return;
    }
    this.host.style.display = ''; // 确保可见

    const videoStyle = window.getComputedStyle(this.video);
    let hostStyles: any;

    if (this.attachmentStrategy === 'body') {
      // Body 策略：使用 getBoundingClientRect 获取相对于视口的位置
      const rect = this.video.getBoundingClientRect();
      hostStyles = {
        top: `${rect.top + window.scrollY}px`,
        left: `${rect.left + window.scrollX}px`,
        width: `${rect.width}px`,
        height: `${rect.height}px`,
        transform: videoStyle.transform,
        transformOrigin: videoStyle.transformOrigin,
      };
    } else {
      // Sibling 策略：使用 offsetTop/Left 获取相对于父元素的位置
      hostStyles = {
        top: `${this.video.offsetTop}px`,
        left: `${this.video.offsetLeft}px`,
        width: `${this.video.offsetWidth}px`,
        height: `${this.video.offsetHeight}px`,
        transform: videoStyle.transform,
        transformOrigin: videoStyle.transformOrigin,
      };
    }

    // 更新 Host
    Object.assign(this.host.style, hostStyles);

    // 如果 Canvas 存在，同步更新
    if (this.canvas) {
      // Canvas 总是视频的兄弟节点，所以其定位方式不变
      Object.assign(this.canvas.style, {
        top: `${this.video.offsetTop}px`,
        left: `${this.video.offsetLeft}px`,
        width: `${this.video.offsetWidth}px`,
        height: `${this.video.offsetHeight}px`,
        transform: videoStyle.transform,
        transformOrigin: videoStyle.transformOrigin,
        position: 'absolute',
        objectFit: videoStyle.objectFit,
        objectPosition: videoStyle.objectPosition,
        zIndex: videoStyle.zIndex,
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
   * 检测按钮是否被遮挡，并根据结果决定是否切换到 'body' 附加策略。
   */
  private detectAndSwitchStrategy(): void {
    // 确保按钮是可见的才能进行检测
    const initialOpacity = this.button.style.opacity;
    this.button.style.opacity = '1';

    const rect = this.button.getBoundingClientRect();
    const centerX = rect.left + rect.width / 2;
    const centerY = rect.top + rect.height / 2;
    const elementAtPoint = document.elementFromPoint(centerX, centerY);

    // 恢复原始透明度
    this.button.style.opacity = initialOpacity;

    const isButtonOrChild = this.button.contains(elementAtPoint) || this.button === elementAtPoint;

    if (!isButtonOrChild) {
      console.log('Anime4K button is obscured. Switching to body attachment strategy.');
      this.attachmentStrategy = 'body';

      // 切换 Host 到 body
      document.body.appendChild(this.host);

      // 绑定上下文并添加全局事件监听器
      this.boundUpdatePosition = this.updatePosition.bind(this);
      this.boundHandleFullscreenChange = this.handleFullscreenChange.bind(this);
      window.addEventListener('resize', this.boundUpdatePosition);
      window.addEventListener('scroll', this.boundUpdatePosition, true);
      document.addEventListener('fullscreenchange', this.boundHandleFullscreenChange);

      // 立即重新计算位置
      this.updatePosition();
    }
  }

  private handleFullscreenChange(): void {
    const fullscreenElement = document.fullscreenElement;
    // 当视频进入全屏时，将 Host 移动到全屏元素内以确保其可见
    if (fullscreenElement && fullscreenElement.contains(this.video)) {
      fullscreenElement.appendChild(this.host);
    } else {
      // 退出全屏或视频不再全屏时，将 Host 移回 body
      // 仅当策略为 'body' 时才移回 body
      if (this.attachmentStrategy === 'body' && this.host.parentElement !== document.body) {
        document.body.appendChild(this.host);
      }
    }
    // DOM 结构变化后，立即更新位置
    this.updatePosition();
  }

  /**
   * 返回 Shadow DOM 中的按钮元素
   */
  public getButton(): HTMLButtonElement {
    return this.button;
  }

  /**
   * 创建（如果不存在）并返回 Canvas 元素，但不将其附加到 DOM。
   * @returns {HTMLCanvasElement}
   */
  public getCanvas(): HTMLCanvasElement {
    if (this.canvas) {
      return this.canvas;
    }

    this.canvas = document.createElement('canvas');
    this.canvas.width = this.video.videoWidth;
    this.canvas.height = this.video.videoHeight;
    this.canvas.style.pointerEvents = 'none';
    // 初始时不可见，由 showCanvas 负责显示
    this.canvas.style.visibility = 'hidden';
    return this.canvas;
  }

  /**
   * 将已创建的 Canvas 附加到 DOM 并使其可见。
   */
  public showCanvas(): void {
    if (!this.canvas) {
      // 理论上 getCanvas 应该先被调用，但作为安全措施我们在这里也创建它
      this.getCanvas();
    }

    // 确保 canvas 在 DOM 中
    if (!this.canvas!.parentElement) {
      this.video.parentElement?.insertBefore(this.canvas!, this.video);
    }
    
    this.updatePosition(); // 更新位置和尺寸
    this.canvas!.style.visibility = 'visible'; // 设为可见
    this.video.style.opacity = '0'; // 隐藏原视频
  }

  /**
   * 隐藏并销毁 Canvas。
   */
  public hideCanvas(): void {
    this.canvas?.remove();
    this.canvas = undefined;
    this.video.style.opacity = ''; // 恢复原视频
  }

  /**
   * 销毁实例，清理所有资源。
   */
  public destroy(): void {
    this.resizeObserver.disconnect();
    this.mutationObserver.disconnect();
    this.host.remove();
    this.hideCanvas();

    // 如果切换到了 body 策略，移除额外的监听器
    if (this.attachmentStrategy === 'body') {
      window.removeEventListener('resize', this.boundUpdatePosition!);
      window.removeEventListener('scroll', this.boundUpdatePosition!, true);
      document.removeEventListener('fullscreenchange', this.boundHandleFullscreenChange!);
    }

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