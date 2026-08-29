import type { Dimensions, EffectReference } from '../../types';
import type { CompiledEffectPlan, PipelinePass, TerminalTextureTarget } from './backend-types';
import { getEffectDescriptor } from './registry';
import { getRuntimeBackend } from './runtime-registry';
import { internalResizeEffectReference } from '../../engines/core/catalog';
import { getTextureAllocationInfo } from '../texture-pool';
import type { GpuCapabilities } from '../gpu-capabilities';
import {
  resolveOptimizationFeatureFlags,
  type OptimizationFeatureFlags,
} from '../optimization-flags';

function flattenPipelinePasses(pipelines: readonly PipelinePass[]): PipelinePass[] {
  const flattened: PipelinePass[] = [];
  const visit = (pipeline: PipelinePass): void => {
    const children = pipeline.getProfileChildren?.()
      ?? (pipeline as PipelinePass & { pipelines?: PipelinePass[] }).pipelines
      ?? [];
    if (children.length === 0) {
      flattened.push(pipeline);
      return;
    }
    children.forEach(visit);
  };
  pipelines.forEach(visit);
  return flattened;
}

function summarizeTextureAllocations(pipelines: readonly PipelinePass[]): {
  peakTextureBytes: number;
  textureSlotCount: number;
  resourceReleasePlan: CompiledEffectPlan['resourceReleasePlan'];
} {
  const textures = new Set<GPUTexture>();
  for (const pipeline of flattenPipelinePasses(pipelines)) {
    textures.add(pipeline.getOutputTexture());
  }

  let peakTextureBytes = 0;
  for (const texture of textures) {
    peakTextureBytes += getTextureAllocationInfo(texture)?.byteSize ?? 0;
  }

  const resourceReleasePlan: CompiledEffectPlan['resourceReleasePlan'] = [];
  let passOffset = 0;
  for (const pipeline of pipelines) {
    const pipelinePlan = pipeline.getTextureResourcePlan?.();
    // Child plans use pass-local indices. Offset them after flattening so reports and
    // release diagnostics refer to the same global pass numbering as the profiler.
    pipelinePlan?.resourceReleasePlan.forEach(entry => resourceReleasePlan.push({
      ...entry,
      afterPass: entry.afterPass + passOffset,
    }));
    passOffset += flattenPipelinePasses([pipeline]).length;
  }

  return {
    peakTextureBytes,
    textureSlotCount: textures.size,
    resourceReleasePlan,
  };
}

function createPassthroughPlan(inputTexture: GPUTexture, dimensions: Dimensions): CompiledEffectPlan {
  const passthroughPipeline: PipelinePass = {
    profileLabel: 'Passthrough',
    profileGroup: 'Passthrough',
    profileGroupId: 'passthrough',
    pass: () => { },
    getOutputTexture: () => inputTexture,
  };

  return {
    pipelines: [passthroughPipeline],
    outputTexture: inputTexture,
    outputDimensions: dimensions,
    requiredModules: [],
    warmupSteps: 0,
    passCount: 1,
    peakTextureBytes: 0,
    textureSlotCount: 0,
    resourceReleasePlan: [],
  };
}

function assignProfileGroup(pipeline: PipelinePass, group: string, groupId: string): void {
  pipeline.profileGroup = group;
  pipeline.profileGroupId = groupId;
  const children = pipeline.getProfileChildren?.()
    ?? (pipeline as PipelinePass & { pipelines?: PipelinePass[] }).pipelines
    ?? [];
  children.forEach(child => assignProfileGroup(child, group, groupId));
}

function getEffectScale(effect: EffectReference): number {
  const descriptor = getEffectDescriptor(effect);
  return descriptor?.dimensionBehavior.kind === 'scale'
    ? descriptor.dimensionBehavior.scale ?? 1
    : 1;
}

function expectedOutputDimensions(
  effect: EffectReference,
  current: Dimensions,
  target: Dimensions,
): Dimensions {
  const behavior = getEffectDescriptor(effect)?.dimensionBehavior;
  if (behavior?.kind === 'target') {
    return { ...target };
  }
  const scale = behavior?.kind === 'scale' ? behavior.scale ?? 1 : 1;
  return {
    width: Math.round(current.width * scale),
    height: Math.round(current.height * scale),
  };
}

