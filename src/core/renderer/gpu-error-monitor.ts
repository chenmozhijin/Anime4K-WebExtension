import { RendererRuntimeError } from '../errors';
import {
  flushGpuResourceErrors,
  subscribeGpuResourceErrors,
  type GpuResourceError,
} from '../gpu-resource-cache';
import { createLogger } from '../../utils/logger';

const logger = createLogger('gpu-error-monitor');

export class RendererGpuErrorMonitor {
  private static readonly GPU_ERROR_FLUSH_DELAY_MS = 0;

  private capturedGpuErrors: GpuResourceError[] = [];
  private readonly gpuErrorUnsubscribe: (() => void);
  private readonly deviceErrorEventTarget: (GPUDevice & EventTarget) | null;
  private readonly boundUncapturedErrorHandler = (event: Event) => {
    const gpuEvent = event as Event & {
      error?: { name?: string; message?: string };
      preventDefault?: () => void;
    };
    const message = gpuEvent.error?.message ?? 'Unknown uncaptured GPU error';
    const kind = gpuEvent.error?.name === 'GPUValidationError'
      ? 'validation'
      : gpuEvent.error?.name === 'GPUInternalError'
        ? 'internal'
        : gpuEvent.error?.name === 'GPUOutOfMemoryError'
          ? 'out-of-memory'
          : 'unknown';

    this.capturedGpuErrors.push({
      source: 'uncapturederror',
      message,
      kind,
    });

    logger.error('Uncaptured GPU error.', gpuEvent.error ?? event);
    gpuEvent.preventDefault?.();
  };

  constructor(private readonly device: GPUDevice) {
    this.gpuErrorUnsubscribe = subscribeGpuResourceErrors(device, (error) => {
      this.capturedGpuErrors.push(error);
      logger.error(`GPU resource error from ${error.source}: ${error.message}`);
    });

    const eventTargetDevice = device as GPUDevice & EventTarget;
    if (typeof eventTargetDevice.addEventListener === 'function') {
      eventTargetDevice.addEventListener('uncapturederror', this.boundUncapturedErrorHandler as EventListener);
      this.deviceErrorEventTarget = eventTargetDevice;
    } else {
      this.deviceErrorEventTarget = null;
    }
  }

  public reset(): void {
    this.capturedGpuErrors = [];
  }

  public async throwIfCaptured(stage: string): Promise<void> {
    await flushGpuResourceErrors(this.device);
    await new Promise(resolve => setTimeout(resolve, RendererGpuErrorMonitor.GPU_ERROR_FLUSH_DELAY_MS));
    this.throwIfKnown(stage);
  }

  public throwIfKnown(stage: string): void {
    if (this.capturedGpuErrors.length === 0) {
      return;
    }

    const summary = this.capturedGpuErrors
      .map(error => `[${error.kind}] ${error.source}: ${error.message}`)
      .join(' | ');
    this.capturedGpuErrors = [];

    throw new RendererRuntimeError(`WebGPU failed during ${stage}: ${summary}`);
  }

  public dispose(): void {
    this.gpuErrorUnsubscribe();
    if (this.deviceErrorEventTarget && typeof this.deviceErrorEventTarget.removeEventListener === 'function') {
      this.deviceErrorEventTarget.removeEventListener('uncapturederror', this.boundUncapturedErrorHandler as EventListener);
    }
    this.capturedGpuErrors = [];
  }
}
