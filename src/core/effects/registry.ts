import type { EffectDescriptor, EffectReference, PerformanceTier } from '../../types';
import { createEffectReference } from './reference';
import { anime4kEffectDescriptors, resolveAnime4kPreset } from '../../engines/anime4k/catalog';
import { artcnnEffectDescriptors } from '../../engines/artcnn/catalog';
import { coreEffectDescriptors } from '../../engines/core/catalog';

const descriptors = [
  ...anime4kEffectDescriptors,
  ...artcnnEffectDescriptors,
  ...coreEffectDescriptors,
];
const descriptorById = new Map(descriptors.map(descriptor => [descriptor.id, descriptor]));
const descriptorByBackendKey = new Map(descriptors.map(descriptor => [`${descriptor.backendId}:${descriptor.key}`, descriptor]));

export function listEffectDescriptors(includeHidden = false): EffectDescriptor[] {
  return descriptors.filter(descriptor => includeHidden || !descriptor.hidden);
}

export function getEffectDescriptorById(id: string): EffectDescriptor | undefined {
  return descriptorById.get(id);
}

export function getEffectDescriptor(effect: Pick<EffectReference, 'id' | 'backendId' | 'key'>): EffectDescriptor | undefined {
  return descriptorById.get(effect.id) ?? descriptorByBackendKey.get(`${effect.backendId}:${effect.key}`);
}

export function normalizeEffectReference(effect: unknown): EffectReference | null {
  if (!effect || typeof effect !== 'object') {
    return null;
  }

  const candidate = effect as Partial<EffectReference> & { className?: string };
  const descriptor =
    (typeof candidate.id === 'string' ? getEffectDescriptorById(candidate.id) : undefined)
    ?? (typeof candidate.backendId === 'string' && typeof candidate.key === 'string'
      ? descriptorByBackendKey.get(`${candidate.backendId}:${candidate.key}`)
      : undefined)
    ?? (typeof candidate.className === 'string'
      ? descriptorByBackendKey.get(`anime4k:${candidate.className}`)
      : undefined);

  if (!descriptor) {
    return null;
  }

  return createEffectReference(descriptor, candidate.params);
}

export function resolvePresetEffects(backendId: string, modeId: string, tier: PerformanceTier): EffectReference[] {
  switch (backendId) {
    case 'anime4k':
      return resolveAnime4kPreset(modeId, tier);
    default:
      return [];
  }
}

export function validateEffectChain(effects: readonly EffectReference[]): { valid: boolean; errors: string[] } {
  const errors: string[] = [];

  effects.forEach((effect, index) => {
    const descriptor = getEffectDescriptor(effect);
    if (!descriptor) {
      errors.push(`Effect ${index + 1} is not registered.`);
      return;
    }

    if (!descriptor.supportsVideoRealtime) {
      errors.push(`${descriptor.name} does not support realtime video processing.`);
    }
  });

  return {
    valid: errors.length === 0,
    errors,
  };
}
