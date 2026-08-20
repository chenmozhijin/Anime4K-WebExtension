import type {
  EnhancementEffect,
  EnhancementMode,
  PerformanceTier,
  RecommendedPresetId,
  RecommendedPresetMode,
} from '../../../types';
import { normalizeEffectReference } from '../../../core/effects/registry';

export const PERFORMANCE_TIERS: readonly PerformanceTier[] = [
  'performance',
  'balanced',
  'quality',
  'ultra',
];

export const DEFAULT_RECOMMENDED_PRESET_MODE_ID = 'recommended-detail-preserving' as const;

export const RECOMMENDED_PRESET_MODES: readonly RecommendedPresetMode[] = [
  {
    id: 'recommended-detail-preserving',
    presetId: 'detail-preserving',
    name: 'Detail Preserving',
    nameKey: 'recommendedDetailPreserving',
    effectFamily: 'CuNNy',
    isBuiltIn: true,
    isRecommended: true,
  },
  {
    id: 'recommended-compression-cleanup',
    presetId: 'compression-cleanup',
    name: 'Compression Cleanup',
    nameKey: 'recommendedCompressionCleanup',
    effectFamily: 'ARNet',
    isBuiltIn: true,
    isRecommended: true,
  },
  {
    id: 'recommended-soft-style',
    presetId: 'soft-style',
    name: 'Soft Style',
    nameKey: 'recommendedSoftStyle',
    effectFamily: 'ArtCNN',
    isBuiltIn: true,
    isRecommended: true,
  },
];

export const RECOMMENDED_PRESET_MATRIX: Readonly<Record<RecommendedPresetId, Readonly<Record<PerformanceTier, string>>>> = {
  'detail-preserving': {
    performance: 'cunny/Upscale/DS/Faster',
    balanced: 'cunny/Upscale/DS/4x16',
    quality: 'cunny/Upscale/DS/4x32',
    ultra: 'cunny/Upscale/DS/8x32',
  },
  'compression-cleanup': {
    performance: 'acnet/Upscale/ARNet/F8B8_BOX_HDN',
    balanced: 'acnet/Upscale/ARNet/F8B18_BOX_HDN',
    quality: 'acnet/Upscale/ARNet/F8B32_BOX_HDN',
    ultra: 'acnet/Upscale/ARNet/F8B64_BOX_HDN',
  },
  'soft-style': {
    performance: 'artcnn/Upscale/C4F16_DS',
    balanced: 'artcnn/Upscale/C4F16_DS',
    quality: 'artcnn/Upscale/C4F32_DS',
    ultra: 'artcnn/Upscale/C4F32_DS',
  },
};

export function isRecommendedPresetMode(mode: EnhancementMode): mode is RecommendedPresetMode {
  return 'isRecommended' in mode && mode.isRecommended === true;
}

export function isRecommendedPresetModeId(value: unknown): value is RecommendedPresetMode['id'] {
  return typeof value === 'string'
    && RECOMMENDED_PRESET_MODES.some(mode => mode.id === value);
}

export function getRecommendedPresetEffectId(
  presetId: RecommendedPresetId,
  tier: PerformanceTier,
): string {
  return RECOMMENDED_PRESET_MATRIX[presetId][tier];
}

export function resolveRecommendedPresetEffects(
  presetId: RecommendedPresetId,
  tier: PerformanceTier,
): EnhancementEffect[] {
  const effectId = getRecommendedPresetEffectId(presetId, tier);
  const effect = normalizeEffectReference({ id: effectId });
  if (!effect) {
    throw new Error(`Recommended preset effect is not registered: ${effectId}`);
  }

  return [effect];
}
