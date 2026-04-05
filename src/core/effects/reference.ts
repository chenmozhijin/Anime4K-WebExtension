import type { EffectDescriptor, EffectReference } from '../../types';

export function createEffectReference(descriptor: EffectDescriptor, params?: EffectReference['params']): EffectReference {
  return {
    id: descriptor.id,
    backendId: descriptor.backendId,
    key: descriptor.key,
    params: params && Object.keys(params).length > 0 ? params : undefined,
  };
}
