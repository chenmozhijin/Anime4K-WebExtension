import type { Dimensions, EffectDescriptor, EffectReference, PerformanceTier } from '../../types';

export interface PipelinePass {
  updateParam?(param: string, value: any): void;
  readonly profileLabel?: string;
  profileGroup?: string;
  pass(encoder: GPUCommandEncoder, profile?: PipelineProfileRecorder): void;
  getOutputTexture(): GPUTexture;
  getProfileChildren?(): PipelinePass[];
  destroy?(): void;
}

export interface PipelineProfileRecorder {
  recordPass(pass: PipelinePass, encode: () => void): void;
  recordNamedPass(label: string, group: string, encode: () => void): void;
  createComputePassDescriptor?(pass: PipelinePass): GPUComputePassDescriptor | undefined;
  createRenderPassDescriptor?(pass: PipelinePass, descriptor: GPURenderPassDescriptor): GPURenderPassDescriptor;
  resolveGpuQueries?(encoder: GPUCommandEncoder): void;
  collectGpuResultsAsync?(): void;
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
