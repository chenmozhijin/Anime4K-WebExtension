import type { PipelinePass } from '../../core/effects/backend-types';
import { createEffectBackend, createPipelineConstructorLoader } from '../../core/effects/backend-factory';
import { anime4kBackendId, anime4kEffectDescriptors, resolveAnime4kPreset } from './catalog';

type PipelineConstructor = new (options: any) => PipelinePass;
type PipelineModule = Record<string, PipelineConstructor>;
type EffectLoader = () => Promise<PipelineConstructor>;

function createLoader<T extends PipelineModule>(moduleImporter: () => Promise<T>, exportName: keyof T & string): EffectLoader {
  return createPipelineConstructorLoader(moduleImporter, exportName);
}

const loaders: Record<string, EffectLoader> = {
  BilateralMean: createLoader(
    () => import(/* webpackChunkName: "anime4k-effect-bilateral-mean" */ './pipelines/denoise/BilateralMean'),
    'BilateralMean',
  ),
  ClampHighlights: createLoader(
    () => import(/* webpackChunkName: "anime4k-effect-clamp-highlights" */ './pipelines/helpers/ClampHighlights'),
    'ClampHighlights',
  ),
  CNNM: createLoader(
    () => import(/* webpackChunkName: "anime4k-effect-cnnm" */ './pipelines/restore/CNNM'),
    'CNNM',
  ),
  CNNS: createLoader(
    () => import(/* webpackChunkName: "anime4k-effect-cnns" */ './pipelines/restore/CNNS'),
    'CNNS',
  ),
  CNNL: createLoader(
    () => import(/* webpackChunkName: "anime4k-effect-cnnl" */ './pipelines/restore/CNNL'),
    'CNNL',
  ),
  CNNSoftM: createLoader(
    () => import(/* webpackChunkName: "anime4k-effect-cnnsoftm" */ './pipelines/restore/CNNSoftM'),
    'CNNSoftM',
  ),
  CNNSoftVL: createLoader(
    () => import(/* webpackChunkName: "anime4k-effect-cnnsoftvl" */ './pipelines/restore/CNNSoftVL'),
    'CNNSoftVL',
  ),
  CNNUL: createLoader(
    () => import(/* webpackChunkName: "anime4k-effect-cnnul" */ './pipelines/restore/CNNUL'),
    'CNNUL',
  ),
  CNNVL: createLoader(
    () => import(/* webpackChunkName: "anime4k-effect-cnnvl" */ './pipelines/restore/CNNVL'),
    'CNNVL',
  ),
  CNNx2M: createLoader(
    () => import(/* webpackChunkName: "anime4k-effect-cnnx2m" */ './pipelines/upscale/CNNx2M'),
    'CNNx2M',
  ),
  CNNx2S: createLoader(
    () => import(/* webpackChunkName: "anime4k-effect-cnnx2s" */ './pipelines/upscale/CNNx2S'),
    'CNNx2S',
  ),
  CNNx2L: createLoader(
    () => import(/* webpackChunkName: "anime4k-effect-cnnx2l" */ './pipelines/upscale/CNNx2L'),
    'CNNx2L',
  ),
  CNNx2UL: createLoader(
    () => import(/* webpackChunkName: "anime4k-effect-cnnx2ul" */ './pipelines/upscale/CNNx2UL'),
    'CNNx2UL',
  ),
  CNNx2VL: createLoader(
    () => import(/* webpackChunkName: "anime4k-effect-cnnx2vl" */ './pipelines/upscale/CNNx2VL'),
    'CNNx2VL',
  ),
  DenoiseCNNx2VL: createLoader(
    () => import(/* webpackChunkName: "anime4k-effect-denoise-cnnx2vl" */ './pipelines/upscale/DenoiseCNNx2VL'),
    'DenoiseCNNx2VL',
  ),
  DoG: createLoader(
    () => import(/* webpackChunkName: "anime4k-effect-dog" */ './pipelines/deblur/DoG'),
    'DoG',
  ),
  GANUUL: createLoader(
    () => import(/* webpackChunkName: "anime4k-effect-ganuul" */ './pipelines/restore/GANUUL'),
    'GANUUL',
  ),
  GANx3L: createLoader(
    () => import(/* webpackChunkName: "anime4k-effect-ganx3l" */ './pipelines/upscale/GANx3L'),
    'GANx3L',
  ),
  GANx4UUL: createLoader(
    () => import(/* webpackChunkName: "anime4k-effect-ganx4uul" */ './pipelines/upscale/GANx4UUL'),
    'GANx4UUL',
  ),
};

export const anime4kBackend = createEffectBackend({
  backendId: anime4kBackendId,
  backendDisplayName: 'Anime4K',
  descriptors: anime4kEffectDescriptors,
  loaders,
  resolvePreset: resolveAnime4kPreset,
  createPipeline(PipelineClass, context) {
    return new PipelineClass({
      device: context.device,
      inputTexture: context.inputTexture,
      nativeDimensions: context.currentDimensions,
      targetDimensions: context.targetDimensions,
      terminalTarget: context.terminalTarget,
      optimizationFlags: context.optimizationFlags,
    });
  },
  getBenchmarkProfiles() {
    return [
      {
        id: 'anime4k-default-benchmark',
        name: 'Anime4K A+A',
        effects: resolveAnime4kPreset('A+A', 'performance'),
      },
    ];
  },
});
