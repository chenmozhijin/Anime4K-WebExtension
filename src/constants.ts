/**
 * 增强模式常量
 * 定义可用的Anime4K增强模式及其标识符
 */
export const MODES = {
  ModeA: 'ModeA',
  ModeB: 'ModeB',
  ModeC: 'ModeC',
  ModeAA: 'ModeAA',
  ModeBB: 'ModeBB',
  ModeCA: 'ModeCA',
} as const;

/**
 * 分辨率设置常量
 * 定义所有可用的分辨率选项及其标识符
 */
export const RESOLUTIONS = {
  DEFAULT: 'x2',    // 默认分辨率设置
  x2: 'x2',         // 2倍放大
  x4: 'x4',         // 4倍放大
  x8: 'x8',         // 8倍放大
  '720p': '720p',   // 720p固定分辨率
  '1080p': '1080p', // 1080p固定分辨率
  '2k': '2k',       // 2K分辨率
  '4k': '4k',       // 4K分辨率
  native: 'native'  // 原始分辨率
} as const;

/**
 * 初始化属性标识
 * 用于标记已初始化的视频元素
 */
export const ANIME4K_APPLIED_ATTR = 'data-anime4k-applied';

/**
 * 按钮类名
 * 用于标识增强按钮的CSS类名
 */
export const ANIME4K_BUTTON_CLASS = 'anime4k-button';