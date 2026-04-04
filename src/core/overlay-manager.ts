import { ANIME4K_BUTTON_CLASS } from '../constants';

type StyleMap = Record<string, string>;

/**
 * OverlayManager
 * 唯一负责创建、管理和销毁所有与特定视频关联的UI元素的模块。
 * 这包括UI覆盖层 (Host + Shadow DOM + Button) 和渲染目标 Canvas。
 */
export class OverlayManager {
  private static readonly HOST_MARKER_ATTR = 'data-anime4k-overlay-host';
  private static readonly CANVAS_HOST_MARKER_ATTR = 'data-anime4k-overlay-canvas-host';
  private static readonly SLOT_MARKER_ATTR = 'data-anime4k-overlay-slot';
  private static readonly bodyStrategyInstances = new Set<OverlayManager>();
  private static readonly boundGlobalBodyStrategyUpdate = () => {
    OverlayManager.bodyStrategyInstances.forEach(instance => instance.scheduleLayoutUpdate());
  };

  private video: HTMLVideoElement;
  private readonly host: HTMLElement;
  private readonly shadowRoot: ShadowRoot;
  private readonly button: HTMLButtonElement;
  private canvasHost?: HTMLElement;
  private canvas?: HTMLCanvasElement;
  private hideButtonTimeout?: number;
  private destroyed = false;
  private layoutFrameId: number | null = null;
  private shouldRevealButtonOnNextLayout = false;
  private readonly slotId: string;
  private readonly hostStyleCache: StyleMap = {};
  private readonly canvasHostStyleCache: StyleMap = {};
  private readonly canvasStyleCache: StyleMap = {};

  private attachmentStrategy: 'sibling' | 'body' = 'sibling';
  private readonly resizeObserver: ResizeObserver;
  private readonly mutationObserver: MutationObserver;

  public static create(video: HTMLVideoElement): OverlayManager {
    const slotId = OverlayManager.getOrCreateSlotId(video);
    OverlayManager.cleanupOrphanedArtifacts(video, slotId);
    return new OverlayManager(video);
  }

  private constructor(video: HTMLVideoElement) {
    this.video = video;
    this.slotId = OverlayManager.getOrCreateSlotId(video);

    this.host = document.createElement('div');
    this.host.setAttribute(OverlayManager.HOST_MARKER_ATTR, '');
    this.host.setAttribute(OverlayManager.SLOT_MARKER_ATTR, this.slotId);
    this.host.style.position = 'absolute';
    this.host.style.pointerEvents = 'none';
    this.host.style.zIndex = '2147483646';
    this.video.parentElement?.insertBefore(this.host, this.video);

    this.shadowRoot = this.host.attachShadow({ mode: 'closed' });
    this.button = this.createButtonInShadow();
    this.injectStyles();

    this.resizeObserver = new ResizeObserver(() => this.scheduleLayoutUpdate());
    this.resizeObserver.observe(this.video);

    this.mutationObserver = new MutationObserver(() => this.scheduleLayoutUpdate());
    this.mutationObserver.observe(this.video, {
      attributes: true,
      attributeFilter: ['style', 'class'],
    });

    this.scheduleLayoutUpdate(true);
    window.setTimeout(() => this.detectAndSwitchStrategy(), 100);
  }

  public getButton(): HTMLButtonElement {
    return this.button;
  }

  public updateLayout(): void {
    this.scheduleLayoutUpdate();
  }

  public getCanvas(): HTMLCanvasElement {
    if (this.canvas) {
      return this.canvas;
    }

    if (!this.canvasHost) {
      this.canvasHost = document.createElement('div');
      this.canvasHost.setAttribute(OverlayManager.CANVAS_HOST_MARKER_ATTR, '');
      this.canvasHost.setAttribute(OverlayManager.SLOT_MARKER_ATTR, this.slotId);
      this.canvasHost.style.pointerEvents = 'none';
      this.canvasHost.style.position = 'absolute';
      this.video.parentElement?.insertBefore(this.canvasHost, this.video);
    }

    this.canvas = document.createElement('canvas');
    this.canvas.width = this.video.videoWidth;
    this.canvas.height = this.video.videoHeight;
    this.canvas.style.pointerEvents = 'none';
    this.canvas.style.position = 'absolute';
    this.canvas.style.visibility = 'hidden';
    this.canvasHost.appendChild(this.canvas);
    return this.canvas;
  }

