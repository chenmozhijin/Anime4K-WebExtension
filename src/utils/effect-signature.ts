import type { EnhancementEffect } from '../types';

function stableSerialize(value: unknown): string {
  if (value === null || value === undefined) {
    return String(value);
  }

  if (typeof value !== 'object') {
    return JSON.stringify(value);
  }

  if (Array.isArray(value)) {
    return `[${value.map(stableSerialize).join(',')}]`;
  }

  const entries = Object.entries(value as Record<string, unknown>)
    .sort(([left], [right]) => left.localeCompare(right));

  return `{${entries.map(([key, entryValue]) => `${JSON.stringify(key)}:${stableSerialize(entryValue)}`).join(',')}}`;
}

export function createEffectSignature(effects: readonly EnhancementEffect[]): string {
  return effects.map(effect => stableSerialize({
    id: effect.id,
    className: effect.className,
    upscaleFactor: effect.upscaleFactor ?? null,
    params: effect.params ?? null,
  })).join('|');
}
