import type { Dimensions } from '../../../types';
import type { OptimizationFeatureFlags } from '../../optimization-flags';

export type TextureSymbol = string;

export type DimensionExpression =
  | { kind: 'absolute'; width: number; height: number }
  | { kind: 'texture'; texture: TextureSymbol; scale?: number };

interface GraphStageBase {
  id: string;
  name?: string;
  output: TextureSymbol;
}

export interface ComputeGraphStage extends GraphStageBase {
  op: 'compute';
  inputs: TextureSymbol[];
  shaderWGSL: string;
  cacheKeyPrefix: string;
  outputSize?: DimensionExpression;
  outputFormat?: GPUTextureFormat;
  outputUsage?: GPUTextureUsageFlags;
  includeSampler?: boolean;
  samplerBindingOrder?: 'before-output' | 'after-output';
  samplerKey?: string;
  samplerDescriptor?: GPUSamplerDescriptor;
  workgroupSize?: Dimensions;
  dispatchSize?: DimensionExpression;
  entryPoint?: string;
  extraLayoutEntries?: GPUBindGroupLayoutEntry[];
  extraBindGroupEntries?: GPUBindGroupEntry[];
  extraLayoutKey?: string;
  optimizedShaderWGSL?: string;
  optimizedWorkgroupSize?: Dimensions;
  optimizationFlag?: keyof OptimizationFeatureFlags;
}

export interface MultiComputeGraphStage {
  id: string;
  name?: string;
  op: 'multi-compute';
  inputs: TextureSymbol[];
  outputs: TextureSymbol[];
  shaderWGSL: string;
  baselineShaders: string[];
  cacheKeyPrefix: string;
  outputSize?: DimensionExpression;
  workgroupSize?: Dimensions;
  optimizationFlag?: keyof OptimizationFeatureFlags;
}

export interface DepthToSpaceGraphStage extends GraphStageBase {
  op: 'depth-to-space';
  inputs: [TextureSymbol, TextureSymbol, TextureSymbol];
  cacheKeyPrefix: string;
}

export interface RenderCompositeGraphStage extends GraphStageBase {
  op: 'render-composite';
  terminalDirect?: boolean;
  inputs: TextureSymbol[];
  fragmentWGSL: string;
  outputSize: DimensionExpression;
  cacheKeyPrefix: string;
  samplerKey?: string;
  outputFormat?: GPUTextureFormat;
  outputUsage?: GPUTextureUsageFlags;
}

export interface ResizeGraphStage extends GraphStageBase {
  op: 'resize';
  input: TextureSymbol;
  outputSize: DimensionExpression;
}

export interface LumaRecomposeGraphStage extends GraphStageBase {
  op: 'luma-recompose';
  source: TextureSymbol;
  luma: TextureSymbol;
  outputSize: DimensionExpression;
  cacheKeyPrefix: string;
  shaderWGSL?: string;
  workgroupSize?: Dimensions;
}

export interface ModelTailGraphStage extends GraphStageBase {
  op: 'model-tail';
  terminalDirect?: boolean;
  source: TextureSymbol;
  features: TextureSymbol[];
  headShaders: string[];
  kind: 'restore' | 'upscale';
  outputSize: DimensionExpression;
  cacheKeyPrefix: string;
}

export type GraphStage =
  | ComputeGraphStage
  | MultiComputeGraphStage
  | DepthToSpaceGraphStage
  | RenderCompositeGraphStage
  | ResizeGraphStage
  | LumaRecomposeGraphStage
  | ModelTailGraphStage;

export interface EffectGraph {
  input: TextureSymbol;
  output: TextureSymbol;
  stages: GraphStage[];
}
