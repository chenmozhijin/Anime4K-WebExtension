import { createEffectBackend } from '../../core/effects/backend-factory';
import { cunnyBackendId, cunnyEffectDescriptors } from './catalog';
import { cunnyGeneratedModelLoaders } from './generated/loaders';
import { CuNNyGeneratedPipeline } from './pipeline';

export const cunnyBackend = createEffectBackend({
  backendId: cunnyBackendId,
  backendDisplayName: 'CuNNy',
  descriptors: cunnyEffectDescriptors,
  loaders: cunnyGeneratedModelLoaders,
  createPipeline(model, context) {
    return new CuNNyGeneratedPipeline({
      device: context.device,
      inputTexture: context.inputTexture,
      nativeDimensions: context.currentDimensions,
      model,
    });
  },
});
