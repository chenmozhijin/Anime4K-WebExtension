import type {
  Dimensions,
  FramePerformanceSnapshot,
  PassTimingEntry,
  PerformanceMonitorMode,
  PerformanceTier,
  PerformanceTimingSource,
} from '../../types';
import type { PipelinePass, PipelineProfileRecorder } from '../effects/backend-types';

const SNAPSHOT_INTERVAL_MS = 500;
const FPS_WINDOW_MS = 1000;
const FRAME_BUDGET_60FPS_MS = 1000 / 60;
const GPU_SAMPLE_INTERVAL_FRAMES = 60;
const GPU_TIMESTAMP_MAX_PASSES = 128;
const GPU_TIMESTAMP_QUERY_COUNT = GPU_TIMESTAMP_MAX_PASSES * 2;
const GPU_TIMESTAMP_BYTE_LENGTH = GPU_TIMESTAMP_QUERY_COUNT * 8;
const GPU_TIMESTAMP_RING_SIZE = 2;

export interface PerformanceProfilerMetadata {
  mode: PerformanceMonitorMode;
  gpuName: string;
  uploadMethod: string;
  modeName: string;
  tier: PerformanceTier;
  sourceDimensions: Dimensions;
  targetDimensions: Dimensions;
  timestampAvailable: boolean;
}

export interface CompleteFrameTimings {
  frameMs: number;
  uploadMs: number;
  encodeMs: number;
  submitMs: number;
}

type DropSample = {
  time: number;
  presented: number;
  dropped: number;
};

type GpuTimestampPass = {
  label: string;
  group: string;
  beginIndex: number;
  endIndex: number;
};

type GpuTimestampSlot = {
  querySet: GPUQuerySet;
  resolveBuffer: GPUBuffer;
  readBuffer: GPUBuffer;
  passes: GpuTimestampPass[];
  queryCount: number;
  pending: boolean;
  active: boolean;
};

type GpuPassTimestampWrites = {
  querySet: GPUQuerySet;
  beginningOfPassWriteIndex?: number;
  endOfPassWriteIndex?: number;
};

export interface PerformanceProfilerGpuOptions {
  device?: GPUDevice;
}

export class PerformanceFrameProfiler implements PipelineProfileRecorder {
  private readonly frameTimes: number[] = [];
  private readonly dropSamples: DropSample[] = [];
  private readonly passEntries: PassTimingEntry[] = [];
  private readonly lastGpuMsByKey = new Map<string, number>();
  private lastSnapshotAt = 0;
  private previousPresentedFrames: number | null = null;
  private metadata: PerformanceProfilerMetadata;
  private device?: GPUDevice;
  private gpuSlots: GpuTimestampSlot[] = [];
  private activeGpuSlot: GpuTimestampSlot | null = null;
  private frameCounter = 0;
  private shouldSampleGpuFrame = false;

  constructor(
    metadata: PerformanceProfilerMetadata,
    private readonly onSnapshot: (snapshot: FramePerformanceSnapshot) => void,
    gpuOptions: PerformanceProfilerGpuOptions = {},
  ) {
    this.metadata = metadata;
    this.device = gpuOptions.device;
    this.configureGpuResources();
  }

  updateMetadata(metadata: PerformanceProfilerMetadata, gpuOptions: PerformanceProfilerGpuOptions = {}): void {
    const deviceChanged = gpuOptions.device !== undefined && gpuOptions.device !== this.device;
    const timestampAvailabilityChanged = metadata.timestampAvailable !== this.metadata.timestampAvailable;
    this.metadata = metadata;
    if (gpuOptions.device !== undefined) {
      this.device = gpuOptions.device;
    }

    if (deviceChanged || timestampAvailabilityChanged) {
      this.configureGpuResources();
    } else if (metadata.timestampAvailable && this.gpuSlots.length === 0) {
      this.configureGpuResources();
    }
  }

  beginFrame(videoFrameMetadata?: VideoFrameCallbackMetadata): void {
    const now = performance.now();
    this.passEntries.length = 0;
    this.activeGpuSlot = null;
    this.gpuSlots.forEach(slot => {
      if (!slot.pending) {
        slot.active = false;
        slot.queryCount = 0;
        slot.passes.length = 0;
      }
    });

    this.frameCounter += 1;
    this.shouldSampleGpuFrame = this.metadata.timestampAvailable
      && this.gpuSlots.length > 0
      && (this.frameCounter === 1 || this.frameCounter % GPU_SAMPLE_INTERVAL_FRAMES === 0);

    this.frameTimes.push(now);
    while (this.frameTimes.length > 0 && now - this.frameTimes[0] > FPS_WINDOW_MS) {
      this.frameTimes.shift();
    }

    const presentedFrames = videoFrameMetadata?.presentedFrames;
    if (typeof presentedFrames === 'number') {
      if (this.previousPresentedFrames !== null) {
        const presented = Math.max(0, presentedFrames - this.previousPresentedFrames);
        const dropped = Math.max(0, presented - 1);
        this.dropSamples.push({ time: now, presented, dropped });
      }
      this.previousPresentedFrames = presentedFrames;
    }

    while (this.dropSamples.length > 0 && now - this.dropSamples[0].time > FPS_WINDOW_MS) {
      this.dropSamples.shift();
    }
  }

