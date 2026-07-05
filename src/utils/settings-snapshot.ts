import type { Anime4KWebExtSettings } from '../types';
import { getSettings } from './settings';
import { compileWhitelistRules, type CompiledWhitelistRule } from './whitelist';
import { createLogger } from './logger';

export interface SettingsSnapshot {
  settings: Anime4KWebExtSettings;
  compiledWhitelist: CompiledWhitelistRule[];
  revision: number;
}

type SettingsSnapshotListener = (snapshot: SettingsSnapshot) => void;

const SYNC_KEYS = new Set([
  'selectedModeId',
  'targetResolutionSetting',
  'whitelistEnabled',
  'whitelist',
  'customModes',
  'enableCrossOriginFix',
]);

const LOCAL_KEYS = new Set([
  'performanceTier',
  'gpuBenchmarkResult',
  'hasCompletedOnboarding',
  'performanceMonitorMode',
  'performanceMonitorHudCollapsed',
  'performanceMonitorHudPosition',
  'performanceMonitorHudWidth',
]);

let currentSnapshot: SettingsSnapshot | null = null;
let initPromise: Promise<SettingsSnapshot> | null = null;
let refreshPromise: Promise<SettingsSnapshot> | null = null;
let storageListenerInstalled = false;
const listeners = new Set<SettingsSnapshotListener>();
const logger = createLogger('settings-snapshot');

function notifyListeners(snapshot: SettingsSnapshot): void {
  listeners.forEach(listener => {
    try {
      listener(snapshot);
    } catch (error) {
      logger.error('Settings snapshot listener failed.', error);
    }
  });
}

function buildSnapshot(settings: Anime4KWebExtSettings): SettingsSnapshot {
  return {
    settings,
    compiledWhitelist: compileWhitelistRules(settings.whitelist ?? []),
    revision: (currentSnapshot?.revision ?? 0) + 1,
  };
}

function shouldRefreshSnapshot(
  changes: Record<string, chrome.storage.StorageChange>,
  areaName: 'sync' | 'local' | 'managed' | string,
): boolean {
  if (areaName === 'sync') {
    return Object.keys(changes).some(key => SYNC_KEYS.has(key));
  }

  if (areaName === 'local') {
    return Object.keys(changes).some(key => LOCAL_KEYS.has(key));
  }

  return false;
}

function ensureStorageListener(): void {
  if (storageListenerInstalled) {
    return;
  }

  chrome.storage.onChanged.addListener((changes, areaName) => {
    if (!shouldRefreshSnapshot(changes, areaName)) {
      return;
    }

    void refreshSettingsSnapshot();
  });

  storageListenerInstalled = true;
}

export async function refreshSettingsSnapshot(): Promise<SettingsSnapshot> {
  ensureStorageListener();

  if (!refreshPromise) {
    refreshPromise = (async () => {
      const settings = await getSettings();
      const nextSnapshot = buildSnapshot(settings);
      currentSnapshot = nextSnapshot;
      notifyListeners(nextSnapshot);
      return nextSnapshot;
    })();
  }

  try {
    return await refreshPromise;
  } finally {
    refreshPromise = null;
  }
}

export async function initSettingsSnapshot(): Promise<SettingsSnapshot> {
  ensureStorageListener();

  if (!currentSnapshot) {
    initPromise ??= refreshSettingsSnapshot();
    currentSnapshot = await initPromise;
  }

  return currentSnapshot;
}

export function getSettingsSnapshot(): SettingsSnapshot {
  if (!currentSnapshot) {
    throw new Error('Settings snapshot has not been initialized.');
  }

  return currentSnapshot;
}

export function subscribeSettingsSnapshot(listener: SettingsSnapshotListener): () => void {
  listeners.add(listener);
  return () => {
    listeners.delete(listener);
  };
}
