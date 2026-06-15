import conv2dtf from './shaders/conv2dtf.wgsl';
import conv2dtf1 from './shaders/conv2dtf1.wgsl';
import conv2dtf2 from './shaders/conv2dtf2.wgsl';
import conv2d1tf from './shaders/conv2d1tf.wgsl';
import conv2d1tf1 from './shaders/conv2d1tf1.wgsl';
import conv2d1tf2 from './shaders/conv2d1tf2.wgsl';
import conv2d2tf from './shaders/conv2d2tf.wgsl';
import conv2d2tf1 from './shaders/conv2d2tf1.wgsl';
import conv2d2tf2 from './shaders/conv2d2tf2.wgsl';
import conv2d3tf from './shaders/conv2d3tf.wgsl';
import conv2d3tf1 from './shaders/conv2d3tf1.wgsl';
import conv2d3tf2 from './shaders/conv2d3tf2.wgsl';
import conv2d4tf from './shaders/conv2d4tf.wgsl';
import conv2d4tf1 from './shaders/conv2d4tf1.wgsl';
import conv2d4tf2 from './shaders/conv2d4tf2.wgsl';
import conv2d5tf from './shaders/conv2d5tf.wgsl';
import conv2d5tf1 from './shaders/conv2d5tf1.wgsl';
import conv2d5tf2 from './shaders/conv2d5tf2.wgsl';
import conv2d6tf from './shaders/conv2d6tf.wgsl';
import conv2d6tf1 from './shaders/conv2d6tf1.wgsl';
import conv2d6tf2 from './shaders/conv2d6tf2.wgsl';
import conv2dlasttf from './shaders/conv2dlasttf.wgsl';
import conv2dlasttf1 from './shaders/conv2dlasttf1.wgsl';
import conv2dlasttf2 from './shaders/conv2dlasttf2.wgsl';

import { Anime4KPipeline, Anime4KPipelineDescriptor } from '../../interfaces';
import { Conv2d, DepthToSpace, Overlay } from '../../helpers';

export class CNNx2UL implements Anime4KPipeline {
  /**
   *  [0 - 2] conv2d_tf - conv2d_tf2
   *  [3 - 5] conv2d_1_tf - conv2d_1_tf2
   *  [6 - 8] conv2d_2_tf - conv2d_2_tf2
   *  [9 - 11] conv2d_3_tf - conv2d_3_tf2
   *  [12 - 14] conv2d_4_tf - conv2d_4_tf2
   *  [15 - 17] conv2d_5_tf - conv2d_5_tf2
   *  [18 - 20] conv2d_6_tf - conv2d_6_tf2
   *  [21 - 23] conv2d_last_tf - conv2d_last_tf2
   */
  pipelines: Anime4KPipeline[] = [];

  /**
   * Creates an instance of CNNx2UL.
   *
   * @param {Object} options - The options for the CNNx2UL pipeline.
   * @param {GPUDevice} options.device - The GPU device to use for
   * creating textures and shader modules.
   * @param {GPUTexture} options.inputTexture - The input texture for the pipeline.
   */
  constructor({
    device,
    inputTexture,
  }: Anime4KPipelineDescriptor) {
    const shaders: string[] = [
      conv2dtf, conv2dtf1, conv2dtf2,
      conv2d1tf, conv2d1tf1, conv2d1tf2,
      conv2d2tf, conv2d2tf1, conv2d2tf2,
      conv2d3tf, conv2d3tf1, conv2d3tf2,
      conv2d4tf, conv2d4tf1, conv2d4tf2,
      conv2d5tf, conv2d5tf1, conv2d5tf2,
      conv2d6tf, conv2d6tf1, conv2d6tf2,
      conv2dlasttf, conv2dlasttf1, conv2dlasttf2];

    for (let i = 0; i < 3; i += 1) {
      this.pipelines.push(new Conv2d({
        device,
        inputTextures: [inputTexture],
        shaderWGSL: shaders[i],
        name: `conv2d_tf_${i}`,
      }));
    }

    const outputTextures: GPUTexture[] = [];
    for (let i = 1; i < 7; i += 1) {
      outputTextures.length = 0;
      outputTextures.push(this.pipelines[3 * (i - 1)].getOutputTexture());
      outputTextures.push(this.pipelines[3 * (i - 1) + 1].getOutputTexture());
      outputTextures.push(this.pipelines[3 * (i - 1) + 2].getOutputTexture());

      for (let j = 0; j < 3; j += 1) {
        this.pipelines.push(new Conv2d({
          device,
          inputTextures: outputTextures,
          shaderWGSL: shaders[3 * i + j],
          name: `conv2d_${i}_tf_${j}`,
        }));
      }
    }

    outputTextures.length = 0;
    for (let i = 6; i < this.pipelines.length; i += 1) {
      outputTextures.push(this.pipelines[i].getOutputTexture());
    }

    for (let i = 0; i <= 2; i += 1) {
      this.pipelines.push(new Conv2d({
        device,
        inputTextures: outputTextures,
        shaderWGSL: shaders[21 + i],
        name: `conv2d_last_tf_${i}`,
      }));
    }
    this.pipelines.push(new DepthToSpace({
      device,
      inputTextures: [
        this.pipelines[21].getOutputTexture(),
        this.pipelines[22].getOutputTexture(),
        this.pipelines[23].getOutputTexture(),
      ],
      name: 'DepthToSpace',
    }));
    this.pipelines.push(new Overlay({
      device,
      inputTextures: [inputTexture, this.pipelines[24].getOutputTexture()],
      outputTextureSize: [2 * inputTexture.width, 2 * inputTexture.height],
    }));
  }

  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  updateParam(param: string, value: any): void {
    throw new Error(`${this.constructor.name} has no param`);
  }

  getOutputTexture() : GPUTexture {
    return this.pipelines[this.pipelines.length - 1].getOutputTexture();
  }

  pass(encoder: GPUCommandEncoder) {
    for (let i = 0; i < this.pipelines.length; i += 1) {
      this.pipelines[i].pass(encoder);
    }
  }

  destroy(): void {
    this.pipelines.forEach((pipeline) => pipeline.destroy?.());
  }
}
