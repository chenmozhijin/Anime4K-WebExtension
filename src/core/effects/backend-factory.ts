import type { Dimensions, EffectDescriptor, EffectReference, PerformanceTier } from '../../types';
import type { AlgorithmBackend, BenchmarkProfile, CompileEffectContext, PipelinePass } from './backend-types';

export type EffectPayloadLoader<TPayload> = () => Promise<TPayload>;

export interface CreateEffectBackendOptions<TPayload> {
  backendId: string;
  backendDisplayName: string;
  descriptors: EffectDescriptor[];
  loaders: Record<string, EffectPayloadLoader<TPayload>>;
  createPipeline(payload: TPayload, context: CompileEffectContext, descriptor: EffectDescriptor, effect: EffectReference): PipelinePass | Promise<PipelinePass>;
  resolvePreset?: (modeId: string, tier: PerformanceTier) => EffectReference[];
  getBenchmarkProfiles?: () => BenchmarkProfile[];
  getOutputDimensions?: (descriptor: EffectDescriptor, context: CompileEffectContext) => Dimensions;
  getRequiredModuleId?: (descriptor: EffectDescriptor, effect: EffectReference) => string;
  warmupSteps?: number;
}

export type PipelineConstructor = new (options: any) => PipelinePass;

export function createPipelineConstructorLoader<TModule extends Record<string, PipelineConstructor>>(
  moduleImporter: () => Promise<TModule>,
  exportName: keyof TModule & string,
): EffectPayloadLoader<PipelineConstructor> {
  return async () => {
    const module = await moduleImporter();
    const constructor = module[exportName];
    if (!constructor) {
      throw new Error(`Pipeline export not found: ${exportName}`);
    }

    return constructor;
  };
}

function getDefaultOutputDimensions(descriptor: EffectDescriptor, context: CompileEffectContext): Dimensions {
  switch (descriptor.dimensionBehavior.kind) {
    case 'scale': {
      const scale = descriptor.dimensionBehavior.scale ?? 1;
      return {
        width: Math.ceil(context.currentDimensions.width * scale),
        height: Math.ceil(context.currentDimensions.height * scale),
      };
    }
    case 'target':
      return { ...context.targetDimensions };
    case 'same':
    default:
      return { ...context.currentDimensions };
  }
}

export function createEffectBackend<TPayload>({
  backendId,
  backendDisplayName,
  descriptors,
  loaders,
  createPipeline,
  resolvePreset = () => [],
  getBenchmarkProfiles = () => [],
  getOutputDimensions = getDefaultOutputDimensions,
  getRequiredModuleId = (_descriptor, effect) => `${backendId}:${effect.key}`,
  warmupSteps = 1,
}: CreateEffectBackendOptions<TPayload>): AlgorithmBackend {
  const descriptorByKey = new Map(descriptors.map(descriptor => [descriptor.key, descriptor]));
  const payloadCache = new Map<string, Promise<TPayload>>();

  function loadPayload(effect: EffectReference): Promise<TPayload> {
    const descriptor = descriptorByKey.get(effect.key);
    const loader = loaders[effect.key];
    if (!descriptor || !loader) {
      throw new Error(`Unsupported ${backendDisplayName} effect: ${effect.key}`);
    }

    const cacheKey = `${backendId}:${effect.key}`;
    let payloadPromise = payloadCache.get(cacheKey);
    if (!payloadPromise) {
      payloadPromise = loader();
      payloadCache.set(cacheKey, payloadPromise);
    }

    return payloadPromise;
  }

  return {
    backendId,
    listEffects() {
      return descriptors;
    },
    resolvePreset,
    async compileEffect(effect, context) {
      const descriptor = descriptorByKey.get(effect.key);
      if (!descriptor) {
        throw new Error(`Unsupported ${backendDisplayName} effect: ${effect.key}`);
      }

      const payload = await loadPayload(effect);
      const pipeline = await createPipeline(payload, context, descriptor, effect);

      return {
        pipelines: [pipeline],
        outputTexture: pipeline.getOutputTexture(),
        outputDimensions: getOutputDimensions(descriptor, context),
        requiredModules: [getRequiredModuleId(descriptor, effect)],
        warmupSteps,
      };
    },
    getBenchmarkProfiles,
  };
}
