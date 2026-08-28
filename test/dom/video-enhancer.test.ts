import { beforeEach, describe, expect, it, vi } from 'vitest';
import { installChromeMock } from '../support/chrome';
import { NIJILUCID_APPLIED_ATTR } from '../../src/constants';

const state = vi.hoisted(() => {
  const currentSettings = {
    selectedModeId: 'builtin-mode-a',
    enableCrossOriginFix: false,
  } as any;
  const rendererInstance = {
    destroy: vi.fn(),
    updateConfiguration: vi.fn(),
    updateVideoSource: vi.fn(),
    handleSourceResize: vi.fn(),
    updatePerformanceMonitor: vi.fn(),
  };
  const rendererCreate = vi.fn();
  const shouldAttemptCrossOriginRecovery = vi.fn();
  const attemptCrossOriginRecovery = vi.fn();
  const resolveRendererState = vi.fn();
  const getAppliedRendererStateChanges = vi.fn();
  const overlayInstances: any[] = [];
  const geometryInstances: any[] = [];
  const notifierInstances: any[] = [];
  let rendererOptions: any = null;

  class MockGeometryController {
    public readonly attach = vi.fn();
    public readonly detach = vi.fn();
    public readonly clearPending = vi.fn();
    public readonly bindVideo = vi.fn((newVideo: HTMLVideoElement) => this.video = newVideo);
    public readonly queue = vi.fn(async (settings: any, reason: string) => {
      return this.options.processUpdate(settings, reason);
    });

    constructor(
      private video: HTMLVideoElement,
      private readonly options: {
        getCurrentSettings: () => any;
        shouldHandleVideoChange: () => boolean;
        processUpdate: (settings: any, reason: string) => Promise<void>;
      },
    ) {
      geometryInstances.push(this);
    }
  }

  class MockNotifier {
    public readonly clear = vi.fn();
    public readonly present = vi.fn();

    constructor() {
      notifierInstances.push(this);
    }
  }

  return {
    currentSettings,
    rendererInstance,
    rendererCreate,
    shouldAttemptCrossOriginRecovery,
    attemptCrossOriginRecovery,
    resolveRendererState,
    getAppliedRendererStateChanges,
    overlayInstances,
    geometryInstances,
    notifierInstances,
    MockGeometryController,
    MockNotifier,
    get rendererOptions() {
      return rendererOptions;
    },
    set rendererOptions(value: any) {
      rendererOptions = value;
    },
  };
});

vi.mock('../../src/utils/settings-snapshot', () => ({
  getSettingsSnapshot: () => ({ settings: state.currentSettings }),
}));

vi.mock('../../src/core/renderer', () => ({
  Renderer: {
    create: state.rendererCreate,
  },
}));

vi.mock('../../src/core/overlay-manager', () => ({
  OverlayManager: {
    create: vi.fn(() => {
      const button = document.createElement('button');
      const canvas = document.createElement('canvas');
      const overlay = {
        getButton: () => button,
        getCanvas: vi.fn(() => canvas),
        showCanvas: vi.fn(),
        hideCanvas: vi.fn(),
        showPerformanceHud: vi.fn(),
        hidePerformanceHud: vi.fn(),
        updateLayout: vi.fn(),
        detach: vi.fn(),
        reattach: vi.fn(),
        destroy: vi.fn(),
      };
      state.overlayInstances.push(overlay);
      return overlay;
    }),
  },
}));

vi.mock('../../src/core/video-enhancer/geometry-controller', () => ({
  VideoEnhancerGeometryController: state.MockGeometryController,
}));

vi.mock('../../src/core/video-enhancer/error-notifier', () => ({
  EnhancerErrorNotifier: state.MockNotifier,
}));

vi.mock('../../src/core/video-enhancer/cross-origin-recovery', () => ({
  shouldAttemptCrossOriginRecovery: state.shouldAttemptCrossOriginRecovery,
  attemptCrossOriginRecovery: state.attemptCrossOriginRecovery,
}));

vi.mock('../../src/core/video-enhancer/render-state', () => ({
  resolveRendererState: state.resolveRendererState,
  buildAppliedRendererState: vi.fn((_settings, modeId, sourceDimensions, targetDimensions, effectsSignature) => ({
    modeId,
    sourceDimensions,
    targetDimensions,
    effectsSignature,
  })),
  getAppliedRendererStateChanges: state.getAppliedRendererStateChanges,
}));

import { VideoEnhancer } from '../../src/core/video-enhancer';

function createVideo(options: {
  readyState?: number;
  width?: number;
  height?: number;
  src?: string;
} = {}): HTMLVideoElement {
  const video = document.createElement('video');
  Object.defineProperties(video, {
    HAVE_METADATA: {
      configurable: true,
      value: 1,
    },
    readyState: {
      configurable: true,
      writable: true,
      value: options.readyState ?? 1,
    },
    videoWidth: {
      configurable: true,
      writable: true,
      value: options.width ?? 320,
    },
    videoHeight: {
      configurable: true,
      writable: true,
      value: options.height ?? 180,
    },
  });
  video.src = options.src ?? 'https://example.com/video.mp4';
  return video;
}

