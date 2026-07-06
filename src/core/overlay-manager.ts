import { ANIME4K_BUTTON_CLASS } from '../constants';
import type {
  FramePerformanceSnapshot,
  PerformanceMonitorHudPosition,
  PassTimingEntry,
} from '../types';
import { createLogger } from '../utils/logger';
import { getRenderableParent } from './video-discovery';

type StyleMap = Record<string, string>;
const logger = createLogger('overlay');
const HUD_UPDATE_INTERVAL_MS = 500;
const HUD_MAX_GROUP_ROWS = 12;
const HUD_COLORS = ['#8b5f50', '#8f8f8f', '#00a889', '#4c78a8', '#f2b84b', '#b55c76', '#6b78d6', '#65a765'];
const HUD_MIN_WIDTH = 260;
const HUD_MAX_WIDTH = 640;
const HUD_DEFAULT_WIDTH = 360;

interface PerformanceHudOptions {
  collapsed: boolean;
  position: PerformanceMonitorHudPosition;
  width: number | null;
  onClose(): void;
  onToggleCollapsed(collapsed: boolean): void;
  onPositionChange(position: PerformanceMonitorHudPosition): void;
  onWidthChange(width: number | null): void;
  onCopy(text: string): void;
}

type HudResizeState = {
  pointerId: number;
  startX: number;
  startWidth: number;
};

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
  private visibilityCheckFrameId: number | null = null;
  private obscuredCheckStreak = 0;
  private originalVideoOpacity: string | null = null;
  private canvasVisible = false;
  private performanceHud?: HTMLElement;
  private performanceHudOptions?: PerformanceHudOptions;
  private latestPerformanceSnapshot?: FramePerformanceSnapshot;
  private pendingPerformanceSnapshot?: FramePerformanceSnapshot;
  private hudLastRenderAt = 0;
  private hudRenderTimeout?: number;
  private hudResizeState?: HudResizeState;
  private renderTimingCollapsed = false;

  private attachmentStrategy: 'sibling' | 'body' = 'sibling';
  private readonly resizeObserver: ResizeObserver;
  private readonly mutationObserver: MutationObserver;
  private observedRenderableParent: Element | ShadowRoot | null | undefined = undefined;

  private getAttachmentParent(video: HTMLVideoElement = this.video): Element | ShadowRoot | null {
    return getRenderableParent(video);
  }

  private isAttachedToShadowRoot(video: HTMLVideoElement = this.video): boolean {
    return this.getAttachmentParent(video) instanceof ShadowRoot;
  }

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
    this.getAttachmentParent()?.insertBefore(this.host, this.video);

    this.shadowRoot = this.host.attachShadow({ mode: 'closed' });
    this.button = this.createButtonInShadow();
    this.injectStyles();

    this.resizeObserver = new ResizeObserver(() => this.scheduleLayoutUpdate());
    this.resizeObserver.observe(this.video);

    this.mutationObserver = new MutationObserver(() => {
      this.observeLayoutTargets();
      this.scheduleLayoutUpdate();
    });
    this.observeLayoutTargets();
    this.addGlobalLayoutListeners();

    this.scheduleLayoutUpdate(true);
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
      this.getAttachmentParent()?.insertBefore(this.canvasHost, this.video);
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

    const attachmentParent = this.getAttachmentParent();
    if (this.canvasHost && attachmentParent && this.canvasHost.parentNode !== attachmentParent) {
      attachmentParent.insertBefore(this.canvasHost, this.video);
    }

    if (this.canvas && this.canvas.parentElement !== this.canvasHost) {
      this.canvasHost?.appendChild(this.canvas);
    }

    this.scheduleLayoutUpdate();
    if (this.canvas) {
      this.canvas.style.visibility = 'visible';
    }
    this.canvasVisible = true;
    this.originalVideoOpacity ??= this.video.style.opacity;
    this.video.style.opacity = '0';
  }

  public hideCanvas(): void {
    this.canvas?.remove();
    this.canvasHost?.remove();
    this.canvas = undefined;
    this.canvasHost = undefined;
    this.canvasHostStyleCacheReset();
    this.canvasStyleCacheReset();
    this.restoreVideoOpacity();
    this.canvasVisible = false;
  }

  public showPerformanceHud(snapshot: FramePerformanceSnapshot, options: PerformanceHudOptions): void {
    this.performanceHudOptions = options;
    this.latestPerformanceSnapshot = snapshot;

    if (!this.performanceHud) {
      this.performanceHud = document.createElement('section');
      this.performanceHud.className = 'anime4k-performance-hud';
      this.performanceHud.addEventListener('click', this.handlePerformanceHudClick);
      this.performanceHud.addEventListener('pointerdown', this.handlePerformanceHudPointerDown);
      this.shadowRoot.appendChild(this.performanceHud);
    }

    this.schedulePerformanceHudRender(snapshot, true);
  }

  public hidePerformanceHud(): void {
    if (this.hudRenderTimeout) {
      clearTimeout(this.hudRenderTimeout);
      this.hudRenderTimeout = undefined;
    }
    this.pendingPerformanceSnapshot = undefined;
    this.latestPerformanceSnapshot = undefined;
    this.performanceHudOptions = undefined;
    this.performanceHud?.remove();
    this.performanceHud = undefined;
    this.hudResizeState = undefined;
  }

  public detach(): void {
    this.restoreVideoOpacity();
    this.host.remove();
    this.canvasHost?.remove();
  }

  public reattach(newVideo: HTMLVideoElement): void {
    if (this.destroyed) {
      return;
    }

    this.resizeObserver.disconnect();
    this.mutationObserver.disconnect();
    this.observedRenderableParent = undefined;

    this.restoreVideoOpacity();
    this.video.removeAttribute(OverlayManager.SLOT_MARKER_ATTR);
    this.video = newVideo;
    this.video.setAttribute(OverlayManager.SLOT_MARKER_ATTR, this.slotId);

    const attachmentParent = this.getAttachmentParent(newVideo);
    if (this.attachmentStrategy === 'body' && !this.isAttachedToShadowRoot(newVideo)) {
      OverlayManager.registerBodyStrategyInstance(this);
      document.body.appendChild(this.host);
    } else {
      this.unsubscribeBodyStrategy();
      this.attachmentStrategy = 'sibling';
      attachmentParent?.insertBefore(this.host, newVideo);
    }

    if (this.canvasHost) {
      attachmentParent?.insertBefore(this.canvasHost, newVideo);
    }

    this.resizeObserver.observe(newVideo);
    this.observeLayoutTargets();

    if (this.canvasVisible) {
      this.originalVideoOpacity = this.video.style.opacity;
      this.video.style.opacity = '0';
    }

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
    if (this.visibilityCheckFrameId !== null) {
      cancelAnimationFrame(this.visibilityCheckFrameId);
      this.visibilityCheckFrameId = null;
    }

    this.resizeObserver.disconnect();
    this.mutationObserver.disconnect();
    this.observedRenderableParent = undefined;
    this.removeGlobalLayoutListeners();
    this.host.remove();
    this.hidePerformanceHud();
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
      this.scheduleVisibilityCheck();

      if (this.shouldRevealButtonOnNextLayout) {
        this.showButtonTemporarily();
        this.shouldRevealButtonOnNextLayout = false;
      }
    });
  }

  private addGlobalLayoutListeners(): void {
    window.addEventListener('resize', this.boundScheduleLayoutUpdate);
    window.addEventListener('scroll', this.boundScheduleLayoutUpdate, true);
    document.addEventListener('fullscreenchange', this.boundScheduleLayoutUpdate);
  }

  private removeGlobalLayoutListeners(): void {
    window.removeEventListener('resize', this.boundScheduleLayoutUpdate);
    window.removeEventListener('scroll', this.boundScheduleLayoutUpdate, true);
    document.removeEventListener('fullscreenchange', this.boundScheduleLayoutUpdate);
  }

  private readonly boundScheduleLayoutUpdate = () => this.scheduleLayoutUpdate();

  private restoreVideoOpacity(): void {
    if (this.originalVideoOpacity === null) {
      return;
    }

    this.video.style.opacity = this.originalVideoOpacity;
    this.originalVideoOpacity = null;
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
    this.ensureSiblingStrategyParents();
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

  private observeLayoutTargets(): void {
    if (this.destroyed) {
      return;
    }

    const nextParent = this.getAttachmentParent();
    if (this.observedRenderableParent === nextParent) {
      return;
    }

    this.mutationObserver.disconnect();
    this.mutationObserver.observe(this.video, {
      attributes: true,
      attributeFilter: ['style', 'class', 'hidden'],
    });

    if (nextParent) {
      this.mutationObserver.observe(nextParent, {
        attributes: true,
        attributeFilter: ['style', 'class'],
        childList: true,
      });
    }

    this.observedRenderableParent = nextParent;
  }

  private ensureSiblingStrategyParents(): void {
    if (this.attachmentStrategy !== 'sibling') {
      return;
    }

    const attachmentParent = this.getAttachmentParent();
    if (!attachmentParent) {
      return;
    }

    if (this.host.parentNode !== attachmentParent) {
      attachmentParent.insertBefore(this.host, this.video);
    }

    if (this.canvasHost && this.canvasHost.parentNode !== attachmentParent) {
      attachmentParent.insertBefore(this.canvasHost, this.video);
    }
  }

  private scheduleVisibilityCheck(): void {
    if (
      this.destroyed
      || this.attachmentStrategy === 'body'
      || this.visibilityCheckFrameId !== null
      || this.isAttachedToShadowRoot()
    ) {
      return;
    }

    this.visibilityCheckFrameId = requestAnimationFrame(() => {
      this.visibilityCheckFrameId = null;

      if (this.destroyed || this.attachmentStrategy === 'body') {
        return;
      }

      if (!this.isButtonObscured()) {
        this.obscuredCheckStreak = 0;
        return;
      }

      this.obscuredCheckStreak += 1;
      if (this.obscuredCheckStreak < 2) {
        this.scheduleVisibilityCheck();
        return;
      }

      this.switchToBodyStrategy();
    });
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

  private isButtonObscured(): boolean {
    if (this.destroyed) {
      return false;
    }

    const initialOpacity = this.button.style.opacity;
    this.button.style.opacity = '1';

    const rect = this.button.getBoundingClientRect();
    if (rect.width === 0 || rect.height === 0) {
      this.button.style.opacity = initialOpacity;
      return false;
    }
    const centerX = rect.left + rect.width / 2;
    const centerY = rect.top + rect.height / 2;
    const elementAtPoint = document.elementFromPoint(centerX, centerY);

    this.button.style.opacity = initialOpacity;

    const hitsOverlayHost = elementAtPoint === this.host || this.host.contains(elementAtPoint);
    const isButtonOrChild = this.button.contains(elementAtPoint) || this.button === elementAtPoint;
    return !(isButtonOrChild || hitsOverlayHost);
  }

  private switchToBodyStrategy(): void {
    if (this.destroyed || this.attachmentStrategy === 'body' || this.isAttachedToShadowRoot()) {
      return;
    }

    logger.debug('Overlay button is obscured twice. Switching to body attachment strategy.');
    this.attachmentStrategy = 'body';
    OverlayManager.registerBodyStrategyInstance(this);
    document.body.appendChild(this.host);
    this.obscuredCheckStreak = 0;
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

  private readonly handlePerformanceHudClick = (event: Event): void => {
    const target = event.target as HTMLElement;
    const action = target.closest<HTMLElement>('[data-hud-action]')?.dataset.hudAction;
    if (!action || !this.performanceHudOptions) {
      return;
    }

    event.stopPropagation();
    switch (action) {
      case 'toggle': {
        const nextCollapsed = !this.performanceHudOptions.collapsed;
        this.performanceHudOptions.onToggleCollapsed(nextCollapsed);
        this.performanceHudOptions = {
          ...this.performanceHudOptions,
          collapsed: nextCollapsed,
        };
        this.latestPerformanceSnapshot && this.renderPerformanceHud(this.latestPerformanceSnapshot);
        break;
      }
      case 'close':
        this.performanceHudOptions.onClose();
        break;
      case 'copy':
        if (this.latestPerformanceSnapshot) {
          this.performanceHudOptions.onCopy(this.formatPerformanceSnapshotText(this.latestPerformanceSnapshot));
        }
        break;
      case 'toggle-render':
        this.renderTimingCollapsed = !this.renderTimingCollapsed;
        this.latestPerformanceSnapshot && this.renderPerformanceHud(this.latestPerformanceSnapshot);
        break;
      case 'position': {
        const nextPosition = this.nextHudPosition(this.performanceHudOptions.position);
        this.performanceHudOptions.onPositionChange(nextPosition);
        this.performanceHudOptions = {
          ...this.performanceHudOptions,
          position: nextPosition,
        };
        this.latestPerformanceSnapshot && this.renderPerformanceHud(this.latestPerformanceSnapshot);
        break;
      }
      default:
        break;
    }
  };

  private readonly handlePerformanceHudPointerDown = (event: PointerEvent): void => {
    const target = event.target as HTMLElement;
    if (!target.closest('[data-hud-resize]') || !this.performanceHud || !this.performanceHudOptions) {
      return;
    }

    event.preventDefault();
    event.stopPropagation();
    this.hudResizeState = {
      pointerId: event.pointerId,
      startX: event.clientX,
      startWidth: this.performanceHud.getBoundingClientRect().width,
    };
    this.performanceHud.setPointerCapture(event.pointerId);
    this.performanceHud.addEventListener('pointermove', this.handlePerformanceHudPointerMove);
    this.performanceHud.addEventListener('pointerup', this.handlePerformanceHudPointerUp);
    this.performanceHud.addEventListener('pointercancel', this.handlePerformanceHudPointerUp);
  };

  private readonly handlePerformanceHudPointerMove = (event: PointerEvent): void => {
    if (!this.hudResizeState || !this.performanceHud || !this.performanceHudOptions) {
      return;
    }

    const direction = this.performanceHudOptions.position.includes('right') ? -1 : 1;
    const nextWidth = this.clampHudWidth(
      this.hudResizeState.startWidth + (event.clientX - this.hudResizeState.startX) * direction,
    );
    this.performanceHud.style.width = `${nextWidth}px`;
    this.performanceHudOptions = {
      ...this.performanceHudOptions,
      width: nextWidth,
    };
  };

  private readonly handlePerformanceHudPointerUp = (event: PointerEvent): void => {
    if (!this.hudResizeState || !this.performanceHud || !this.performanceHudOptions) {
      return;
    }

    if (this.performanceHud.hasPointerCapture(this.hudResizeState.pointerId)) {
      this.performanceHud.releasePointerCapture(this.hudResizeState.pointerId);
    }
    this.performanceHud.removeEventListener('pointermove', this.handlePerformanceHudPointerMove);
    this.performanceHud.removeEventListener('pointerup', this.handlePerformanceHudPointerUp);
    this.performanceHud.removeEventListener('pointercancel', this.handlePerformanceHudPointerUp);
    this.hudResizeState = undefined;
    this.performanceHudOptions.onWidthChange(this.clampHudWidth(this.performanceHud.getBoundingClientRect().width));
    event.stopPropagation();
  };

  private schedulePerformanceHudRender(snapshot: FramePerformanceSnapshot, force = false): void {
    const now = performance.now();
    if (force || now - this.hudLastRenderAt >= HUD_UPDATE_INTERVAL_MS) {
      this.renderPerformanceHud(snapshot);
      return;
    }

    this.pendingPerformanceSnapshot = snapshot;
    if (this.hudRenderTimeout) {
      return;
    }

    this.hudRenderTimeout = window.setTimeout(() => {
      this.hudRenderTimeout = undefined;
      if (this.pendingPerformanceSnapshot) {
        const pending = this.pendingPerformanceSnapshot;
        this.pendingPerformanceSnapshot = undefined;
        this.renderPerformanceHud(pending);
      }
    }, HUD_UPDATE_INTERVAL_MS - (now - this.hudLastRenderAt));
  }

  private renderPerformanceHud(snapshot: FramePerformanceSnapshot): void {
    if (!this.performanceHud || !this.performanceHudOptions) {
      return;
    }

    this.hudLastRenderAt = performance.now();
    this.latestPerformanceSnapshot = snapshot;
    const { collapsed, position } = this.performanceHudOptions;
    const statusClass = snapshot.frameMs > snapshot.budgetMs
      ? 'is-over'
      : snapshot.frameMs > snapshot.budgetMs * 0.8
        ? 'is-warn'
        : '';
    this.performanceHud.className = `anime4k-performance-hud ${position} ${collapsed ? 'is-collapsed' : ''} ${statusClass}`;
    this.performanceHud.style.width = collapsed ? '' : `${this.getHudRenderWidth()}px`;
    this.performanceHud.innerHTML = collapsed
      ? this.renderPerformanceHudMini(snapshot)
      : this.renderPerformanceHudFull(snapshot);
  }

  private renderPerformanceHudMini(snapshot: FramePerformanceSnapshot): string {
    const gpuLabel = this.hudMessage('hudLabelGpu', 'GPU');
    const gpuText = snapshot.timestampAvailable
      ? `${gpuLabel} ${this.formatMs(this.sumGpuMs(snapshot.groupEntries))}`
      : `${gpuLabel} n/a`;
    return `
      <button class="hud-mini" data-hud-action="toggle" type="button">
        <span>${this.formatFps(snapshot.fps)} ${this.escapeHtml(this.hudMessage('hudLabelFps', 'FPS'))}</span>
        <span>${this.formatMs(snapshot.frameMs)}</span>
        <span>${this.escapeHtml(gpuText)}</span>
        <span>${this.escapeHtml(this.hudMessage('hudLabelDrop', 'Drop'))} ${(snapshot.droppedFrameRate * 100).toFixed(1)}%</span>
      </button>
    `;
  }

  private renderPerformanceHudFull(snapshot: FramePerformanceSnapshot): string {
    const groups = this.prepareHudRows(snapshot.groupEntries);
    const canShowPassTimings = snapshot.mode === 'gpu'
      && snapshot.timestampAvailable
      && groups.some(entry => typeof entry.gpuMs === 'number');
    const total = groups.reduce((sum, entry) => sum + this.getEntryDisplayMs(entry), 0);
    const bar = groups.map((entry, index) => {
      const width = total > 0 ? Math.max(2, (this.getEntryDisplayMs(entry) / total) * 100) : 0;
      return `<span style="width:${width.toFixed(2)}%;background:${HUD_COLORS[index % HUD_COLORS.length]}"></span>`;
    }).join('');
    const rows = groups.map((entry, index) => `
      <div class="hud-row">
        <span class="hud-swatch" style="background:${HUD_COLORS[index % HUD_COLORS.length]}"></span>
        <span class="hud-name">${this.escapeHtml(entry.label)}</span>
        <span class="hud-ms">${this.formatEntryMs(entry)}</span>
      </div>
    `).join('');
    const gpuLabel = this.hudMessage('hudLabelGpu', 'GPU');
    const gpuStatus = snapshot.timestampAvailable
      ? `${gpuLabel} ${this.formatMs(this.sumGpuMs(snapshot.groupEntries))}`
      : `${gpuLabel} n/a`;

    return `
      <div class="hud-titlebar">
        <button class="hud-icon hud-collapse-button" data-hud-action="toggle" type="button" title="${this.escapeHtml(this.hudMessage('hudActionCollapse', 'Collapse'))}">
          <span class="hud-chevron"></span>
        </button>
        <span class="hud-title">${this.escapeHtml(this.hudMessage('performanceMonitor', 'Performance Monitor'))}</span>
        <button class="hud-icon" data-hud-action="copy" type="button" title="${this.escapeHtml(this.hudMessage('hudActionCopy', 'Copy'))}">⧉</button>
        <button class="hud-icon" data-hud-action="close" type="button" title="${this.escapeHtml(this.hudMessage('hudActionClose', 'Close'))}">×</button>
      </div>
      <div class="hud-body">
        <div class="hud-info">${this.escapeHtml(this.hudMessage('hudLabelGpu', 'GPU'))}: ${this.escapeHtml(snapshot.gpuName)}</div>
        <div class="hud-info">${this.escapeHtml(this.hudMessage('hudLabelUpload', 'Upload'))}: ${this.escapeHtml(snapshot.uploadMethod)}</div>
        <div class="hud-info">${this.escapeHtml(this.hudMessage('hudLabelMode', 'Mode'))}: ${this.escapeHtml(snapshot.modeName)} / ${snapshot.tier}</div>
        <div class="hud-info">${this.escapeHtml(this.hudMessage('hudLabelSource', 'Source'))}: ${snapshot.sourceDimensions.width}x${snapshot.sourceDimensions.height} → ${snapshot.targetDimensions.width}x${snapshot.targetDimensions.height}</div>
        <div class="hud-metrics">
          <span>${this.escapeHtml(this.hudMessage('hudLabelFps', 'FPS'))}: ${this.formatFps(snapshot.fps)}</span>
          <span>${this.escapeHtml(this.hudMessage('hudLabelDrop', 'Drop'))}: ${(snapshot.droppedFrameRate * 100).toFixed(1)}%</span>
          <span>${this.escapeHtml(gpuStatus)}</span>
        </div>
        <div class="hud-section">
          <button class="hud-section-title ${this.renderTimingCollapsed ? 'is-collapsed' : ''}" data-hud-action="toggle-render" type="button">
            <span class="hud-chevron"></span>
            <span>${this.escapeHtml(this.hudMessage('hudLabelRenderTime', 'Render time'))}</span>
          </button>
          ${this.renderTimingCollapsed
            ? ''
            : canShowPassTimings
              ? `
                <div class="hud-stack" title="${this.formatMs(snapshot.frameMs)} / ${this.formatMs(snapshot.budgetMs)}">${bar}</div>
                ${rows}
                <div class="hud-rule"></div>
                <div class="hud-row hud-total">
                  <span></span>
                  <span class="hud-name">${this.escapeHtml(this.hudMessage('hudLabelTotal', 'Total'))}</span>
                  <span class="hud-ms">${this.formatMs(snapshot.frameMs)}</span>
                </div>
              `
              : this.renderGpuDiagnosticsHint(snapshot)}
        </div>
        <span class="hud-resize-grip" data-hud-resize></span>
      </div>
    `;
  }

  private prepareHudRows(entries: PassTimingEntry[]): PassTimingEntry[] {
    if (entries.length <= HUD_MAX_GROUP_ROWS) {
      return entries;
    }

    const visible = entries.slice(0, HUD_MAX_GROUP_ROWS);
    const other = entries.slice(HUD_MAX_GROUP_ROWS).reduce((acc, entry) => ({
      cpuMs: acc.cpuMs + entry.cpuMs,
      gpuMs: acc.gpuMs + (entry.gpuMs ?? 0),
      hasGpu: acc.hasGpu || typeof entry.gpuMs === 'number',
    }), { cpuMs: 0, gpuMs: 0, hasGpu: false });
    return [
      ...visible,
      {
        label: this.hudMessage('hudLabelOther', 'Other'),
        group: this.hudMessage('hudLabelOther', 'Other'),
        cpuMs: other.cpuMs,
        gpuMs: other.hasGpu ? other.gpuMs : undefined,
        source: other.hasGpu ? 'mixed' : 'cpu',
      },
    ];
  }

  private renderGpuDiagnosticsHint(snapshot: FramePerformanceSnapshot): string {
    const message = this.getPassTimingHint(snapshot);

    return `
      <div class="hud-cpu-summary">
        <div class="hud-row hud-summary-row">
          <span></span>
          <span class="hud-name">${this.escapeHtml(this.hudMessage('hudLabelFrameCpu', 'Frame CPU'))}</span>
          <span class="hud-ms">${this.formatMs(snapshot.frameMs)}</span>
        </div>
        <div class="hud-row hud-summary-row">
          <span></span>
          <span class="hud-name">${this.escapeHtml(this.hudMessage('hudLabelUploadCpu', 'Upload CPU'))}</span>
          <span class="hud-ms">${this.formatMs(snapshot.uploadMs)}</span>
        </div>
        <div class="hud-row hud-summary-row">
          <span></span>
          <span class="hud-name">${this.escapeHtml(this.hudMessage('hudLabelEncodeCpu', 'Encode CPU'))}</span>
          <span class="hud-ms">${this.formatMs(snapshot.encodeMs)}</span>
        </div>
        <div class="hud-row hud-summary-row">
          <span></span>
          <span class="hud-name">${this.escapeHtml(this.hudMessage('hudLabelSubmitCpu', 'Submit CPU'))}</span>
          <span class="hud-ms">${this.formatMs(snapshot.submitMs)}</span>
        </div>
      </div>
      <div class="hud-hint">${this.escapeHtml(message)}</div>
    `;
  }

  private nextHudPosition(position: PerformanceMonitorHudPosition): PerformanceMonitorHudPosition {
    switch (position) {
      case 'top-left':
        return 'top-right';
      case 'top-right':
        return 'bottom-right';
      case 'bottom-right':
        return 'bottom-left';
      case 'bottom-left':
      default:
        return 'top-left';
    }
  }

  private formatPerformanceSnapshotText(snapshot: FramePerformanceSnapshot): string {
    const hasGpuPassTimings = snapshot.mode === 'gpu'
      && snapshot.timestampAvailable
      && snapshot.groupEntries.some(entry => typeof entry.gpuMs === 'number');
    const lines = [
      this.hudMessage('hudSnapshotTitle', 'Anime4K Performance Monitor'),
      `${this.hudMessage('hudLabelGpu', 'GPU')}: ${snapshot.gpuName}`,
      `${this.hudMessage('hudLabelUpload', 'Upload')}: ${snapshot.uploadMethod}`,
      `${this.hudMessage('hudLabelMode', 'Mode')}: ${snapshot.modeName} / ${snapshot.tier}`,
      `${this.hudMessage('hudLabelSource', 'Source')}: ${snapshot.sourceDimensions.width}x${snapshot.sourceDimensions.height} -> ${snapshot.targetDimensions.width}x${snapshot.targetDimensions.height}`,
      `${this.hudMessage('hudLabelFps', 'FPS')}: ${this.formatFps(snapshot.fps)}`,
      `${this.hudMessage('hudLabelFrameCpu', 'Frame CPU')}: ${this.formatMs(snapshot.frameMs)}`,
      `${this.hudMessage('hudLabelUploadCpu', 'Upload CPU')}: ${this.formatMs(snapshot.uploadMs)}`,
      `${this.hudMessage('hudLabelEncodeCpu', 'Encode CPU')}: ${this.formatMs(snapshot.encodeMs)}`,
      `${this.hudMessage('hudLabelSubmitCpu', 'Submit CPU')}: ${this.formatMs(snapshot.submitMs)}`,
      `${this.hudMessage('hudLabelDrop', 'Drop')}: ${(snapshot.droppedFrameRate * 100).toFixed(1)}%`,
    ];

    if (!hasGpuPassTimings) {
      lines.push(this.getPassTimingHint(snapshot));
      return lines.join('\n');
    }

    lines.push(
      ...snapshot.groupEntries.map(entry => `${entry.label}: ${this.formatEntryMs(entry)}`),
    );
    return lines.join('\n');
  }

  private formatFps(value: number): string {
    return Number.isFinite(value) ? value.toFixed(1) : '0.0';
  }

  private formatMs(value: number | undefined): string {
    return typeof value === 'number' && Number.isFinite(value) ? `${value.toFixed(2)} ms` : 'n/a';
  }

  private formatEntryMs(entry: PassTimingEntry): string {
    if (typeof entry.gpuMs === 'number') {
      return `${this.formatMs(entry.cpuMs)} / ${this.hudMessage('hudLabelGpu', 'GPU')} ${this.formatMs(entry.gpuMs)}`;
    }

    return this.formatMs(entry.cpuMs);
  }

  private getEntryDisplayMs(entry: PassTimingEntry): number {
    return entry.gpuMs ?? entry.cpuMs;
  }

  private getPassTimingHint(snapshot: FramePerformanceSnapshot): string {
    if (snapshot.mode === 'lite') {
      return this.hudMessage(
        'hudTimingLiteHint',
        'Effect timings require GPU diagnostics. Lite mode only shows overall frame stats.',
      );
    }

    if (!snapshot.timestampAvailable) {
      return this.hudMessage(
        'hudTimingUnavailableHint',
        'GPU timestamp queries are unavailable. Effect timings cannot be measured accurately.',
      );
    }

    return this.hudMessage(
      'hudTimingWaitingHint',
      'Waiting for GPU timestamp samples. Effect timings appear when GPU diagnostics data is available.',
    );
  }

  private hudMessage(key: string, fallback: string, substitutions?: string[]): string {
    const message = chrome.i18n.getMessage(key, substitutions);
    return message || fallback;
  }

  private sumGpuMs(entries: PassTimingEntry[]): number | undefined {
    const values = entries.map(entry => entry.gpuMs).filter((value): value is number => typeof value === 'number');
    return values.length > 0 ? values.reduce((sum, value) => sum + value, 0) : undefined;
  }

  private getHudRenderWidth(): number {
    return this.clampHudWidth(this.performanceHudOptions?.width ?? this.getDefaultHudWidth());
  }

  private getDefaultHudWidth(): number {
    const hostWidth = this.host.clientWidth || this.video.offsetWidth || HUD_DEFAULT_WIDTH;
    if (hostWidth <= 0) {
      return HUD_DEFAULT_WIDTH;
    }

    return Math.min(HUD_DEFAULT_WIDTH, Math.max(HUD_MIN_WIDTH, hostWidth * 0.62));
  }

  private clampHudWidth(width: number): number {
    const hostWidth = this.host.clientWidth || this.video.offsetWidth || window.innerWidth || HUD_MAX_WIDTH;
    const availableWidth = hostWidth > 16 ? hostWidth - 16 : HUD_MAX_WIDTH;
    const maxWidth = Math.min(HUD_MAX_WIDTH, Math.max(160, availableWidth));
    const minWidth = Math.min(HUD_MIN_WIDTH, maxWidth);
    return Math.round(Math.min(maxWidth, Math.max(minWidth, width)));
  }

  private escapeHtml(value: string): string {
    return value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#039;');
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
          logger.debug('Removing orphaned overlay host from body.', host);
          host.remove();
        }
      });
  }

  private static cleanupAdjacentMarkedSiblings(video: HTMLVideoElement, slotId: string): void {
    let sibling = video.previousElementSibling;
    while (sibling && OverlayManager.isMarkedSiblingForSlot(sibling, slotId)) {
      const previousSibling = sibling.previousElementSibling;
      logger.debug('Removing orphaned overlay sibling artifact.', sibling);
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

      .anime4k-performance-hud {
        --hud-primary: #6A0DAD;
        --hud-primary-strong: #7B1FD1;
        --hud-primary-soft: rgba(106, 13, 173, 0.22);
        --hud-surface: rgba(23, 20, 26, 0.92);
        --hud-surface-high: rgba(36, 31, 41, 0.94);
        --hud-outline: rgba(232, 222, 248, 0.18);
        --hud-text: #f4eff7;
        --hud-text-muted: rgba(244, 239, 247, 0.72);
        position: absolute;
        z-index: 2147483647;
        width: min(360px, calc(100% - 16px));
        min-width: min(260px, calc(100% - 16px));
        max-height: calc(100% - 16px);
        overflow: hidden;
        pointer-events: auto;
        color: var(--hud-text);
        background: var(--hud-surface);
        border: 1px solid var(--hud-outline);
        border-radius: 8px;
        box-shadow: 0 8px 24px rgba(0, 0, 0, 0.34);
        font: 13px/1.28 "Segoe UI", system-ui, sans-serif;
        backdrop-filter: blur(10px);
      }

      .anime4k-performance-hud.is-collapsed {
        width: auto;
        min-width: 0;
      }

      .anime4k-performance-hud.top-left {
        top: 8px;
        left: 8px;
      }

      .anime4k-performance-hud.top-right {
        top: 8px;
        right: 8px;
      }

      .anime4k-performance-hud.bottom-left {
        bottom: 8px;
        left: 8px;
      }

      .anime4k-performance-hud.bottom-right {
        right: 8px;
        bottom: 8px;
      }

      .hud-titlebar {
        display: grid;
        grid-template-columns: auto 1fr auto auto;
        align-items: center;
        gap: 6px;
        min-height: 30px;
        padding: 0 7px;
        background:
          linear-gradient(90deg, rgba(106, 13, 173, 0.36), rgba(106, 13, 173, 0.12)),
          var(--hud-surface-high);
        border-bottom: 1px solid var(--hud-outline);
      }

      .hud-title {
        overflow: hidden;
        white-space: nowrap;
        text-overflow: ellipsis;
        font-size: 13px;
        font-weight: 600;
      }

      .hud-icon,
      .hud-mini {
        border: 0;
        color: inherit;
        background: transparent;
        cursor: pointer;
      }

      .hud-icon {
        width: 22px;
        height: 22px;
        padding: 0;
        border-radius: 5px;
        font-size: 15px;
        line-height: 20px;
      }

      .hud-icon:hover,
      .hud-mini:hover {
        background: var(--hud-primary-soft);
      }

      .hud-chevron {
        display: inline-block;
        width: 7px;
        height: 7px;
        border-right: 2px solid currentColor;
        border-bottom: 2px solid currentColor;
        transform: rotate(45deg);
      }

      .hud-collapse-button {
        display: inline-flex;
        align-items: center;
        justify-content: center;
      }

      .hud-body {
        position: relative;
        padding: 8px 10px 11px;
      }

      .hud-info,
      .hud-metrics {
        margin-bottom: 4px;
        color: var(--hud-text);
        font-size: 12px;
      }

      .hud-metrics {
        display: grid;
        grid-template-columns: repeat(3, minmax(0, 1fr));
        gap: 6px;
        color: var(--hud-text-muted);
      }

      .hud-section {
        margin-top: 8px;
      }

      .hud-section-title {
        display: grid;
        grid-template-columns: auto 1fr;
        align-items: center;
        gap: 7px;
        width: 100%;
        margin: 0 0 7px;
        padding: 4px 8px;
        border: 0;
        border-left: 3px solid var(--hud-primary-strong);
        border-radius: 4px;
        color: inherit;
        background: var(--hud-primary-soft);
        cursor: pointer;
        font-size: 12px;
        font-weight: 600;
        font-family: inherit;
        text-align: left;
      }

      .hud-section-title:hover {
        background: rgba(106, 13, 173, 0.32);
      }

      .hud-section-title.is-collapsed .hud-chevron {
        transform: rotate(-45deg);
      }

      .hud-stack {
        display: flex;
        height: 22px;
        margin: 0 0 8px;
        overflow: hidden;
        border-radius: 4px;
        background: rgba(255, 255, 255, 0.09);
      }

      .hud-stack span {
        display: block;
        min-width: 1px;
      }

      .hud-row {
        display: grid;
        grid-template-columns: 12px minmax(0, 1fr) minmax(78px, auto);
        align-items: center;
        gap: 6px;
        min-height: 20px;
        font-size: 12px;
      }

      .hud-swatch {
        width: 10px;
        height: 10px;
        border-radius: 2px;
      }

      .hud-name {
        overflow: hidden;
        white-space: nowrap;
        text-overflow: ellipsis;
      }

      .hud-ms {
        text-align: right;
        font-variant-numeric: tabular-nums;
      }

      .hud-rule {
        height: 1px;
        margin: 6px 0;
        background: var(--hud-outline);
      }

      .hud-total {
        font-size: 12px;
        font-weight: 600;
      }

      .hud-cpu-summary {
        padding: 2px 0 4px;
      }

      .hud-summary-row {
        color: var(--hud-text-muted);
      }

      .hud-hint {
        margin-top: 6px;
        padding: 7px 8px;
        border: 1px solid var(--hud-outline);
        border-radius: 5px;
        color: var(--hud-text-muted);
        background: rgba(255, 255, 255, 0.06);
        font-size: 12px;
        line-height: 1.35;
      }

      .anime4k-performance-hud.is-warn .hud-ms,
      .anime4k-performance-hud.is-warn .hud-mini span:nth-child(2) {
        color: #ffd166;
      }

      .anime4k-performance-hud.is-over .hud-ms,
      .anime4k-performance-hud.is-over .hud-mini span:nth-child(2) {
        color: #ff6b6b;
      }

      .hud-mini {
        display: grid;
        grid-template-columns: repeat(4, max-content);
        gap: 7px;
        width: 100%;
        min-height: 26px;
        padding: 4px 7px;
        border-left: 3px solid var(--hud-primary-strong);
        font: 12px/1.3 "Segoe UI", system-ui, sans-serif;
        font-variant-numeric: tabular-nums;
        text-align: left;
      }

      .hud-resize-grip {
        position: absolute;
        right: 2px;
        bottom: 2px;
        width: 13px;
        height: 13px;
        cursor: nwse-resize;
        opacity: 0.62;
      }

      .hud-resize-grip::before {
        content: "";
        position: absolute;
        right: 2px;
        bottom: 2px;
        width: 8px;
        height: 8px;
        background:
          linear-gradient(135deg, transparent 45%, var(--hud-text-muted) 47%, var(--hud-text-muted) 53%, transparent 55%),
          linear-gradient(135deg, transparent 64%, var(--hud-text-muted) 66%, var(--hud-text-muted) 72%, transparent 74%);
      }
    `;
    this.shadowRoot.appendChild(style);
  }
}
