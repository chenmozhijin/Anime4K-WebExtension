import { describe, expect, it } from 'vitest';
import {
  buildAppliedRendererState,
  calculateTargetDimensions,
  getAppliedRendererStateChanges,
  resolveRendererState,
} from '../../src/core/video-enhancer/render-state';
import type { Anime4KWebExtSettings } from '../../src/types';

const baseSettings: Anime4KWebExtSettings = {
  selectedModeId: 'custom-a',
  performanceTier: 'balanced',
  performanceMonitorMode: 'off',
  performanceMonitorHudCollapsed: false,
  performanceMonitorHudPosition: 'top-left',
  performanceMonitorHudWidth: null,
  targetResolutionSetting: 'x2',
  whitelistEnabled: true,
  whitelist: [],
  enableCrossOriginFix: true,
  customModes: [],
  enhancementModes: [
    {
      id: 'builtin-a',
      baseMode: 'A',
      name: 'Builtin A',
      backendId: 'anime4k',
      presetKey: 'A',
      isBuiltIn: true,
    },
    {
      id: 'custom-a',
      name: 'Custom A',
      isBuiltIn: false,
      effects: [],
    },
  ],
};

describe('video enhancer render state', () => {
  it('calculates multiplier and fixed-resolution targets', () => {
    expect(calculateTargetDimensions(320, 180, 'x4')).toEqual({ width: 1280, height: 720 });
    expect(calculateTargetDimensions(1920, 1080, '720p')).toEqual({ width: 1280, height: 720 });
    expect(calculateTargetDimensions(320, 180, 'source')).toEqual({ width: 320, height: 180 });
  });

  it('resolves the active mode and effect signature', () => {
    const resolved = resolveRendererState(baseSettings, { width: 320, height: 180 });

    expect(resolved.selectedMode.id).toBe('custom-a');
    expect(resolved.effects).toEqual([]);
    expect(resolved.effectsSignature).toBe('');
    expect(resolved.targetDimensions).toEqual({ width: 640, height: 360 });
  });

  it('detects applied renderer state changes', () => {
    const previous = buildAppliedRendererState(
      baseSettings,
      'builtin-a',
      { width: 320, height: 180 },
      { width: 640, height: 360 },
      'sig-a',
    );
    const next = buildAppliedRendererState(
      {
        ...baseSettings,
        performanceTier: 'quality',
        targetResolutionSetting: '1080p',
      },
      'builtin-b',
      { width: 640, height: 360 },
      { width: 1920, height: 1080 },
      'sig-b',
    );

    expect(getAppliedRendererStateChanges(previous, next)).toEqual({
      sourceChanged: true,
      targetChanged: true,
      effectsChanged: true,
      modeChanged: true,
      tierChanged: true,
      resolutionChanged: true,
    });
  });
});