describe('VideoEnhancer', () => {
  beforeEach(() => {
    installChromeMock();
    Object.defineProperty(navigator, 'gpu', {
      configurable: true,
      writable: true,
      value: {},
    });
    state.overlayInstances.length = 0;
    state.geometryInstances.length = 0;
    state.notifierInstances.length = 0;
    state.rendererOptions = null;
    state.currentSettings.selectedModeId = 'builtin-mode-a';
    state.currentSettings.enableCrossOriginFix = false;
    state.currentSettings.performanceMonitorMode = 'off';
    state.currentSettings.performanceTier = 'balanced';
    state.rendererInstance.destroy.mockReset();
    state.rendererInstance.updateConfiguration.mockReset();
    state.rendererInstance.updateVideoSource.mockReset();
    state.rendererInstance.handleSourceResize.mockReset();
    state.rendererInstance.updatePerformanceMonitor.mockReset().mockReturnValue(true);
    state.rendererCreate.mockReset().mockImplementation(async (options: any) => {
      state.rendererOptions = options;
      return state.rendererInstance;
    });
    state.shouldAttemptCrossOriginRecovery.mockReset().mockReturnValue(false);
    state.attemptCrossOriginRecovery.mockReset().mockResolvedValue({ status: 'skipped' });
    state.resolveRendererState.mockReset().mockReturnValue({
      selectedMode: { id: 'builtin-mode-a', name: 'Mode A' },
      effects: [{ id: 'anime4k/CNNM', backendId: 'anime4k', key: 'CNNM' }],
      effectsSignature: 'signature-a',
      targetDimensions: { width: 1280, height: 720 },
    });
    state.getAppliedRendererStateChanges.mockReset().mockReturnValue({
      sourceChanged: false,
      targetChanged: false,
      effectsChanged: false,
      modeChanged: false,
      tierChanged: false,
      resolutionChanged: false,
    });
  });

  it('enables enhancement, shows the overlay on first frame, and disables cleanly', async () => {
    state.currentSettings.enableCrossOriginFix = true;
    state.shouldAttemptCrossOriginRecovery.mockReturnValue(true);
    state.attemptCrossOriginRecovery.mockResolvedValue({ status: 'recovered' });
    const video = createVideo();
    const enhancer = VideoEnhancer.create(video);

    await enhancer.toggleEnhancement();

    const overlay = state.overlayInstances[0];
    const geometry = state.geometryInstances[0];
    expect(state.attemptCrossOriginRecovery).toHaveBeenCalledTimes(1);
    expect(state.rendererCreate).toHaveBeenCalledTimes(1);
    expect(overlay.getCanvas).toHaveBeenCalledTimes(1);
    expect(overlay.updateLayout).toHaveBeenCalledTimes(1);
    expect(geometry.attach).toHaveBeenCalledTimes(1);
    expect(video.getAttribute(NIJILUCID_APPLIED_ATTR)).toBe('true');
    expect(enhancer.getCurrentModeId()).toBe('builtin-mode-a');
    expect(enhancer.getVideoElement()).toBe(video);

    state.rendererOptions.onProgress('warming-up');
    expect(overlay.getButton().innerText).toBe('warming-up');
    state.rendererOptions.onFirstFrameRendered();
    expect(overlay.showCanvas).toHaveBeenCalledTimes(1);

    await enhancer.toggleEnhancement();

    expect(geometry.detach).toHaveBeenCalledTimes(1);
    expect(state.rendererInstance.destroy).toHaveBeenCalledTimes(1);
    expect(overlay.hideCanvas).toHaveBeenCalledTimes(1);
    expect(video.hasAttribute(NIJILUCID_APPLIED_ATTR)).toBe(false);
    expect(enhancer.getCurrentModeId()).toBeNull();
  });

  it('waits for metadata and retries once after fallback cross-origin recovery', async () => {
    const securityError = new Error('Canvas has been tainted by cross-origin data.');
    securityError.name = 'SecurityError';
    const video = createVideo({ readyState: 0, src: 'https://cdn.example.com/video.mp4' });
    const enhancer = VideoEnhancer.create(video);

    state.currentSettings.enableCrossOriginFix = true;
    state.rendererCreate
      .mockRejectedValueOnce(securityError)
      .mockImplementationOnce(async (options: any) => {
        state.rendererOptions = options;
        return state.rendererInstance;
      });
    state.attemptCrossOriginRecovery.mockResolvedValue({ status: 'recovered' });

    const togglePromise = enhancer.toggleEnhancement();
    await Promise.resolve();
    expect(state.overlayInstances[0].getButton().innerText).toBe('waitingVideoLoad');

    Object.defineProperty(video, 'readyState', {
      configurable: true,
      writable: true,
      value: 1,
    });
    video.dispatchEvent(new Event('loadedmetadata'));
    await togglePromise;

    expect(state.rendererCreate).toHaveBeenCalledTimes(2);
    expect(state.attemptCrossOriginRecovery).toHaveBeenCalledTimes(1);
    expect(video.getAttribute(NIJILUCID_APPLIED_ATTR)).toBe('true');
  });

  it('cancels a pending metadata wait when the enhancer is destroyed', async () => {
    const video = createVideo({ readyState: 0, width: 0, height: 0 });
    const enhancer = VideoEnhancer.create(video);

    const togglePromise = enhancer.toggleEnhancement();
    await Promise.resolve();

    enhancer.destroy();
    await expect(togglePromise).resolves.toBeUndefined();

    expect(state.rendererCreate).not.toHaveBeenCalled();
    expect(state.notifierInstances[0].present).not.toHaveBeenCalled();
  });

  it('routes source-only updates to handleSourceResize and full changes to updateConfiguration', async () => {
    const video = createVideo();
    const enhancer = VideoEnhancer.create(video);

    await enhancer.toggleEnhancement();

    state.getAppliedRendererStateChanges
      .mockReturnValueOnce({
        sourceChanged: true,
        targetChanged: false,
        effectsChanged: false,
        modeChanged: false,
        tierChanged: false,
        resolutionChanged: false,
      })
      .mockReturnValueOnce({
        sourceChanged: false,
        targetChanged: true,
        effectsChanged: true,
        modeChanged: false,
        tierChanged: false,
        resolutionChanged: false,
      });

    await enhancer.updateSettings(state.currentSettings);
    await enhancer.updateSettings(state.currentSettings);

    expect(state.rendererInstance.handleSourceResize).toHaveBeenCalledTimes(1);
    expect(state.rendererInstance.updateConfiguration).toHaveBeenCalledTimes(1);
  });

  it('updates the performance monitor in place when switching from Lite to GPU diagnostics', async () => {
    state.currentSettings.performanceMonitorMode = 'lite';
    const enhancer = VideoEnhancer.create(createVideo());
    await enhancer.toggleEnhancement();

    state.rendererInstance.destroy.mockClear();
    state.rendererInstance.updatePerformanceMonitor.mockClear();
    state.currentSettings.performanceMonitorMode = 'gpu';

    await enhancer.updateSettings(state.currentSettings);

    expect(state.rendererCreate).toHaveBeenCalledTimes(1);
    expect(state.rendererInstance.destroy).not.toHaveBeenCalled();
    expect(state.rendererInstance.updatePerformanceMonitor).toHaveBeenCalledWith(expect.objectContaining({
      mode: 'gpu',
    }));
  });

  it('surfaces runtime/update errors and tears down enhancement state', async () => {
    const video = createVideo();
    const enhancer = VideoEnhancer.create(video);
    await enhancer.toggleEnhancement();

    const overlay = state.overlayInstances[0];
    const notifier = state.notifierInstances[0];
    const geometry = state.geometryInstances[0];

    geometry.queue.mockRejectedValueOnce(new Error('update failed'));
    await expect(enhancer.updateSettings(state.currentSettings)).rejects.toThrow('update failed');
    expect(notifier.present).toHaveBeenCalledWith(expect.any(Error), 'update', {
      enableCrossOriginFix: false,
    });
    expect(state.rendererInstance.destroy).toHaveBeenCalledTimes(1);
    expect(overlay.hideCanvas).toHaveBeenCalledTimes(1);

    state.rendererOptions.onError(new Error('render failed'));
    await Promise.resolve();
    expect(notifier.present).toHaveBeenCalledWith(expect.any(Error), 'render', {
      enableCrossOriginFix: false,
    });
  });

  it('reattaches to new videos and destroys itself idempotently', async () => {
    const video = createVideo();
    const newVideo = createVideo({ width: 640, height: 360 });
    const enhancer = VideoEnhancer.create(video);

    await enhancer.toggleEnhancement();
    state.getAppliedRendererStateChanges.mockReturnValue({
      sourceChanged: false,
      targetChanged: false,
      effectsChanged: false,
      modeChanged: false,
      tierChanged: false,
      resolutionChanged: false,
    });

    enhancer.detach();
    await enhancer.reattach(newVideo);

    const overlay = state.overlayInstances[0];
    const geometry = state.geometryInstances[0];
    const notifier = state.notifierInstances[0];

    expect(overlay.detach).toHaveBeenCalledTimes(1);
    expect(overlay.reattach).toHaveBeenCalledWith(newVideo);
    expect(geometry.bindVideo).toHaveBeenCalledWith(newVideo);
    expect(state.rendererInstance.updateVideoSource).toHaveBeenCalledWith(newVideo);
    expect(newVideo.getAttribute(NIJILUCID_APPLIED_ATTR)).toBe('true');

    enhancer.destroy();
    enhancer.destroy();

    expect(geometry.clearPending).toHaveBeenCalledTimes(1);
    expect(notifier.clear).toHaveBeenCalledTimes(1);
    expect(overlay.destroy).toHaveBeenCalledTimes(1);
  });
});