  recordPass(pass: PipelinePass, encode: () => void): void {
    this.recordNamedPass(
      pass.profileLabel ?? pass.constructor.name,
      pass.profileGroup ?? pass.profileLabel ?? pass.constructor.name,
      encode,
    );
  }

  recordNamedPass(label: string, group: string, encode: () => void): void {
    const startedAt = performance.now();
    encode();
    const cpuMs = performance.now() - startedAt;
    const gpuMs = this.lastGpuMsByKey.get(this.buildEntryKey(label, group));
    this.passEntries.push({
      label,
      group,
      cpuMs,
      gpuMs,
      source: typeof gpuMs === 'number' ? 'mixed' : 'cpu',
    });
  }

  addInstantEntry(label: string, group: string, cpuMs: number): void {
    this.passEntries.push({
      label,
      group,
      cpuMs,
      source: 'cpu',
    });
  }

  completeFrame(timings: CompleteFrameTimings): void {
    const now = performance.now();
    if (now - this.lastSnapshotAt < SNAPSHOT_INTERVAL_MS) {
      return;
    }

    this.lastSnapshotAt = now;
    const timingSource = this.getSnapshotTimingSource();

    this.onSnapshot({
      mode: this.metadata.mode,
      timingSource,
      gpuName: this.metadata.gpuName,
      uploadMethod: this.metadata.uploadMethod,
      modeName: this.metadata.modeName,
      tier: this.metadata.tier,
      sourceDimensions: { ...this.metadata.sourceDimensions },
      targetDimensions: { ...this.metadata.targetDimensions },
      fps: this.getFps(),
      droppedFrameRate: this.getDroppedFrameRate(),
      frameMs: timings.frameMs,
      uploadMs: timings.uploadMs,
      encodeMs: timings.encodeMs,
      submitMs: timings.submitMs,
      passEntries: this.passEntries.slice(),
      groupEntries: this.buildGroupEntries(),
      budgetMs: FRAME_BUDGET_60FPS_MS,
      timestampAvailable: this.metadata.timestampAvailable,
    });
  }

  createComputePassDescriptor(pass: PipelinePass): GPUComputePassDescriptor | undefined {
    const timestampWrites = this.allocateTimestampWrites(pass);
    return timestampWrites ? { timestampWrites } : undefined;
  }

  createRenderPassDescriptor(pass: PipelinePass, descriptor: GPURenderPassDescriptor): GPURenderPassDescriptor {
    const timestampWrites = this.allocateTimestampWrites(pass);
    return timestampWrites ? { ...descriptor, timestampWrites } : descriptor;
  }

  resolveGpuQueries(encoder: GPUCommandEncoder): void {
    const slot = this.activeGpuSlot;
    if (!slot || slot.queryCount === 0) {
      return;
    }

    encoder.resolveQuerySet(slot.querySet, 0, slot.queryCount, slot.resolveBuffer, 0);
    encoder.copyBufferToBuffer(slot.resolveBuffer, 0, slot.readBuffer, 0, slot.queryCount * 8);
  }

  collectGpuResultsAsync(): void {
    const slot = this.activeGpuSlot;
    this.activeGpuSlot = null;
    if (!slot || slot.queryCount === 0 || slot.pending) {
      return;
    }

    const byteLength = slot.queryCount * 8;
    const passes = slot.passes.slice();
    slot.pending = true;
    void slot.readBuffer.mapAsync(GPUMapMode.READ, 0, byteLength)
      .then(() => {
        const mapped = slot.readBuffer.getMappedRange(0, byteLength);
        const copy = mapped.slice(0);
        slot.readBuffer.unmap();
        this.applyGpuTimestampResults(copy, passes);
      })
      .catch(() => {
        this.disableGpuTimestamps();
      })
      .finally(() => {
        slot.pending = false;
        slot.active = false;
        slot.queryCount = 0;
        slot.passes.length = 0;
      });
  }

  destroy(): void {
    this.disableGpuTimestamps();
  }

  private getFps(): number {
    if (this.frameTimes.length < 2) {
      return this.frameTimes.length;
    }

    const first = this.frameTimes[0];
    const last = this.frameTimes[this.frameTimes.length - 1];
    const duration = Math.max(1, last - first);
    return ((this.frameTimes.length - 1) * 1000) / duration;
  }

  private getDroppedFrameRate(): number {
    const totals = this.dropSamples.reduce((acc, sample) => ({
      presented: acc.presented + sample.presented,
      dropped: acc.dropped + sample.dropped,
    }), { presented: 0, dropped: 0 });

    return totals.presented > 0 ? totals.dropped / totals.presented : 0;
  }

