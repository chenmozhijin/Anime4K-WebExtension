import { beforeEach, describe, expect, it, vi } from 'vitest';

const { pipelineDescriptors, borrowTextureMock, releaseTextureMock } = vi.hoisted(() => ({
  pipelineDescriptors: [] as Array<GPUComputePipelineDescriptor | GPURenderPipelineDescriptor>,
  borrowTextureMock: vi.fn(),
  releaseTextureMock: vi.fn(),
}));

vi.mock('../../src/core/gpu-resource-cache', () => ({
  getOrCreateShaderModule: vi.fn((_device: GPUDevice, _key: string, create: () => unknown) => create()),
  getOrCreateBindGroupLayout: vi.fn((_device: GPUDevice, _key: string, create: () => unknown) => create()),
  getOrCreateComputePipeline: vi.fn((_device: GPUDevice, _key: string, create: () => GPUComputePipelineDescriptor) => {
    const descriptor = create();
    pipelineDescriptors.push(descriptor);
    return descriptor;
  }),
  getOrCreateRenderPipeline: vi.fn((_device: GPUDevice, _key: string, create: () => GPURenderPipelineDescriptor) => {
    const descriptor = create();
    pipelineDescriptors.push(descriptor);
    return descriptor;
  }),
  getOrCreateSampler: vi.fn((_device: GPUDevice, _key: string, create: () => unknown) => create()),
  createBindGroupChecked: vi.fn((_device: GPUDevice, _key: string, create: () => unknown) => create()),
}));

vi.mock('../../src/core/texture-pool', () => ({
  borrowTexture: borrowTextureMock,
  releaseTexture: releaseTextureMock,
}));

import { PixelShuffleRecomposePass } from '../../src/core/gpu-passes/pixel-shuffle-recompose-pass';

describe('PixelShuffleRecomposePass', () => {
  const sourceTexture = { createView: vi.fn(() => ({})) } as unknown as GPUTexture;
  const packedLumaTexture = {
    width: 112,
    height: 48,
    createView: vi.fn(() => ({})),
  } as unknown as GPUTexture;
  const device = { createPipelineLayout: vi.fn(descriptor => descriptor) } as unknown as GPUDevice;

  beforeEach(() => {
    pipelineDescriptors.length = 0;
    borrowTextureMock.mockReset();
    releaseTextureMock.mockReset();
  });

  it('dispatches one invocation per packed source pixel and preserves explicit f16 quantization', () => {
    const outputTexture = {
      width: 224,
      height: 96,
      createView: vi.fn(() => ({})),
    } as unknown as GPUTexture;
    borrowTextureMock.mockReturnValue(outputTexture);
    const dispatchWorkgroups = vi.fn();
    const pass = new PixelShuffleRecomposePass({
      device,
      sourceTexture,
      packedLumaTexture,
      outputSize: { width: 224, height: 96 },
      name: 'acnet-test',
      cacheKeyPrefix: 'acnet',
    });

    pass.pass({
      beginComputePass: () => ({
        setPipeline: vi.fn(),
        setBindGroup: vi.fn(),
        dispatchWorkgroups,
        end: vi.fn(),
      }),
    } as unknown as GPUCommandEncoder);

    expect(dispatchWorkgroups).toHaveBeenCalledWith(14, 6);
    const computeCode = (pipelineDescriptors[0] as GPUComputePipelineDescriptor)
      .compute.module as unknown as { code: string };
    expect(computeCode.code).toContain('unpack2x16float(pack2x16float');
    expect(computeCode.code).toContain('textureStore(outTex, outputBase');

    pass.destroy();
    expect(releaseTextureMock).toHaveBeenCalledWith(outputTexture);
  });

  it('renders directly to the terminal without allocating a 2x intermediate texture', () => {
    const terminalView = {} as GPUTextureView;
    const draw = vi.fn();
    const pass = new PixelShuffleRecomposePass({
      device,
      sourceTexture,
      packedLumaTexture,
      outputSize: { width: 224, height: 96 },
      name: 'acnet-terminal',
      cacheKeyPrefix: 'acnet',
      terminalTarget: {
        width: 224,
        height: 96,
        format: 'bgra8unorm',
        getCurrentView: () => terminalView,
      },
    });

    pass.pass({
      beginRenderPass: vi.fn(() => ({
        setPipeline: vi.fn(),
        setBindGroup: vi.fn(),
        draw,
        end: vi.fn(),
      })),
    } as unknown as GPUCommandEncoder);

    expect(pass.presentsToTerminal).toBe(true);
    expect(pass.getOutputTexture()).toBe(packedLumaTexture);
    expect(borrowTextureMock).not.toHaveBeenCalled();
    expect(draw).toHaveBeenCalledWith(3);
  });
});
