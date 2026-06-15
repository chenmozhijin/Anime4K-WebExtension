import conv2dtfWGSL from './shaders/conv2dtf.wgsl';
import conv2dtf1WGSL from './shaders/conv2dtf1.wgsl';
import conv2d1tfWGSL from './shaders/conv2d1tf.wgsl';
import conv2d1tf1WGSL from './shaders/conv2d1tf1.wgsl';
import conv2d1tf2WGSL from './shaders/conv2d1tf2.wgsl';
import conv2d2tfWGSL from './shaders/conv2d2tf.wgsl';
import conv2d2tf1WGSL from './shaders/conv2d2tf1.wgsl';
import conv2d3tfWGSL from './shaders/conv2d3tf.wgsl';
import conv2d3tf1WGSL from './shaders/conv2d3tf1.wgsl';
import conv2d3tf2WGSL from './shaders/conv2d3tf2.wgsl';
import conv2d4tfWGSL from './shaders/conv2d4tf.wgsl';
import conv2d4tf1WGSL from './shaders/conv2d4tf1.wgsl';
import conv2d5tfWGSL from './shaders/conv2d5tf.wgsl';
import conv2d5tf1WGSL from './shaders/conv2d5tf1.wgsl';
import conv2d5tf2WGSL from './shaders/conv2d5tf2.wgsl';
import conv2d6tfWGSL from './shaders/conv2d6tf.wgsl';
import conv2d6tf1WGSL from './shaders/conv2d6tf1.wgsl';
import output from './shaders/output.wgsl';

import { Anime4KPipeline, Anime4KPipelineDescriptor } from '../../interfaces';
import { Conv2d, Overlay } from '../../helpers';

export class GANUUL implements Anime4KPipeline {
  /**
   * pipelines:
   *  [0] conv2d_tf
   *  [1] conv2d_tf1
   *  [2] conv2d_1_tf
   *  [3] conv2d_1_tf1
   *  [4] conv2d_1_tf2
   *  [5] conv2d_2_tf
   *  [6] conv2d_2_tf1
   *  [7] conv2d_3_tf
   *  [8] conv2d_3_tf1
   *  [9] conv2d_3_tf2
   *  [10] conv2d_4_tf
   *  [11] conv2d_4_tf1
   *  [12] conv2d_5_tf
   *  [13] conv2d_5_tf1
   *  [14] conv2d_5_tf2
   *  [15] conv2d_6_tf
   *  [16] conv2d_6_tf1
   *  [17] output
   */
  pipelines: Anime4KPipeline[] = [];

  /**
   * Creates an instance of GANUUL.
   *
   * @param {Object} options - The options for the GANUUL pipeline.
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
      conv2d1tfWGSL, conv2d1tf1WGSL, conv2d1tf2WGSL,
      conv2d2tfWGSL, conv2d2tf1WGSL,
      conv2d3tfWGSL, conv2d3tf1WGSL, conv2d3tf2WGSL,
      conv2d4tfWGSL, conv2d4tf1WGSL,
      conv2d5tfWGSL, conv2d5tf1WGSL, conv2d5tf2WGSL,
      conv2d6tfWGSL, conv2d6tf1WGSL,
      output];

    // inputTexture -> 0, 1
    this.pipelines.push(new Conv2d({
      device,
      inputTextures: [inputTexture],
      shaderWGSL: shaders[0],
      name: 'conv2d_tf',
    }));
    this.pipelines.push(new Conv2d({
      device,
      inputTextures: [inputTexture],
      shaderWGSL: shaders[1],
      name: 'conv2d_tf1',
    }));

    // 0, 1 -> 2, 3, 4
    const outputTextures: GPUTexture[] = [];
    this.fillOutputTextures(outputTextures, 0, 2);
    for (let i = 0; i < 3; i += 1) {
      this.pipelines.push(new Conv2d({
        device,
        inputTextures: outputTextures,
        shaderWGSL: shaders[i + 2],
        name: `conv2d_1_tf_${i}`,
      }));
    }

    // 2, 3, 4 -> 5, 6
    outputTextures.length = 0;
    this.fillOutputTextures(outputTextures, 2, 3);
    for (let i = 0; i < 2; i += 1) {
      this.pipelines.push(new Conv2d({
        device,
        inputTextures: outputTextures,
        shaderWGSL: shaders[i + 5],
        name: `conv2d_2_tf_${i}`,
      }));
    }

    // 0, 1, 5, 6 -> 7, 8, 9
    outputTextures.length = 0;
    this.fillOutputTextures(outputTextures, 0, 2);
    this.fillOutputTextures(outputTextures, 5, 2);
    for (let i = 0; i < 3; i += 1) {
      this.pipelines.push(new Conv2d({
        device,
        inputTextures: outputTextures,
        shaderWGSL: shaders[i + 7],
        name: `conv2d_3_tf_${i}`,
      }));
    }

    // 7, 8, 9 -> 10, 11
    outputTextures.length = 0;
    this.fillOutputTextures(outputTextures, 7, 3);
    for (let i = 0; i < 2; i += 1) {
      this.pipelines.push(new Conv2d({
        device,
        inputTextures: outputTextures,
        shaderWGSL: shaders[i + 10],
        name: `conv2d_4_tf_${i}`,
      }));
    }

    // 5, 6, 10, 11 -> 12, 13, 14
    outputTextures.length = 0;
    this.fillOutputTextures(outputTextures, 5, 2);
    this.fillOutputTextures(outputTextures, 10, 2);
    for (let i = 0; i < 3; i += 1) {
      this.pipelines.push(new Conv2d({
        device,
        inputTextures: outputTextures,
        shaderWGSL: shaders[i + 12],
        name: `conv2d_5_tf_${i}`,
      }));
    }

    // 12, 13, 14 -> 15, 16
    outputTextures.length = 0;
    this.fillOutputTextures(outputTextures, 12, 3);
    for (let i = 0; i < 2; i += 1) {
      this.pipelines.push(new Conv2d({
        device,
        inputTextures: outputTextures,
        shaderWGSL: shaders[i + 15],
        name: `conv2d_6_tf_${i}`,
      }));
    }

    // 10, 11, 15, 16 -> output
    outputTextures.length = 0;
    this.fillOutputTextures(outputTextures, 10, 2);
    this.fillOutputTextures(outputTextures, 15, 2);
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

  fillOutputTextures(outputTextures: GPUTexture[], from: number, count: number) {
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
