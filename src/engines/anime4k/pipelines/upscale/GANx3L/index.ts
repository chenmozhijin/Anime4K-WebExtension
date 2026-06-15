import conv2d0tf0WGSL from './shaders/conv2d0tf0.wgsl';
import conv2d0tf1WGSL from './shaders/conv2d0tf1.wgsl';
import conv2d0tf2WGSL from './shaders/conv2d0tf2.wgsl';
import conv2d1tfWGSL from './shaders/conv2d1tf.wgsl';
import conv2d2tfWGSL from './shaders/conv2d2tf.wgsl';
import conv2d3tf0WGSL from './shaders/conv2d3tf0.wgsl';
import conv2d3tf1WGSL from './shaders/conv2d3tf1.wgsl';
import conv2d3tf2WGSL from './shaders/conv2d3tf2.wgsl';
import conv2d4tfWGSL from './shaders/conv2d4tf.wgsl';
import conv2d5tfWGSL from './shaders/conv2d5tf.wgsl';
import conv2d6tf0WGSL from './shaders/conv2d6tf0.wgsl';
import conv2d6tf1WGSL from './shaders/conv2d6tf1.wgsl';
import conv2d6tf2WGSL from './shaders/conv2d6tf2.wgsl';
import conv2d7tfWGSL from './shaders/conv2d7tf.wgsl';
import conv2d8tfWGSL from './shaders/conv2d8tf.wgsl';
import conv2d9tf0WGSL from './shaders/conv2d9tf0.wgsl';
import conv2d9tf1WGSL from './shaders/conv2d9tf1.wgsl';
import conv2d9tf2WGSL from './shaders/conv2d9tf2.wgsl';
import conv2d10tfWGSL from './shaders/conv2d10tf.wgsl';
import conv2d11tfWGSL from './shaders/conv2d11tf.wgsl';
import conv2d12tf0WGSL from './shaders/conv2d12tf0.wgsl';
import conv2d12tf1WGSL from './shaders/conv2d12tf1.wgsl';
import conv2d12tf2WGSL from './shaders/conv2d12tf2.wgsl';
import conv2d13tfWGSL from './shaders/conv2d13tf.wgsl';
import conv0ups0WGSL from './shaders/conv0ups0.wgsl';
import conv0ups1WGSL from './shaders/conv0ups1.wgsl';
import conv0ups2WGSL from './shaders/conv0ups2.wgsl';
import overlayConv1ups0WGSL from './shaders/overlayConv1ups0.wgsl';
import overlayConv1ups1WGSL from './shaders/overlayConv1ups1.wgsl';
import overlayOutputWGSL from './shaders/overlayOutput.wgsl';

import { Anime4KPipeline, Anime4KPipelineDescriptor } from '../../interfaces';
import { Conv2d, Overlay } from '../../helpers';

export class GANx3L implements Anime4KPipeline {
  /**
   * pipelines:
   *  [0] conv2d_tf
   *  [1] conv2d_tf1
   *  [2] conv2d_tf2
   *  [3] conv2d_2_tf
   *  [4] conv2d_1_tf
   *  [5] conv2d_3_tf
   *  [6] conv2d_3_tf1
   *  [7] conv2d_3_tf2
   *  [8] conv2d_5_tf
   *  [9] conv2d_4_tf
   *  [10] conv2d_6_tf
   *  [11] conv2d_6_tf1
   *  [12] conv2d_6_tf2
   *  [13] conv2d_8_tf
   *  [14] conv2d_7_tf
   *  [15] conv2d_9_tf
   *  [16] conv2d_9_tf1
   *  [17] conv2d_9_tf2
   *  [18] conv2d_11_tf
   *  [19] conv2d_10_tf
   *  [20] conv2d_12_tf
   *  [21] conv2d_12_tf1
   *  [22] conv2d_12_tf2
   *  [23] conv2d_13_tf
   *  [24] conv0ups
   *  [25] conv0ups1
   *  [26] conv0ups2
   *  [27] conv1ups
   *  [28] conv1ups1
   *  [29] output
   */
  pipelines: Anime4KPipeline[] = [];

