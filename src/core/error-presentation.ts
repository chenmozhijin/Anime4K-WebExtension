export type ErrorPresentationPhase = 'enhance' | 'render' | 'update' | 'reattach';

export interface ErrorPresentationOptions {
  phase: ErrorPresentationPhase;
  enableCrossOriginFix: boolean;
  genericEnhanceMessage: string;
  genericRenderMessage: string;
  crossOriginHintMessage: string;
  knownMessages: {
    gpuUnsupported: string;
    gpuOutOfMemory: string;
    gpuDeviceLost: string;
    textureDimensionExceeded: string;
    textureDimensionExceededWithAdapterLimit: string;
    effectCompilationValidationFailed: string;
    effectCompilationFailed: string;
    effectWarmupValidationFailed: string;
    effectWarmupFailed: string;
    frameSubmissionValidationFailed: string;
    frameSubmissionFailed: string;
  };
}

export interface ErrorPresentation {
  summary: string;
  details?: string;
  showOptionsLink: boolean;
}

function getErrorName(error: unknown): string {
  return typeof error === 'object' && error && 'name' in error && typeof (error as { name?: string }).name === 'string'
    ? (error as { name: string }).name
    : 'Error';
}

function getErrorMessage(error: unknown): string {
  if (error instanceof Error) {
    return error.message;
  }

  if (typeof error === 'string') {
    return error;
  }

  return String(error);
}

function collectErrorChain(error: unknown, maxDepth = 4): unknown[] {
  const chain: unknown[] = [];
  const seen = new Set<unknown>();
  let current: unknown = error;
  let depth = 0;

  while (current && depth < maxDepth && !seen.has(current)) {
    chain.push(current);
    seen.add(current);

    if (typeof current !== 'object' || !('cause' in current)) {
      break;
    }

    current = (current as { cause?: unknown }).cause;
    depth += 1;
  }

  return chain;
}

function collectErrorMessages(error: unknown, maxDepth = 4): string[] {
  const messages: string[] = [];
  for (const current of collectErrorChain(error, maxDepth)) {
    const message = getErrorMessage(current).trim();
    if (message && !messages.includes(message)) {
      messages.push(message);
    }
  }
  return messages;
}

function isCrossOriginError(error: unknown): boolean {
  const chain = collectErrorChain(error);
  return chain.some(current => getErrorName(current) === 'SecurityError')
    && chain.some(current => getErrorMessage(current).toLowerCase().includes('tainted'));
}

function detectGpuStage(messages: readonly string[]): string | null {
  for (const message of messages) {
    const match = /WebGPU failed during ([^:]+):/i.exec(message);
    if (match?.[1]) {
      return match[1].trim().toLowerCase();
    }
  }

  return null;
}

interface TextureDimensionLimit {
  requiredWidth: string;
  requiredHeight: string;
  maxWidth: string;
  maxHeight: string;
  adapterLimit?: string;
}

