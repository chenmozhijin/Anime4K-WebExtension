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

// 增强模式接口
interface EnhancementMode {
  id: string; // 唯一ID, e.g., "builtin-mode-a" or "custom-1687300000"
  name: string;
  isBuiltIn: boolean;
  effects: EnhancementEffect[];
}

// 定义设置接口
interface Anime4KWebExtSettings {
  selectedModeId: string;
  targetResolutionSetting: string;
  whitelistEnabled: boolean;
  whitelist: WhitelistRule[];
  enhancementModes: EnhancementMode[];
  enableCrossOriginFix: boolean;
}

// 定义尺寸接口
interface Dimensions {
  width: number;
  height: number;
}

// 导出接口供其他模块使用
export { VideoEnhancer, Anime4KWebExtSettings, Dimensions, WhitelistRule, EnhancementEffect, EnhancementMode };