  /**
   * Creates an instance of GANx3L.
   *
   * @param {Object} options - The options for the GANx3L pipeline.
   * @param {GPUDevice} options.device - The GPU device to use for
   * creating textures and shader modules.
   * @param {GPUTexture} options.inputTexture - The input texture for the pipeline.
   */
  constructor({
    device,
    inputTexture,
  }: Anime4KPipelineDescriptor) {
    this.pipelines.push(new Conv2d({
      device,
      inputTextures: [inputTexture],
      shaderWGSL: conv2d0tf0WGSL,
      name: 'conv2d_tf',
    }));
    this.pipelines.push(new Conv2d({
      device,
      inputTextures: [inputTexture],
      shaderWGSL: conv2d0tf1WGSL,
      name: 'conv2d_tf1',
    }));
    this.pipelines.push(new Conv2d({
      device,
      inputTextures: [inputTexture],
      shaderWGSL: conv2d0tf2WGSL,
      name: 'conv2d_tf2',
    }));

    const outputTextures: GPUTexture[] = [];
    this.fillOutputTextures(outputTextures, 0, 3);
    this.pipelines.push(new Conv2d({
      device,
      inputTextures: outputTextures,
      shaderWGSL: conv2d2tfWGSL,
      name: 'conv2d_2_tf',
    }));
    this.pipelines.push(new Conv2d({
      device,
      inputTextures: outputTextures,
      shaderWGSL: conv2d1tfWGSL,
      name: 'conv2d_1_tf',
    }));

    outputTextures.push(this.pipelines[3].getOutputTexture());
    outputTextures.push(this.pipelines[4].getOutputTexture());
    this.pipelines.push(new Conv2d({
      device,
      inputTextures: outputTextures,
      shaderWGSL: conv2d3tf0WGSL,
      name: 'conv2d_3_tf',
    }));
    this.pipelines.push(new Conv2d({
      device,
      inputTextures: outputTextures,
      shaderWGSL: conv2d3tf1WGSL,
      name: 'conv2d_3_tf1',
    }));
    this.pipelines.push(new Conv2d({
      device,
      inputTextures: outputTextures,
      shaderWGSL: conv2d3tf2WGSL,
      name: 'conv2d_3_tf2',
    }));

    outputTextures.length = 0;
    this.fillOutputTextures(outputTextures, 5, 3);
    this.pipelines.push(new Conv2d({
      device,
      inputTextures: outputTextures,
      shaderWGSL: conv2d5tfWGSL,
      name: 'conv2d_5_tf',
    }));
    this.pipelines.push(new Conv2d({
      device,
      inputTextures: outputTextures,
      shaderWGSL: conv2d4tfWGSL,
      name: 'conv2d_4_tf',
    }));

    outputTextures.push(this.pipelines[8].getOutputTexture());
    outputTextures.push(this.pipelines[4].getOutputTexture());
    outputTextures.push(this.pipelines[9].getOutputTexture());
    this.pipelines.push(new Conv2d({
      device,
      inputTextures: outputTextures,
      shaderWGSL: conv2d6tf0WGSL,
      name: 'conv2d_6_tf',
    }));
    this.pipelines.push(new Conv2d({
      device,
      inputTextures: outputTextures,
      shaderWGSL: conv2d6tf1WGSL,
      name: 'conv2d_6_tf1',
    }));
    this.pipelines.push(new Conv2d({
      device,
      inputTextures: outputTextures,
      shaderWGSL: conv2d6tf2WGSL,
      name: 'conv2d_6_tf2',
    }));

    outputTextures.length = 0;
    this.fillOutputTextures(outputTextures, 10, 3);
    this.pipelines.push(new Conv2d({
      device,
      inputTextures: outputTextures,
      shaderWGSL: conv2d8tfWGSL,
      name: 'conv2d_8_tf',
    }));
    this.pipelines.push(new Conv2d({
      device,
      inputTextures: outputTextures,
      shaderWGSL: conv2d7tfWGSL,
      name: 'conv2d_7_tf',
    }));

    outputTextures.push(this.pipelines[13].getOutputTexture());
    outputTextures.push(this.pipelines[4].getOutputTexture());
    outputTextures.push(this.pipelines[9].getOutputTexture());
    outputTextures.push(this.pipelines[14].getOutputTexture());
    this.pipelines.push(new Conv2d({
      device,
      inputTextures: outputTextures,
      shaderWGSL: conv2d9tf0WGSL,
      name: 'conv2d_9_tf',
    }));
    this.pipelines.push(new Conv2d({
      device,
      inputTextures: outputTextures,
      shaderWGSL: conv2d9tf1WGSL,
      name: 'conv2d_9_tf1',
    }));
    this.pipelines.push(new Conv2d({
      device,
      inputTextures: outputTextures,
      shaderWGSL: conv2d9tf2WGSL,
      name: 'conv2d_9_tf2',
    }));

    outputTextures.length = 0;
    this.fillOutputTextures(outputTextures, 15, 3);
    this.pipelines.push(new Conv2d({
      device,
      inputTextures: outputTextures,
      shaderWGSL: conv2d11tfWGSL,
      name: 'conv2d_11_tf',
    }));
    this.pipelines.push(new Conv2d({
      device,
      inputTextures: outputTextures,
      shaderWGSL: conv2d10tfWGSL,
      name: 'conv2d_10_tf',
    }));

    outputTextures.push(this.pipelines[18].getOutputTexture());
    outputTextures.push(this.pipelines[4].getOutputTexture());
    outputTextures.push(this.pipelines[9].getOutputTexture());
    outputTextures.push(this.pipelines[14].getOutputTexture());
    outputTextures.push(this.pipelines[19].getOutputTexture());
    this.pipelines.push(new Conv2d({
      device,
      inputTextures: outputTextures,
      shaderWGSL: conv2d12tf0WGSL,
      name: 'conv2d_12_tf',
    }));
    this.pipelines.push(new Conv2d({
      device,
      inputTextures: outputTextures,
      shaderWGSL: conv2d12tf1WGSL,
      name: 'conv2d_12_tf1',
    }));
    this.pipelines.push(new Conv2d({
      device,
      inputTextures: outputTextures,
      shaderWGSL: conv2d12tf2WGSL,
      name: 'conv2d_12_tf2',
    }));

    outputTextures.length = 0;
    this.fillOutputTextures(outputTextures, 20, 3);
    this.pipelines.push(new Conv2d({
      device,
      inputTextures: outputTextures,
      shaderWGSL: conv2d13tfWGSL,
      name: 'conv2d_13_tf',
    }));

    outputTextures.push(this.pipelines[18].getOutputTexture());
    outputTextures.push(this.pipelines[4].getOutputTexture());
    outputTextures.push(this.pipelines[9].getOutputTexture());
    outputTextures.push(this.pipelines[14].getOutputTexture());
    outputTextures.push(this.pipelines[19].getOutputTexture());
    outputTextures.push(this.pipelines[23].getOutputTexture());
    this.pipelines.push(new Conv2d({
      device,
      inputTextures: outputTextures,
      shaderWGSL: conv0ups0WGSL,
      name: 'conv0ups',
    }));
    this.pipelines.push(new Conv2d({
      device,
      inputTextures: outputTextures,
      shaderWGSL: conv0ups1WGSL,
      name: 'conv0ups1',
    }));
    this.pipelines.push(new Conv2d({
      device,
      inputTextures: outputTextures,
      shaderWGSL: conv0ups2WGSL,
      name: 'conv0ups2',
    }));

    outputTextures.length = 0;
    this.fillOutputTextures(outputTextures, 24, 3);
    this.pipelines.push(new Overlay({
      device,
      inputTextures: outputTextures,
      outputTextureSize: [3 * inputTexture.width, 3 * inputTexture.height],
      fragmentWGSL: overlayConv1ups0WGSL,
      name: 'conv1ups',
    }));
    this.pipelines.push(new Overlay({
      device,
      inputTextures: outputTextures,
      outputTextureSize: [3 * inputTexture.width, 3 * inputTexture.height],
      fragmentWGSL: overlayConv1ups1WGSL,
      name: 'conv1ups1',
    }));
    this.pipelines.push(new Overlay({
      device,
      inputTextures: [
        this.pipelines[27].getOutputTexture(),
        this.pipelines[28].getOutputTexture(),
        inputTexture,
      ],
      outputTextureSize: [3 * inputTexture.width, 3 * inputTexture.height],
      fragmentWGSL: overlayOutputWGSL,
      name: 'output',
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
