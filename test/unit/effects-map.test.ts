import { describe, expect, it } from 'vitest';
import { AVAILABLE_EFFECTS } from '../../src/utils/effects-map';

describe('available effects map', () => {
  it('exposes every ACNetGLSL model as a visible custom-mode effect', () => {
    const acnetEffects = AVAILABLE_EFFECTS.filter(effect => effect.backendId === 'acnet');

    expect(acnetEffects).toHaveLength(33);
    expect(acnetEffects.map(effect => effect.id)).toContain('acnet/Upscale/F8B4');
    expect(acnetEffects.map(effect => effect.id)).toContain('acnet/Upscale/Legacy/GAN');
    expect(acnetEffects.map(effect => effect.id)).toContain('acnet/Upscale/ARNet/F8B8');
  });

  it('exposes every CuNNy v1 model as a visible custom-mode effect', () => {
    const cunnyEffects = AVAILABLE_EFFECTS.filter(effect => effect.backendId === 'cunny');

    expect(cunnyEffects).toHaveLength(18);
    expect(cunnyEffects.map(effect => effect.id)).toContain('cunny/Upscale/DS/Fast');
    expect(cunnyEffects.map(effect => effect.id)).toContain('cunny/Upscale/DS/8x32');
    expect(cunnyEffects.map(effect => effect.id)).toContain('cunny/Upscale/SOFT/Veryfast');
    expect(cunnyEffects.every(effect => effect.license?.expression === 'LGPL-3.0-or-later')).toBe(true);
  });
});
