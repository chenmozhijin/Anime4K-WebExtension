import type { PipelinePass, PipelineProfileRecorder } from '../../../../../core/effects/backend-types';
import { ComputeTexturePass } from '../../../../../core/gpu-passes/compute-texture-pass';
import { Anime4KPipeline, ClampHighlightsPipelineDescriptor } from '../../interfaces';
import luminationXWGSL from './shaders/luminationX.wgsl';
import luminationYWGSL from './shaders/luminationY.wgsl';
import clampWGSL from './shaders/clamp.wgsl';

export class ClampHighlights implements Anime4KPipeline {
  readonly name: string;

  readonly outputTexture: GPUTexture;

  readonly statsXTexture: GPUTexture;

  readonly statsYTexture: GPUTexture;

  private readonly passes: ComputeTexturePass[];

  constructor({
    device,
    inputTexture,
    name = 'clamp highlights',
  }: ClampHighlightsPipelineDescriptor) {
    this.name = name;
    const outputSize = {
      width: inputTexture.width,
      height: inputTexture.height,
    };

    const luminationXPass = new ComputeTexturePass({
      device,
      inputTextures: [inputTexture],
      shaderWGSL: luminationXWGSL,
      name: `${name} Lumination X`,
      cacheKeyPrefix: 'anime4k/helper/ClampHighlights/lumination-x',
      outputSize,
      outputUsage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING,
    });

    const luminationYPass = new ComputeTexturePass({
      device,
      inputTextures: [luminationXPass.outputTexture],
      shaderWGSL: luminationYWGSL,
      name: `${name} Lumination Y`,
      cacheKeyPrefix: 'anime4k/helper/ClampHighlights/lumination-y',
      outputSize,
      outputUsage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING,
    });

    const clampPass = new ComputeTexturePass({
      device,
      inputTextures: [
        inputTexture,
        luminationYPass.outputTexture,
      ],
      shaderWGSL: clampWGSL,
      name: `${name} Clamp`,
      cacheKeyPrefix: 'anime4k/helper/ClampHighlights/clamp',
      outputSize,
      outputUsage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING,
    });

    this.passes = [
      luminationXPass,
      luminationYPass,
      clampPass,
    ];
    this.statsXTexture = luminationXPass.outputTexture;
    this.statsYTexture = luminationYPass.outputTexture;
    this.outputTexture = clampPass.outputTexture;
  }

  pass(encoder: GPUCommandEncoder, profile?: PipelineProfileRecorder): void {
    this.passes.forEach(pass => pass.pass(encoder, profile));
  }

  updateParam(param: string, value: any): void {
    throw new Error(`${this.name} has no param.`);
  }

  getOutputTexture(): GPUTexture {
    return this.outputTexture;
  }

  destroy(): void {
    this.passes.forEach(pass => pass.destroy());
  }

  getProfileChildren(): PipelinePass[] {
    return this.passes;
  }
}
