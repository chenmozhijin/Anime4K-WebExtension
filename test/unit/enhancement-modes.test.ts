import { describe, expect, it } from 'vitest';
import {
  BUILTIN_MODES,
  buildEnhancementModes,
  getEffectsForMode,
} from '../../src/features/enhancement/domain/modes';
import {
  RECOMMENDED_PRESET_MATRIX,
  RECOMMENDED_PRESET_MODES,
  getRecommendedPresetEffectId,
  resolveRecommendedPresetEffects,
  resolveRecommendedPresetStageCount,
} from '../../src/features/enhancement/domain/recommended-presets';
import { getEffectDescriptorById } from '../../src/core/effects/registry';
import { resolveAnime4kPresetEffectChain } from '../../src/engines/anime4k/preset-resolver';
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

  it('matches the recommended preset matrix exactly', () => {
    expect(RECOMMENDED_PRESET_MODES.map(mode => mode.id)).toEqual([
      'recommended-detail-preserving',
      'recommended-compression-cleanup',
      'recommended-soft-style',
    ]);
    expect(RECOMMENDED_PRESET_MODES.map(mode => mode.effectFamily)).toEqual([
      'CuNNy',
      'ARNet',
      'ArtCNN',
    ]);
    expect(RECOMMENDED_PRESET_MATRIX).toEqual({
      'detail-preserving': {
        performance: 'cunny/Upscale/DS/Faster',
        balanced: 'cunny/Upscale/DS/4x16',
        quality: 'cunny/Upscale/DS/4x32',
        ultra: 'cunny/Upscale/DS/8x32',
      },
      'compression-cleanup': {
        performance: 'acnet/Upscale/ARNet/F8B8_BOX_HDN',
        balanced: 'acnet/Upscale/ARNet/F8B16_BOX_HDN',
        quality: 'acnet/Upscale/ARNet/F8B32_BOX_HDN',
        ultra: 'acnet/Upscale/ARNet/F8B64_BOX_HDN',
      },
      'soft-style': {
        performance: 'artcnn/Upscale/C4F16_DS',
        balanced: 'artcnn/Upscale/C4F16_DS',
        quality: 'artcnn/Upscale/C4F32_DS',
        ultra: 'artcnn/Upscale/C4F32_DS',
      },
    });
    expect(getRecommendedPresetEffectId('detail-preserving', 'ultra')).toBe('cunny/Upscale/DS/8x32');
  });

  it('references only registered effects from the recommended preset matrix', () => {
    Object.entries(RECOMMENDED_PRESET_MATRIX).forEach(([presetId, tiers]) => {
      Object.entries(tiers).forEach(([tier, effectId]) => {
        expect(getEffectDescriptorById(effectId), `${presetId}/${tier}`).toBeDefined();
      });
    });
  });

  it('expands recommended presets into the requested explicit scale chain', () => {
    const expectedStageCounts = { x2: 1, x4: 2, x8: 3 } as const;

    RECOMMENDED_PRESET_MODES.forEach(mode => {
      (Object.entries(expectedStageCounts) as Array<[keyof typeof expectedStageCounts, number]>).forEach(
        ([targetResolutionSetting, expectedStageCount]) => {
          expect(resolveRecommendedPresetStageCount({ targetResolutionSetting })).toBe(expectedStageCount);

          const effects = resolveRecommendedPresetEffects(mode.presetId, 'balanced', {
            targetResolutionSetting,
          });
          expect(effects).toHaveLength(expectedStageCount);
          expect(effects.map(effect => effect.id)).toEqual(
            Array(expectedStageCount).fill(getRecommendedPresetEffectId(mode.presetId, 'balanced')),
          );
          if (effects.length > 1) {
            expect(effects[0]).not.toBe(effects[1]);
          }
        },
      );
    });
  });

  it('derives fixed-target chain length from actual dimensions and caps it at x8', () => {
    expect(resolveRecommendedPresetStageCount({
      targetResolutionSetting: '720p',
      sourceDimensions: { width: 320, height: 180 },
      targetDimensions: { width: 1280, height: 720 },
    })).toBe(2);
    expect(resolveRecommendedPresetStageCount({
      targetResolutionSetting: '1080p',
      sourceDimensions: { width: 640, height: 360 },
      targetDimensions: { width: 1920, height: 1080 },
    })).toBe(2);
    expect(resolveRecommendedPresetStageCount({
      targetResolutionSetting: '4k',
      sourceDimensions: { width: 320, height: 180 },
      targetDimensions: { width: 3840, height: 2160 },
    })).toBe(3);
    expect(resolveRecommendedPresetStageCount({
      targetResolutionSetting: '720p',
      sourceDimensions: { width: 1920, height: 1080 },
      targetDimensions: { width: 1280, height: 720 },
    })).toBe(1);
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
    expect(BUILTIN_MODES.some(mode => mode.backendId === 'artcnn')).toBe(false);
    expect(modes).toContain(artcnnMode);
    expect(getEffectsForMode(artcnnMode, 'performance', {
      targetResolutionSetting: 'x8',
      sourceDimensions: { width: 320, height: 180 },
      targetDimensions: { width: 2560, height: 1440 },
    })).toEqual(artcnnMode.effects);
  });

  it('keeps compatibility mode effect chains unchanged', () => {
    BUILTIN_MODES.forEach(mode => {
      expect(getEffectsForMode(mode, 'balanced', {
        targetResolutionSetting: 'x8',
        sourceDimensions: { width: 320, height: 180 },
        targetDimensions: { width: 2560, height: 1440 },
      })).toEqual(
        resolveAnime4kPresetEffectChain(mode.presetKey, 'balanced'),
      );
    });
  });
});
