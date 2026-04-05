import { describe, expect, it } from 'vitest';
import { getEffectChainSummary, resolveEffectChain } from '../../src/utils/effect-chain-templates';

describe('effect-chain templates', () => {
  it('resolves anime4k preset effects', () => {
    const effects = resolveEffectChain('A+A', 'balanced');

    expect(effects.length).toBeGreaterThan(0);
    expect(effects.every(effect => effect.backendId === 'anime4k')).toBe(true);
  });

  it('summarizes effect chain names', () => {
    const effects = resolveEffectChain('A', 'performance');
    const summary = getEffectChainSummary(effects);

    expect(summary).not.toBe('No effects');
    expect(summary).toContain('->');
  });
});
