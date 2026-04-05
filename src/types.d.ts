// ===== 性能档位类型 =====
type PerformanceTier = 'performance' | 'balanced' | 'quality' | 'ultra';

// ===== 基础模式类型 =====
type BaseMode = 'A' | 'B' | 'C' | 'A+A' | 'B+B' | 'C+A';

type EffectCategory = 'restore' | 'upscale' | 'denoise' | 'deblur' | 'helper' | 'resize' | 'custom';

interface EffectParamSchemaEntry {
  type: 'number' | 'boolean' | 'select';
  label?: string;
  min?: number;
  max?: number;
  step?: number;
  defaultValue?: string | number | boolean;
  options?: Array<{ label: string; value: string | number | boolean }>;
}

interface DimensionBehavior {
  kind: 'same' | 'scale' | 'target';
  scale?: number;
}

// 定义视频增强器接口
interface VideoEnhancer {
  destroy: () => void;
  toggleEnhancement: () => Promise<void>;
  getCurrentModeId: () => string | null;
  updateSettings: (settings: Anime4KWebExtSettings) => Promise<void>;
  getVideoElement: () => HTMLVideoElement;
  detach: () => void;
  reattach: (newVideo: HTMLVideoElement) => Promise<void>;
}

// 白名单规则接口
interface WhitelistRule {
  pattern: string;
  enabled: boolean;
}

// 可发现的效果描述
interface EffectDescriptor {
  id: string;
  backendId: string;
  key: string;
  name: string;
  category: EffectCategory;
  paramsSchema?: Record<string, EffectParamSchemaEntry>;
  dimensionBehavior: DimensionBehavior;
  supportsVideoRealtime: boolean;
  hidden?: boolean;
}

// 存储在模式中的效果引用
interface EffectReference {
  id: string;
  backendId: string;
  key: string;
  params?: { [key: string]: any };
}

// 为兼容现有代码保留别名
type EnhancementEffect = EffectReference;

// ===== 内置模式接口（效果链由档位决定）=====
interface BuiltInMode {
  id: string;          // 'builtin-mode-a'
  baseMode: BaseMode;  // 'A'
  name: string;        // 'Mode A'
  backendId: string;
  presetKey: string;
  isBuiltIn: true;
}

// ===== 自定义模式接口（效果链完全用户控制）=====
interface CustomMode {
  id: string;
  name: string;
  isBuiltIn: false;
  effects: EnhancementEffect[];
}

// 统一的增强模式类型
type EnhancementMode = BuiltInMode | CustomMode;

// ===== GPU 测试结果接口 =====
interface GPUBenchmarkResult {
  tier: PerformanceTier;
  scores: Record<PerformanceTier, number>;       // 各档位平均帧时间 (ms)
  maxScores: Record<PerformanceTier, number>;    // 各档位最大帧时间 (ms)
  timestamp: number;
  adapterInfo: string;
}

type BenchmarkRunStatus = 'idle' | 'running' | 'interrupted' | 'completed' | 'failed';
type BenchmarkFailureReason = 'crash' | 'timeout' | 'device-lost' | 'validation';

interface BenchmarkRunState {
  status: BenchmarkRunStatus;
  failureReason?: BenchmarkFailureReason;
  fallbackTierApplied?: PerformanceTier | null;
  startedAt?: number;
  endedAt?: number;
}

// ===== 跨设备同步的设置 (storage.sync) =====
interface SyncedSettings {
  selectedModeId: string;
  targetResolutionSetting: string;
  whitelistEnabled: boolean;
  whitelist: WhitelistRule[];
  customModes: CustomMode[];
  enableCrossOriginFix: boolean;
}

// ===== 仅本地存储的设置 (storage.local) =====
interface LocalSettings {
  performanceTier: PerformanceTier;
  gpuBenchmarkResult: GPUBenchmarkResult | null;
  hasCompletedOnboarding: boolean;
  benchmarkRunState: BenchmarkRunState;
}

// ===== 运行时合并的完整设置 =====
interface Anime4KWebExtSettings extends SyncedSettings {
  performanceTier: PerformanceTier;
  // 内置模式会在运行时动态生成并与 customModes 合并
  enhancementModes: EnhancementMode[];
}

// 定义尺寸接口
interface Dimensions {
  width: number;
  height: number;
}

// 导出接口供其他模块使用
export {
  PerformanceTier,
  BaseMode,
  VideoEnhancer,
  Anime4KWebExtSettings,
  SyncedSettings,
  LocalSettings,
  Dimensions,
  WhitelistRule,
  EnhancementEffect,
  EffectReference,
  EffectDescriptor,
  EffectCategory,
  EffectParamSchemaEntry,
  DimensionBehavior,
  EnhancementMode,
  BuiltInMode,
  CustomMode,
  GPUBenchmarkResult,
  BenchmarkRunState,
  BenchmarkRunStatus,
  BenchmarkFailureReason,
};

declare global {
  var __ANIME4K_DISABLE_AUTO_BOOTSTRAP__: boolean | undefined;
}
