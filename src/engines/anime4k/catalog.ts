import type { Anime4KPresetId, EffectDescriptor, EffectReference, PerformanceTier } from '../../types';
import { createEffectReference } from '../../core/effects/reference';

export const anime4kBackendId = 'anime4k';

export const anime4kEffectDescriptors: EffectDescriptor[] = [
  {
    id: 'anime4k/Deblur/DoG',
    backendId: anime4kBackendId,
    key: 'DoG',
    name: 'Deblur (DoG)',
    category: 'deblur',
    dimensionBehavior: { kind: 'same' },
    supportsVideoRealtime: true,
  },
  {
    id: 'anime4k/Denoise/BilateralMean',
    backendId: anime4kBackendId,
    key: 'BilateralMean',
    name: 'Denoise (Bilateral Mean)',
    category: 'denoise',
    dimensionBehavior: { kind: 'same' },
    supportsVideoRealtime: true,
  },
  {
    id: 'anime4k/Restore/CNNM',
    backendId: anime4kBackendId,
    key: 'CNNM',
    name: 'Restore CNN (M)',
    category: 'restore',
    dimensionBehavior: { kind: 'same' },
    supportsVideoRealtime: true,
  },
  {
    id: 'anime4k/Restore/CNNSoftM',
    backendId: anime4kBackendId,
    key: 'CNNSoftM',
    name: 'Restore CNN Soft (M)',
    category: 'restore',
    dimensionBehavior: { kind: 'same' },
    supportsVideoRealtime: true,
  },
  {
    id: 'anime4k/Restore/CNNSoftVL',
    backendId: anime4kBackendId,
    key: 'CNNSoftVL',
    name: 'Restore CNN Soft (VL)',
    category: 'restore',
    dimensionBehavior: { kind: 'same' },
    supportsVideoRealtime: true,
  },
  {
    id: 'anime4k/Restore/CNNVL',
    backendId: anime4kBackendId,
    key: 'CNNVL',
    name: 'Restore CNN (VL)',
    category: 'restore',
    dimensionBehavior: { kind: 'same' },
    supportsVideoRealtime: true,
  },
  {
    id: 'anime4k/Restore/CNNUL',
    backendId: anime4kBackendId,
    key: 'CNNUL',
    name: 'Restore CNN (UL)',
    category: 'restore',
    dimensionBehavior: { kind: 'same' },
    supportsVideoRealtime: true,
  },
  {
    id: 'anime4k/Restore/GANUUL',
    backendId: anime4kBackendId,
    key: 'GANUUL',
    name: 'Restore GAN (UUL)',
    category: 'restore',
    dimensionBehavior: { kind: 'same' },
    supportsVideoRealtime: true,
  },
  {
    id: 'anime4k/Upscale/CNNx2M',
    backendId: anime4kBackendId,
    key: 'CNNx2M',
    name: 'Upscale CNN x2 (M)',
    category: 'upscale',
    dimensionBehavior: { kind: 'scale', scale: 2 },
    supportsVideoRealtime: true,
  },
  {
    id: 'anime4k/Upscale/CNNx2VL',
    backendId: anime4kBackendId,
    key: 'CNNx2VL',
    name: 'Upscale CNN x2 (VL)',
    category: 'upscale',
    dimensionBehavior: { kind: 'scale', scale: 2 },
    supportsVideoRealtime: true,
  },
  {
    id: 'anime4k/Upscale/DenoiseCNNx2VL',
    backendId: anime4kBackendId,
    key: 'DenoiseCNNx2VL',
    name: 'Upscale & Denoise CNN x2 (VL)',
    category: 'upscale',
    dimensionBehavior: { kind: 'scale', scale: 2 },
    supportsVideoRealtime: true,
  },
  {
    id: 'anime4k/Upscale/CNNx2UL',
    backendId: anime4kBackendId,
    key: 'CNNx2UL',
    name: 'Upscale CNN x2 (UL)',
    category: 'upscale',
    dimensionBehavior: { kind: 'scale', scale: 2 },
    supportsVideoRealtime: true,
  },
  {
    id: 'anime4k/Upscale/GANx3L',
    backendId: anime4kBackendId,
    key: 'GANx3L',
    name: 'Upscale GAN x3 (L)',
    category: 'upscale',
    dimensionBehavior: { kind: 'scale', scale: 3 },
    supportsVideoRealtime: true,
  },
  {
    id: 'anime4k/Upscale/GANx4UUL',
    backendId: anime4kBackendId,
    key: 'GANx4UUL',
    name: 'Upscale GAN x4 (UUL)',
    category: 'upscale',
    dimensionBehavior: { kind: 'scale', scale: 4 },
    supportsVideoRealtime: true,
  },
  {
    id: 'anime4k/Helper/ClampHighlights',
    backendId: anime4kBackendId,
    key: 'ClampHighlights',
    name: 'Clamp Highlights',
    category: 'helper',
    dimensionBehavior: { kind: 'same' },
    supportsVideoRealtime: true,
  },
];

