// 定义视频增强器接口
interface VideoEnhancer {
  destroy: () => void;
  toggleEnhancement: () => Promise<void>;
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

// 定义设置接口
interface Anime4KWebExtSettings {
  selectedModeName: string;
  targetResolutionSetting: string;
  whitelistEnabled: boolean;
  whitelist: WhitelistRule[];
}

// 定义尺寸接口
interface Dimensions {
  width: number;
  height: number;
}

// 导出接口供其他模块使用
export { VideoEnhancer, Anime4KWebExtSettings, Dimensions, WhitelistRule };