export async function compileEffectChain(options: {
  device: GPUDevice;
  inputTexture: GPUTexture;
  effects: readonly EffectReference[];
  sourceDimensions: Dimensions;
  targetDimensions: Dimensions;
  capabilities?: GpuCapabilities;
  terminalTarget?: TerminalTextureTarget;
  optimizationFlags?: Partial<OptimizationFeatureFlags>;
}): Promise<CompiledEffectPlan> {
  const {
    device,
    inputTexture,
    effects,
    sourceDimensions,
    targetDimensions,
    capabilities,
    terminalTarget,
  } = options;
  const optimizationFlags = resolveOptimizationFeatureFlags(options.optimizationFlags);

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

  try {
    for (const [index, effect] of effects.entries()) {
      const descriptor = getEffectDescriptor(effect);
      if (!descriptor) {
        throw new Error(`Effect not found: ${effect.id}`);
      }

      const backend = await getRuntimeBackend(effect.backendId);
      const expectedDimensions = expectedOutputDimensions(effect, currentDimensions, targetDimensions);
      // Only the final, size-identical effect may receive a canvas view. The backend
      // still decides whether it has a certified presenter; otherwise it returns RGBA16F.
      const canPresentTerminal = optimizationFlags.terminalDirect
        && index === effects.length - 1
        && terminalTarget
        && expectedDimensions.width === terminalTarget.width
        && expectedDimensions.height === terminalTarget.height;
      const compiled = await backend.compileEffect(effect, {
        device,
        capabilities,
        inputTexture: currentTexture,
        sourceDimensions,
        currentDimensions,
        targetDimensions,
        terminalTarget: canPresentTerminal ? terminalTarget : undefined,
        optimizationFlags,
      });

      compiled.pipelines.forEach(pipeline => assignProfileGroup(
        pipeline,
        descriptor.name,
        `effect:${index}:${descriptor.id}`,
      ));
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
          // This is deterministic chain geometry normalization, not adaptive quality
          // degradation: the requested final target and every model stage remain intact.
          const resizeTarget = {
            width: Math.ceil(idealIntermediateWidth),
            height: Math.ceil(idealIntermediateHeight),
          };
          const resizeBackend = await getRuntimeBackend(internalResizeEffectReference.backendId);
          const resizeCompiled = await resizeBackend.compileEffect(internalResizeEffectReference, {
            device,
            capabilities,
            inputTexture: currentTexture,
            sourceDimensions,
            currentDimensions,
            targetDimensions: resizeTarget,
            optimizationFlags,
          });
          resizeCompiled.pipelines.forEach(pipeline => assignProfileGroup(
            pipeline,
            'Downscale',
            `downscale:${index}`,
          ));
          pipelines.push(...resizeCompiled.pipelines);
          resizeCompiled.requiredModules.forEach(moduleId => requiredModules.add(moduleId));
          warmupSteps += resizeCompiled.warmupSteps;
          currentTexture = resizeCompiled.outputTexture;
          currentDimensions = resizeCompiled.outputDimensions;
        }
      }
    }
  } catch (error) {
    for (const pipeline of pipelines) {
      try {
        pipeline.destroy?.();
      } catch {
        // Ignore cleanup failures from a rejected effect chain.
      }
    }
    throw error;
  }

  const flattenedPipelines = flattenPipelinePasses(pipelines);
  const allocationSummary = summarizeTextureAllocations(pipelines);
  const terminalPass = flattenedPipelines.find(pipeline => pipeline.presentsToTerminal);
  return {
    pipelines,
    outputTexture: currentTexture,
    outputDimensions: currentDimensions,
    requiredModules: [...requiredModules],
    warmupSteps,
    passCount: flattenedPipelines.length,
    peakTextureBytes: allocationSummary.peakTextureBytes,
    textureSlotCount: allocationSummary.textureSlotCount,
    resourceReleasePlan: allocationSummary.resourceReleasePlan,
    terminalPresenter: terminalPass ? {
      kind: 'direct-canvas',
      passLabel: terminalPass.profileLabel ?? terminalPass.constructor.name,
    } : undefined,
  };
}
