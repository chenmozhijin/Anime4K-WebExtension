import { EnhancementEffect } from '../types';

/**
 * 所有可用的增强效果清单。
 * 这是系统中所有效果的唯一“真相来源”。
 * id: 唯一标识符，用于存储和识别。
 * name: 显示在UI上的用户友好名称。
 * className: 对应于 `anime4k-webgpu` 库中导出的类名，用于动态实例化。
 */
export const AVAILABLE_EFFECTS: EnhancementEffect[] = [
  // Deblur Effects
  {
    id: 'anime4k/Deblur/DoG',
    name: 'Deblur (DoG)',
    className: 'DoG',
    // params: { strength: 4 } // 示例：未来可支持参数配置
  },

  // Denoise Effects
  {
    id: 'anime4k/Denoise/BilateralMean',
    name: 'Denoise (Bilateral Mean)',
    className: 'BilateralMean',
  },

  // Restore Effects
  {
    id: 'anime4k/Restore/CNNM',
    name: 'Restore CNN (M)',
    className: 'CNNM',
  },
  {
    id: 'anime4k/Restore/CNNSoftM',
    name: 'Restore CNN Soft (M)',
    className: 'CNNSoftM',
  },
  {
    id: 'anime4k/Restore/CNNSoftVL',
    name: 'Restore CNN Soft (VL)',
    className: 'CNNSoftVL',
  },
  {
    id: 'anime4k/Restore/CNNVL',
    name: 'Restore CNN (VL)',
    className: 'CNNVL',
  },
  {
    id: 'anime4k/Restore/CNNUL',
    name: 'Restore CNN (UL)',
    className: 'CNNUL',
  },
  {
    id: 'anime4k/Restore/GANUUL',
    name: 'Restore GAN (UUL)',
    className: 'GANUUL',
  },

  // Upscale Effects
  {
    id: 'anime4k/Upscale/CNNx2M',
    name: 'Upscale CNN x2 (M)',
    className: 'CNNx2M',
    upscaleFactor: 2,
  },
  {
    id: 'anime4k/Upscale/CNNx2VL',
    name: 'Upscale CNN x2 (VL)',
    className: 'CNNx2VL',
    upscaleFactor: 2,
  },
  {
    id: 'anime4k/Upscale/DenoiseCNNx2VL',
    name: 'Upscale & Denoise CNN x2 (VL)',
    className: 'DenoiseCNNx2VL',
    upscaleFactor: 2,
  },
  {
    id: 'anime4k/Upscale/CNNx2UL',
    name: 'Upscale CNN x2 (UL)',
    className: 'CNNx2UL',
    upscaleFactor: 2,
  },
  {
    id: 'anime4k/Upscale/GANx3L',
    name: 'Upscale GAN x3 (L)',
    className: 'GANx3L',
    upscaleFactor: 3,
  },
  {
    id: 'anime4k/Upscale/GANx4UUL',
    name: 'Upscale GAN x4 (UUL)',
    className: 'GANx4UUL',
    upscaleFactor: 4,
  },

  // Helper Effects
  // 注意：`Downscale` 将由扩展根据分辨率自动处理，不作为用户可选效果。
  // `ClampHighlights` 可由用户选择。
  {
    id: 'anime4k/Helper/ClampHighlights',
    name: 'Helper: Clamp Highlights',
    className: 'ClampHighlights',
  },
];