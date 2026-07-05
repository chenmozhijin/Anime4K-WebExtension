/**
 * 配置迁移模块
 * 将旧版 effect 结构迁移到 backend-aware effect references。
 */

import type { CustomMode, EnhancementEffect, LocalSettings, PerformanceTier, SyncedSettings } from '../types';
import { normalizeEffectReference } from '../core/effects/registry';
import { createLogger } from './logger';

interface LegacyEnhancementMode {
  id: string;
  name: string;
  isBuiltIn: boolean;
  effects: unknown[];
}

interface MigrationSyncStorage extends Partial<SyncedSettings> {
  _configVersion?: number;
  enhancementModes?: LegacyEnhancementMode[];
}

type MigrationLocalStorage = Partial<LocalSettings>;

const CURRENT_CONFIG_VERSION = 3;
const logger = createLogger('migration');

function normalizeCustomModes(modes: unknown): CustomMode[] {
  if (!Array.isArray(modes)) {
    return [];
  }

  return modes.flatMap((mode): CustomMode[] => {
    if (!mode || typeof mode !== 'object') {
      return [];
    }

    const candidate = mode as Partial<CustomMode> & { effects?: unknown[] };
    if (typeof candidate.id !== 'string' || typeof candidate.name !== 'string') {
      return [];
    }

    const effects = (candidate.effects ?? [])
      .map((effect) => normalizeEffectReference(effect))
      .filter((effect): effect is EnhancementEffect => Boolean(effect));

    return [{
      id: candidate.id,
      name: candidate.name,
      isBuiltIn: false,
      effects,
    }];
  });
}

export async function needsMigration(): Promise<boolean> {
  const data = await chrome.storage.sync.get<MigrationSyncStorage>(['_configVersion', 'enhancementModes', 'customModes']);
  return (data._configVersion ?? 0) < CURRENT_CONFIG_VERSION
    || Boolean(data.enhancementModes);
}

export async function migrateToLatest(): Promise<void> {
  logger.info('Migrating configuration to v3.');

  const syncData = await chrome.storage.sync.get<MigrationSyncStorage>([
    '_configVersion',
    'enhancementModes',
    'customModes',
    'selectedModeId',
    'targetResolutionSetting',
    'whitelistEnabled',
    'whitelist',
    'enableCrossOriginFix',
  ]);

  const legacyModes = syncData.enhancementModes as LegacyEnhancementMode[] | undefined;
  const customModes = legacyModes
    ? normalizeCustomModes(legacyModes.filter((mode) => !mode.isBuiltIn))
    : normalizeCustomModes(syncData.customModes);

  await chrome.storage.sync.set({
    customModes,
    selectedModeId: syncData.selectedModeId || 'builtin-mode-a',
    targetResolutionSetting: syncData.targetResolutionSetting || 'x2',
    whitelistEnabled: syncData.whitelistEnabled ?? false,
    whitelist: syncData.whitelist || [],
    enableCrossOriginFix: syncData.enableCrossOriginFix ?? false,
    _configVersion: CURRENT_CONFIG_VERSION,
  });

  await chrome.storage.sync.remove('enhancementModes');

  const localData = await chrome.storage.local.get<MigrationLocalStorage>([
    'performanceTier',
    'gpuBenchmarkResult',
    'hasCompletedOnboarding',
    'benchmarkRunState',
    'performanceMonitorMode',
    'performanceMonitorHudCollapsed',
    'performanceMonitorHudPosition',
    'performanceMonitorHudWidth',
  ]);
  await chrome.storage.local.set({
    performanceTier: (localData.performanceTier || 'balanced') as PerformanceTier,
    gpuBenchmarkResult: localData.gpuBenchmarkResult ?? null,
    hasCompletedOnboarding: localData.hasCompletedOnboarding ?? false,
    benchmarkRunState: localData.benchmarkRunState ?? {
      status: 'idle',
      fallbackTierApplied: null,
    },
    performanceMonitorMode: localData.performanceMonitorMode ?? 'off',
    performanceMonitorHudCollapsed: localData.performanceMonitorHudCollapsed ?? false,
    performanceMonitorHudPosition: localData.performanceMonitorHudPosition ?? 'top-left',
    performanceMonitorHudWidth: localData.performanceMonitorHudWidth ?? null,
  });
  await chrome.storage.local.remove('_benchmarkInProgress');

  logger.info(`Migrated ${customModes.length} custom modes.`);
}

export async function ensureLatestConfig(): Promise<void> {
  if (await needsMigration()) {
    await migrateToLatest();
    return;
  }

  const syncData = await chrome.storage.sync.get<MigrationSyncStorage>(['_configVersion']);
  if (!syncData._configVersion) {
    await chrome.storage.sync.set({
      customModes: [],
      selectedModeId: 'builtin-mode-a',
      targetResolutionSetting: 'x2',
      whitelistEnabled: false,
      whitelist: [],
      enableCrossOriginFix: false,
      _configVersion: CURRENT_CONFIG_VERSION,
    });

    await chrome.storage.local.set({
      performanceTier: 'balanced' as PerformanceTier,
      gpuBenchmarkResult: null,
      hasCompletedOnboarding: false,
      benchmarkRunState: {
        status: 'idle',
        fallbackTierApplied: null,
      },
      performanceMonitorMode: 'off',
      performanceMonitorHudCollapsed: false,
      performanceMonitorHudPosition: 'top-left',
      performanceMonitorHudWidth: null,
    });

    logger.info('Initialized new config with defaults.');
  }
}
