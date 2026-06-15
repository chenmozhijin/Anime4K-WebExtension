import type { EnhancementEffect } from '../../../types';
import { listEffectDescriptors } from '../../../core/effects/registry';

export function getEffectChainSummary(effects: EnhancementEffect[]): string {
  const availableEffects = listEffectDescriptors(false);
  return effects
    .map(effect => availableEffects.find(descriptor => descriptor.id === effect.id)?.name ?? effect.id)
    .join(' -> ') || 'No effects';
}
