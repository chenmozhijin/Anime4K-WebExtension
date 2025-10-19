/**
 * 基础渲染器错误类，所有与渲染器相关的特定错误都应继承自此类。
 */
export class RendererError extends Error {
  public cause?: Error;

  constructor(message: string, options?: ErrorOptions) {
    super(message, options);
    this.name = 'RendererError';
    if (options?.cause instanceof Error) {
      this.cause = options.cause;
    }
  }
}

/**
 * 表示在渲染器初始化阶段发生的错误。
 * 例如：获取GPU设备失败、WebGPU功能不支持等。
 */
export class RendererInitializationError extends RendererError {
  constructor(message: string, options?: ErrorOptions) {
    super(message, options);
    this.name = 'RendererInitializationError';
  }
}

/**
 * 表示在渲染循环（运行时）发生的错误。
 */
export class RendererRuntimeError extends RendererError {
  public recoverable: boolean;

  constructor(message: string, options?: ErrorOptions & { recoverable?: boolean }) {
    super(message, options);
    this.name = 'RendererRuntimeError';
    this.recoverable = options?.recoverable ?? false;
  }
}
