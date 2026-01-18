// ===== 性能档位类型 =====
type PerformanceTier = 'performance' | 'balanced' | 'quality' | 'ultra';

// ===== 基础模式类型 =====
type BaseMode = 'A' | 'B' | 'C' | 'A+A' | 'B+B' | 'C+A';

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

// 增强效果接口
interface EnhancementEffect {
  id: string;       // 唯一ID, e.g., "anime4k/Upscale/CNNx2VL"
  name: string;     // 显示名称, e.g., "Upscale CNNx2VL"
  className: string; // 用于代码中实例化的类名, e.g., "CNNx2VL"
  params?: { [key: string]: any }; // 未来可用于配置效果参数
  upscaleFactor?: number; // 效果的放大倍数，例如 2 表示 2x 放大
}

// ===== 内置模式接口（效果链由档位决定）=====
interface BuiltInMode {
  id: string;          // 'builtin-mode-a'
  baseMode: BaseMode;  // 'A'
  name: string;        // 'Mode A'
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
  EnhancementMode,
  BuiltInMode,
  CustomMode,
  GPUBenchmarkResult,
};