  public showCanvas(): void {
    if (!this.canvas) {
      this.getCanvas();
    }

    if (!this.canvasHost) {
      this.getCanvas();
    }

    if (this.canvasHost && this.canvasHost.parentElement !== this.video.parentElement) {
      this.video.parentElement?.insertBefore(this.canvasHost, this.video);
    }

    if (this.canvas && this.canvas.parentElement !== this.canvasHost) {
      this.canvasHost?.appendChild(this.canvas);
    }

    this.scheduleLayoutUpdate();
    if (this.canvas) {
      this.canvas.style.visibility = 'visible';
    }
    this.video.style.opacity = '0';
  }

  public hideCanvas(): void {
    this.canvas?.remove();
    this.canvasHost?.remove();
    this.canvas = undefined;
    this.canvasHost = undefined;
    this.canvasHostStyleCacheReset();
    this.canvasStyleCacheReset();
    this.video.style.opacity = '';
  }

  public detach(): void {
    this.host.remove();
    this.canvasHost?.remove();
  }

  public reattach(newVideo: HTMLVideoElement): void {
    if (this.destroyed) {
      return;
    }

    this.resizeObserver.disconnect();
    this.mutationObserver.disconnect();

    this.video.removeAttribute(OverlayManager.SLOT_MARKER_ATTR);
    this.video = newVideo;
    this.video.setAttribute(OverlayManager.SLOT_MARKER_ATTR, this.slotId);

    if (this.attachmentStrategy === 'sibling') {
      newVideo.parentElement?.insertBefore(this.host, newVideo);
    } else {
      OverlayManager.registerBodyStrategyInstance(this);
      document.body.appendChild(this.host);
    }

    if (this.canvasHost) {
      newVideo.parentElement?.insertBefore(this.canvasHost, newVideo);
    }

    this.resizeObserver.observe(newVideo);
    this.mutationObserver.observe(newVideo, {
      attributes: true,
      attributeFilter: ['style', 'class'],
    });

    this.scheduleLayoutUpdate(true);
  }

  public destroy(): void {
    if (this.destroyed) {
      return;
    }

    this.destroyed = true;
    if (this.layoutFrameId !== null) {
      cancelAnimationFrame(this.layoutFrameId);
      this.layoutFrameId = null;
    }

    this.resizeObserver.disconnect();
    this.mutationObserver.disconnect();
    this.host.remove();
    this.hideCanvas();
    this.video.removeAttribute(OverlayManager.SLOT_MARKER_ATTR);
    this.unsubscribeBodyStrategy();

    if (this.hideButtonTimeout) {
      clearTimeout(this.hideButtonTimeout);
    }
  }

  private scheduleLayoutUpdate(revealButton = false): void {
    if (this.destroyed) {
      return;
    }

    this.shouldRevealButtonOnNextLayout ||= revealButton;
    if (this.layoutFrameId !== null) {
      return;
    }

    this.layoutFrameId = requestAnimationFrame(() => {
      this.layoutFrameId = null;
      this.updatePosition();

      if (this.shouldRevealButtonOnNextLayout) {
        this.showButtonTemporarily();
        this.shouldRevealButtonOnNextLayout = false;
      }
    });
  }

