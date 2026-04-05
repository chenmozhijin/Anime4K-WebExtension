import type { Dimensions, EffectDescriptor, EffectReference, PerformanceTier } from '../../types';

export interface PipelinePass {
  updateParam(param: string, value: any): void;
  pass(encoder: GPUCommandEncoder): void;
  getOutputTexture(): GPUTexture;
  destroy?(): void;
}

export interface CompileEffectContext {
  device: GPUDevice;
  inputTexture: GPUTexture;
  sourceDimensions: Dimensions;
  currentDimensions: Dimensions;
  targetDimensions: Dimensions;
}

export interface CompiledEffectNode {
  pipelines: PipelinePass[];
  outputTexture: GPUTexture;
  outputDimensions: Dimensions;
  requiredModules: string[];
  warmupSteps: number;
}

export interface CompiledEffectPlan {
  pipelines: PipelinePass[];
  outputTexture: GPUTexture;
  outputDimensions: Dimensions;
  requiredModules: string[];
  warmupSteps: number;
}

export interface BenchmarkProfile {
  id: string;
  name: string;
  effects: EffectReference[];
}

export interface AlgorithmBackend {
  backendId: string;
  listEffects(): EffectDescriptor[];
  resolvePreset(modeId: string, tier: PerformanceTier): EffectReference[];
  compileEffect(effect: EffectReference, context: CompileEffectContext): Promise<CompiledEffectNode>;
  getBenchmarkProfiles(): BenchmarkProfile[];
}
