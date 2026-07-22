import { describe, expect, it, vi } from 'vitest';
import { PerformanceFrameProfiler } from '../../src/core/performance-monitor/profiler';
import type { FramePerformanceSnapshot } from '../../src/types';
import { createWebGpuMock } from '../support/webgpu';

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

  it('sizes timestamp query storage from the compiled pass capacity', () => {
    const webgpu = createWebGpuMock();
    const device = webgpu.device as unknown as GPUDevice;
    const createQuerySet = vi.spyOn(device, 'createQuerySet');

    const profiler = new PerformanceFrameProfiler({
      mode: 'gpu',
      gpuName: 'Mock GPU',
      uploadMethod: 'VideoFrame direct',
      modeName: 'Mode A',
      tier: 'ultra',
      sourceDimensions: { width: 1920, height: 1080 },
      targetDimensions: { width: 3840, height: 2160 },
      timestampAvailable: true,
    }, vi.fn(), {
      device,
      passCapacity: 154,
    });

    expect(createQuerySet).toHaveBeenCalledTimes(2);
    expect(createQuerySet).toHaveBeenCalledWith({ type: 'timestamp', count: 308 });
    profiler.destroy();
  });

  it('does not allocate per-pass CPU entries between snapshot frames', () => {
    const profiler = new PerformanceFrameProfiler({
      mode: 'lite',
      gpuName: 'Mock GPU',
      uploadMethod: 'VideoFrame direct',
      modeName: 'Mode A',
      tier: 'balanced',
      sourceDimensions: { width: 1280, height: 720 },
      targetDimensions: { width: 2560, height: 1440 },
      timestampAvailable: false,
    }, vi.fn());
    const internals = profiler as unknown as { lastSnapshotAt: number; passEntries: unknown[] };
    const encode = vi.fn();

    internals.lastSnapshotAt = performance.now();
    profiler.beginFrame();
    profiler.recordNamedPass('pass', 'group', encode);

    expect(encode).toHaveBeenCalledOnce();
    expect(internals.passEntries).toHaveLength(0);
  });

  it('does not publish an empty snapshot when a frame crosses the refresh boundary', () => {
    let now = 1499;
    const nowSpy = vi.spyOn(performance, 'now').mockImplementation(() => now);
    const onSnapshot = vi.fn<(snapshot: FramePerformanceSnapshot) => void>();
    const profiler = new PerformanceFrameProfiler({
      mode: 'gpu',
      gpuName: 'Mock GPU',
      uploadMethod: 'VideoFrame direct',
      modeName: 'Mode A',
      tier: 'balanced',
      sourceDimensions: { width: 1280, height: 720 },
      targetDimensions: { width: 2560, height: 1440 },
      timestampAvailable: true,
    }, onSnapshot);
    const internals = profiler as unknown as {
      lastSnapshotAt: number;
      lastGpuMsByKey: Map<string, number>;
    };
    internals.lastSnapshotAt = 1000;
    internals.lastGpuMsByKey.set('Effect A\u0000pass', 1.25);

    profiler.beginFrame();
    profiler.recordNamedPass('pass', 'Effect A', () => undefined);
    now = 1501;
    profiler.completeFrame({ frameMs: 2, uploadMs: 0.1, encodeMs: 1, submitMs: 0.1 });

    expect(onSnapshot).not.toHaveBeenCalled();

    now = 1502;
    profiler.beginFrame();
    profiler.recordNamedPass('pass', 'Effect A', () => undefined);
    profiler.completeFrame({ frameMs: 2, uploadMs: 0.1, encodeMs: 1, submitMs: 0.1 });

    expect(onSnapshot).toHaveBeenCalledOnce();
    expect(onSnapshot.mock.calls[0][0]).toMatchObject({
      timingSource: 'mixed',
      groupEntries: [{ label: 'Effect A', gpuMs: 1.25 }],
    });
    nowSpy.mockRestore();
  });

  it('samples GPU timestamps by elapsed time at 24 fps', () => {
    let now = 0;
    const nowSpy = vi.spyOn(performance, 'now').mockImplementation(() => now);
    const webgpu = createWebGpuMock();
    const profiler = new PerformanceFrameProfiler({
      mode: 'gpu',
      gpuName: 'Mock GPU',
      uploadMethod: 'VideoFrame direct',
      modeName: 'Mode A',
      tier: 'balanced',
      sourceDimensions: { width: 1280, height: 720 },
      targetDimensions: { width: 2560, height: 1440 },
      timestampAvailable: true,
    }, vi.fn(), {
      device: webgpu.device as unknown as GPUDevice,
      passCapacity: 1,
    });
    const pass = {
      profileLabel: 'pass',
      profileGroup: 'Effect A',
      pass: () => undefined,
      getOutputTexture: () => ({} as GPUTexture),
    };

    profiler.beginFrame();
    expect(profiler.createComputePassDescriptor(pass)).toBeDefined();

    for (let frame = 1; frame < 24; frame += 1) {
      now = frame * (1000 / 24);
      profiler.beginFrame();
      expect(profiler.createComputePassDescriptor(pass)).toBeUndefined();
    }

    now = 1000;
    profiler.beginFrame();
    expect(profiler.createComputePassDescriptor(pass)).toBeDefined();

    profiler.destroy();
    nowSpy.mockRestore();
  });

  it('ignores a retired timestamp map failure after resources are rebuilt', async () => {
    const webgpu = createWebGpuMock();
    const device = webgpu.device as unknown as GPUDevice;
    const createBuffer = device.createBuffer.bind(device);
    let rejectRetiredMap: (error: Error) => void = () => undefined;
    let interceptedReadBuffer = false;
    vi.spyOn(device, 'createBuffer').mockImplementation(descriptor => {
      const buffer = createBuffer(descriptor);
      if (!interceptedReadBuffer && (descriptor.usage & GPUBufferUsage.MAP_READ) !== 0) {
        interceptedReadBuffer = true;
        vi.spyOn(buffer, 'mapAsync').mockImplementation(() => new Promise<undefined>((_resolve, reject) => {
          rejectRetiredMap = reject;
        }));
      }
      return buffer;
    });
    const metadata = {
      mode: 'gpu' as const,
      gpuName: 'Mock GPU',
      uploadMethod: 'VideoFrame direct',
      modeName: 'Mode A',
      tier: 'balanced' as const,
      sourceDimensions: { width: 1280, height: 720 },
      targetDimensions: { width: 2560, height: 1440 },
      timestampAvailable: true,
    };
    const profiler = new PerformanceFrameProfiler(metadata, vi.fn(), {
      device,
      passCapacity: 1,
    });
    const pass = {
      profileLabel: 'pass',
      profileGroup: 'Effect A',
      pass: () => undefined,
      getOutputTexture: () => ({} as GPUTexture),
    };

    profiler.beginFrame();
    expect(profiler.createComputePassDescriptor(pass)).toBeDefined();
    const encoder = device.createCommandEncoder();
    profiler.resolveGpuQueries(encoder);
    device.queue.submit([encoder.finish()]);
    profiler.collectGpuResultsAsync();

    profiler.updateMetadata(metadata, { device, passCapacity: 2 });
    rejectRetiredMap(new Error('retired map failed'));
    await Promise.resolve();
    await Promise.resolve();

    const internals = profiler as unknown as {
      metadata: { timestampAvailable: boolean };
      gpuSlots: unknown[];
    };
    expect(internals.metadata.timestampAvailable).toBe(true);
    expect(internals.gpuSlots).toHaveLength(2);
    profiler.beginFrame();
    expect(profiler.createComputePassDescriptor(pass)).toBeDefined();

    profiler.destroy();
  });
});
