type LostInfo = {
  reason: GPUDeviceLostReason;
  message: string;
};

class MockTexture {
  destroyed = false;

  constructor(
    public readonly width: number,
    public readonly height: number,
    public readonly format: GPUTextureFormat,
    public readonly usage: GPUTextureUsageFlags,
    public readonly label?: string,
  ) {}

  createView(): GPUTextureView {
    return { texture: this } as unknown as GPUTextureView;
  }

  destroy(): void {
    this.destroyed = true;
  }
}

class MockBuffer {
  destroyed = false;
  readonly data: ArrayBuffer;
  mapped = false;

  constructor(public readonly size: number) {
    this.data = new ArrayBuffer(size);
  }

  async mapAsync(): Promise<void> {
    this.mapped = true;
  }

  getMappedRange(offset = 0, size = this.size - offset): ArrayBuffer {
    return this.data.slice(offset, offset + size);
  }

  unmap(): void {
    this.mapped = false;
  }

  destroy(): void {
    this.destroyed = true;
  }
}

class MockQuerySet {
  destroyed = false;
  readonly values: bigint[];

  constructor(public readonly count: number) {
    this.values = Array.from({ length: count }, () => 0n);
  }

  destroy(): void {
    this.destroyed = true;
  }
}

type MockPassTimestampWrites = {
  querySet: GPUQuerySet;
  beginningOfPassWriteIndex?: number;
  endOfPassWriteIndex?: number;
};

class MockQueue {
  submissions = 0;
  copiedImages = 0;
  writeTextureCalls = 0;
  writeBufferCalls = 0;

  copyExternalImageToTexture(): void {
    this.copiedImages += 1;
  }

  submit(commandBuffers: GPUCommandBuffer[]): void {
    this.submissions += commandBuffers.length;
  }

  async onSubmittedWorkDone(): Promise<void> {
    return undefined;
  }

  writeTexture(): void {
    this.writeTextureCalls += 1;
  }

  writeBuffer(): void {
    this.writeBufferCalls += 1;
  }
}

class MockPassEncoder {
  setPipeline(): void {}
  setBindGroup(): void {}
  draw(): void {}
  dispatchWorkgroups(): void {}
  end(): void {}
}

class MockCommandEncoder {
  private timestamp = 1_000_000n;

  beginRenderPass(descriptor?: GPURenderPassDescriptor): GPURenderPassEncoder {
    this.writePassTimestamps(descriptor?.timestampWrites);
    return new MockPassEncoder() as unknown as GPURenderPassEncoder;
  }

  beginComputePass(descriptor?: GPUComputePassDescriptor): GPUComputePassEncoder {
    this.writePassTimestamps(descriptor?.timestampWrites);
    return new MockPassEncoder() as unknown as GPUComputePassEncoder;
  }

  resolveQuerySet(
    querySet: GPUQuerySet,
    firstQuery: number,
    queryCount: number,
    destination: GPUBuffer,
    destinationOffset: number,
  ): void {
    const mockQuerySet = querySet as unknown as MockQuerySet;
    const mockDestination = destination as unknown as MockBuffer;
    const view = new DataView(mockDestination.data);
    for (let index = 0; index < queryCount; index += 1) {
      view.setBigUint64(destinationOffset + index * 8, mockQuerySet.values[firstQuery + index] ?? 0n, true);
    }
  }

  copyBufferToBuffer(
    source: GPUBuffer,
    sourceOffset: number,
    destination: GPUBuffer,
    destinationOffset: number,
    size: number,
  ): void {
    const sourceBuffer = source as unknown as MockBuffer;
    const destinationBuffer = destination as unknown as MockBuffer;
    new Uint8Array(destinationBuffer.data, destinationOffset, size)
      .set(new Uint8Array(sourceBuffer.data, sourceOffset, size));
  }

  finish(): GPUCommandBuffer {
    return {} as GPUCommandBuffer;
  }

  private writePassTimestamps(timestampWrites?: MockPassTimestampWrites): void {
    if (!timestampWrites) {
      return;
    }

    const querySet = timestampWrites.querySet as unknown as MockQuerySet;
    const beginIndex = timestampWrites.beginningOfPassWriteIndex;
    const endIndex = timestampWrites.endOfPassWriteIndex;
    if (typeof beginIndex === 'number') {
      querySet.values[beginIndex] = this.timestamp;
      this.timestamp += 1_000_000n;
    }
    if (typeof endIndex === 'number') {
      querySet.values[endIndex] = this.timestamp;
      this.timestamp += 1_000_000n;
    }
  }
}

class MockDevice {
  readonly queue = new MockQueue() as unknown as GPUQueue;
  features = new Set<GPUFeatureName>() as unknown as GPUSupportedFeatures;
  readonly limits = {
    maxBufferSize: 1024 * 1024,
    maxStorageBufferBindingSize: 1024 * 1024,
    maxComputeWorkgroupStorageSize: 32768,
  } as GPUSupportedLimits;
  destroyed = false;
  textures: MockTexture[] = [];
  buffers: MockBuffer[] = [];
  private readonly eventListeners = new Map<string, Set<(event: Event) => void>>();
  private readonly scopedErrors: ({ name?: string; message?: string } | null)[] = [];
  private lostResolve!: (info: LostInfo) => void;
  lost: Promise<LostInfo>;

  constructor() {
    this.lost = new Promise(resolve => {
      this.lostResolve = resolve;
    });
  }

  createTexture(descriptor: GPUTextureDescriptor): GPUTexture {
    const size = descriptor.size as any;
    const [width, height] = Array.isArray(size)
      ? size
      : [size.width ?? 1, size.height ?? 1];
    const texture = new MockTexture(width, height, descriptor.format, descriptor.usage, descriptor.label);
    this.textures.push(texture);
    return texture as unknown as GPUTexture;
  }

