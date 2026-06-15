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

function collectErrorMessages(error: unknown, maxDepth = 4): string[] {
  const messages: string[] = [];
  let current: unknown = error;
  let depth = 0;

  while (current && depth < maxDepth) {
    const message = getErrorMessage(current).trim();
    if (message && !messages.includes(message)) {
      messages.push(message);
    }

    if (!(current instanceof Error) || !('cause' in current)) {
      break;
    }

    current = (current as Error & { cause?: unknown }).cause;
    depth += 1;
  }

  return messages;
}

function isCrossOriginError(error: unknown): boolean {
  const name = getErrorName(error);
  const messages = collectErrorMessages(error).join(' | ').toLowerCase();
  return name === 'SecurityError' && messages.includes('tainted');
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
  const summary = buildGenericSummary(messages, options);
  return {
    summary,
    details: buildDetails(messages, summary),
    showOptionsLink: false,
  };
}
