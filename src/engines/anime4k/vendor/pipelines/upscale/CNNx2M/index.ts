import conv2dtfWGSL from './shaders/conv2dtf.wgsl';
import conv2d1tfWGSL from './shaders/conv2d1tf.wgsl';
import conv2d2tfWGSL from './shaders/conv2d2tf.wgsl';
import conv2d3tfWGSL from './shaders/conv2d3tf.wgsl';
import conv2d4tfWGSL from './shaders/conv2d4tf.wgsl';
import conv2d5tfWGSL from './shaders/conv2d5tf.wgsl';
import conv2d6tfWGSL from './shaders/conv2d6tf.wgsl';
import conv2dlasttfWGSL from './shaders/conv2dlasttf.wgsl';

import { Anime4KPipeline, Anime4KPipelineDescriptor } from '../../interfaces';
import { Conv2d, DepthToSpace, Overlay } from '../../helpers';

export class CNNx2M implements Anime4KPipeline {
  pipelines: Anime4KPipeline[] = [];

  /**
   * Creates an instance of CNNSoftVL.
   *
   * @param {Object} options - The options for the CNNSoftVL pipeline.
   * @param {GPUDevice} options.device - The GPU device to use for
   * creating textures and shader modules.
   * @param {GPUTexture} options.inputTexture - The input texture for the pipeline.
   */
  constructor({
    device,
    inputTexture,
  }: Anime4KPipelineDescriptor) {
    const shaders: string[] = [
      conv2dtfWGSL, conv2d1tfWGSL, conv2d2tfWGSL,
      conv2d3tfWGSL, conv2d4tfWGSL, conv2d5tfWGSL,
      conv2d6tfWGSL, conv2dlasttfWGSL];

    this.pushPipeline(device, [inputTexture], shaders[0], 'conv2d_tf');

    for (let i = 1; i < shaders.length - 1; i += 1) {
      this.pushPipeline(
        device,
        [this.pipelines[i - 1].getOutputTexture()],
        shaders[i],
        `conv2d_${i}_tf`,
      );
    }

    const outputTextures: GPUTexture[] = [];
    this.fillOutputTextures(outputTextures, 0, 7);
    this.pushPipeline(device, outputTextures, shaders[shaders.length - 1], 'conv2d_last_tf');
    outputTextures.length = 0;
    outputTextures.push(this.getOutputTexture());
    outputTextures.push(this.getOutputTexture());
    outputTextures.push(this.getOutputTexture());

    this.pipelines.push(new DepthToSpace({
      device,
      inputTextures: outputTextures,
      name: 'DepthToSpace',
    }));
    this.pipelines.push(new Overlay({
      device,
      inputTextures: [inputTexture, this.getOutputTexture()],
      outputTextureSize: [2 * inputTexture.width, 2 * inputTexture.height],
    }));
  }

  updateParam(param: string, value: any): void {
    throw new Error('Method not implemented.');
  }

  pass(encoder: GPUCommandEncoder): void {
    for (let i = 0; i < this.pipelines.length; i += 1) {
      this.pipelines[i].pass(encoder);
    }
  }

  getOutputTexture(): GPUTexture {
    return this.pipelines[this.pipelines.length - 1].getOutputTexture();
  }

  private pushPipeline(
    device: GPUDevice,
    inputTexture: GPUTexture[],
    shaderWGSL: string,
    name: string,
  ): void {
    this.pipelines.push(new Conv2d({
      device,
      inputTextures: inputTexture,
      shaderWGSL,
      name,
    }));
  }

  private fillOutputTextures(outputTextures: GPUTexture[], from: number, count: number) {
    for (let i = from; i < from + count; i += 1) {
      outputTextures.push(this.pipelines[i].getOutputTexture());
    }
  }

  destroy(): void {
    this.pipelines.forEach((pipeline) => pipeline.destroy?.());
  }
}
