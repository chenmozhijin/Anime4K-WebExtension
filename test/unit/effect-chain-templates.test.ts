import { describe, expect, it } from 'vitest';
import { getEffectChainSummary } from '../../src/features/enhancement/domain/effect-chain-summary';
import { resolveAnime4kPresetEffectChain } from '../../src/engines/anime4k/preset-resolver';

describe('effect-chain templates', () => {
  it('resolves anime4k preset effects', () => {
    const effects = resolveAnime4kPresetEffectChain('A+A', 'balanced');

    expect(effects.length).toBeGreaterThan(0);
    expect(effects.every(effect => effect.backendId === 'anime4k')).toBe(true);
  });

  it('summarizes effect chain names', () => {
    const effects = resolveAnime4kPresetEffectChain('A', 'performance');
    const summary = getEffectChainSummary(effects);

    expect(summary).not.toBe('No effects');
    expect(summary).toContain('->');
  });
});
