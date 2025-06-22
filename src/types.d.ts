// 定义视频增强器接口
interface VideoEnhancer {
  destroy: () => void;
  toggleEnhancement: () => Promise<void>;
  getCurrentModeId: () => string | null;
  updateSettings: (settings: Anime4KWebExtSettings) => Promise<void>;
}

// 扩展HTMLVideoElement接口
declare global {
  interface HTMLVideoElement {
    _anime4kEnhancer?: VideoEnhancer;
  }
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
}

// 定义尺寸接口
interface Dimensions {
  width: number;
  height: number;
}

import type { ModeA, ModeB, ModeC, ModeAA, ModeBB, ModeCA } from 'anime4k-webgpu';
import type { MODES } from './constants';

// 从 MODES 常量中提取模式名称的类型
export type Anime4KMode = keyof typeof MODES;

// 定义模式类构造函数的通用接口
// 这允许我们引用类本身作为类型
export interface Anime4KClass {
  new (...args: any[]): any;
}

// 定义模式类映射的类型
// 它将模式名称（如 'ModeA'）映射到对应的类类型
export type ModeClasses = {
  [K in Anime4KMode]: Anime4KClass;
} & {
  // 更具体地定义我们已知的模式，以获得更好的类型提示
  ModeA: typeof ModeA;
  ModeB: typeof ModeB;
  ModeC: typeof ModeC;
  ModeAA: typeof ModeAA;
  ModeBB: typeof ModeBB;
  ModeCA: typeof ModeCA;
};

// 导出接口供其他模块使用
export { VideoEnhancer, Anime4KWebExtSettings, Dimensions, WhitelistRule, EnhancementEffect, EnhancementMode };