import type { Dimensions, EffectReference } from '../../types';
import type { CompiledEffectPlan, PipelinePass } from './backend-types';
import { getEffectDescriptor } from './registry';
import { getRuntimeBackend } from './runtime-registry';
import { internalResizeEffectReference } from '../../engines/core/catalog';

function createPassthroughPlan(inputTexture: GPUTexture, dimensions: Dimensions): CompiledEffectPlan {
  const passthroughPipeline: PipelinePass = {
    pass: () => { },
    getOutputTexture: () => inputTexture,
    updateParam: () => { },
  };

  return {
    pipelines: [passthroughPipeline],
    outputTexture: inputTexture,
    outputDimensions: dimensions,
    requiredModules: [],
    warmupSteps: 0,
  };
}

function getEffectScale(effect: EffectReference): number {
  const descriptor = getEffectDescriptor(effect);
  return descriptor?.dimensionBehavior.kind === 'scale'
    ? descriptor.dimensionBehavior.scale ?? 1
    : 1;
}

export async function compileEffectChain(options: {
  device: GPUDevice;
  inputTexture: GPUTexture;
  effects: readonly EffectReference[];
  sourceDimensions: Dimensions;
  targetDimensions: Dimensions;
}): Promise<CompiledEffectPlan> {
  const { device, inputTexture, effects, sourceDimensions, targetDimensions } = options;

  if (effects.length === 0) {
    return createPassthroughPlan(inputTexture, sourceDimensions);
  }

  const pipelines: PipelinePass[] = [];
  const requiredModules = new Set<string>();
  let warmupSteps = 0;
  let currentTexture = inputTexture;
  let currentDimensions = { ...sourceDimensions };

  const upscaleFactors = effects.map(getEffectScale);
  const remainingUpscaleFactors = upscaleFactors.map((_, index) =>
    upscaleFactors.slice(index + 1).reduce((acc, value) => acc * value, 1));

  for (const [index, effect] of effects.entries()) {
    const descriptor = getEffectDescriptor(effect);
    if (!descriptor) {
      throw new Error(`Effect not found: ${effect.id}`);
    }

    const backend = await getRuntimeBackend(effect.backendId);
    const compiled = await backend.compileEffect(effect, {
      device,
      inputTexture: currentTexture,
      sourceDimensions,
      currentDimensions,
      targetDimensions,
    });

    pipelines.push(...compiled.pipelines);
    compiled.requiredModules.forEach(moduleId => requiredModules.add(moduleId));
    warmupSteps += compiled.warmupSteps;
    currentTexture = compiled.outputTexture;
    currentDimensions = compiled.outputDimensions;

    const remainingFactor = remainingUpscaleFactors[index];
    if ((descriptor.dimensionBehavior.scale ?? 1) > 1 && remainingFactor > 1) {
      const idealIntermediateWidth = targetDimensions.width / remainingFactor;
      const idealIntermediateHeight = targetDimensions.height / remainingFactor;

      if (
        currentDimensions.width > idealIntermediateWidth * 1.1
        || currentDimensions.height > idealIntermediateHeight * 1.1
      ) {
        const resizeTarget = {
          width: Math.ceil(idealIntermediateWidth),
          height: Math.ceil(idealIntermediateHeight),
        };
        const resizeBackend = await getRuntimeBackend(internalResizeEffectReference.backendId);
        const resizeCompiled = await resizeBackend.compileEffect(internalResizeEffectReference, {
          device,
          inputTexture: currentTexture,
          sourceDimensions,
          currentDimensions,
          targetDimensions: resizeTarget,
        });
        pipelines.push(...resizeCompiled.pipelines);
        resizeCompiled.requiredModules.forEach(moduleId => requiredModules.add(moduleId));
        warmupSteps += resizeCompiled.warmupSteps;
        currentTexture = resizeCompiled.outputTexture;
        currentDimensions = resizeCompiled.outputDimensions;
      }
    }
  }

  return {
    pipelines,
    outputTexture: currentTexture,
    outputDimensions: currentDimensions,
    requiredModules: [...requiredModules],
    warmupSteps,
  };
}
