import { Anime4KWebExtSettings, EnhancementMode, EnhancementEffect } from '../types';
import { AVAILABLE_EFFECTS } from './effects-map';

// 定义内置模式，用于迁移和默认设置
const BUILTIN_MODES: EnhancementMode[] = [
  {
    id: 'builtin-mode-a',
    name: 'Mode A',
    isBuiltIn: true,
    effects: [
      AVAILABLE_EFFECTS.find(e => e.id === 'anime4k/Helper/ClampHighlights')!,
      AVAILABLE_EFFECTS.find(e => e.id === 'anime4k/Restore/CNNVL')!,
      AVAILABLE_EFFECTS.find(e => e.id === 'anime4k/Upscale/CNNx2VL')!,
      AVAILABLE_EFFECTS.find(e => e.id === 'anime4k/Upscale/CNNx2M')!,
    ].filter(Boolean)
  },
  {
    id: 'builtin-mode-b',
    name: 'Mode B',
    isBuiltIn: true,
    effects: [
      AVAILABLE_EFFECTS.find(e => e.id === 'anime4k/Helper/ClampHighlights')!,
      AVAILABLE_EFFECTS.find(e => e.id === 'anime4k/Restore/CNNSoftVL')!,
      AVAILABLE_EFFECTS.find(e => e.id === 'anime4k/Upscale/CNNx2VL')!,
      AVAILABLE_EFFECTS.find(e => e.id === 'anime4k/Upscale/CNNx2M')!,
    ].filter(Boolean)
  },
  {
    id: 'builtin-mode-c',
    name: 'Mode C',
    isBuiltIn: true,
    effects: [
      AVAILABLE_EFFECTS.find(e => e.id === 'anime4k/Helper/ClampHighlights')!,
      AVAILABLE_EFFECTS.find(e => e.id === 'anime4k/Upscale/DenoiseCNNx2VL')!,
      AVAILABLE_EFFECTS.find(e => e.id === 'anime4k/Upscale/CNNx2M')!,
    ].filter(Boolean)
  },
  {
    id: 'builtin-mode-aa',
    name: 'Mode A+A',
    isBuiltIn: true,
    effects: [
      AVAILABLE_EFFECTS.find(e => e.id === 'anime4k/Helper/ClampHighlights')!,
      AVAILABLE_EFFECTS.find(e => e.id === 'anime4k/Restore/CNNVL')!,
      AVAILABLE_EFFECTS.find(e => e.id === 'anime4k/Upscale/CNNx2VL')!,
      AVAILABLE_EFFECTS.find(e => e.id === 'anime4k/Restore/CNNVL')!,
      AVAILABLE_EFFECTS.find(e => e.id === 'anime4k/Upscale/CNNx2M')!,
    ].filter(Boolean)
  },
  {
    id: 'builtin-mode-bb',
    name: 'Mode B+B',
    isBuiltIn: true,
    effects: [
      AVAILABLE_EFFECTS.find(e => e.id === 'anime4k/Helper/ClampHighlights')!,
      AVAILABLE_EFFECTS.find(e => e.id === 'anime4k/Restore/CNNSoftVL')!,
      AVAILABLE_EFFECTS.find(e => e.id === 'anime4k/Upscale/CNNx2VL')!,
      AVAILABLE_EFFECTS.find(e => e.id === 'anime4k/Restore/CNNSoftVL')!,
      AVAILABLE_EFFECTS.find(e => e.id === 'anime4k/Upscale/CNNx2M')!,
    ].filter(Boolean)
  },
  {
    id: 'builtin-mode-ca',
    name: 'Mode C+A',
    isBuiltIn: true,
    effects: [
      AVAILABLE_EFFECTS.find(e => e.id === 'anime4k/Helper/ClampHighlights')!,
      AVAILABLE_EFFECTS.find(e => e.id === 'anime4k/Upscale/DenoiseCNNx2VL')!,
      AVAILABLE_EFFECTS.find(e => e.id === 'anime4k/Restore/CNNVL')!,
      AVAILABLE_EFFECTS.find(e => e.id === 'anime4k/Upscale/CNNx2M')!,
    ].filter(Boolean)
  }
];


/**
 * Ensures all effects within a list of modes are consistent with AVAILABLE_EFFECTS.
 * It removes effects that no longer exist and updates properties of existing ones.
 * @param modes The array of enhancement modes to synchronize.
 * @returns A new array of synchronized enhancement modes.
 */
