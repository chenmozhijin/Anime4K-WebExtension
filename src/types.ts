export type PerformanceTier = 'performance' | 'balanced' | 'quality' | 'ultra';
export type PerformanceMonitorMode = 'off' | 'lite' | 'gpu';
export type PerformanceMonitorHudPosition = 'top-left' | 'top-right' | 'bottom-left' | 'bottom-right';
export type PerformanceTimingSource = 'cpu' | 'gpu' | 'mixed' | 'unavailable';

// Anime4K preset ids are kept for backward compatibility with existing built-in modes.
export type Anime4KPresetId = 'A' | 'B' | 'C' | 'A+A' | 'B+B' | 'C+A';

export type EffectCategory = 'restore' | 'upscale' | 'denoise' | 'deblur' | 'helper' | 'resize' | 'custom';

export interface EffectParamSchemaEntry {
  type: 'number' | 'boolean' | 'select';
  label?: string;
  min?: number;
  max?: number;
  step?: number;
  defaultValue?: string | number | boolean;
  options?: Array<{ label: string; value: string | number | boolean }>;
}

export interface DimensionBehavior {
  kind: 'same' | 'scale' | 'target';
  scale?: number;
}

export interface VideoEnhancer {
  destroy: () => void;
  toggleEnhancement: () => Promise<void>;
  getCurrentModeId: () => string | null;
  updateSettings: (settings: Anime4KWebExtSettings) => Promise<void>;
  getVideoElement: () => HTMLVideoElement;
  detach: () => void;
  reattach: (newVideo: HTMLVideoElement) => Promise<void>;
}

export interface WhitelistRule {
  pattern: string;
  enabled: boolean;
}

export interface EffectDescriptor {
  id: string;
  backendId: string;
  key: string;
  name: string;
  category: EffectCategory;
  paramsSchema?: Record<string, EffectParamSchemaEntry>;
  dimensionBehavior: DimensionBehavior;
  supportsVideoRealtime: boolean;
  hidden?: boolean;
  license?: {
    expression: string;
    componentName: string;
    sourceUrl: string;
  };
}

export interface EffectReference {
  id: string;
  backendId: string;
  key: string;
  params?: { [key: string]: any };
}

export type EnhancementEffect = EffectReference;

export interface BuiltInMode {
  id: string;
  baseMode: Anime4KPresetId;
  name: string;
  backendId: string;
  presetKey: string;
  isBuiltIn: true;
}

export interface CustomMode {
  id: string;
  name: string;
  isBuiltIn: false;
  effects: EnhancementEffect[];
}

export type EnhancementMode = BuiltInMode | CustomMode;

export interface GPUBenchmarkResult {
  tier: PerformanceTier;
  scores: Record<PerformanceTier, number>;
  maxScores: Record<PerformanceTier, number>;
  timestamp: number;
  adapterInfo: string;
}

export type BenchmarkRunStatus = 'idle' | 'running' | 'interrupted' | 'completed' | 'failed';
export type BenchmarkFailureReason = 'crash' | 'timeout' | 'device-lost' | 'validation';

export interface BenchmarkRunState {
  status: BenchmarkRunStatus;
  failureReason?: BenchmarkFailureReason;
  fallbackTierApplied?: PerformanceTier | null;
  startedAt?: number;
  endedAt?: number;
}

export interface SyncedSettings {
  selectedModeId: string;
  targetResolutionSetting: string;
  whitelistEnabled: boolean;
  whitelist: WhitelistRule[];
  customModes: CustomMode[];
  enableCrossOriginFix: boolean;
}

export interface LocalSettings {
  performanceTier: PerformanceTier;
  gpuBenchmarkResult: GPUBenchmarkResult | null;
  hasCompletedOnboarding: boolean;
  benchmarkRunState: BenchmarkRunState;
  performanceMonitorMode: PerformanceMonitorMode;
  performanceMonitorHudCollapsed: boolean;
  performanceMonitorHudPosition: PerformanceMonitorHudPosition;
  performanceMonitorHudWidth: number | null;
}

export interface Anime4KWebExtSettings extends SyncedSettings {
  performanceTier: PerformanceTier;
  enhancementModes: EnhancementMode[];
  performanceMonitorMode: PerformanceMonitorMode;
  performanceMonitorHudCollapsed: boolean;
  performanceMonitorHudPosition: PerformanceMonitorHudPosition;
  performanceMonitorHudWidth: number | null;
}

export interface Dimensions {
  width: number;
  height: number;
}

export interface PassTimingEntry {
  label: string;
  group: string;
  cpuMs: number;
  gpuMs?: number;
  source: PerformanceTimingSource;
}

export interface PerformanceMonitorOptions {
  mode: PerformanceMonitorMode;
  hudCollapsed: boolean;
  hudPosition: PerformanceMonitorHudPosition;
}

export interface FramePerformanceSnapshot {
  mode: PerformanceMonitorMode;
  timingSource: PerformanceTimingSource;
  gpuName: string;
  uploadMethod: string;
  modeName: string;
  tier: PerformanceTier;
  sourceDimensions: Dimensions;
  targetDimensions: Dimensions;
  fps: number;
  droppedFrameRate: number;
  frameMs: number;
  uploadMs: number;
  encodeMs: number;
  submitMs: number;
  passEntries: PassTimingEntry[];
  groupEntries: PassTimingEntry[];
  budgetMs: number;
  timestampAvailable: boolean;
}
