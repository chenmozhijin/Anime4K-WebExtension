import type { Dimensions } from '../../types';
import type { AlgorithmBackend, CompileEffectContext, CompiledEffectNode, PipelinePass } from '../../core/effects/backend-types';
import { artcnnBackendId, artcnnEffectDescriptors } from './catalog';

type PipelineConstructor = new (options: any) => PipelinePass;
type EffectFactory = (context: CompileEffectContext) => Promise<CompiledEffectNode>;
type PipelineModule = Record<string, PipelineConstructor>;
type EffectLoader = () => Promise<PipelineConstructor>;

const effectDescriptorByKey = new Map(artcnnEffectDescriptors.map(descriptor => [descriptor.key, descriptor]));
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
    const outputDimensions: Dimensions = {
      width: Math.ceil(context.currentDimensions.width * scale),
      height: Math.ceil(context.currentDimensions.height * scale),
    };

    return {
      pipelines: [pipeline],
      outputTexture: pipeline.getOutputTexture(),
      outputDimensions,
      requiredModules: [`${artcnnBackendId}:${descriptorKey}`],
      warmupSteps: 1,
    };
  };
}

const factories: Record<string, EffectFactory> = Object.fromEntries(
  Object.entries(loaders).map(([key, loader]) => [key, createFactory(key, loader)]),
);

export const artcnnBackend: AlgorithmBackend = {
  backendId: artcnnBackendId,
  listEffects() {
    return artcnnEffectDescriptors;
  },
  resolvePreset() {
    return [];
  },
  async compileEffect(effect, context) {
    const factory = factories[effect.key];
    if (!factory) {
      throw new Error(`Unsupported ArtCNN effect: ${effect.key}`);
    }

    return factory(context);
  },
  getBenchmarkProfiles() {
    return [];
  },
};

