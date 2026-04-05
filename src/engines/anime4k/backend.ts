import type { Dimensions } from '../../types';
import type { AlgorithmBackend, CompileEffectContext, CompiledEffectNode, PipelinePass } from '../../core/effects/backend-types';
import { anime4kBackendId, anime4kEffectDescriptors, resolveAnime4kPreset } from './catalog';

type PipelineConstructor = new (options: any) => PipelinePass;
type EffectFactory = (context: CompileEffectContext) => Promise<CompiledEffectNode>;
type PipelineModule = Record<string, PipelineConstructor>;
type EffectLoader = () => Promise<PipelineConstructor>;

const effectDescriptorByKey = new Map(anime4kEffectDescriptors.map(descriptor => [descriptor.key, descriptor]));

const pipelineConstructorCache = new Map<string, Promise<PipelineConstructor>>();

function createLoader<T extends PipelineModule>(moduleImporter: () => Promise<T>, exportName: keyof T & string): EffectLoader {
  return async () => {
    let constructorPromise = pipelineConstructorCache.get(exportName);
    if (!constructorPromise) {
      constructorPromise = moduleImporter().then(module => module[exportName]);
      pipelineConstructorCache.set(exportName, constructorPromise);
    }

    return constructorPromise;
  };
}

const loaders: Record<string, EffectLoader> = {
  BilateralMean: createLoader(
    () => import(/* webpackChunkName: "anime4k-effect-bilateral-mean" */ './vendor/pipelines/denoise/BilateralMean'),
    'BilateralMean',
  ),
  ClampHighlights: createLoader(
    () => import(/* webpackChunkName: "anime4k-effect-clamp-highlights" */ './vendor/pipelines/helpers/ClampHighlights'),
    'ClampHighlights',
  ),
  CNNM: createLoader(
    () => import(/* webpackChunkName: "anime4k-effect-cnnm" */ './vendor/pipelines/restore/CNNM'),
    'CNNM',
  ),
  CNNSoftM: createLoader(
    () => import(/* webpackChunkName: "anime4k-effect-cnnsoftm" */ './vendor/pipelines/restore/CNNSoftM'),
    'CNNSoftM',
  ),
  CNNSoftVL: createLoader(
    () => import(/* webpackChunkName: "anime4k-effect-cnnsoftvl" */ './vendor/pipelines/restore/CNNSoftVL'),
    'CNNSoftVL',
  ),
  CNNUL: createLoader(
    () => import(/* webpackChunkName: "anime4k-effect-cnnul" */ './vendor/pipelines/restore/CNNUL'),
    'CNNUL',
  ),
  CNNVL: createLoader(
    () => import(/* webpackChunkName: "anime4k-effect-cnnvl" */ './vendor/pipelines/restore/CNNVL'),
    'CNNVL',
  ),
  CNNx2M: createLoader(
    () => import(/* webpackChunkName: "anime4k-effect-cnnx2m" */ './vendor/pipelines/upscale/CNNx2M'),
    'CNNx2M',
  ),
  CNNx2UL: createLoader(
    () => import(/* webpackChunkName: "anime4k-effect-cnnx2ul" */ './vendor/pipelines/upscale/CNNx2UL'),
    'CNNx2UL',
  ),
  CNNx2VL: createLoader(
    () => import(/* webpackChunkName: "anime4k-effect-cnnx2vl" */ './vendor/pipelines/upscale/CNNx2VL'),
    'CNNx2VL',
  ),
  DenoiseCNNx2VL: createLoader(
    () => import(/* webpackChunkName: "anime4k-effect-denoise-cnnx2vl" */ './vendor/pipelines/upscale/DenoiseCNNx2VL'),
    'DenoiseCNNx2VL',
  ),
  DoG: createLoader(
    () => import(/* webpackChunkName: "anime4k-effect-dog" */ './vendor/pipelines/deblur/DoG'),
    'DoG',
  ),
  GANUUL: createLoader(
    () => import(/* webpackChunkName: "anime4k-effect-ganuul" */ './vendor/pipelines/restore/GANUUL'),
    'GANUUL',
  ),
  GANx3L: createLoader(
    () => import(/* webpackChunkName: "anime4k-effect-ganx3l" */ './vendor/pipelines/upscale/GANx3L'),
    'GANx3L',
  ),
  GANx4UUL: createLoader(
    () => import(/* webpackChunkName: "anime4k-effect-ganx4uul" */ './vendor/pipelines/upscale/GANx4UUL'),
    'GANx4UUL',
  ),
};

function createFactory(
  descriptorKey: string,
  loadPipelineClass: EffectLoader,
): EffectFactory {
  return async (context) => {
    const PipelineClass = await loadPipelineClass();
    const pipeline = new PipelineClass({
      device: context.device,
      inputTexture: context.inputTexture,
      nativeDimensions: context.currentDimensions,
      targetDimensions: context.targetDimensions,
    });
    const descriptor = effectDescriptorByKey.get(descriptorKey);
    const scale = descriptor?.dimensionBehavior.scale ?? 1;
    const outputDimensions: Dimensions = descriptor?.dimensionBehavior.kind === 'scale'
      ? {
        width: Math.ceil(context.currentDimensions.width * scale),
        height: Math.ceil(context.currentDimensions.height * scale),
      }
      : { ...context.currentDimensions };

    return {
      pipelines: [pipeline],
      outputTexture: pipeline.getOutputTexture(),
      outputDimensions,
      requiredModules: [`${anime4kBackendId}:${descriptorKey}`],
      warmupSteps: 1,
    };
  };
}

const factories: Record<string, EffectFactory> = Object.fromEntries(
  Object.entries(loaders).map(([key, loader]) => [key, createFactory(key, loader)]),
);

export const anime4kBackend: AlgorithmBackend = {
  backendId: anime4kBackendId,
  listEffects() {
    return anime4kEffectDescriptors;
  },
  resolvePreset(modeId, tier) {
    return resolveAnime4kPreset(modeId, tier);
  },
  async compileEffect(effect, context) {
    const factory = factories[effect.key];
    if (!factory) {
      throw new Error(`Unsupported Anime4K effect: ${effect.key}`);
    }
    return factory(context);
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
};
