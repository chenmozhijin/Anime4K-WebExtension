import { createEffectBackend } from '../../core/effects/backend-factory';
import { acnetBackendId, acnetEffectDescriptors } from './catalog';
import { acnetGeneratedModelLoaders } from './generated/loaders';
import { ACNetGeneratedPipeline } from './pipeline';

export const acnetBackend = createEffectBackend({
  backendId: acnetBackendId,
  backendDisplayName: 'ACNetGLSL',
  descriptors: acnetEffectDescriptors,
  loaders: acnetGeneratedModelLoaders,
  createPipeline(model, context) {
    return ACNetGeneratedPipeline.create({
      device: context.device,
      inputTexture: context.inputTexture,
      nativeDimensions: context.currentDimensions,
      model,
      optimizationFlags: context.optimizationFlags,
      terminalTarget: context.terminalTarget,
      capabilities: context.capabilities,
    });
  },
});