  private updatePosition(): void {
    if (this.destroyed) {
      return;
    }

    if (!this.video.isConnected || (this.video.offsetWidth === 0 && this.video.offsetHeight === 0)) {
      this.applyStyles(this.host, { display: 'none' }, this.hostStyleCache);
      if (this.canvasHost) {
        this.applyStyles(this.canvasHost, { display: 'none' }, this.canvasHostStyleCache);
      }
      return;
    }

    this.applyStyles(this.host, { display: '' }, this.hostStyleCache);
    if (this.canvasHost) {
      this.applyStyles(this.canvasHost, { display: '' }, this.canvasHostStyleCache);
    }

    const videoStyle = window.getComputedStyle(this.video);
    const hostStyles = this.buildHostStyles(videoStyle);
    this.applyStyles(this.host, hostStyles, this.hostStyleCache);

    if (this.canvasHost) {
      this.applyStyles(this.canvasHost, {
        top: `${this.video.offsetTop}px`,
        left: `${this.video.offsetLeft}px`,
        width: `${this.video.offsetWidth}px`,
        height: `${this.video.offsetHeight}px`,
        transform: videoStyle.transform,
        transformOrigin: videoStyle.transformOrigin,
        position: 'absolute',
        zIndex: videoStyle.zIndex,
        borderRadius: videoStyle.borderRadius,
        overflow: 'hidden',
        pointerEvents: 'none',
      }, this.canvasHostStyleCache);
    }

    if (this.canvas) {
      this.applyStyles(this.canvas, {
        position: 'absolute',
        top: '0',
        left: '0',
        width: '100%',
        height: '100%',
        objectFit: videoStyle.objectFit,
        objectPosition: videoStyle.objectPosition,
        zIndex: '0',
      }, this.canvasStyleCache);
    }
  }

  private buildHostStyles(videoStyle: CSSStyleDeclaration): StyleMap {
    if (this.attachmentStrategy === 'body') {
      this.ensureBodyStrategyHostParent();
      const rect = this.video.getBoundingClientRect();
      const hostParent = this.host.parentElement;
      const parentRect = hostParent && hostParent !== document.body
        ? hostParent.getBoundingClientRect()
        : null;

      return {
        top: `${parentRect ? rect.top - parentRect.top : rect.top + window.scrollY}px`,
        left: `${parentRect ? rect.left - parentRect.left : rect.left + window.scrollX}px`,
        width: `${rect.width}px`,
        height: `${rect.height}px`,
        transform: videoStyle.transform,
        transformOrigin: videoStyle.transformOrigin,
        borderRadius: videoStyle.borderRadius,
      };
    }

    return {
      top: `${this.video.offsetTop}px`,
      left: `${this.video.offsetLeft}px`,
      width: `${this.video.offsetWidth}px`,
      height: `${this.video.offsetHeight}px`,
      transform: videoStyle.transform,
      transformOrigin: videoStyle.transformOrigin,
      borderRadius: videoStyle.borderRadius,
    };
  }

  private ensureBodyStrategyHostParent(): void {
    const fullscreenElement = document.fullscreenElement;
    if (fullscreenElement && fullscreenElement.contains(this.video)) {
      if (this.host.parentElement !== fullscreenElement) {
        fullscreenElement.appendChild(this.host);
      }
      return;
    }

    if (this.host.parentElement !== document.body) {
      document.body.appendChild(this.host);
    }
  }

  private detectAndSwitchStrategy(): void {
    if (this.destroyed) {
      return;
    }

    const initialOpacity = this.button.style.opacity;
    this.button.style.opacity = '1';

    const rect = this.button.getBoundingClientRect();
    const centerX = rect.left + rect.width / 2;
    const centerY = rect.top + rect.height / 2;
    const elementAtPoint = document.elementFromPoint(centerX, centerY);

    this.button.style.opacity = initialOpacity;

    const isButtonOrChild = this.button.contains(elementAtPoint) || this.button === elementAtPoint;
    if (isButtonOrChild || this.attachmentStrategy === 'body') {
      return;
    }

    console.log('Anime4K button is obscured. Switching to body attachment strategy.');
    this.attachmentStrategy = 'body';
    OverlayManager.registerBodyStrategyInstance(this);
    document.body.appendChild(this.host);
    this.scheduleLayoutUpdate(true);
  }

  private showButtonTemporarily(): void {
    if (this.hideButtonTimeout) {
      clearTimeout(this.hideButtonTimeout);
    }

    this.button.classList.add('show-initially');
    this.hideButtonTimeout = window.setTimeout(() => {
      this.button.classList.remove('show-initially');
    }, 3000);
  }

  private applyStyles(element: HTMLElement, nextStyles: StyleMap, cache: StyleMap): void {
    Object.entries(nextStyles).forEach(([key, value]) => {
      if (cache[key] === value) {
        return;
      }

      (element.style as CSSStyleDeclaration & Record<string, string>)[key] = value;
      cache[key] = value;
    });
  }

