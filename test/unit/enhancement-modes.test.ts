import { describe, expect, it } from 'vitest';
import {
  BUILTIN_MODES,
  buildEnhancementModes,
  getEffectsForMode,
} from '../../src/features/enhancement/domain/modes';
import type { CustomMode } from '../../src/types';

describe('enhancement modes', () => {
  it('keeps built-in modes limited to Anime4K presets', () => {
    expect(BUILTIN_MODES).toHaveLength(6);
    expect(BUILTIN_MODES.map(mode => mode.backendId)).toEqual([
      'anime4k',
      'anime4k',
      'anime4k',
      'anime4k',
      'anime4k',
      'anime4k',
    ]);
    expect(BUILTIN_MODES.map(mode => mode.presetKey)).toEqual(['A', 'B', 'C', 'A+A', 'B+B', 'C+A']);
  });

  it('keeps ArtCNN reachable only through custom modes', () => {
    const artcnnMode: CustomMode = {
      id: 'custom-artcnn',
      name: 'ArtCNN Custom',
      isBuiltIn: false,
      effects: [{
        id: 'artcnn/Upscale/C4F16',
        backendId: 'artcnn',
        key: 'C4F16',
      }],
    };

    const modes = buildEnhancementModes([artcnnMode]);
    expect(modes.filter(mode => mode.isBuiltIn).some(mode => mode.backendId === 'artcnn')).toBe(false);
    expect(modes).toContain(artcnnMode);
    expect(getEffectsForMode(artcnnMode, 'performance')).toEqual(artcnnMode.effects);
  });
});
