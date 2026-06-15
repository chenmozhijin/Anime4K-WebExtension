import type {
  Anime4KWebExtSettings,
  BuiltInMode,
  CustomMode,
  EnhancementEffect,
  EnhancementMode,
  PerformanceTier,
} from '../../../types';
import { normalizeEffectReference, resolvePresetEffects } from '../../../core/effects/registry';

export const BUILTIN_MODES: BuiltInMode[] = [
  { id: 'builtin-mode-a', baseMode: 'A', name: 'Mode A', backendId: 'anime4k', presetKey: 'A', isBuiltIn: true },
  { id: 'builtin-mode-b', baseMode: 'B', name: 'Mode B', backendId: 'anime4k', presetKey: 'B', isBuiltIn: true },
  { id: 'builtin-mode-c', baseMode: 'C', name: 'Mode C', backendId: 'anime4k', presetKey: 'C', isBuiltIn: true },
  { id: 'builtin-mode-aa', baseMode: 'A+A', name: 'Mode A+A', backendId: 'anime4k', presetKey: 'A+A', isBuiltIn: true },
  { id: 'builtin-mode-bb', baseMode: 'B+B', name: 'Mode B+B', backendId: 'anime4k', presetKey: 'B+B', isBuiltIn: true },
  { id: 'builtin-mode-ca', baseMode: 'C+A', name: 'Mode C+A', backendId: 'anime4k', presetKey: 'C+A', isBuiltIn: true },
];

export function synchronizeEffectsForCustomModes(modes: CustomMode[]): CustomMode[] {
  return modes.map(mode => {
    const effects = (mode.effects as unknown[])
      .map(effectInMode => normalizeEffectReference(effectInMode))
      .filter((effect): effect is EnhancementEffect => !!effect);

    return { ...mode, effects };
  });
}

export function buildEnhancementModes(customModes: CustomMode[]): EnhancementMode[] {
  return [...BUILTIN_MODES, ...customModes];
}

export function buildEnhancementSettings(
  settings: Omit<Anime4KWebExtSettings, 'enhancementModes' | 'customModes'> & { customModes: CustomMode[] },
): Anime4KWebExtSettings {
  const customModes = synchronizeEffectsForCustomModes(settings.customModes);
  return {
    ...settings,
    customModes,
    enhancementModes: buildEnhancementModes(customModes),
  };
}

export function getEffectsForMode(mode: EnhancementMode, tier: PerformanceTier): EnhancementEffect[] {
  if (mode.isBuiltIn) {
    return resolvePresetEffects(mode.backendId, mode.presetKey, tier);
  }

  return mode.effects;
}

export function findModeById(modes: EnhancementMode[], modeId: string): EnhancementMode | undefined {
  return modes.find(mode => mode.id === modeId);
}
