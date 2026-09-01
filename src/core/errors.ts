/**
 * 基础渲染器错误类，所有与渲染器相关的特定错误都应继承自此类。
 */
export class RendererError extends Error {
  // `declare` keeps the type information without emitting an own property with
  // the value `undefined`. Firefox DevTools renders that property as
  // "Caused by: undefined" even when no cause was supplied.
  declare public cause?: Error;

  constructor(message: string, options?: ErrorOptions) {
    super(message, options);
    this.name = 'RendererError';

    // ErrorOptions.cause is intentionally `unknown`. Normalize it here so all
    // renderer error subclasses have a useful, traversable cause and never
    // expose an undefined cause property.
    if (options && 'cause' in options) {
      if (options.cause === undefined) {
        delete (this as Error & { cause?: unknown }).cause;
      } else {
        this.cause = normalizeError(options.cause, 'Unknown renderer error cause.');
      }
    }
  }
}

/**
 * Converts a rejected/ thrown unknown value into an Error without relying on
 * `instanceof` alone. Errors crossing a browser realm can fail that check,
 * while Web APIs may also reject with strings, plain objects, or undefined.
 */
export function normalizeError(value: unknown, fallbackMessage = 'Unknown error.'): Error {
  if (value instanceof Error) {
    return value;
  }

  if (typeof value === 'string') {
    const message = value.trim();
    return new Error(message || fallbackMessage);
  }

  if (value !== null && typeof value === 'object') {
    const candidateMessage = readStringProperty(value, 'message');
    const message = candidateMessage || safeStringify(value) || fallbackMessage;
    const normalized = new Error(message);
    const candidateName = readStringProperty(value, 'name');
    if (candidateName) {
      normalized.name = candidateName;
    }
    return normalized;
  }

  const primitiveMessage = safeStringify(value);
  return new Error(primitiveMessage || fallbackMessage);
}

function readStringProperty(value: object, property: 'message' | 'name'): string | undefined {
  try {
    const candidate = (value as Record<string, unknown>)[property];
    if (typeof candidate !== 'string') {
      return undefined;
    }
    const text = candidate.trim();
    return text || undefined;
  } catch {
    return undefined;
  }
}

function safeStringify(value: unknown): string | undefined {
  if (value === undefined || value === null) {
    return undefined;
  }

  try {
    const text = String(value).trim();
    // Avoid replacing a useful fallback with the unhelpful default object tag.
    return text && text !== '[object Object]' ? text : undefined;
  } catch {
    return undefined;
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
