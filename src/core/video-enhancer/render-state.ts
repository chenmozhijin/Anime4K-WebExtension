import { getEffectsForMode } from '../../utils/settings';
import { createEffectSignature } from '../../utils/effect-signature';
import type { Dimensions, Anime4KWebExtSettings, EnhancementMode, PerformanceTier } from '../../types';

export interface AppliedRendererState {
  selectedModeId: string;
  performanceTier: PerformanceTier;
  targetResolutionSetting: string;
  sourceDimensions: Dimensions;
  targetDimensions: Dimensions;
  effectsSignature: string;
}

export interface ResolvedRendererState {
  selectedMode: EnhancementMode;
  effects: ReturnType<typeof getEffectsForMode>;
  effectsSignature: string;
  targetDimensions: Dimensions;
}

export interface AppliedRendererStateChanges {
  sourceChanged: boolean;
  targetChanged: boolean;
  effectsChanged: boolean;
  modeChanged: boolean;
  tierChanged: boolean;
  resolutionChanged: boolean;
}

export function calculateTargetDimensions(
  videoWidth: number,
  videoHeight: number,
  resolutionSetting: string,
): Dimensions {
  const multipliers: Record<string, number> = { x2: 2, x4: 4, x8: 8 };
  const fixedResolutionHeights: Record<string, number> = {
    '720p': 720,
    '1080p': 1080,
    '2k': 1440,
    '4k': 2160,
  };

  if (multipliers[resolutionSetting]) {
    return {
      width: Math.max(1, Math.round(videoWidth * multipliers[resolutionSetting])),
      height: Math.max(1, Math.round(videoHeight * multipliers[resolutionSetting])),
    };
  }

  if (fixedResolutionHeights[resolutionSetting]) {
    const height = fixedResolutionHeights[resolutionSetting];
    const sourceAspect = videoHeight > 0 ? videoWidth / videoHeight : 1;
    return {
      width: Math.max(1, Math.round(height * sourceAspect)),
      height,
    };
  }

  return { width: videoWidth, height: videoHeight };
}

export function resolveRendererState(
  settings: Anime4KWebExtSettings,
  sourceDimensions: Dimensions,
): ResolvedRendererState {
  const { selectedModeId, enhancementModes, targetResolutionSetting } = settings;
  const selectedMode =
    enhancementModes.find((mode: EnhancementMode) => mode.id === selectedModeId)
    || enhancementModes.find((mode: EnhancementMode) => mode.isBuiltIn)!;
  const effects = getEffectsForMode(selectedMode, settings.performanceTier);

  return {
    selectedMode,
    effects,
    effectsSignature: createEffectSignature(effects),
    targetDimensions: calculateTargetDimensions(
      sourceDimensions.width,
      sourceDimensions.height,
      targetResolutionSetting,
    ),
  };
}

export function buildAppliedRendererState(
  settings: Anime4KWebExtSettings,
  selectedModeId: string,
  sourceDimensions: Dimensions,
  targetDimensions: Dimensions,
  effectsSignature: string,
): AppliedRendererState {
  return {
    selectedModeId,
    performanceTier: settings.performanceTier,
    targetResolutionSetting: settings.targetResolutionSetting,
    sourceDimensions,
    targetDimensions,
    effectsSignature,
  };
}

export function getAppliedRendererStateChanges(
  previousState: AppliedRendererState | null,
  nextState: AppliedRendererState,
): AppliedRendererStateChanges {
  return {
    sourceChanged: !previousState
      || previousState.sourceDimensions.width !== nextState.sourceDimensions.width
      || previousState.sourceDimensions.height !== nextState.sourceDimensions.height,
    targetChanged: !previousState
      || previousState.targetDimensions.width !== nextState.targetDimensions.width
      || previousState.targetDimensions.height !== nextState.targetDimensions.height,
    effectsChanged: !previousState
      || previousState.effectsSignature !== nextState.effectsSignature,
    modeChanged: !previousState || previousState.selectedModeId !== nextState.selectedModeId,
    tierChanged: !previousState || previousState.performanceTier !== nextState.performanceTier,
    resolutionChanged: !previousState
      || previousState.targetResolutionSetting !== nextState.targetResolutionSetting,
  };
}
