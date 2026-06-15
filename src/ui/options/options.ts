import './options.css';
import '../common-vars.css';
import { Sidebar } from './Sidebar';
import { showNotice } from '../shared/notice';
import { createLogger } from '../../utils/logger';
import { setupInternationalization, getTierDisplayName } from './modules/helpers';
import { createOptionsStateStore } from './modules/options-state';
import { createModesSection } from './modules/modes-section';
import { createWhitelistSection } from './modules/whitelist-section';
import { createGeneralSection } from './modules/general-section';

const logger = createLogger('options');

const store = createOptionsStateStore();

type OptionsSections = {
  modes: ReturnType<typeof createModesSection>;
  whitelist: ReturnType<typeof createWhitelistSection>;
  general: ReturnType<typeof createGeneralSection>;
};

let sections: OptionsSections | null = null;

const notifyUpdate = (modifiedModeId?: string) => {
  chrome.runtime.sendMessage({ type: 'SETTINGS_UPDATED', modifiedModeId });
};

async function refreshAll(): Promise<void> {
  if (!sections) {
    return;
  }

  await store.refresh();
  await renderAll();
}

async function renderAll(): Promise<void> {
  if (!sections) {
    return;
  }

  const localSettings = store.getLocalSettingsState();
  if (localSettings.benchmarkRunState.status === 'interrupted') {
    showNotice({
      kind: 'warning',
      message: chrome.i18n.getMessage('benchmarkFallbackApplied', [getTierDisplayName('performance')]),
      timeoutMs: 5000,
    });
  }

  sections.modes.render();
  sections.whitelist.render();
  await sections.general.render();
}

function bindRuntimeRefresh(): void {
  chrome.runtime.onMessage.addListener(async message => {
    if (message.type === 'SETTINGS_UPDATED') {
      await refreshAll();
      logger.debug('Settings updated.', { tier: store.getCurrentTier() });
    }
  });

  chrome.storage.onChanged.addListener((changes, areaName) => {
    if (areaName !== 'sync' && areaName !== 'local') {
      return;
    }

    const relevantKeys = [
      'selectedModeId',
      'targetResolutionSetting',
      'whitelistEnabled',
      'whitelist',
      'customModes',
      'enableCrossOriginFix',
      'performanceTier',
      'gpuBenchmarkResult',
    ];

    if (!Object.keys(changes).some(key => relevantKeys.includes(key))) {
      return;
    }

    void refreshAll();
  });
}

document.addEventListener('DOMContentLoaded', async () => {
  setupInternationalization();

  try {
    const sidebar = new Sidebar();
    sidebar.initialize();
  } catch (error) {
    logger.error('Failed to initialize sidebar:', error);
  }

  sections = {
    modes: createModesSection({
      getSettingsState: () => store.getSettingsState(),
      getCurrentTier: () => store.getCurrentTier(),
      notifyUpdate,
    }),
    whitelist: createWhitelistSection({
      getWhitelistRules: () => store.getSettingsState().whitelist,
      setWhitelistRules: rules => {
        store.getSettingsState().whitelist = rules;
      },
      refreshAll: async () => {
        await refreshAll();
      },
    }),
    general: createGeneralSection({
      getCrossOriginFixEnabled: () => store.getSettingsState().enableCrossOriginFix,
      setCrossOriginFixEnabled: enabled => {
        store.getSettingsState().enableCrossOriginFix = enabled;
      },
      getCurrentTier: () => store.getCurrentTier(),
      setCurrentTier: tier => {
        store.setCurrentTier(tier);
      },
      setBenchmarkResult: result => {
        store.getLocalSettingsState().gpuBenchmarkResult = result;
      },
      notifyUpdate,
      renderModes: () => {
        sections?.modes.render();
      },
    }),
  };

  await store.load();
  await renderAll();

  sections.modes.bindEvents();
  sections.whitelist.bindEvents();
  sections.general.bindEvents();
  bindRuntimeRefresh();
});
