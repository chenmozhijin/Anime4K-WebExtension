import type { AlgorithmBackend } from '../../core/effects/backend-types';
import { createEffectReference } from '../../core/effects/reference';
import { Downscale } from '../../core/shared-effects/downscale';
import {
  coreBackendId,
  coreEffectDescriptors,
  resizeToTargetDescriptor,
} from './catalog';

export const coreBackend: AlgorithmBackend = {
  backendId: coreBackendId,
  listEffects() {
    return coreEffectDescriptors;
  },
  resolvePreset() {
    return [];
  },
  async compileEffect(effect, context) {
    switch (effect.key) {
      case 'resize-to-target':
      case 'resize-linear-internal': {
        const pipeline = new Downscale({
          device: context.device,
          inputTexture: context.inputTexture,
          targetDimensions: context.targetDimensions,
          name: effect.key,
        });
        return {
          pipelines: [pipeline],
          outputTexture: pipeline.getOutputTexture(),
          outputDimensions: { ...context.targetDimensions },
          requiredModules: [`${coreBackendId}:${effect.key}`],
          warmupSteps: 1,
        };
      }
      default:
        throw new Error(`Unsupported core effect: ${effect.key}`);
    }
  },
  getBenchmarkProfiles() {
    return [
      {
        id: 'core-resize-target',
        name: 'Resize To Target',
        effects: [createEffectReference(resizeToTargetDescriptor)],
      },
    ];
  },
};
