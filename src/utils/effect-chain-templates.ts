/**
 * 效果链模板
 * 根据 Anime4K 官方模式定义：
 * - Mode A: Restore -> Upscale (优化高模糊/压缩伪影)
 * - Mode B: Restore_Soft -> Upscale (优化下采样振铃/低模糊)
 * - Mode C: Upscale_Denoise -> Upscale (无退化图像/壁纸)
 */

import type { BaseMode, PerformanceTier, EnhancementEffect } from '../types';
import { AVAILABLE_EFFECTS } from './effects-map';

/**
 * 效果链模板定义
 * baseMode × performanceTier → className[]
 */
const EFFECT_CHAIN_TEMPLATES: Record<BaseMode, Record<PerformanceTier, string[]>> = {
    'A': {
        performance: ['ClampHighlights', 'CNNM', 'CNNx2M', 'CNNx2M'],
        balanced: ['ClampHighlights', 'CNNVL', 'CNNx2VL', 'CNNx2M'],
        quality: ['ClampHighlights', 'CNNUL', 'CNNx2UL', 'CNNx2VL'],
        ultra: ['ClampHighlights', 'CNNUL', 'CNNx2UL', 'CNNx2UL'],
    },
    'B': {
        performance: ['ClampHighlights', 'CNNSoftM', 'CNNx2M', 'CNNx2M'],
        balanced: ['ClampHighlights', 'CNNSoftVL', 'CNNx2VL', 'CNNx2M'],
        quality: ['ClampHighlights', 'CNNSoftVL', 'CNNx2UL', 'CNNx2VL'],  // CNNSoftUL 不存在，使用 CNNSoftVL
        ultra: ['ClampHighlights', 'CNNSoftVL', 'CNNx2UL', 'CNNx2UL'],    // CNNSoftUL 不存在，使用 CNNSoftVL
    },
    'C': {
        performance: ['ClampHighlights', 'DenoiseCNNx2VL', 'CNNx2M'],
        balanced: ['ClampHighlights', 'DenoiseCNNx2VL', 'CNNx2M'],
        quality: ['ClampHighlights', 'DenoiseCNNx2VL', 'CNNx2VL'],  // DenoiseCNNx2UL 不存在，使用 DenoiseCNNx2VL
        ultra: ['ClampHighlights', 'DenoiseCNNx2VL', 'CNNx2UL'],    // DenoiseCNNx2UL 不存在，使用 DenoiseCNNx2VL
    },
    'A+A': {
        performance: ['ClampHighlights', 'CNNM', 'CNNx2M', 'CNNM', 'CNNx2M'],
        balanced: ['ClampHighlights', 'CNNVL', 'CNNx2VL', 'CNNVL', 'CNNx2M'],
        quality: ['ClampHighlights', 'CNNUL', 'CNNx2UL', 'CNNUL', 'CNNx2VL'],
        ultra: ['ClampHighlights', 'CNNUL', 'CNNx2UL', 'CNNUL', 'CNNx2UL', 'CNNUL', 'CNNx2VL'],
    },
    'B+B': {
        performance: ['ClampHighlights', 'CNNSoftM', 'CNNx2M', 'CNNSoftM', 'CNNx2M'],
        balanced: ['ClampHighlights', 'CNNSoftVL', 'CNNx2VL', 'CNNSoftVL', 'CNNx2M'],
        quality: ['ClampHighlights', 'CNNSoftVL', 'CNNx2UL', 'CNNSoftVL', 'CNNx2VL'],  // CNNSoftUL 不存在
        ultra: ['ClampHighlights', 'CNNSoftVL', 'CNNx2UL', 'CNNSoftVL', 'CNNx2UL'],    // CNNSoftUL 不存在
    },
    'C+A': {
        performance: ['ClampHighlights', 'DenoiseCNNx2VL', 'CNNM', 'CNNx2M'],
        balanced: ['ClampHighlights', 'DenoiseCNNx2VL', 'CNNVL', 'CNNx2M'],
        quality: ['ClampHighlights', 'DenoiseCNNx2VL', 'CNNUL', 'CNNx2VL'],  // DenoiseCNNx2UL 不存在
        ultra: ['ClampHighlights', 'DenoiseCNNx2VL', 'CNNUL', 'CNNx2UL'],    // DenoiseCNNx2UL 不存在
    },
};

/**
 * 根据基础模式和性能档位解析效果链
 * @param baseMode 基础模式 (A, B, C, A+A, B+B, C+A)
 * @param tier 性能档位 (performance, balanced, quality, ultra)
 * @returns 效果数组
 */
export function resolveEffectChain(
    baseMode: BaseMode,
    tier: PerformanceTier
): EnhancementEffect[] {
    const classNames = EFFECT_CHAIN_TEMPLATES[baseMode][tier];
    return classNames
        .map(className => AVAILABLE_EFFECTS.find(e => e.className === className))
        .filter((e): e is EnhancementEffect => !!e);
}

/**
 * 获取效果链的简短描述
 */
export function getEffectChainSummary(effects: EnhancementEffect[]): string {
    return effects.map(e => e.name.split('(')[0].trim()).join(' → ') || 'No effects';
}
