import type {
  NijiLucidSettings,
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

export type SettingsStorageArea = 'sync' | 'local';

export interface SettingsSaveFailure {
  area: SettingsStorageArea;
  error: unknown;
}

export class SettingsSaveError extends Error {
  readonly failures: SettingsSaveFailure[];

  readonly succeededAreas: SettingsStorageArea[];

  constructor(failures: SettingsSaveFailure[], succeededAreas: SettingsStorageArea[]) {
    const failedAreas = failures.map(failure => failure.area).join(', ');
    super(`Failed to save settings to ${failedAreas}.`);
    this.name = 'SettingsSaveError';
    this.failures = failures;
    this.succeededAreas = succeededAreas;
  }
}

export async function getSettings(): Promise<NijiLucidSettings> {
  const [synced, local] = await Promise.all([
    getSyncedSettings(),
    getLocalSettings(),
  ]);

  return buildEnhancementSettings({
    ...synced,
    performanceTier: local.performanceTier,
    performanceMonitorMode: local.performanceMonitorMode,
    performanceMonitorHudCollapsed: local.performanceMonitorHudCollapsed,
    performanceMonitorHudPosition: local.performanceMonitorHudPosition,
    performanceMonitorHudWidth: local.performanceMonitorHudWidth,
  });
}

export async function saveSettings(settings: Partial<NijiLucidSettings>): Promise<void> {
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
    'performanceMonitorMode',
    'performanceMonitorHudCollapsed',
    'performanceMonitorHudPosition',
    'performanceMonitorHudWidth',
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

  const operations: Array<{ area: SettingsStorageArea; promise: Promise<void> }> = [];
  if (Object.keys(syncSettings).length > 0) {
    operations.push({ area: 'sync', promise: saveSyncedSettings(syncSettings) });
  }
  if (Object.keys(localSettings).length > 0) {
    operations.push({ area: 'local', promise: saveLocalSettings(localSettings) });
  }

  const results = await Promise.allSettled(operations.map(operation => operation.promise));
  const failures: SettingsSaveFailure[] = [];
  const succeededAreas: SettingsStorageArea[] = [];

  results.forEach((result, index) => {
    const area = operations[index].area;
    if (result.status === 'fulfilled') {
      succeededAreas.push(area);
      return;
    }

    failures.push({
      area,
      error: result.reason,
    });
  });

  if (failures.length > 0) {
    throw new SettingsSaveError(failures, succeededAreas);
  }
}
