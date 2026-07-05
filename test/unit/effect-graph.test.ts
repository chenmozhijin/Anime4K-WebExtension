import { beforeEach, describe, expect, it, vi } from 'vitest';

const {
  computeOptions,
  depthOptions,
  compositeOptions,
  resizeOptions,
  lumaOptions,
  passInstances,
} = vi.hoisted(() => ({
  computeOptions: [] as any[],
  depthOptions: [] as any[],
  compositeOptions: [] as any[],
  resizeOptions: [] as any[],
  lumaOptions: [] as any[],
  passInstances: [] as Array<{
    outputTexture: GPUTexture;
    pass: ReturnType<typeof vi.fn>;
    destroy: ReturnType<typeof vi.fn>;
  }>,
}));

function createMockPass(label: string, width: number, height: number) {
  const instance = {
    outputTexture: { label, width, height } as unknown as GPUTexture,
    pass: vi.fn(),
    destroy: vi.fn(),
    getOutputTexture: vi.fn(() => ({ label, width, height } as unknown as GPUTexture)),
  };
  instance.getOutputTexture.mockReturnValue(instance.outputTexture);
  passInstances.push(instance);
  return instance;
}

vi.mock('../../src/core/gpu-passes/compute-texture-pass', () => ({
  ComputeTexturePass: vi.fn(function ComputeTexturePass(options: any) {
    computeOptions.push(options);
    const firstInput = options.inputTextures[0];
    const width = options.outputSize?.width ?? firstInput.width;
    const height = options.outputSize?.height ?? firstInput.height;
    return createMockPass(`compute-${computeOptions.length}`, width, height);
  }),
}));

vi.mock('../../src/core/gpu-passes/depth-to-space-pass', () => ({
  DepthToSpacePass: vi.fn(function DepthToSpacePass(options: any) {
    depthOptions.push(options);
    return createMockPass(
      `depth-${depthOptions.length}`,
      options.inputTextures[0].width * 2,
      options.inputTextures[0].height * 2,
    );
  }),
}));

vi.mock('../../src/core/gpu-passes/render-composite-pass', () => ({
  RenderCompositePass: vi.fn(function RenderCompositePass(options: any) {
    compositeOptions.push(options);
    return createMockPass(`composite-${compositeOptions.length}`, options.outputSize.width, options.outputSize.height);
  }),
}));

vi.mock('../../src/core/shared-effects/downscale', () => ({
  Downscale: vi.fn(function Downscale(options: any) {
    resizeOptions.push(options);
    return createMockPass(`resize-${resizeOptions.length}`, options.targetDimensions.width, options.targetDimensions.height);
  }),
}));

vi.mock('../../src/core/gpu-passes/luma-recompose-pass', () => ({
  LumaRecomposePass: vi.fn(function LumaRecomposePass(options: any) {
    lumaOptions.push(options);
    return createMockPass(`luma-${lumaOptions.length}`, options.outputSize.width, options.outputSize.height);
  }),
}));

import { EffectGraphRunner } from '../../src/core/effects/graph';
import { createCNNLGraph } from '../../src/engines/anime4k/pipelines/restore/CNNL/graph';
import { createCNNMGraph } from '../../src/engines/anime4k/pipelines/restore/CNNM/graph';
import { createCNNSGraph } from '../../src/engines/anime4k/pipelines/restore/CNNS/graph';
import { createCNNSoftMGraph } from '../../src/engines/anime4k/pipelines/restore/CNNSoftM/graph';
import { createCNNSoftVLGraph } from '../../src/engines/anime4k/pipelines/restore/CNNSoftVL/graph';
import { createCNNULGraph } from '../../src/engines/anime4k/pipelines/restore/CNNUL/graph';
import { createCNNVLGraph } from '../../src/engines/anime4k/pipelines/restore/CNNVL/graph';
import { createGANUULGraph } from '../../src/engines/anime4k/pipelines/restore/GANUUL/graph';
import { createDenoiseCNNx2VLGraph } from '../../src/engines/anime4k/pipelines/upscale/DenoiseCNNx2VL/graph';
import { createCNNx2LGraph } from '../../src/engines/anime4k/pipelines/upscale/CNNx2L/graph';
import { createCNNx2MGraph } from '../../src/engines/anime4k/pipelines/upscale/CNNx2M/graph';
import { createCNNx2SGraph } from '../../src/engines/anime4k/pipelines/upscale/CNNx2S/graph';
import { createCNNx2ULGraph } from '../../src/engines/anime4k/pipelines/upscale/CNNx2UL/graph';
import { createCNNx2VLGraph } from '../../src/engines/anime4k/pipelines/upscale/CNNx2VL/graph';
import { createGANx3LGraph } from '../../src/engines/anime4k/pipelines/upscale/GANx3L/graph';
import { createGANx4UULGraph } from '../../src/engines/anime4k/pipelines/upscale/GANx4UUL/graph';

