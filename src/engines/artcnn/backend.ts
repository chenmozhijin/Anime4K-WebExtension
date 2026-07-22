import type { PipelinePass } from '../../core/effects/backend-types';
import { createEffectBackend, createPipelineConstructorLoader } from '../../core/effects/backend-factory';
import { artcnnBackendId, artcnnEffectDescriptors } from './catalog';

type PipelineConstructor = new (options: any) => PipelinePass;
type PipelineModule = Record<string, PipelineConstructor>;
type EffectLoader = () => Promise<PipelineConstructor>;

function createLoader<T extends PipelineModule>(moduleImporter: () => Promise<T>, exportName: keyof T & string): EffectLoader {
  return createPipelineConstructorLoader(moduleImporter, exportName);
}

const loaders: Record<string, EffectLoader> = {
  C4F16: createLoader(
    () => import(/* webpackChunkName: "artcnn-effect-c4f16" */ './pipelines/upscale/C4F16'),
    'ArtCNNC4F16',
  ),
  C4F16_DS: createLoader(
    () => import(/* webpackChunkName: "artcnn-effect-c4f16-ds" */ './pipelines/upscale/C4F16DS'),
    'ArtCNNC4F16DS',
  ),
  C4F16_DN: createLoader(
    () => import(/* webpackChunkName: "artcnn-effect-c4f16-dn" */ './pipelines/upscale/C4F16DN'),
    'ArtCNNC4F16DN',
  ),
  C4F32: createLoader(
    () => import(/* webpackChunkName: "artcnn-effect-c4f32" */ './pipelines/upscale/C4F32'),
    'ArtCNNC4F32',
  ),
  C4F32_DS: createLoader(
    () => import(/* webpackChunkName: "artcnn-effect-c4f32-ds" */ './pipelines/upscale/C4F32DS'),
    'ArtCNNC4F32DS',
  ),
  C4F32_DN: createLoader(
    () => import(/* webpackChunkName: "artcnn-effect-c4f32-dn" */ './pipelines/upscale/C4F32DN'),
    'ArtCNNC4F32DN',
  ),
};

export const artcnnBackend = createEffectBackend({
  backendId: artcnnBackendId,
  backendDisplayName: 'ArtCNN',
  descriptors: artcnnEffectDescriptors,
  loaders,
  createPipeline(PipelineClass, context) {
    return new PipelineClass({
      device: context.device,
      inputTexture: context.inputTexture,
      nativeDimensions: context.currentDimensions,
      targetDimensions: context.targetDimensions,
      optimizationFlags: context.optimizationFlags,
      terminalTarget: context.terminalTarget,
    });
  },
});