function detectTextureDimensionLimit(messages: readonly string[]): TextureDimensionLimit | null {
  const joined = messages.join('\n');
  const required = /Texture size\s*\(\[?Extent3D\s+width:\s*(\d+),\s*height:\s*(\d+)/i.exec(joined);
  const maximum = /exceeded maximum texture size\s*\(\[?Extent3D\s+width:\s*(\d+),\s*height:\s*(\d+)/i.exec(joined);
  if (!required || !maximum) {
    return null;
  }

  const adapterLimit = /maxTextureDimension2D\s+of\s*(\d+)/i.exec(joined)?.[1];
  return {
    requiredWidth: required[1],
    requiredHeight: required[2],
    maxWidth: maximum[1],
    maxHeight: maximum[2],
    ...(adapterLimit ? { adapterLimit } : {}),
  };
}

function formatTemplate(template: string, values: Record<string, string>): string {
  return template.replace(/\{([A-Za-z][A-Za-z0-9]*)\}/g, (token, key: string) => values[key] ?? token);
}

function buildTextureDimensionSummary(
  limit: TextureDimensionLimit,
  options: ErrorPresentationOptions,
): string {
  const template = limit.adapterLimit
    ? options.knownMessages.textureDimensionExceededWithAdapterLimit
    : options.knownMessages.textureDimensionExceeded;
  return formatTemplate(template, {
    requiredWidth: limit.requiredWidth,
    requiredHeight: limit.requiredHeight,
    maxWidth: limit.maxWidth,
    maxHeight: limit.maxHeight,
    adapterLimit: limit.adapterLimit ?? '',
  });
}

function buildTextureDimensionDetails(messages: readonly string[]): string | undefined {
  const joined = messages.join('\n');
  const stage = /WebGPU failed during effect compilation(?: \((.+?)\))?:/i.exec(joined)?.[0];
  const texture = /Texture size\s*\(\[?Extent3D[^\r\n]*?exceeded maximum texture size\s*\(\[?Extent3D[^\r\n]*?\)\.?/i.exec(joined)?.[0];
  const adapter = /This adapter supports a higher maxTextureDimension2D of\s*\d+[^.]*\./i.exec(joined)?.[0];
  const details = [stage, texture, adapter].filter((value): value is string => Boolean(value));
  return details.length > 0 ? [...new Set(details)].join('\n') : undefined;
}

function buildStageSummary(
  stage: string | null,
  hasValidation: boolean,
  options: ErrorPresentationOptions,
): string {
  if (stage?.startsWith('effect compilation')) {
    return hasValidation
      ? options.knownMessages.effectCompilationValidationFailed
      : options.knownMessages.effectCompilationFailed;
  }

  if (stage?.startsWith('effect warmup')) {
    return hasValidation
      ? options.knownMessages.effectWarmupValidationFailed
      : options.knownMessages.effectWarmupFailed;
  }

  if (stage?.startsWith('frame submission')) {
    return hasValidation
      ? options.knownMessages.frameSubmissionValidationFailed
      : options.knownMessages.frameSubmissionFailed;
  }

  return options.genericRenderMessage;
}

function buildGenericSummary(
  messages: readonly string[],
  options: ErrorPresentationOptions,
): string {
  const joined = messages.join(' | ');
  const lowerJoined = joined.toLowerCase();
  const stage = detectGpuStage(messages);
  const hasValidation = lowerJoined.includes('gpuvalidationerror')
    || lowerJoined.includes('[validation]')
    || lowerJoined.includes('validation');

  if (lowerJoined.includes('webgpu not supported')
    || lowerJoined.includes('no adapter found')
    || lowerJoined.includes('failed to get gpu device')) {
    return options.knownMessages.gpuUnsupported;
  }

  if (lowerJoined.includes('out-of-memory') || lowerJoined.includes('gpuoutofmemoryerror')) {
    return options.knownMessages.gpuOutOfMemory;
  }

  if (lowerJoined.includes('device loss') || lowerJoined.includes('device lost')) {
    return options.knownMessages.gpuDeviceLost;
  }

  if (stage || lowerJoined.includes('webgpu failed during')) {
    return buildStageSummary(stage, hasValidation, options);
  }

  const primary = messages[0];
  if (primary
    && primary.length <= 140
    && !primary.includes('[validation]')
    && !primary.includes('uncapturederror')
    && !primary.toLowerCase().includes('webgpu failed during')) {
    return primary;
  }

  return options.phase === 'enhance'
    ? options.genericEnhanceMessage
    : options.genericRenderMessage;
}

function buildDetails(messages: readonly string[], summary: string): string | undefined {
  const filtered = messages.filter(message => message && message !== summary);
  if (filtered.length === 0) {
    return undefined;
  }

  return filtered.join('\n');
}

export function buildErrorPresentation(
  error: unknown,
  options: ErrorPresentationOptions,
): ErrorPresentation {
  if (isCrossOriginError(error)) {
    const messages = collectErrorMessages(error);
    return {
      summary: options.crossOriginHintMessage,
      details: buildDetails(messages, options.crossOriginHintMessage),
      showOptionsLink: !options.enableCrossOriginFix,
    };
  }

  const messages = collectErrorMessages(error);
  const textureDimensionLimit = detectTextureDimensionLimit(messages);
  if (textureDimensionLimit) {
    return {
      summary: buildTextureDimensionSummary(textureDimensionLimit, options),
      details: buildTextureDimensionDetails(messages),
      showOptionsLink: false,
    };
  }

  const summary = buildGenericSummary(messages, options);
  return {
    summary,
    details: buildDetails(messages, summary),
    showOptionsLink: false,
  };
}