describe('EffectGraphRunner', () => {
  beforeEach(() => {
    computeOptions.length = 0;
    depthOptions.length = 0;
    compositeOptions.length = 0;
    resizeOptions.length = 0;
    lumaOptions.length = 0;
    passInstances.length = 0;
  });

  it('builds graph stages in order, resolves texture symbols, and forwards pass/destroy', () => {
    const device = {} as GPUDevice;
    const inputTexture = { label: 'input', width: 16, height: 9 } as unknown as GPUTexture;
    const runner = new EffectGraphRunner({
      device,
      inputTexture,
      graph: {
        input: 'input',
        output: 'output',
        stages: [{
          id: 'conv0',
          op: 'compute',
          inputs: ['input'],
          output: 'conv0',
          shaderWGSL: 'shader-0',
          cacheKeyPrefix: 'test/conv',
        }, {
          id: 'conv1',
          op: 'compute',
          inputs: ['conv0'],
          output: 'conv1',
          shaderWGSL: 'shader-1',
          cacheKeyPrefix: 'test/conv',
          outputSize: { kind: 'texture', texture: 'input', scale: 2 },
        }, {
          id: 'depth',
          op: 'depth-to-space',
          inputs: ['conv1', 'conv1', 'conv1'],
          output: 'depth',
          cacheKeyPrefix: 'test/depth',
        }, {
          id: 'composite',
          op: 'render-composite',
          inputs: ['input', 'depth'],
          output: 'output',
          fragmentWGSL: 'fragment',
          outputSize: { kind: 'texture', texture: 'input', scale: 2 },
          cacheKeyPrefix: 'test/composite',
        }],
      },
    });

    expect(computeOptions[0].inputTextures).toEqual([inputTexture]);
    expect(computeOptions[1].inputTextures).toEqual([passInstances[0].outputTexture]);
    expect(computeOptions[1].outputSize).toEqual({ width: 32, height: 18 });
    expect(depthOptions[0].inputTextures).toEqual([
      passInstances[1].outputTexture,
      passInstances[1].outputTexture,
      passInstances[1].outputTexture,
    ]);
    expect(compositeOptions[0].inputTextures).toEqual([inputTexture, passInstances[2].outputTexture]);
    expect(compositeOptions[0].outputSize).toEqual({ width: 32, height: 18 });
    expect(runner.getOutputTexture()).toBe(passInstances[3].outputTexture);

    const encoder = {} as GPUCommandEncoder;
    runner.pass(encoder);
    passInstances.forEach(instance => expect(instance.pass).toHaveBeenCalledWith(encoder, undefined));

    runner.destroy();
    passInstances.forEach(instance => expect(instance.destroy).toHaveBeenCalledTimes(1));
  });

  it('covers resize and luma-recompose stages', () => {
    const device = {} as GPUDevice;
    const inputTexture = { label: 'input', width: 20, height: 10 } as unknown as GPUTexture;
    const runner = new EffectGraphRunner({
      device,
      inputTexture,
      graph: {
        input: 'input',
        output: 'rgba',
        stages: [{
          id: 'resize',
          op: 'resize',
          input: 'input',
          output: 'resized',
          outputSize: { kind: 'absolute', width: 10, height: 5 },
        }, {
          id: 'luma',
          op: 'compute',
          inputs: ['resized'],
          output: 'luma',
          shaderWGSL: 'luma-shader',
          cacheKeyPrefix: 'test/luma',
        }, {
          id: 'recompose',
          op: 'luma-recompose',
          source: 'resized',
          luma: 'luma',
          output: 'rgba',
          outputSize: { kind: 'texture', texture: 'luma' },
          cacheKeyPrefix: 'test/recompose',
        }],
      },
    });

    expect(resizeOptions[0].targetDimensions).toEqual({ width: 10, height: 5 });
    expect(lumaOptions[0].sourceTexture).toBe(passInstances[0].outputTexture);
    expect(lumaOptions[0].lumaTexture).toBe(passInstances[1].outputTexture);
    expect(runner.getOutputTexture()).toBe(passInstances[2].outputTexture);
  });

  it('fails fast when a stage references an undefined texture symbol', () => {
    expect(() => new EffectGraphRunner({
      device: {} as GPUDevice,
      inputTexture: { width: 16, height: 9 } as unknown as GPUTexture,
      graph: {
        input: 'input',
        output: 'output',
        stages: [{
          id: 'bad',
          op: 'compute',
          inputs: ['missing'],
          output: 'output',
          shaderWGSL: 'shader',
          cacheKeyPrefix: 'test/bad',
        }],
      },
    })).toThrow('Effect graph texture is not defined: missing');
  });

  it('describes Anime4K CNNx2M without exporting extra pipeline constructors from the effect module', () => {
    const graph = createCNNx2MGraph();

    expect(graph.input).toBe('input');
    expect(graph.output).toBe('output');
    expect(graph.stages).toHaveLength(10);
    expect(graph.stages.slice(0, 8).map(stage => stage.op)).toEqual(Array(8).fill('compute'));
    expect(graph.stages[8]).toMatchObject({
      id: 'depth-to-space',
      op: 'depth-to-space',
      inputs: ['conv-last', 'conv-last', 'conv-last'],
      output: 'depth',
    });
    expect(graph.stages[9]).toMatchObject({
      id: 'overlay',
      op: 'render-composite',
      inputs: ['input', 'depth'],
      output: 'output',
      outputSize: { kind: 'texture', texture: 'input', scale: 2 },
    });
  });

  it('describes Anime4K CNNS and CNNx2S as graph pipelines', () => {
    const restoreGraph = createCNNSGraph();
    expect(restoreGraph.stages.map(stage => stage.op)).toEqual([
      'compute',
      'compute',
      'compute',
      'compute',
      'render-composite',
    ]);
    expect(restoreGraph.stages[4]).toMatchObject({
      id: 'overlay',
      inputs: ['input', 'restore'],
      outputSize: { kind: 'texture', texture: 'input' },
    });

    const upscaleGraph = createCNNx2SGraph();
    expect(upscaleGraph.stages.map(stage => stage.op)).toEqual([
      'compute',
      'compute',
      'compute',
      'compute',
      'depth-to-space',
      'render-composite',
    ]);
    expect(upscaleGraph.stages[4]).toMatchObject({
      id: 'depth-to-space',
      inputs: ['conv-last', 'conv-last', 'conv-last'],
    });
    expect(upscaleGraph.stages[5]).toMatchObject({
      id: 'overlay',
      inputs: ['input', 'depth'],
      outputSize: { kind: 'texture', texture: 'input', scale: 2 },
    });
  });

  it('describes Anime4K CNNM and CNNSoftM as graph restore pipelines', () => {
    for (const graph of [createCNNMGraph(), createCNNSoftMGraph()]) {
      expect(graph.input).toBe('input');
      expect(graph.output).toBe('output');
      expect(graph.stages.map(stage => stage.op)).toEqual([
        'compute',
        'compute',
        'compute',
        'compute',
        'compute',
        'compute',
        'compute',
        'compute',
        'render-composite',
      ]);
      expect(graph.stages[7]).toMatchObject({
        id: 'output',
        inputs: ['conv0', 'conv1', 'conv2', 'conv3', 'conv4', 'conv5', 'conv6'],
        output: 'restore',
      });
      expect(graph.stages[8]).toMatchObject({
        id: 'overlay',
        inputs: ['input', 'restore'],
        output: 'output',
        outputSize: { kind: 'texture', texture: 'input' },
      });
    }
  });

  it('describes Anime4K CNNL and CNNx2L branch graph pipelines', () => {
    const restoreGraph = createCNNLGraph();
    expect(restoreGraph.stages.map(stage => stage.op)).toEqual([
      'compute',
      'compute',
      'compute',
      'compute',
      'compute',
      'compute',
      'compute',
      'compute',
      'compute',
      'render-composite',
    ]);
    expect(restoreGraph.stages[2]).toMatchObject({
      id: 'conv2d_1_tf',
      inputs: ['conv0', 'conv1'],
      output: 'conv2',
    });
    expect(restoreGraph.stages[8]).toMatchObject({
      id: 'output',
      inputs: ['conv6', 'conv7'],
      output: 'restore',
    });
    expect(restoreGraph.stages[9]).toMatchObject({
      id: 'overlay',
      inputs: ['input', 'restore'],
      outputSize: { kind: 'texture', texture: 'input' },
    });

    const upscaleGraph = createCNNx2LGraph();
    expect(upscaleGraph.stages.map(stage => stage.op)).toEqual([
      'compute',
      'compute',
      'compute',
      'compute',
      'compute',
      'compute',
      'compute',
      'compute',
      'compute',
      'depth-to-space',
      'render-composite',
    ]);
    expect(upscaleGraph.stages[6]).toMatchObject({
      id: 'conv2d_last_tf_0',
      inputs: ['conv4', 'conv5'],
      output: 'last0',
    });
    expect(upscaleGraph.stages[9]).toMatchObject({
      id: 'depth-to-space',
      inputs: ['last0', 'last1', 'last2'],
      output: 'depth',
    });
    expect(upscaleGraph.stages[10]).toMatchObject({
      id: 'overlay',
      inputs: ['input', 'depth'],
      outputSize: { kind: 'texture', texture: 'input', scale: 2 },
    });
  });

  it('describes Anime4K VL branch graph pipelines', () => {
    for (const graph of [createCNNVLGraph(), createCNNSoftVLGraph()]) {
      expect(graph.stages).toHaveLength(18);
      expect(graph.stages.slice(0, 16).map(stage => stage.op)).toEqual(Array(16).fill('compute'));
      expect(graph.stages[2]).toMatchObject({
        id: 'conv2d_1_tf',
        inputs: ['conv0', 'conv1'],
        output: 'conv2',
      });
      expect(graph.stages[14]).toMatchObject({
        id: 'conv2d_7_tf',
        inputs: ['conv12', 'conv13'],
        output: 'conv14',
      });
      expect(graph.stages[16]).toMatchObject({
        id: 'output',
        inputs: [
          'conv2',
          'conv3',
          'conv4',
          'conv5',
          'conv6',
          'conv7',
          'conv8',
          'conv9',
          'conv10',
          'conv11',
          'conv12',
          'conv13',
          'conv14',
          'conv15',
        ],
        output: 'restore',
      });
      expect(graph.stages[17]).toMatchObject({
        id: 'overlay',
        inputs: ['input', 'restore'],
        outputSize: { kind: 'texture', texture: 'input' },
      });
    }

    for (const graph of [createCNNx2VLGraph(), createDenoiseCNNx2VLGraph()]) {
      expect(graph.stages).toHaveLength(19);
      expect(graph.stages.slice(0, 17).map(stage => stage.op)).toEqual(Array(17).fill('compute'));
      expect(graph.stages[14]).toMatchObject({
        id: 'conv2d_last_tf_0',
        inputs: [
          'conv0',
          'conv1',
          'conv2',
          'conv3',
          'conv4',
          'conv5',
          'conv6',
          'conv7',
          'conv8',
          'conv9',
          'conv10',
          'conv11',
          'conv12',
          'conv13',
        ],
        output: 'last0',
      });
      expect(graph.stages[17]).toMatchObject({
        id: 'depth-to-space',
        inputs: ['last0', 'last1', 'last2'],
        output: 'depth',
      });
      expect(graph.stages[18]).toMatchObject({
        id: 'overlay',
        inputs: ['input', 'depth'],
        outputSize: { kind: 'texture', texture: 'input', scale: 2 },
      });
    }
  });

  it('describes Anime4K UL triple-branch graph pipelines', () => {
    const restoreGraph = createCNNULGraph();
    expect(restoreGraph.stages).toHaveLength(26);
    expect(restoreGraph.stages.slice(0, 24).map(stage => stage.op)).toEqual(Array(24).fill('compute'));
    expect(restoreGraph.stages[3]).toMatchObject({
      id: 'conv2d_1_tf_0',
      inputs: ['conv0', 'conv1', 'conv2'],
      output: 'conv3',
    });
    expect(restoreGraph.stages[24]).toMatchObject({
      id: 'output',
      inputs: [
        'conv9',
        'conv10',
        'conv11',
        'conv12',
        'conv13',
        'conv14',
        'conv15',
        'conv16',
        'conv17',
        'conv18',
        'conv19',
        'conv20',
        'conv21',
        'conv22',
        'conv23',
      ],
      output: 'restore',
    });
    expect(restoreGraph.stages[25]).toMatchObject({
      id: 'overlay',
      inputs: ['input', 'restore'],
      outputSize: { kind: 'texture', texture: 'input' },
    });

    const upscaleGraph = createCNNx2ULGraph();
    expect(upscaleGraph.stages).toHaveLength(26);
    expect(upscaleGraph.stages.slice(0, 24).map(stage => stage.op)).toEqual(Array(24).fill('compute'));
    expect(upscaleGraph.stages[21]).toMatchObject({
      id: 'conv2d_last_tf_0',
      inputs: [
        'conv6',
        'conv7',
        'conv8',
        'conv9',
        'conv10',
        'conv11',
        'conv12',
        'conv13',
        'conv14',
        'conv15',
        'conv16',
        'conv17',
        'conv18',
        'conv19',
        'conv20',
      ],
      output: 'last0',
    });
    expect(upscaleGraph.stages[24]).toMatchObject({
      id: 'depth-to-space',
      inputs: ['last0', 'last1', 'last2'],
      output: 'depth',
    });
    expect(upscaleGraph.stages[25]).toMatchObject({
      id: 'overlay',
      inputs: ['input', 'depth'],
      outputSize: { kind: 'texture', texture: 'input', scale: 2 },
    });
  });

  it('describes Anime4K GANUUL graph skip connections and half residual output', () => {
    const graph = createGANUULGraph();

    expect(graph.stages).toHaveLength(19);
    expect(graph.stages.slice(0, 18).map(stage => stage.op)).toEqual(Array(18).fill('compute'));
    expect(graph.stages[7]).toMatchObject({
      id: 'conv2d_3_tf_0',
      inputs: ['conv0', 'conv1', 'conv5', 'conv6'],
      output: 'conv7',
    });
    expect(graph.stages[12]).toMatchObject({
      id: 'conv2d_5_tf_0',
      inputs: ['conv5', 'conv6', 'conv10', 'conv11'],
      output: 'conv12',
    });
    expect(graph.stages[17]).toMatchObject({
      id: 'output',
      inputs: ['conv10', 'conv11', 'conv15', 'conv16'],
      output: 'residual',
    });
    expect(graph.stages[18]).toMatchObject({
      id: 'output-half-residual',
      op: 'render-composite',
      inputs: ['input', 'residual'],
      output: 'output',
      outputSize: { kind: 'texture', texture: 'input' },
    });
  });

  it('describes Anime4K GANx3L graph upsample wiring', () => {
    const graph = createGANx3LGraph();

    expect(graph.stages).toHaveLength(30);
    expect(graph.stages.slice(0, 27).map(stage => stage.op)).toEqual(Array(27).fill('compute'));
    expect(graph.stages[5]).toMatchObject({
      id: 'conv2d_3_tf',
      inputs: ['conv0', 'conv1', 'conv2', 'conv3', 'conv4'],
      output: 'conv5',
    });
    expect(graph.stages[20]).toMatchObject({
      id: 'conv2d_12_tf',
      inputs: ['conv15', 'conv16', 'conv17', 'conv18', 'conv4', 'conv9', 'conv14', 'conv19'],
      output: 'conv20',
    });
    expect(graph.stages[24]).toMatchObject({
      id: 'conv0ups',
      inputs: ['conv20', 'conv21', 'conv22', 'conv18', 'conv4', 'conv9', 'conv14', 'conv19', 'conv23'],
      output: 'ups0',
    });
    expect(graph.stages[27]).toMatchObject({
      id: 'conv1ups',
      op: 'render-composite',
      inputs: ['ups0', 'ups1', 'ups2'],
      outputSize: { kind: 'texture', texture: 'input', scale: 3 },
    });
    expect(graph.stages[29]).toMatchObject({
      id: 'output',
      op: 'render-composite',
      inputs: ['overlay0', 'overlay1', 'input'],
      output: 'output',
      outputSize: { kind: 'texture', texture: 'input', scale: 3 },
    });
  });

  it('describes Anime4K GANx4UUL graph upsample wiring', () => {
    const graph = createGANx4UULGraph();

    expect(graph.stages).toHaveLength(85);
    expect(graph.stages.slice(0, 77).map(stage => stage.op)).toEqual(Array(77).fill('compute'));
    expect(graph.stages[8]).toMatchObject({
      id: 'conv2d_3_tf',
      inputs: [
        'conv2d_tf',
        'conv2d_tf1',
        'conv2d_tf2',
        'conv2d_tf3',
        'conv2d_tf4',
        'conv2d_tf5',
        'conv2d_2_tf',
        'conv2d_1_tf',
      ],
      output: 'conv2d_3_tf',
    });
    expect(graph.stages[70]).toMatchObject({
      id: 'conv2d_25_tf',
      inputs: [
        'conv2d_24_tf',
        'conv2d_24_tf1',
        'conv2d_24_tf2',
        'conv2d_24_tf3',
        'conv2d_24_tf4',
        'conv2d_24_tf5',
      ],
      output: 'conv2d_25_tf',
    });
    expect(graph.stages[71]).toMatchObject({
      id: 'conv0ups',
      inputs: [
        'conv2d_24_tf',
        'conv2d_24_tf1',
        'conv2d_24_tf2',
        'conv2d_24_tf3',
        'conv2d_24_tf4',
        'conv2d_24_tf5',
        'conv2d_23_tf',
        'conv2d_1_tf',
        'conv2d_4_tf',
        'conv2d_7_tf',
        'conv2d_10_tf',
        'conv2d_13_tf',
        'conv2d_16_tf',
        'conv2d_19_tf',
        'conv2d_22_tf',
        'conv2d_25_tf',
      ],
      output: 'conv0ups',
    });
    expect(graph.stages[77]).toMatchObject({
      id: 'conv1ups',
      op: 'render-composite',
      inputs: ['conv0ups', 'conv0ups1', 'conv0ups2', 'conv0ups3', 'conv0ups4', 'conv0ups5'],
      outputSize: { kind: 'texture', texture: 'input', scale: 4 },
    });
    expect(graph.stages[83]).toMatchObject({
      id: 'output',
      op: 'compute',
      inputs: ['conv1ups', 'conv1ups1', 'conv1ups2', 'conv1ups3', 'conv1ups4', 'conv1ups5'],
      output: 'output-conv',
    });
    expect(graph.stages[84]).toMatchObject({
      id: 'overlay',
      op: 'render-composite',
      inputs: ['input', 'output-conv'],
      output: 'output',
      outputSize: { kind: 'texture', texture: 'input', scale: 4 },
    });
  });
});
