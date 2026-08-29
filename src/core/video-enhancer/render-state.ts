import { getEffectsForMode } from '../../utils/settings';
import { createEffectSignature } from '../../utils/effect-signature';
import type { Dimensions, NijiLucidSettings, EnhancementMode, PerformanceTier } from '../../types';

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
  const fixedResolutionShortEdges: Record<string, number> = {
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

  if (fixedResolutionShortEdges[resolutionSetting]) {
    const shortEdge = fixedResolutionShortEdges[resolutionSetting];
    const sourceAspect = videoHeight > 0 ? videoWidth / videoHeight : 1;
    const isPortrait = videoWidth > 0 && videoHeight > videoWidth;

    if (isPortrait) {
      return {
        width: shortEdge,
        height: Math.max(1, Math.round(shortEdge / sourceAspect)),
      };
    }

    return {
      width: Math.max(1, Math.round(shortEdge * sourceAspect)),
      height: shortEdge,
    };
  }

  return { width: videoWidth, height: videoHeight };
}

export function resolveRendererState(
  settings: NijiLucidSettings,
  sourceDimensions: Dimensions,
): ResolvedRendererState {
  const { selectedModeId, enhancementModes, targetResolutionSetting } = settings;
  const selectedMode =
    enhancementModes.find((mode: EnhancementMode) => mode.id === selectedModeId)
    || enhancementModes.find((mode: EnhancementMode) => mode.isBuiltIn)!;
  const targetDimensions = calculateTargetDimensions(
    sourceDimensions.width,
    sourceDimensions.height,
    targetResolutionSetting,
  );
  const effects = getEffectsForMode(selectedMode, settings.performanceTier, {
    targetResolutionSetting,
    sourceDimensions,
    targetDimensions,
  });

  return {
    selectedMode,
    effects,
    effectsSignature: createEffectSignature(effects),
    targetDimensions,
  };
}

export function buildAppliedRendererState(
  settings: NijiLucidSettings,
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
