import { beforeEach, describe, expect, it, vi } from 'vitest';
import { VideoEnhancerGeometryController } from '../../src/core/video-enhancer/geometry-controller';

class MockVideo extends EventTarget {}

describe('VideoEnhancerGeometryController', () => {
  const settings = { selectedModeId: 'builtin-mode-a' } as any;

  beforeEach(() => {
    vi.restoreAllMocks();
  });

  it('coalesces queued updates while one is in flight', async () => {
    const video = new MockVideo() as HTMLVideoElement;
    let releaseFirst!: () => void;
    const firstUpdate = new Promise<void>(resolve => {
      releaseFirst = resolve;
    });
    const processUpdate = vi
      .fn<(_: any, __: string) => Promise<void>>()
      .mockImplementationOnce(async () => {
        await firstUpdate;
      })
      .mockResolvedValue(undefined);

    const controller = new VideoEnhancerGeometryController(video, {
      getCurrentSettings: () => settings,
      shouldHandleVideoChange: () => true,
      processUpdate,
    });

    const firstPromise = controller.queue(settings, 'first');
    const secondPromise = controller.queue(settings, 'second');
    controller.queue(settings, 'third');
    releaseFirst();

    await Promise.all([firstPromise, secondPromise]);

    expect(processUpdate.mock.calls).toEqual([
      [settings, 'first'],
      [settings, 'third'],
    ]);
  });

  it('binds video events, reacts to geometry changes, and detaches from both videos', async () => {
    const firstVideo = new MockVideo() as HTMLVideoElement;
    const secondVideo = new MockVideo() as HTMLVideoElement;
    const processUpdate = vi.fn().mockResolvedValue(undefined);
    const controller = new VideoEnhancerGeometryController(firstVideo, {
      getCurrentSettings: () => settings,
      shouldHandleVideoChange: () => true,
      processUpdate,
    });

    controller.attach();
    firstVideo.dispatchEvent(new Event('resize'));
    await Promise.resolve();

    const previousVideo = controller.bindVideo(secondVideo);
    controller.attach();
    secondVideo.dispatchEvent(new Event('loadedmetadata'));
    await Promise.resolve();

    controller.detach();
    secondVideo.dispatchEvent(new Event('resize'));
    await Promise.resolve();

    expect(previousVideo).toBe(firstVideo);
    expect(processUpdate.mock.calls).toEqual([
      [settings, 'video geometry change'],
      [settings, 'video geometry change'],
    ]);
  });
});