  private buildGroupEntries(): PassTimingEntry[] {
    const byGroup = new Map<string, PassTimingEntry>();
    for (const entry of this.passEntries) {
      const existing = byGroup.get(entry.group);
      if (!existing) {
        byGroup.set(entry.group, {
          label: entry.group,
          group: entry.group,
          cpuMs: entry.cpuMs,
          gpuMs: entry.gpuMs,
          source: entry.source,
        });
        continue;
      }

      existing.cpuMs += entry.cpuMs;
      if (typeof entry.gpuMs === 'number') {
        existing.gpuMs = (existing.gpuMs ?? 0) + entry.gpuMs;
      }
      existing.source = typeof existing.gpuMs === 'number' ? 'mixed' : existing.source;
    }

    return [...byGroup.values()];
  }

  private getSnapshotTimingSource(): PerformanceTimingSource {
    if (this.metadata.mode === 'gpu' && !this.metadata.timestampAvailable) {
      return 'unavailable';
    }

    return this.passEntries.some(entry => typeof entry.gpuMs === 'number') ? 'mixed' : 'cpu';
  }

  private allocateTimestampWrites(pass: PipelinePass): GpuPassTimestampWrites | undefined {
    if (!this.shouldSampleGpuFrame || !this.metadata.timestampAvailable) {
      return undefined;
    }

    const slot = this.getActiveGpuSlot();
    if (!slot || slot.queryCount + 2 > GPU_TIMESTAMP_QUERY_COUNT) {
      return undefined;
    }

    const label = pass.profileLabel ?? pass.constructor.name;
    const group = pass.profileGroup ?? label;
    const beginIndex = slot.queryCount;
    const endIndex = slot.queryCount + 1;
    slot.queryCount += 2;
    slot.passes.push({ label, group, beginIndex, endIndex });

    return {
      querySet: slot.querySet,
      beginningOfPassWriteIndex: beginIndex,
      endOfPassWriteIndex: endIndex,
    };
  }

  private getActiveGpuSlot(): GpuTimestampSlot | null {
    if (this.activeGpuSlot) {
      return this.activeGpuSlot;
    }

    const slot = this.gpuSlots.find(candidate => !candidate.pending && !candidate.active) ?? null;
    if (!slot) {
      this.shouldSampleGpuFrame = false;
      return null;
    }

    slot.active = true;
    slot.queryCount = 0;
    slot.passes.length = 0;
    this.activeGpuSlot = slot;
    return slot;
  }

  private configureGpuResources(): void {
    this.destroyGpuResources();
    this.lastGpuMsByKey.clear();
    this.activeGpuSlot = null;
    this.shouldSampleGpuFrame = false;

    if (!this.metadata.timestampAvailable || !this.device) {
      return;
    }

    try {
      this.gpuSlots = Array.from({ length: GPU_TIMESTAMP_RING_SIZE }, () => ({
        querySet: this.device!.createQuerySet({
          type: 'timestamp',
          count: GPU_TIMESTAMP_QUERY_COUNT,
        }),
        resolveBuffer: this.device!.createBuffer({
          size: GPU_TIMESTAMP_BYTE_LENGTH,
          usage: GPUBufferUsage.QUERY_RESOLVE | GPUBufferUsage.COPY_SRC,
        }),
        readBuffer: this.device!.createBuffer({
          size: GPU_TIMESTAMP_BYTE_LENGTH,
          usage: GPUBufferUsage.COPY_DST | GPUBufferUsage.MAP_READ,
        }),
        passes: [],
        queryCount: 0,
        pending: false,
        active: false,
      }));
    } catch {
      this.disableGpuTimestamps();
    }
  }

  private destroyGpuResources(): void {
    for (const slot of this.gpuSlots) {
      try {
        slot.querySet.destroy();
      } catch {
        // Ignore profiling teardown failures.
      }
      try {
        slot.resolveBuffer.destroy();
      } catch {
        // Ignore profiling teardown failures.
      }
      try {
        slot.readBuffer.destroy();
      } catch {
        // Ignore profiling teardown failures.
      }
    }
    this.gpuSlots = [];
  }

  private disableGpuTimestamps(): void {
    this.destroyGpuResources();
    this.activeGpuSlot = null;
    this.shouldSampleGpuFrame = false;
    this.lastGpuMsByKey.clear();
    this.metadata = {
      ...this.metadata,
      timestampAvailable: false,
    };
  }

  private applyGpuTimestampResults(buffer: ArrayBuffer, passes: GpuTimestampPass[]): void {
    const view = new DataView(buffer);
    for (const pass of passes) {
      const begin = view.getBigUint64(pass.beginIndex * 8, true);
      const end = view.getBigUint64(pass.endIndex * 8, true);
      if (end < begin) {
        continue;
      }

      const gpuMs = Number(end - begin) / 1_000_000;
      if (Number.isFinite(gpuMs)) {
        this.lastGpuMsByKey.set(this.buildEntryKey(pass.label, pass.group), gpuMs);
      }
    }
  }

  private buildEntryKey(label: string, group: string): string {
    return `${group}\u0000${label}`;
  }
}
