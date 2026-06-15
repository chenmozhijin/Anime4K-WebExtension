import type {
  BenchmarkRunState,
  LocalSettings,
  SyncedSettings,
} from '../../types';

export const DEFAULT_SYNCED_SETTINGS: SyncedSettings = {
  selectedModeId: 'builtin-mode-a',
  targetResolutionSetting: 'x2',
  whitelistEnabled: false,
  whitelist: [],
  customModes: [],
  enableCrossOriginFix: false,
};

export const DEFAULT_LOCAL_SETTINGS: LocalSettings = {
  performanceTier: 'balanced',
  gpuBenchmarkResult: null,
  hasCompletedOnboarding: false,
  benchmarkRunState: {
    status: 'idle',
    fallbackTierApplied: null,
  },
};

export function normalizeBenchmarkRunState(state: unknown): BenchmarkRunState {
  if (!state || typeof state !== 'object') {
    return { ...DEFAULT_LOCAL_SETTINGS.benchmarkRunState };
  }

  const candidate = state as Partial<BenchmarkRunState>;
  return {
    status: candidate.status ?? DEFAULT_LOCAL_SETTINGS.benchmarkRunState.status,
    failureReason: candidate.failureReason,
    fallbackTierApplied: candidate.fallbackTierApplied ?? null,
    startedAt: candidate.startedAt,
    endedAt: candidate.endedAt,
  };
}

export async function getSyncedSettings(): Promise<SyncedSettings> {
  return new Promise(resolve => {
    chrome.storage.sync.get([
      'selectedModeId',
      'targetResolutionSetting',
      'whitelistEnabled',
      'whitelist',
      'customModes',
      'enableCrossOriginFix',
    ], data => {
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

export async function getLocalSettings(): Promise<LocalSettings> {
  return new Promise(resolve => {
    chrome.storage.local.get([
      'performanceTier',
      'gpuBenchmarkResult',
      'gpuAdapterInfo',
      'hasCompletedOnboarding',
      'benchmarkRunState',
    ], data => {
      resolve({
        performanceTier: data.performanceTier ?? DEFAULT_LOCAL_SETTINGS.performanceTier,
        gpuBenchmarkResult: data.gpuBenchmarkResult ?? DEFAULT_LOCAL_SETTINGS.gpuBenchmarkResult,
        hasCompletedOnboarding: data.hasCompletedOnboarding ?? DEFAULT_LOCAL_SETTINGS.hasCompletedOnboarding,
        benchmarkRunState: normalizeBenchmarkRunState(data.benchmarkRunState),
      });
    });
  });
}

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
