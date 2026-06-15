import type { Anime4KPresetId, EnhancementEffect, PerformanceTier } from '../../types';
import { resolvePresetEffects } from '../../core/effects/registry';

export function resolveAnime4kPresetEffectChain(
  presetId: Anime4KPresetId,
  tier: PerformanceTier,
): EnhancementEffect[] {
  return resolvePresetEffects('anime4k', presetId, tier);
}