  createShaderModule(descriptor: GPUShaderModuleDescriptor): GPUShaderModule {
    return { label: descriptor.label, code: descriptor.code } as unknown as GPUShaderModule;
  }

  createBindGroupLayout(descriptor: GPUBindGroupLayoutDescriptor): GPUBindGroupLayout {
    return descriptor as unknown as GPUBindGroupLayout;
  }

  createPipelineLayout(descriptor: GPUPipelineLayoutDescriptor): GPUPipelineLayout {
    return descriptor as unknown as GPUPipelineLayout;
  }

  createRenderPipeline(descriptor: GPURenderPipelineDescriptor): GPURenderPipeline {
    return descriptor as unknown as GPURenderPipeline;
  }

  createComputePipeline(descriptor: GPUComputePipelineDescriptor): GPUComputePipeline {
    return descriptor as unknown as GPUComputePipeline;
  }

  createSampler(descriptor: GPUSamplerDescriptor): GPUSampler {
    return descriptor as unknown as GPUSampler;
  }

  createBindGroup(descriptor: GPUBindGroupDescriptor): GPUBindGroup {
    return descriptor as unknown as GPUBindGroup;
  }

  createBuffer(descriptor: GPUBufferDescriptor): GPUBuffer {
    const buffer = new MockBuffer(descriptor.size);
    this.buffers.push(buffer);
    return buffer as unknown as GPUBuffer;
  }

  createQuerySet(descriptor: GPUQuerySetDescriptor): GPUQuerySet {
    return new MockQuerySet(descriptor.count) as unknown as GPUQuerySet;
  }

  createCommandEncoder(): GPUCommandEncoder {
    return new MockCommandEncoder() as unknown as GPUCommandEncoder;
  }

  addEventListener(type: string, listener: (event: Event) => void): void {
    const listeners = this.eventListeners.get(type) ?? new Set<(event: Event) => void>();
    listeners.add(listener);
    this.eventListeners.set(type, listeners);
  }

  removeEventListener(type: string, listener: (event: Event) => void): void {
    this.eventListeners.get(type)?.delete(listener);
  }

  pushErrorScope(): void {}

  async popErrorScope(): Promise<{ name?: string; message?: string } | null> {
    return this.scopedErrors.shift() ?? null;
  }

  queueScopedError(error: { name?: string; message?: string } | null): void {
    this.scopedErrors.push(error);
  }

  emitUncapturedError(error: { name?: string; message?: string }): void {
    const listeners = this.eventListeners.get('uncapturederror');
    if (!listeners || listeners.size === 0) {
      return;
    }

    const event = {
      error,
      preventDefault: () => undefined,
    } as unknown as Event;
    listeners.forEach(listener => listener(event));
  }

  loseDevice(reason: GPUDeviceLostReason = 'unknown', message = 'Mock device lost'): void {
    this.lostResolve({ reason, message });
  }

  destroy(): void {
    this.destroyed = true;
    this.lostResolve({
      reason: 'destroyed',
      message: 'Device destroyed',
    });
  }
}

class MockAdapter {
  readonly features: GPUSupportedFeatures;

  readonly info = {
    vendor: 'MockVendor',
    architecture: 'MockArchitecture',
    device: 'MockDevice',
    description: 'Mock GPU',
  } as GPUAdapterInfo;

  readonly limits = {
    maxBufferSize: 1024 * 1024,
    maxStorageBufferBindingSize: 1024 * 1024,
    maxComputeWorkgroupStorageSize: 32768,
  } as GPUSupportedLimits;

  constructor(public readonly device: MockDevice, features: GPUFeatureName[] = []) {
    this.features = new Set(features) as unknown as GPUSupportedFeatures;
  }

  async requestDevice(descriptor?: GPUDeviceDescriptor): Promise<GPUDevice> {
    // Adapter support and device enablement are distinct in WebGPU. Mirror the
    // requested descriptor so capability tests catch accidental use of unsupported state.
    this.device.features = new Set(
      [...(descriptor?.requiredFeatures ?? [])] as GPUFeatureName[],
    ) as unknown as GPUSupportedFeatures;
    return this.device as unknown as GPUDevice;
  }
}

export function createWebGpuMock(options: { features?: GPUFeatureName[] } = {}) {
  const device = new MockDevice();
  const adapter = new MockAdapter(device, options.features);

  return {
    adapter,
    device,
    gpu: {
      async requestAdapter(): Promise<GPUAdapter> {
        return adapter as unknown as GPUAdapter;
      },
      getPreferredCanvasFormat(): GPUTextureFormat {
        return 'rgba8unorm';
      },
    } as GPU,
  };
}

export function installWebGpuMock(options: { features?: GPUFeatureName[] } = {}) {
  const mock = createWebGpuMock(options);
  Object.defineProperty(globalThis.navigator, 'gpu', {
    configurable: true,
    writable: true,
    value: mock.gpu,
  });
  return mock;
}

export function createMockCanvasContext(device: GPUDevice, format: GPUTextureFormat = 'rgba8unorm'): GPUCanvasContext {
  return {
    configure: () => undefined,
    unconfigure: () => undefined,
    getCurrentTexture: () => ({
      createView: () => ({}) as GPUTextureView,
      width: 1,
      height: 1,
      format,
      usage: GPUTextureUsage.RENDER_ATTACHMENT,
      destroy: () => undefined,
    }) as unknown as GPUTexture,
  } as unknown as GPUCanvasContext;
}
