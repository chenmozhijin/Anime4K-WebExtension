import type {
  BenchmarkRunState,
  LocalSettings,
  PerformanceMonitorHudPosition,
  PerformanceMonitorMode,
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
  performanceMonitorMode: 'off',
  performanceMonitorHudCollapsed: false,
  performanceMonitorHudPosition: 'top-left',
  performanceMonitorHudWidth: null,
};

function normalizePerformanceMonitorMode(value: unknown): PerformanceMonitorMode {
  return value === 'lite' || value === 'gpu' ? value : DEFAULT_LOCAL_SETTINGS.performanceMonitorMode;
}

function normalizePerformanceMonitorHudPosition(value: unknown): PerformanceMonitorHudPosition {
  switch (value) {
    case 'top-right':
    case 'bottom-left':
    case 'bottom-right':
      return value;
    case 'top-left':
    default:
      return DEFAULT_LOCAL_SETTINGS.performanceMonitorHudPosition;
  }
}

function normalizePerformanceMonitorHudWidth(value: unknown): number | null {
  if (typeof value !== 'number' || !Number.isFinite(value)) {
    return DEFAULT_LOCAL_SETTINGS.performanceMonitorHudWidth;
  }

  return Math.round(Math.min(640, Math.max(260, value)));
}

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
      'performanceMonitorMode',
      'performanceMonitorHudCollapsed',
      'performanceMonitorHudPosition',
      'performanceMonitorHudWidth',
    ], data => {
      resolve({
        performanceTier: data.performanceTier ?? DEFAULT_LOCAL_SETTINGS.performanceTier,
        gpuBenchmarkResult: data.gpuBenchmarkResult ?? DEFAULT_LOCAL_SETTINGS.gpuBenchmarkResult,
        hasCompletedOnboarding: data.hasCompletedOnboarding ?? DEFAULT_LOCAL_SETTINGS.hasCompletedOnboarding,
        benchmarkRunState: normalizeBenchmarkRunState(data.benchmarkRunState),
        performanceMonitorMode: normalizePerformanceMonitorMode(data.performanceMonitorMode),
        performanceMonitorHudCollapsed: data.performanceMonitorHudCollapsed ?? DEFAULT_LOCAL_SETTINGS.performanceMonitorHudCollapsed,
        performanceMonitorHudPosition: normalizePerformanceMonitorHudPosition(data.performanceMonitorHudPosition),
        performanceMonitorHudWidth: normalizePerformanceMonitorHudWidth(data.performanceMonitorHudWidth),
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
