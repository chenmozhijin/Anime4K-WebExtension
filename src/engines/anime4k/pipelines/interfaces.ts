export interface Anime4KPipeline {
  /**
   * Update the controllable parameter managed by the pipeline
   *
   * @param param  - name of the parameter
   * @param value  - value of the parameter
   */
  updateParam(param: string, value: any): void;

  /**
   * write compute commands into the encoder
   *
   * @param encoder - encoder to record commands into
   */
  pass(encoder: GPUCommandEncoder): void;

  /**
   * get the output texture of this pipeline
   */
  getOutputTexture(): GPUTexture;

  destroy?(): void;
}

export interface OriginalPipelineDescriptor {
  inputTexture: GPUTexture;
}

export interface Conv2dPipelineDescriptor {
  device: GPUDevice;
  inputTextures: GPUTexture[];
  shaderWGSL: string;
  name?: string;
}

export interface DepthToSpacePipelineDescriptor {
  device: GPUDevice;
  inputTextures: GPUTexture[];
  name?: string;
}

export interface OverlayPipelineDescriptor {
  device: GPUDevice;
  inputTextures: GPUTexture[];
  outputTextureSize: number[];
  fragmentWGSL?: string;
  name?: string;
}

export interface DownscalePipelineDescriptor {
  device: GPUDevice;
  inputTexture: GPUTexture;
  targetDimensions: { width: number; height: number };
  name?: string;
}

export interface ClampHighlightsPipelineDescriptor {
  device: GPUDevice;
  inputTexture: GPUTexture;
  name?: string;
}

export interface Anime4KPipelineDescriptor extends OriginalPipelineDescriptor {
  device: GPUDevice;
}

export interface Anime4KPresetPipelineDescriptor extends Anime4KPipelineDescriptor {
  nativeDimensions: { width: number; height: number };
  targetDimensions: { width: number; height: number };
}