const effectDescriptorByKey = new Map(anime4kEffectDescriptors.map(descriptor => [descriptor.key, descriptor]));

const presetTemplates: Record<Anime4KPresetId, Record<PerformanceTier, string[]>> = {
  A: {
    performance: ['ClampHighlights', 'CNNM', 'CNNx2M', 'CNNx2M'],
    balanced: ['ClampHighlights', 'CNNVL', 'CNNx2VL', 'CNNx2M'],
    quality: ['ClampHighlights', 'CNNUL', 'CNNx2UL', 'CNNx2VL'],
    ultra: ['ClampHighlights', 'CNNUL', 'CNNx2UL', 'CNNx2UL'],
  },
  B: {
    performance: ['ClampHighlights', 'CNNSoftM', 'CNNx2M', 'CNNx2M'],
    balanced: ['ClampHighlights', 'CNNSoftVL', 'CNNx2VL', 'CNNx2M'],
    quality: ['ClampHighlights', 'CNNSoftVL', 'CNNx2UL', 'CNNx2VL'],
    ultra: ['ClampHighlights', 'CNNSoftVL', 'CNNx2UL', 'CNNx2UL'],
  },
  C: {
    performance: ['ClampHighlights', 'DenoiseCNNx2VL', 'CNNx2M'],
    balanced: ['ClampHighlights', 'DenoiseCNNx2VL', 'CNNx2M'],
    quality: ['ClampHighlights', 'DenoiseCNNx2VL', 'CNNx2VL'],
    ultra: ['ClampHighlights', 'DenoiseCNNx2VL', 'CNNx2UL'],
  },
  'A+A': {
    performance: ['ClampHighlights', 'CNNM', 'CNNx2M', 'CNNM', 'CNNx2M'],
    balanced: ['ClampHighlights', 'CNNVL', 'CNNx2VL', 'CNNVL', 'CNNx2M'],
    quality: ['ClampHighlights', 'CNNUL', 'CNNx2UL', 'CNNUL', 'CNNx2VL'],
    ultra: ['ClampHighlights', 'CNNUL', 'CNNx2UL', 'CNNUL', 'CNNx2UL', 'CNNUL', 'CNNx2VL'],
  },
  'B+B': {
    performance: ['ClampHighlights', 'CNNSoftM', 'CNNx2M', 'CNNSoftM', 'CNNx2M'],
    balanced: ['ClampHighlights', 'CNNSoftVL', 'CNNx2VL', 'CNNSoftVL', 'CNNx2M'],
    quality: ['ClampHighlights', 'CNNSoftVL', 'CNNx2UL', 'CNNSoftVL', 'CNNx2VL'],
    ultra: ['ClampHighlights', 'CNNSoftVL', 'CNNx2UL', 'CNNSoftVL', 'CNNx2UL'],
  },
  'C+A': {
    performance: ['ClampHighlights', 'DenoiseCNNx2VL', 'CNNM', 'CNNx2M'],
    balanced: ['ClampHighlights', 'DenoiseCNNx2VL', 'CNNVL', 'CNNx2M'],
    quality: ['ClampHighlights', 'DenoiseCNNx2VL', 'CNNUL', 'CNNx2VL'],
    ultra: ['ClampHighlights', 'DenoiseCNNx2VL', 'CNNUL', 'CNNx2UL'],
  },
};

export function resolveAnime4kPreset(modeId: string, tier: PerformanceTier): EffectReference[] {
  const preset = (modeId in presetTemplates ? modeId : 'A') as Anime4KPresetId;
  return presetTemplates[preset][tier]
    .map(key => effectDescriptorByKey.get(key))
    .filter((descriptor): descriptor is EffectDescriptor => Boolean(descriptor))
    .map(descriptor => createEffectReference(descriptor));
}
