import type { EffectDescriptor, EnhancementEffect } from '../../../types';

export type EffectBrowserBackendId = 'all' | 'anime4k' | 'artcnn' | 'acnet' | 'cunny' | 'core';

export interface EffectPresentationItem {
  descriptor: EffectDescriptor;
  backendLabel: string;
  groupLabel: string;
  dimensionLabel: string;
  searchText: string;
  sortKey: string;
}

export interface EffectPresentationGroup {
  label: string;
  items: EffectPresentationItem[];
}

const backendOrder: Record<string, number> = {
  anime4k: 0,
  artcnn: 1,
  acnet: 2,
  cunny: 3,
  core: 4,
};

const backendLabels: Record<string, string> = {
  anime4k: 'Anime4K',
  artcnn: 'ArtCNN',
  acnet: 'ACNet',
  cunny: 'CuNNy',
  core: 'Core',
};

const categoryLabels: Record<string, string> = {
  restore: 'Restore',
  upscale: 'Upscale',
  denoise: 'Denoise',
  deblur: 'Deblur',
  helper: 'Helper',
  resize: 'Resize',
  custom: 'Custom',
};

const categoryOrder: Record<string, number> = {
  restore: 0,
  upscale: 1,
  denoise: 2,
  deblur: 3,
  helper: 4,
  resize: 5,
  custom: 6,
};

function getDimensionLabel(descriptor: EffectDescriptor): string {
  if (descriptor.dimensionBehavior.kind === 'scale') {
    return `x${descriptor.dimensionBehavior.scale ?? 1}`;
  }

  return descriptor.dimensionBehavior.kind === 'target' ? 'target' : 'same';
}

function getArtCNNGroup(descriptor: EffectDescriptor): string {
  return descriptor.key.includes('C4F32') ? 'C4F32' : 'C4F16';
}

function getACNetGroup(descriptor: EffectDescriptor): string {
  if (descriptor.id.includes('/Legacy/')) {
    return 'Legacy';
  }

  if (descriptor.id.includes('/ARNet/')) {
    return 'ARNet';
  }

  return 'ACNet';
}

function getCuNNyGroup(descriptor: EffectDescriptor): string {
  return descriptor.id.includes('/SOFT/') ? 'SOFT' : 'DS';
}

export function getEffectGroupLabel(descriptor: EffectDescriptor, activeBackend: EffectBrowserBackendId): string {
  if (activeBackend === 'all') {
    return backendLabels[descriptor.backendId] ?? descriptor.backendId;
  }

  switch (descriptor.backendId) {
    case 'anime4k':
      return categoryLabels[descriptor.category] ?? descriptor.category;
    case 'artcnn':
      return getArtCNNGroup(descriptor);
    case 'acnet':
      return getACNetGroup(descriptor);
    case 'cunny':
      return getCuNNyGroup(descriptor);
    case 'core':
      return categoryLabels[descriptor.category] ?? descriptor.category;
    default:
      return backendLabels[descriptor.backendId] ?? descriptor.backendId;
  }
}

function getGroupSortWeight(descriptor: EffectDescriptor, activeBackend: EffectBrowserBackendId): number {
  if (activeBackend === 'all') {
    return backendOrder[descriptor.backendId] ?? 99;
  }

  if (descriptor.backendId === 'anime4k' || descriptor.backendId === 'core') {
    return categoryOrder[descriptor.category] ?? 99;
  }

  const label = getEffectGroupLabel(descriptor, activeBackend);
  const groupOrder: Record<string, number> = {
    C4F16: 0,
    C4F32: 1,
    ACNet: 0,
    Legacy: 1,
    ARNet: 2,
    DS: 0,
    SOFT: 1,
  };
  return groupOrder[label] ?? 99;
}

function toSearchText(descriptor: EffectDescriptor, groupLabel: string, dimensionLabel: string): string {
  return [
    descriptor.name,
    descriptor.id,
    descriptor.key,
    descriptor.backendId,
    descriptor.category,
    groupLabel,
    dimensionLabel,
  ].join(' ').toLowerCase();
}

export function createEffectPresentationItem(
  descriptor: EffectDescriptor,
  activeBackend: EffectBrowserBackendId,
): EffectPresentationItem {
  const backendLabel = backendLabels[descriptor.backendId] ?? descriptor.backendId;
  const groupLabel = getEffectGroupLabel(descriptor, activeBackend);
  const dimensionLabel = getDimensionLabel(descriptor);
  return {
    descriptor,
    backendLabel,
    groupLabel,
    dimensionLabel,
    searchText: toSearchText(descriptor, groupLabel, dimensionLabel),
    sortKey: [
      String(getGroupSortWeight(descriptor, activeBackend)).padStart(2, '0'),
      String(backendOrder[descriptor.backendId] ?? 99).padStart(2, '0'),
      descriptor.name.toLowerCase(),
    ].join('/'),
  };
}

export function getEffectPresentationGroups(options: {
  effects: readonly EffectDescriptor[];
  activeBackend: EffectBrowserBackendId;
  query: string;
}): EffectPresentationGroup[] {
  const normalizedQuery = options.query.trim().toLowerCase();
  const queryTerms = normalizedQuery.split(/\s+/).filter(Boolean);
  const visibleItems = options.effects
    .filter(effect => options.activeBackend === 'all' || effect.backendId === options.activeBackend)
    .map(effect => createEffectPresentationItem(effect, options.activeBackend))
    .filter(item => queryTerms.every(term => item.searchText.includes(term)))
    .sort((left, right) => left.sortKey.localeCompare(right.sortKey));

  const groups = new Map<string, EffectPresentationItem[]>();
  for (const item of visibleItems) {
    const group = groups.get(item.groupLabel) ?? [];
    group.push(item);
    groups.set(item.groupLabel, group);
  }

  return [...groups.entries()].map(([label, items]) => ({ label, items }));
}

export function summarizeEffectChain(
  effects: readonly EnhancementEffect[],
  getLabel: (effect: EnhancementEffect) => string,
  maxVisible = 4,
): string {
  if (effects.length === 0) {
    return '';
  }

  const visibleEffects = effects.slice(0, maxVisible).map(effect => getLabel(effect));
  const hiddenCount = effects.length - visibleEffects.length;
  return hiddenCount > 0
    ? `${visibleEffects.join(' > ')} +${hiddenCount}`
    : visibleEffects.join(' > ');
}
