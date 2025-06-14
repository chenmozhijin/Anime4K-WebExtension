import { ModeA, ModeB, ModeC, ModeAA, ModeBB, ModeCA } from 'anime4k-webgpu';

// 将所有需要的类打包到一个对象中
const Anime4KModule = {
  ModeA,
  ModeB,
  ModeC,
  ModeAA,
  ModeBB,
  ModeCA,
};

// 派发一个自定义事件，将模块的导出内容放在 detail 属性中
// 等待此模块的脚本可以监听这个事件来接收模块
document.dispatchEvent(new CustomEvent('anime4k-module-loaded', { detail: Anime4KModule }));

// 确保此文件被 TypeScript 编译器视为一个模块
export {};