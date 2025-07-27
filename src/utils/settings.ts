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
 * 确保所有模式中的效果与 AVAILABLE_EFFECTS 保持一致。
 * 它会移除不再存在的效果，并更新现有效果的属性。
 * @param modes 要同步的增强模式数组。
 * @returns 同步后的新增强模式数组。
 */
export function synchronizeEffectsForAllModes(modes: EnhancementMode[]): EnhancementMode[] {
  const availableEffectsMap = new Map(
    AVAILABLE_EFFECTS.map(e => [e.id, e])
  );

  return modes.map(mode => {
    const synchronizedEffects = mode.effects
      // 映射到我们信任的数据源中完整、最新的效果对象
      .map(effectInMode => availableEffectsMap.get(effectInMode.id))
      // 过滤掉任何未找到的效果（即已从 AVAILABLE_EFFECTS 中移除的效果）
      .filter((effect): effect is EnhancementEffect => !!effect);

    return { ...mode, effects: synchronizedEffects };
  });
}

/**
 * 将存储的增强模式与最新的内置模式定义同步，
 * 并确保每个模式中的所有效果都与 AVAILABLE_EFFECTS 一致。
 * 此函数应在扩展启动时调用一次。
 */
export async function syncModes(): Promise<void> {
  const data = await chrome.storage.sync.get('enhancementModes');
  const storedModes = (data.enhancementModes) as EnhancementMode[] | undefined;

  const builtInModes = JSON.parse(JSON.stringify(BUILTIN_MODES)) as EnhancementMode[];
  const builtInModesMap = new Map(builtInModes.map(m => [m.id, m]));

  let finalModes: EnhancementMode[];

  if (storedModes) {
    // 设置已存在，使用它们作为基础并刷新内置模式
    finalModes = storedModes;

    // 从常量刷新内置模式，以确保它们是最新版本
    finalModes.forEach(mode => {
      if (mode.isBuiltIn && builtInModesMap.has(mode.id)) {
        const freshBuiltInMode = builtInModesMap.get(mode.id)!;
        // 从常量定义更新属性
        mode.name = freshBuiltInMode.name;
        mode.effects = freshBuiltInMode.effects;
      }
    });

    // 添加代码中新增但尚未存储的任何内置模式
    for (const builtInMode of builtInModes) {
      if (!finalModes.some(m => m.id === builtInMode.id)) {
        finalModes.push(builtInMode);
      }
    }

    // 从存储中移除代码中不再存在的任何内置模式
    finalModes = finalModes.filter(mode => {
      return !mode.isBuiltIn || builtInModesMap.has(mode.id);
    });

  } else {
    // 首次运行或设置为空，使用默认内置模式进行初始化
    finalModes = builtInModes;
  }

  // 根据 AVAILABLE_EFFECTS 同步所有模式（自定义和内置）的效果。
  // 这会清理自定义模式，并作为内置模式的最终一致性检查。
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
      'enableCrossOriginFix', 
    ], (data) => {
      // 此函数现在假定 `syncBuiltInModes` 已在启动时运行。
      // 它主要只检索数据并应用默认值。
      resolve({
        selectedModeId: data.selectedModeId || 'builtin-mode-a',
        enhancementModes: data.enhancementModes || [], // 应该已经被同步
        targetResolutionSetting: data.targetResolutionSetting || 'x2',
        whitelistEnabled: data.whitelistEnabled !== undefined ? data.whitelistEnabled : false,
        whitelist: data.whitelist || [],
        enableCrossOriginFix: data.enableCrossOriginFix !== undefined ? data.enableCrossOriginFix : false, 
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