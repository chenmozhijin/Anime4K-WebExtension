import type {
  Anime4KWebExtSettings,
  LocalSettings,
  SyncedSettings,
} from '../../types';
import { buildEnhancementSettings } from '../enhancement/domain/modes';
import {
  getLocalSettings,
  getSyncedSettings,
  saveLocalSettings,
  saveSyncedSettings,
} from './storage';

export async function getSettings(): Promise<Anime4KWebExtSettings> {
  const [synced, local] = await Promise.all([
    getSyncedSettings(),
    getLocalSettings(),
  ]);

  return buildEnhancementSettings({
    ...synced,
    performanceTier: local.performanceTier,
  });
}

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
    'benchmarkRunState',
  ];

  const syncSettings: Partial<SyncedSettings> = {};
  const localSettings: Partial<LocalSettings> = {};

  for (const key of syncKeys) {
    if (key in settings) {
      (syncSettings as Record<string, unknown>)[key] = (settings as Record<string, unknown>)[key];
    }
  }

  for (const key of localKeys) {
    if (key in settings) {
      (localSettings as Record<string, unknown>)[key] = (settings as Record<string, unknown>)[key];
    }
  }

  const operations: Promise<void>[] = [];
  if (Object.keys(syncSettings).length > 0) {
    operations.push(saveSyncedSettings(syncSettings));
  }
  if (Object.keys(localSettings).length > 0) {
    operations.push(saveLocalSettings(localSettings));
  }

  await Promise.all(operations);
}
