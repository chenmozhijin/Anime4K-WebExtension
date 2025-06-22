import { Anime4KWebExtSettings, EnhancementMode } from '../types';
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
    ], (data) => {
      // 从存储中获取的只会是自定义模式
      const customModes = data.enhancementModes || [];
      resolve({
        selectedModeId: data.selectedModeId || 'builtin-mode-a',
        // 总是返回一个由全新的内置模式和存储的自定义模式组成的列表
        enhancementModes: [...BUILTIN_MODES, ...customModes],
        targetResolutionSetting: data.targetResolutionSetting || 'x2',
        whitelistEnabled: data.whitelistEnabled !== undefined ? data.whitelistEnabled : false,
        whitelist: data.whitelist || []
      });
    });
  });
}

/**
 * 保存Anime4K设置
 * @param settings 要保存的设置
 */
export async function saveSettings(settings: Anime4KWebExtSettings): Promise<void> {
  return new Promise((resolve, reject) => {
    // 从待保存的设置中，只过滤出自定义模式进行存储
    const customModesToSave = settings.enhancementModes.filter(mode => !mode.isBuiltIn);

    const newSettingsData = {
      selectedModeId: settings.selectedModeId,
      enhancementModes: customModesToSave,
      targetResolutionSetting: settings.targetResolutionSetting,
      whitelistEnabled: settings.whitelistEnabled,
      whitelist: settings.whitelist
    };

    chrome.storage.sync.set(newSettingsData, () => {
      if (chrome.runtime.lastError) {
        reject(chrome.runtime.lastError);
      } else {
        resolve();
      }
    });
  });
}