export function synchronizeEffectsForAllModes(modes: EnhancementMode[]): EnhancementMode[] {
  const availableEffectsMap = new Map(
    AVAILABLE_EFFECTS.map(e => [e.id, e])
  );

  return modes.map(mode => {
    const synchronizedEffects = mode.effects
      // Map to the full, fresh effect object from our source of truth
      .map(effectInMode => availableEffectsMap.get(effectInMode.id))
      // Filter out any effects that were not found (i.e., they were removed from AVAILABLE_EFFECTS)
      .filter((effect): effect is EnhancementEffect => !!effect);

    return { ...mode, effects: synchronizedEffects };
  });
}

/**
 * Synchronizes the stored enhancement modes with the latest built-in mode definitions
 * and ensures all effects within every mode are consistent with AVAILABLE_EFFECTS.
 * This should be called once on extension startup.
 */
export async function syncModes(): Promise<void> {
  const data = await chrome.storage.sync.get('enhancementModes');
  const storedModes = (data.enhancementModes) as EnhancementMode[] | undefined;

  const builtInModes = JSON.parse(JSON.stringify(BUILTIN_MODES)) as EnhancementMode[];
  const builtInModesMap = new Map(builtInModes.map(m => [m.id, m]));

  let finalModes: EnhancementMode[];

  if (storedModes) {
    // Settings exist, use them as the base and refresh built-in modes
    finalModes = storedModes;

    // Refresh built-in modes from constants to ensure they are up-to-date
    finalModes.forEach(mode => {
      if (mode.isBuiltIn && builtInModesMap.has(mode.id)) {
        const freshBuiltInMode = builtInModesMap.get(mode.id)!;
        // Update properties from the constant definition
        mode.name = freshBuiltInMode.name;
        mode.effects = freshBuiltInMode.effects;
      }
    });

    // Add any new built-in modes from the code that are not in storage yet
    for (const builtInMode of builtInModes) {
      if (!finalModes.some(m => m.id === builtInMode.id)) {
        finalModes.push(builtInMode);
      }
    }

    // Remove any built-in modes from storage that no longer exist in code
    finalModes = finalModes.filter(mode => {
      return !mode.isBuiltIn || builtInModesMap.has(mode.id);
    });

  } else {
    // First time run or empty settings, initialize with default built-in modes
    finalModes = builtInModes;
  }

  // Synchronize effects for ALL modes (custom and built-in) against AVAILABLE_EFFECTS.
  // This cleans up custom modes and acts as a final consistency check for built-in ones.
  const fullySynchronizedModes = synchronizeEffectsForAllModes(finalModes);

  await new Promise<void>((resolve) => {
    chrome.storage.sync.set({ enhancementModes: fullySynchronizedModes }, () => resolve());
  });
  console.log('[Anime4KWebExt] All enhancement modes synchronized.');
}

/**
 * 获取Anime4K设置
 * @returns 设置对象
 */
export async function getSettings(): Promise<Anime4KWebExtSettings> {
  return new Promise(resolve => {
    chrome.storage.sync.get([
      'selectedModeId',
      'enhancementModes',
      'targetResolutionSetting',
      'whitelistEnabled',
      'whitelist',
      'enableCrossOriginFix', // 新增
    ], (data) => {
      // This function now assumes that `syncBuiltInModes` has been run at startup.
      // It primarily just retrieves data and applies defaults.
      resolve({
        selectedModeId: data.selectedModeId || 'builtin-mode-a',
        enhancementModes: data.enhancementModes || [], // Should have been synced
        targetResolutionSetting: data.targetResolutionSetting || 'x2',
        whitelistEnabled: data.whitelistEnabled !== undefined ? data.whitelistEnabled : false,
        whitelist: data.whitelist || [],
        enableCrossOriginFix: data.enableCrossOriginFix !== undefined ? data.enableCrossOriginFix : false, // 新增
      });
    });
  });
}

/**
 * 保存Anime4K设置
 * @param settings 要保存的设置
 */
export async function saveSettings(settings: Partial<Anime4KWebExtSettings>): Promise<void> {
  return new Promise((resolve, reject) => {
    chrome.storage.sync.set(settings, () => {
      if (chrome.runtime.lastError) {
        reject(chrome.runtime.lastError);
      } else {
        resolve();
      }
    });
  });
}