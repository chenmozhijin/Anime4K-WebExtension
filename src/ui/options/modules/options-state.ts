import type { Anime4KWebExtSettings, LocalSettings, PerformanceMonitorMode, PerformanceTier } from '../../../types';
import {
  buildEnhancementModes,
  getLocalSettings,
  getSettings,
  synchronizeEffectsForCustomModes,
} from '../../../utils/settings';

export interface OptionsStateStore {
  load(): Promise<void>;
  refresh(): Promise<void>;
  getSettingsState(): Anime4KWebExtSettings;
  getLocalSettingsState(): LocalSettings;
  getCurrentTier(): PerformanceTier;
  setCurrentTier(tier: PerformanceTier): void;
  getPerformanceMonitorMode(): PerformanceMonitorMode;
  setPerformanceMonitorMode(mode: PerformanceMonitorMode): void;
  syncEnhancementModes(): void;
}

export function createOptionsStateStore(): OptionsStateStore {
  let settingsState: Anime4KWebExtSettings | null = null;
  let localSettingsState: LocalSettings | null = null;

  function ensureSettingsState(): Anime4KWebExtSettings {
    if (!settingsState) {
      throw new Error('Options state has not been loaded.');
    }

    return settingsState;
  }

  function ensureLocalSettingsState(): LocalSettings {
    if (!localSettingsState) {
      throw new Error('Local options state has not been loaded.');
    }

    return localSettingsState;
  }

  function syncEnhancementModes(): void {
    const currentState = ensureSettingsState();
    currentState.customModes = synchronizeEffectsForCustomModes(currentState.customModes);
    currentState.enhancementModes = buildEnhancementModes(currentState.customModes);
  }

  async function load(): Promise<void> {
    const [settings, localSettings] = await Promise.all([
      getSettings(),
      getLocalSettings(),
    ]);
    settingsState = settings;
    localSettingsState = localSettings;
    syncEnhancementModes();
  }

  return {
    load,
    async refresh() {
      await load();
    },
    getSettingsState: ensureSettingsState,
    getLocalSettingsState: ensureLocalSettingsState,
    getCurrentTier() {
      return ensureLocalSettingsState().performanceTier;
    },
    setCurrentTier(tier: PerformanceTier) {
      ensureLocalSettingsState().performanceTier = tier;
      ensureSettingsState().performanceTier = tier;
    },
    getPerformanceMonitorMode() {
      return ensureLocalSettingsState().performanceMonitorMode;
    },
    setPerformanceMonitorMode(mode: PerformanceMonitorMode) {
      ensureLocalSettingsState().performanceMonitorMode = mode;
      ensureSettingsState().performanceMonitorMode = mode;
    },
    syncEnhancementModes,
  };
}
