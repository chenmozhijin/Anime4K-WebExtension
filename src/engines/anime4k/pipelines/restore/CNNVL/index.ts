import conv2dtfWGSL from './shaders/conv2dtf.wgsl';
import conv2dtf1WGSL from './shaders/conv2dtf1.wgsl';
import conv2d1tfWGSL from './shaders/conv2d1tf.wgsl';
import conv2d1tf1WGSL from './shaders/conv2d1tf1.wgsl';
import conv2d2tfWGSL from './shaders/conv2d2tf.wgsl';
import conv2d2tf1WGSL from './shaders/conv2d2tf1.wgsl';
import conv2d3tfWGSL from './shaders/conv2d3tf.wgsl';
import conv2d3tf1WGSL from './shaders/conv2d3tf1.wgsl';
import conv2d4tfWGSL from './shaders/conv2d4tf.wgsl';
import conv2d4tf1WGSL from './shaders/conv2d4tf1.wgsl';
import conv2d5tfWGSL from './shaders/conv2d5tf.wgsl';
import conv2d5tf1WGSL from './shaders/conv2d5tf1.wgsl';
import conv2d6tfWGSL from './shaders/conv2d6tf.wgsl';
import conv2d6tf1WGSL from './shaders/conv2d6tf1.wgsl';
import conv2d7tfWGSL from './shaders/conv2d7tf.wgsl';
import conv2d7tf1WGSL from './shaders/conv2d7tf1.wgsl';
import output from './shaders/output.wgsl';

import { Anime4KPipeline, Anime4KPipelineDescriptor } from '../../interfaces';
import { Conv2d, Overlay } from '../../helpers';

export class CNNVL implements Anime4KPipeline {
  /**
   *  [0, 1] conv2d_tf, conv2d_tf1
   *  [2, 3] conv2d_1_tf, conv2d_1_tf1
   *  [4, 5] conv2d_2_tf, conv2d_2_tf1
   *  [6, 7] conv2d_3_tf, conv2d_3_tf1
   *  [8, 9] conv2d_4_tf, conv2d_4_tf1
   *  [10, 11] conv2d_5_tf, conv2d_5_tf1
   *  [12, 13] conv2d_6_tf, conv2d_6_tf1
   *  [14, 15] conv2d_7_tf, conv2d_7_tf1
   *  [14] output
   */
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
      conv2dtfWGSL, conv2dtf1WGSL,
      conv2d1tfWGSL, conv2d1tf1WGSL,
      conv2d2tfWGSL, conv2d2tf1WGSL,
      conv2d3tfWGSL, conv2d3tf1WGSL,
      conv2d4tfWGSL, conv2d4tf1WGSL,
      conv2d5tfWGSL, conv2d5tf1WGSL,
      conv2d6tfWGSL, conv2d6tf1WGSL,
      conv2d7tfWGSL, conv2d7tf1WGSL,
    ];

    this.pushPipeline(device, [inputTexture], shaders[0], 'conv2d_tf');
    this.pushPipeline(device, [inputTexture], shaders[1], 'conv2d_tf_1');

    const inputTextures: GPUTexture[] = [];
    for (let i = 1; i < 8; i += 1) {
      inputTextures.length = 0;
      this.fillOutputTextures(inputTextures, 2 * (i - 1), 2);
      this.pushPipeline(device, inputTextures, shaders[2 * i], `conv2d_${i}_tf`);
      this.pushPipeline(device, inputTextures, shaders[2 * i + 1], `conv2d_${i}_tf_1`);
    }

    const outputTextures: GPUTexture[] = [];
    this.fillOutputTextures(outputTextures, 2, 14);
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
