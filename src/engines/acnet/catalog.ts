import type { EffectDescriptor } from '../../types';
import type { EffectSourceMeta } from '../../core/effects/source-meta';
import { acnetGeneratedModelMetas, type ACNetGeneratedModelMeta } from './generated/models';

export const acnetBackendId = 'acnet';

export const acnetEffectSourceMetas: EffectSourceMeta<ACNetGeneratedModelMeta>[] = acnetGeneratedModelMetas.map((model) => {
  const descriptor: EffectDescriptor = {
    id: model.id,
    backendId: acnetBackendId,
    key: model.key,
    name: `Upscale ${model.name} x2`,
    category: 'upscale',
    dimensionBehavior: { kind: 'scale', scale: 2 },
    supportsVideoRealtime: true,
  };

  return {
    backendId: acnetBackendId,
    descriptor,
    model,
  };
});

export const acnetEffectDescriptors: EffectDescriptor[] = acnetEffectSourceMetas.map(meta => meta.descriptor);
