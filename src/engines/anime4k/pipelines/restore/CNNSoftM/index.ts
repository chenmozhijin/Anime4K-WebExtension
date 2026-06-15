import conv2dtfWGSL from './shaders/conv2dtf.wgsl';
import conv2d1tfWGSL from './shaders/conv2d1tf.wgsl';
import conv2d2tfWGSL from './shaders/conv2d2tf.wgsl';
import conv2d3tfWGSL from './shaders/conv2d3tf.wgsl';
import conv2d4tfWGSL from './shaders/conv2d4tf.wgsl';
import conv2d5tfWGSL from './shaders/conv2d5tf.wgsl';
import conv2d6tfWGSL from './shaders/conv2d6tf.wgsl';
import output from './shaders/output.wgsl';

import { Anime4KPipeline, Anime4KPipelineDescriptor } from '../../interfaces';
import { Conv2d, Overlay } from '../../helpers';

export class CNNSoftM implements Anime4KPipeline {
  /**
   * 7 conv2d pipelines and output
   */
  pipelines: Anime4KPipeline[] = [];

  /**
   * Creates an instance of CNNUL.
   *
   * @param {Object} options - The options for the CNNM pipeline.
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
      conv2d6tfWGSL];

    // pipeline 0: main -> conv_2d_tf
    this.pipelines.push(new Conv2d({
      device,
      inputTextures: [inputTexture],
      shaderWGSL: shaders[0],
      name: 'conv2d_tf',
    }));

    // pipeline 1 - 6:
    for (let i = 1; i < shaders.length; i += 1) {
      // get the output texture from last pipeline
      this.pipelines.push(new Conv2d({
        device,
        inputTextures: [this.pipelines[i - 1].getOutputTexture()],
        shaderWGSL: shaders[i],
        name: `conv2d_${i}_tf`,
      }));
    }

    const outputTextures: GPUTexture[] = [];
    this.fillOutputTextures(outputTextures, 0, 7);
    this.pipelines.push(new Conv2d({
      device,
      inputTextures: outputTextures,
      shaderWGSL: output,
      name: 'output',
    }));

    this.pipelines.push(new Overlay({
      device,
      inputTextures: [inputTexture, this.pipelines[this.pipelines.length - 1].getOutputTexture()],
      outputTextureSize: [inputTexture.width, inputTexture.height],
    }));
  }

  private fillOutputTextures(outputTextures: GPUTexture[], from: number, count: number) {
    for (let i = from; i < from + count; i += 1) {
      outputTextures.push(this.pipelines[i].getOutputTexture());
    }
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

  destroy(): void {
    this.pipelines.forEach((pipeline) => pipeline.destroy?.());
  }
}
