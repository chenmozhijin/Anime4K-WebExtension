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
const GPU_SAMPLE_INTERVAL_MS = 1000;
const DEFAULT_GPU_TIMESTAMP_PASS_CAPACITY = 128;
// Two slots allow one sampled frame to map asynchronously while rendering continues.
// Do not replace this ring with per-frame onSubmittedWorkDone() synchronization.
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
  groupId: string;
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
  passCapacity?: number;
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
  private currentFrameStartedAt = 0;
  private lastGpuSampleAt = Number.NEGATIVE_INFINITY;
  private gpuResourceGeneration = 0;
  private shouldSampleGpuFrame = false;
  private shouldCollectCpuPassEntries = false;
  private gpuPassCapacity = DEFAULT_GPU_TIMESTAMP_PASS_CAPACITY;

  constructor(
    metadata: PerformanceProfilerMetadata,
    private readonly onSnapshot: (snapshot: FramePerformanceSnapshot) => void,
    gpuOptions: PerformanceProfilerGpuOptions = {},
  ) {
    this.metadata = metadata;
    this.device = gpuOptions.device;
    this.gpuPassCapacity = this.normalizePassCapacity(gpuOptions.passCapacity);
    this.configureGpuResources();
  }

  updateMetadata(metadata: PerformanceProfilerMetadata, gpuOptions: PerformanceProfilerGpuOptions = {}): void {
    const deviceChanged = gpuOptions.device !== undefined && gpuOptions.device !== this.device;
    const timestampAvailabilityChanged = metadata.timestampAvailable !== this.metadata.timestampAvailable;
    const nextPassCapacity = this.normalizePassCapacity(gpuOptions.passCapacity ?? this.gpuPassCapacity);
    const passCapacityChanged = nextPassCapacity !== this.gpuPassCapacity;
    this.metadata = metadata;
    if (gpuOptions.device !== undefined) {
      this.device = gpuOptions.device;
    }
    this.gpuPassCapacity = nextPassCapacity;

    if (deviceChanged || timestampAvailabilityChanged || passCapacityChanged) {
      this.configureGpuResources();
    } else if (metadata.timestampAvailable && this.gpuSlots.length === 0) {
      this.configureGpuResources();
    }
  }

  beginFrame(videoFrameMetadata?: VideoFrameCallbackMetadata): void {
    const now = performance.now();
    this.currentFrameStartedAt = now;
    this.passEntries.length = 0;
    // This decision also controls completeFrame(). Do not re-check the interval at
    // frame end: a frame crossing the 500 ms boundary would publish empty pass rows.
    // Per-pass CPU timing remains limited to actual HUD snapshot frames.
    this.shouldCollectCpuPassEntries = now - this.lastSnapshotAt >= SNAPSHOT_INTERVAL_MS;
    this.activeGpuSlot = null;
    this.gpuSlots.forEach(slot => {
      if (!slot.pending) {
        slot.active = false;
        slot.queryCount = 0;
        slot.passes.length = 0;
      }
    });

    // Use wall-clock cadence rather than decoded-frame count. Anime commonly runs at
    // 23.976/24 fps, where a 60-frame interval would leave GPU data stale for 2.5 s.
    this.shouldSampleGpuFrame = this.metadata.timestampAvailable
      && this.gpuSlots.length > 0
      && now - this.lastGpuSampleAt >= GPU_SAMPLE_INTERVAL_MS;

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
    const label = pass.profileLabel ?? pass.constructor.name;
    const group = pass.profileGroup ?? label;
    this.recordNamedPass(
      label,
      group,
      encode,
      pass.profileGroupId ?? group,
    );
  }

  recordNamedPass(label: string, group: string, encode: () => void, groupId?: string): void {
    if (!this.shouldCollectCpuPassEntries) {
      encode();
      return;
    }

    const resolvedGroupId = groupId ?? group;
    const startedAt = performance.now();
    encode();
    const cpuMs = performance.now() - startedAt;
    const gpuMs = this.lastGpuMsByKey.get(this.buildEntryKey(label, resolvedGroupId));
    this.passEntries.push({
      label,
      group,
      groupId: resolvedGroupId,
      cpuMs,
      gpuMs,
      source: typeof gpuMs === 'number' ? 'mixed' : 'cpu',
    });
  }

  addInstantEntry(label: string, group: string, cpuMs: number, groupId?: string): void {
    if (!this.shouldCollectCpuPassEntries) {
      return;
    }
    const resolvedGroupId = groupId ?? group;
    this.passEntries.push({
      label,
      group,
      groupId: resolvedGroupId,
      cpuMs,
      source: 'cpu',
    });
  }

  completeFrame(timings: CompleteFrameTimings): void {
    // beginFrame() locks this flag before pass encoding, so every emitted snapshot
    // contains the pass entries collected for that same frame.
    if (!this.shouldCollectCpuPassEntries) {
      return;
    }

    const now = performance.now();
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
    const resourceGeneration = this.gpuResourceGeneration;
    slot.pending = true;
    void slot.readBuffer.mapAsync(GPUMapMode.READ, 0, byteLength)
      .then(() => {
        // A resize or plan-capacity change may replace all timestamp resources while
        // this map is pending. Old callbacks must never update or disable the new ring.
        if (resourceGeneration !== this.gpuResourceGeneration || !this.gpuSlots.includes(slot)) {
          try {
            slot.readBuffer.unmap();
          } catch {
            // The retired buffer may already have been destroyed.
          }
          return;
        }
        const mapped = slot.readBuffer.getMappedRange(0, byteLength);
        const copy = mapped.slice(0);
        slot.readBuffer.unmap();
        this.applyGpuTimestampResults(copy, passes);
      })
      .catch(() => {
        if (resourceGeneration === this.gpuResourceGeneration && this.gpuSlots.includes(slot)) {
          this.disableGpuTimestamps();
        }
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
      const groupId = entry.groupId ?? entry.group;
      const existing = byGroup.get(groupId);
      if (!existing) {
        byGroup.set(groupId, {
          label: entry.group,
          group: entry.group,
          groupId,
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
    if (!slot || slot.queryCount + 2 > this.gpuPassCapacity * 2) {
      // Capacity is supplied from the compiled plan. If the plan changes mid-frame,
      // skip excess pass timings rather than writing outside the query set.
      return undefined;
    }

    const label = pass.profileLabel ?? pass.constructor.name;
    const group = pass.profileGroup ?? label;
    const groupId = pass.profileGroupId ?? group;
    const beginIndex = slot.queryCount;
    const endIndex = slot.queryCount + 1;
    slot.queryCount += 2;
    slot.passes.push({ label, group, groupId, beginIndex, endIndex });

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
    // Advance the cadence only after the first pass has secured a real slot. Frames
    // skipped before encoding, or frames blocked by pending maps, retry immediately.
    this.lastGpuSampleAt = this.currentFrameStartedAt;
    return slot;
  }

  private configureGpuResources(): void {
    this.destroyGpuResources();
    this.lastGpuMsByKey.clear();
    this.activeGpuSlot = null;
    this.lastGpuSampleAt = Number.NEGATIVE_INFINITY;
    this.shouldSampleGpuFrame = false;

    if (!this.metadata.timestampAvailable || !this.device) {
      return;
    }

    try {
      // Two timestamps are required per flattened pass. The previous fixed 128-pass
      // allocation truncated large A+A/ARNet plans, so this follows compiled capacity.
      const queryCount = this.gpuPassCapacity * 2;
      const byteLength = queryCount * 8;
      this.gpuSlots = Array.from({ length: GPU_TIMESTAMP_RING_SIZE }, () => ({
        querySet: this.device!.createQuerySet({
          type: 'timestamp',
          count: queryCount,
        }),
        resolveBuffer: this.device!.createBuffer({
          size: byteLength,
          usage: GPUBufferUsage.QUERY_RESOLVE | GPUBufferUsage.COPY_SRC,
        }),
        readBuffer: this.device!.createBuffer({
          size: byteLength,
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
    // Invalidate pending map callbacks before retiring their buffers. Without this
    // generation boundary, an old rejection can disable freshly-created resources.
    this.gpuResourceGeneration += 1;
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
        this.lastGpuMsByKey.set(this.buildEntryKey(pass.label, pass.groupId), gpuMs);
      }
    }
  }

  private buildEntryKey(label: string, groupId: string): string {
    return `${groupId}\u0000${label}`;
  }

  private normalizePassCapacity(value: number | undefined): number {
    if (value === undefined || !Number.isFinite(value)) {
      return DEFAULT_GPU_TIMESTAMP_PASS_CAPACITY;
    }
    return Math.max(1, Math.ceil(value));
  }
}
