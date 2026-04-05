/**
 * Anime4K 内置预设模板解析。
 * 具体效果链由 Anime4K backend 提供，避免共享层写死 Anime4K 类名。
 */

import type { BaseMode, PerformanceTier, EnhancementEffect } from '../types';
import { resolvePresetEffects } from '../core/effects/registry';
import { AVAILABLE_EFFECTS } from './effects-map';

export function resolveEffectChain(
  baseMode: BaseMode,
  tier: PerformanceTier,
): EnhancementEffect[] {
  return resolvePresetEffects('anime4k', baseMode, tier);
}

export function getEffectChainSummary(effects: EnhancementEffect[]): string {
  return effects
    .map((effect) => AVAILABLE_EFFECTS.find((descriptor) => descriptor.id === effect.id)?.name ?? effect.id)
    .join(' -> ') || 'No effects';
}
