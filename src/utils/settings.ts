/**
 * 设置管理模块
 * 处理 storage.sync（跨设备同步）和 storage.local（本地存储）的读写
 */

import type {
  Anime4KWebExtSettings,
  SyncedSettings,
  LocalSettings,
  EnhancementMode,
  BuiltInMode,
  CustomMode,
  EnhancementEffect,
  PerformanceTier,
  BaseMode,
} from '../types';
import { AVAILABLE_EFFECTS } from './effects-map';
import { resolveEffectChain } from './effect-chain-templates';

// ===== 内置模式定义 =====
export const BUILTIN_MODES: BuiltInMode[] = [
  { id: 'builtin-mode-a', baseMode: 'A', name: 'Mode A', isBuiltIn: true },
  { id: 'builtin-mode-b', baseMode: 'B', name: 'Mode B', isBuiltIn: true },
  { id: 'builtin-mode-c', baseMode: 'C', name: 'Mode C', isBuiltIn: true },
  { id: 'builtin-mode-aa', baseMode: 'A+A', name: 'Mode A+A', isBuiltIn: true },
  { id: 'builtin-mode-bb', baseMode: 'B+B', name: 'Mode B+B', isBuiltIn: true },
  { id: 'builtin-mode-ca', baseMode: 'C+A', name: 'Mode C+A', isBuiltIn: true },
];

// ===== 默认设置 =====
const DEFAULT_SYNCED_SETTINGS: SyncedSettings = {
  selectedModeId: 'builtin-mode-a',
  targetResolutionSetting: 'x2',
  whitelistEnabled: false,
  whitelist: [],
  customModes: [],
  enableCrossOriginFix: false,
};

const DEFAULT_LOCAL_SETTINGS: LocalSettings = {
  performanceTier: 'balanced',
  gpuBenchmarkResult: null,
  hasCompletedOnboarding: false,
};

/**
 * 确保自定义模式中的效果与 AVAILABLE_EFFECTS 保持一致
 */
export function synchronizeEffectsForCustomModes(modes: CustomMode[]): CustomMode[] {
  const availableEffectsMap = new Map(
    AVAILABLE_EFFECTS.map(e => [e.id, e])
  );

  return modes.map(mode => {
    const synchronizedEffects = mode.effects
      .map(effectInMode => availableEffectsMap.get(effectInMode.id))
      .filter((effect): effect is EnhancementEffect => !!effect);

    return { ...mode, effects: synchronizedEffects };
  });
}

/**
 * 获取同步设置（storage.sync）
 */
export async function getSyncedSettings(): Promise<SyncedSettings> {
  return new Promise(resolve => {
    chrome.storage.sync.get([
      'selectedModeId',
      'targetResolutionSetting',
      'whitelistEnabled',
      'whitelist',
      'customModes',
      'enableCrossOriginFix',
    ], (data) => {
      resolve({
        selectedModeId: data.selectedModeId ?? DEFAULT_SYNCED_SETTINGS.selectedModeId,
        targetResolutionSetting: data.targetResolutionSetting ?? DEFAULT_SYNCED_SETTINGS.targetResolutionSetting,
        whitelistEnabled: data.whitelistEnabled ?? DEFAULT_SYNCED_SETTINGS.whitelistEnabled,
        whitelist: data.whitelist ?? DEFAULT_SYNCED_SETTINGS.whitelist,
        customModes: data.customModes ?? DEFAULT_SYNCED_SETTINGS.customModes,
        enableCrossOriginFix: data.enableCrossOriginFix ?? DEFAULT_SYNCED_SETTINGS.enableCrossOriginFix,
      });
    });
  });
}

/**
 * 获取本地设置（storage.local）
 */
export async function getLocalSettings(): Promise<LocalSettings> {
  return new Promise(resolve => {
    chrome.storage.local.get([
      'performanceTier',
      'gpuBenchmarkResult',
      'gpuAdapterInfo',
      'hasCompletedOnboarding',
    ], (data) => {
      resolve({
        performanceTier: data.performanceTier ?? DEFAULT_LOCAL_SETTINGS.performanceTier,
        gpuBenchmarkResult: data.gpuBenchmarkResult ?? DEFAULT_LOCAL_SETTINGS.gpuBenchmarkResult,
        hasCompletedOnboarding: data.hasCompletedOnboarding ?? DEFAULT_LOCAL_SETTINGS.hasCompletedOnboarding,
      });
    });
  });
}

/**
 * 获取完整设置（合并 sync 和 local）
 * 内置模式会根据当前档位动态解析效果链
 */
export async function getSettings(): Promise<Anime4KWebExtSettings> {
  const [synced, local] = await Promise.all([
    getSyncedSettings(),
    getLocalSettings(),
  ]);

  // 同步自定义模式的效果
  const syncedCustomModes = synchronizeEffectsForCustomModes(synced.customModes);

  // 合并内置模式和自定义模式
  const enhancementModes: EnhancementMode[] = [
    ...BUILTIN_MODES,
    ...syncedCustomModes,
  ];

  return {
    ...synced,
    customModes: syncedCustomModes,
    performanceTier: local.performanceTier,
    enhancementModes,
  };
}

/**
 * 保存同步设置
 */
export async function saveSyncedSettings(settings: Partial<SyncedSettings>): Promise<void> {
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

/**
 * 保存本地设置
 */
export async function saveLocalSettings(settings: Partial<LocalSettings>): Promise<void> {
  return new Promise((resolve, reject) => {
    chrome.storage.local.set(settings, () => {
      if (chrome.runtime.lastError) {
        reject(chrome.runtime.lastError);
      } else {
        resolve();
      }
    });
  });
}

/**
 * 保存设置（兼容旧 API，自动分离 sync 和 local）
 */
export async function saveSettings(settings: Partial<Anime4KWebExtSettings>): Promise<void> {
  const syncKeys: (keyof SyncedSettings)[] = [
    'selectedModeId',
    'targetResolutionSetting',
    'whitelistEnabled',
    'whitelist',
    'customModes',
    'enableCrossOriginFix',
  ];

  const localKeys: (keyof LocalSettings)[] = [
    'performanceTier',
    'gpuBenchmarkResult',
    'hasCompletedOnboarding',
  ];

  const syncSettings: Partial<SyncedSettings> = {};
  const localSettings: Partial<LocalSettings> = {};

  for (const key of syncKeys) {
    if (key in settings) {
      (syncSettings as any)[key] = (settings as any)[key];
    }
  }

  for (const key of localKeys) {
    if (key in settings) {
      (localSettings as any)[key] = (settings as any)[key];
    }
  }

  const promises: Promise<void>[] = [];
  if (Object.keys(syncSettings).length > 0) {
    promises.push(saveSyncedSettings(syncSettings));
  }
  if (Object.keys(localSettings).length > 0) {
    promises.push(saveLocalSettings(localSettings));
  }

  await Promise.all(promises);
}

/**
 * 根据模式和档位获取实际效果链
 */
export function getEffectsForMode(
  mode: EnhancementMode,
  tier: PerformanceTier
): EnhancementEffect[] {
  if (mode.isBuiltIn) {
    // 内置模式：根据档位动态解析
    return resolveEffectChain((mode as BuiltInMode).baseMode, tier);
  } else {
    // 自定义模式：使用用户定义的效果链
    return (mode as CustomMode).effects;
  }
}

/**
 * 根据 ID 查找模式
 */
export function findModeById(
  modes: EnhancementMode[],
  modeId: string
): EnhancementMode | undefined {
  return modes.find(m => m.id === modeId);
}