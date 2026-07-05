import { describe, expect, it, vi } from 'vitest';
import { PerformanceFrameProfiler } from '../../src/core/performance-monitor/profiler';
import type { FramePerformanceSnapshot } from '../../src/types';

describe('PerformanceFrameProfiler', () => {
  it('keeps group entries in render application order instead of sorting by time', () => {
    const onSnapshot = vi.fn<(snapshot: FramePerformanceSnapshot) => void>();
    const profiler = new PerformanceFrameProfiler({
      mode: 'lite',
      gpuName: 'Mock GPU',
      uploadMethod: 'VideoFrame direct',
      modeName: 'Mode A',
      tier: 'balanced',
      sourceDimensions: { width: 1280, height: 720 },
      targetDimensions: { width: 2560, height: 1440 },
      timestampAvailable: false,
    }, onSnapshot);

    (profiler as unknown as { lastSnapshotAt: number }).lastSnapshotAt = -1000;
    profiler.beginFrame({ presentedFrames: 1 } as VideoFrameCallbackMetadata);
    profiler.addInstantEntry('Upload', 'Upload', 0.2);
    profiler.recordNamedPass('effect-b pass 1', 'Effect B', () => undefined);
    profiler.addInstantEntry('effect-a pass 1', 'Effect A', 20);
    profiler.addInstantEntry('effect-b pass 2', 'Effect B', 3);
    profiler.recordNamedPass('Final Blit', 'Final Blit', () => undefined);
    profiler.completeFrame({
      frameMs: 16,
      uploadMs: 0.2,
      encodeMs: 2,
      submitMs: 0.1,
    });

    expect(onSnapshot).toHaveBeenCalledOnce();
    expect(onSnapshot.mock.calls[0][0].groupEntries.map(entry => entry.label)).toEqual([
      'Upload',
      'Effect B',
      'Effect A',
      'Final Blit',
    ]);
  });
});