  private canvasHostStyleCacheReset(): void {
    Object.keys(this.canvasHostStyleCache).forEach(key => delete this.canvasHostStyleCache[key]);
  }

  private canvasStyleCacheReset(): void {
    Object.keys(this.canvasStyleCache).forEach(key => delete this.canvasStyleCache[key]);
  }

  private unsubscribeBodyStrategy(): void {
    if (this.attachmentStrategy !== 'body') {
      return;
    }

    OverlayManager.unregisterBodyStrategyInstance(this);
  }

  private static registerBodyStrategyInstance(instance: OverlayManager): void {
    if (OverlayManager.bodyStrategyInstances.has(instance)) {
      return;
    }

    OverlayManager.bodyStrategyInstances.add(instance);
    if (OverlayManager.bodyStrategyInstances.size !== 1) {
      return;
    }

    window.addEventListener('resize', OverlayManager.boundGlobalBodyStrategyUpdate);
    window.addEventListener('scroll', OverlayManager.boundGlobalBodyStrategyUpdate, true);
    document.addEventListener('fullscreenchange', OverlayManager.boundGlobalBodyStrategyUpdate);
  }

  private static unregisterBodyStrategyInstance(instance: OverlayManager): void {
    if (!OverlayManager.bodyStrategyInstances.delete(instance)) {
      return;
    }

    if (OverlayManager.bodyStrategyInstances.size !== 0) {
      return;
    }

    window.removeEventListener('resize', OverlayManager.boundGlobalBodyStrategyUpdate);
    window.removeEventListener('scroll', OverlayManager.boundGlobalBodyStrategyUpdate, true);
    document.removeEventListener('fullscreenchange', OverlayManager.boundGlobalBodyStrategyUpdate);
  }

  private static getOrCreateSlotId(video: HTMLVideoElement): string {
    let slotId = video.getAttribute(OverlayManager.SLOT_MARKER_ATTR);
    if (!slotId) {
      slotId = OverlayManager.createSlotId();
      video.setAttribute(OverlayManager.SLOT_MARKER_ATTR, slotId);
    }
    return slotId;
  }

  private static createSlotId(): string {
    return `anime4k-${Date.now().toString(36)}-${Math.random().toString(36).slice(2, 10)}`;
  }

  private static cleanupOrphanedArtifacts(video: HTMLVideoElement, slotId: string): void {
    OverlayManager.cleanupAdjacentMarkedSiblings(video, slotId);

    document
      .querySelectorAll(`body > [${OverlayManager.HOST_MARKER_ATTR}]`)
      .forEach(host => {
        if (host.getAttribute(OverlayManager.SLOT_MARKER_ATTR) === slotId) {
          console.warn('[Anime4KWebExt] Detected orphaned overlay host on body, removing:', host);
          host.remove();
        }
      });
  }

  private static cleanupAdjacentMarkedSiblings(video: HTMLVideoElement, slotId: string): void {
    let sibling = video.previousElementSibling;
    while (sibling && OverlayManager.isMarkedSiblingForSlot(sibling, slotId)) {
      const previousSibling = sibling.previousElementSibling;
      console.warn('[Anime4KWebExt] Detected orphaned overlay artifact, removing:', sibling);
      sibling.remove();
      sibling = previousSibling;
    }
  }

  private static isMarkedSiblingForSlot(element: Element, slotId: string): boolean {
    if (element.getAttribute(OverlayManager.SLOT_MARKER_ATTR) !== slotId) {
      return false;
    }

    return element.hasAttribute(OverlayManager.HOST_MARKER_ATTR)
      || element.hasAttribute(OverlayManager.CANVAS_HOST_MARKER_ATTR);
  }

  private createButtonInShadow(): HTMLButtonElement {
    const button = document.createElement('button');
    button.innerText = chrome.i18n.getMessage('enhanceButton');
    button.classList.add(ANIME4K_BUTTON_CLASS);
    button.part = 'button';
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
        pointer-events: auto;
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
