import type { EffectDescriptor } from '../../types';
import type { EffectSourceMeta } from '../../core/effects/source-meta';
import { cunnyGeneratedModelMetas, type CuNNyGeneratedModelMeta } from './generated/models';

export const cunnyBackendId = 'cunny';

export const cunnyLicense = {
  expression: 'LGPL-3.0-or-later',
  componentName: 'CuNNy',
  sourceUrl: 'https://github.com/funnyplanter/CuNNy',
};

export const cunnyEffectSourceMetas: EffectSourceMeta<CuNNyGeneratedModelMeta>[] = cunnyGeneratedModelMetas.map((model) => {
  const descriptor: EffectDescriptor = {
    id: model.id,
    backendId: cunnyBackendId,
    key: model.key,
    name: `Upscale ${model.name} x2`,
    category: 'upscale',
    dimensionBehavior: { kind: 'scale', scale: 2 },
    supportsVideoRealtime: true,
    license: cunnyLicense,
  };

  return {
    backendId: cunnyBackendId,
    descriptor,
    model,
  };
});

export const cunnyEffectDescriptors: EffectDescriptor[] = cunnyEffectSourceMetas.map(meta => meta.descriptor);
