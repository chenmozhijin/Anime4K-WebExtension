import { Anime4KWebExtSettings } from '../types';

/**
 * 获取Anime4K设置
 * @returns 设置对象
 */
export async function getSettings(): Promise<Anime4KWebExtSettings> {
  return new Promise(resolve => {
    chrome.storage.sync.get(
      ['defaultMode', 'targetResolution', 'whitelistEnabled', 'whitelist'],
      (settings) => {
        resolve({
          selectedModeName: settings.defaultMode || 'ModeA',
          targetResolutionSetting: settings.targetResolution || 'x2',
          whitelistEnabled: settings.whitelistEnabled !== undefined ? settings.whitelistEnabled : false,
          whitelist: settings.whitelist || []
        });
      }
    );
  });
}

/**
 * 保存Anime4K设置
 * @param settings 要保存的设置
 */
export async function saveSettings(settings: Anime4KWebExtSettings): Promise<void> {
  return new Promise((resolve, reject) => {
    chrome.storage.sync.set({
      defaultMode: settings.selectedModeName,
      targetResolution: settings.targetResolutionSetting,
      whitelistEnabled: settings.whitelistEnabled,
      whitelist: settings.whitelist
    }, () => {
      if (chrome.runtime.lastError) {
        reject(chrome.runtime.lastError);
      } else {
        resolve();
      }
    });
  });
}