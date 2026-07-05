import './popup.css';
import '../common-vars.css';
import {
  BUILTIN_MODES,
  getLocalSettings,
  getSettings,
  saveSettings,
  SettingsSaveError,
} from '../../utils/settings';
import { addWhitelistRule, setDefaultWhitelist } from '../../utils/whitelist';
import { themeManager } from '../theme-manager';
import type { PerformanceTier, EnhancementMode, CustomMode } from '../../types';
import { showNotice } from '../shared/notice';
import { runSaveAction } from '../shared/save-action';
import { createLogger } from '../../utils/logger';

let currentTier: PerformanceTier = 'balanced';
const logger = createLogger('popup');

document.addEventListener('DOMContentLoaded', async () => {
  await themeManager.ready();
  document.documentElement.setAttribute('lang', chrome.i18n.getMessage('@@ui_locale'));

  const versionInfo = document.getElementById('version-info');
  if (versionInfo) {
    versionInfo.textContent = chrome.runtime.getManifest().version;
  }

  document.querySelectorAll<HTMLElement>('[data-i18n]').forEach(element => {
    const key = element.getAttribute('data-i18n');
    if (!key) {
      return;
    }

    const message = chrome.i18n.getMessage(key);
    if (message) {
      element.textContent = message;
    }
  });

  document.querySelectorAll<HTMLElement>('[data-i18n-title]').forEach(element => {
    const key = element.getAttribute('data-i18n-title');
    if (!key) {
      return;
    }

    const message = chrome.i18n.getMessage(key);
    if (message) {
      element.setAttribute('title', message);
    }
  });

  const tierButtons = document.querySelectorAll<HTMLButtonElement>('.tier-btn');
  const modeSelect = document.getElementById('mode-select') as HTMLSelectElement | null;
  const resolutionSelect = document.getElementById('resolution-select') as HTMLSelectElement | null;
  const saveButton = document.getElementById('save-settings') as HTMLButtonElement | null;
  const whitelistToggle = document.getElementById('whitelist-toggle') as HTMLInputElement | null;
  const addCurrentPageBtn = document.getElementById('add-current-page') as HTMLButtonElement | null;
  const addCurrentDomainBtn = document.getElementById('add-current-domain') as HTMLButtonElement | null;
  const addParentPathBtn = document.getElementById('add-parent-path') as HTMLButtonElement | null;
  const openSettingsBtn = document.getElementById('open-settings') as HTMLButtonElement | null;

  if (!modeSelect || !resolutionSelect || !saveButton || !whitelistToggle
    || !addCurrentPageBtn || !addCurrentDomainBtn || !addParentPathBtn || !openSettingsBtn) {
    logger.error('Required elements not found.');
    return;
  }

  const renderModeSelect = (settings: {
    enhancementModes: EnhancementMode[];
    customModes: CustomMode[];
    selectedModeId: string;
  }) => {
    modeSelect.innerHTML = '';

    const builtInGroup = document.createElement('optgroup');
    builtInGroup.label = chrome.i18n.getMessage('builtInModes');
    BUILTIN_MODES.forEach(mode => {
      const option = document.createElement('option');
      option.value = mode.id;
      option.textContent = mode.name;
      builtInGroup.appendChild(option);
    });
    modeSelect.appendChild(builtInGroup);

    if (settings.customModes.length > 0) {
      const customGroup = document.createElement('optgroup');
      customGroup.label = chrome.i18n.getMessage('customModes');
      settings.customModes.forEach(mode => {
        const option = document.createElement('option');
        option.value = mode.id;
        option.textContent = mode.name;
        customGroup.appendChild(option);
      });
      modeSelect.appendChild(customGroup);
    }

    modeSelect.value = settings.selectedModeId;
  };

  const updateTierButtons = (tier: PerformanceTier) => {
    tierButtons.forEach(btn => {
      btn.classList.toggle('active', btn.getAttribute('data-tier') === tier);
    });
  };

  const updateTierButtonsDisabled = (isCustomMode: boolean) => {
    tierButtons.forEach(btn => {
      btn.disabled = isCustomMode;
      btn.classList.toggle('disabled', isCustomMode);
    });
  };

  const refreshControls = async () => {
    const [settings, localSettings] = await Promise.all([
      getSettings(),
      getLocalSettings(),
    ]);
    currentSettings = settings;
    currentTier = localSettings.performanceTier;
    renderModeSelect(currentSettings);
    resolutionSelect.value = currentSettings.targetResolutionSetting;
    whitelistToggle.checked = currentSettings.whitelistEnabled;
    updateTierButtons(currentTier);
    updateTierButtonsDisabled(currentSettings.selectedModeId.startsWith('custom-'));
  };

  let currentSettings;
  try {
    const [settings, localSettings] = await Promise.all([
      getSettings(),
      getLocalSettings(),
    ]);
    currentSettings = settings;
    currentTier = localSettings.performanceTier;

    if (localSettings.benchmarkRunState.status === 'interrupted') {
      showNotice({
        kind: 'warning',
        message: chrome.i18n.getMessage(
          'benchmarkFallbackApplied',
          [chrome.i18n.getMessage('tierPerformance')],
        ),
        timeoutMs: 5000,
      });
    }

    updateTierButtons(currentTier);
    renderModeSelect(currentSettings);
    resolutionSelect.value = currentSettings.targetResolutionSetting;
    whitelistToggle.checked = currentSettings.whitelistEnabled;
    updateTierButtonsDisabled(currentSettings.selectedModeId.startsWith('custom-'));

    if (currentSettings.whitelist.length === 0) {
      await setDefaultWhitelist();
      currentSettings = await getSettings();
    }
  } catch (error) {
    logger.error('Error loading settings:', error);
    modeSelect.value = 'builtin-mode-a';
    resolutionSelect.value = 'x2';
    whitelistToggle.checked = false;
  }

  tierButtons.forEach(btn => {
    btn.addEventListener('click', () => {
      const tier = btn.getAttribute('data-tier') as PerformanceTier;
      if (tier && tier !== currentTier) {
        currentTier = tier;
        updateTierButtons(tier);
        logger.debug('Performance tier selected:', tier);
      }
    });
  });

  modeSelect.addEventListener('change', () => {
    updateTierButtonsDisabled(modeSelect.value.startsWith('custom-'));
  });

  saveButton.addEventListener('click', async () => {
    try {
      const updatedSettings = {
        selectedModeId: modeSelect.value,
        targetResolutionSetting: resolutionSelect.value,
        performanceTier: currentTier,
      };
      await saveSettings(updatedSettings);
      logger.debug('Settings saved.', updatedSettings);

      const existingStatus = document.querySelector('.save-status');
      existingStatus?.remove();

      const status = document.createElement('div');
      status.className = 'save-status';
      status.textContent = chrome.i18n.getMessage('settingsSaved');
      saveButton.parentElement?.appendChild(status);

      chrome.tabs.query({ active: true, currentWindow: true }, (tabs) => {
        if (!tabs[0]?.id) {
          return;
        }

        chrome.tabs.sendMessage(tabs[0].id, {
          type: 'SETTINGS_UPDATED',
          modifiedModeId: modeSelect.value,
        }, (response?: {
          status?: 'SUCCESS' | 'NO_ACTION' | 'PARTIAL_SUCCESS' | 'ERROR';
          message?: string;
        }) => {
          if (chrome.runtime.lastError) {
            logger.warn('Message send error:', chrome.runtime.lastError.message);
            return;
          }

          logger.debug('Content script response:', response);
          if (response?.message) {
            status.textContent = response.message;
            status.classList.toggle('warning', response.status === 'PARTIAL_SUCCESS');
            status.classList.toggle('error', response.status === 'ERROR');
          }
        });
      });

      window.setTimeout(() => {
        status.remove();
        window.close();
      }, 1500);
    } catch (error) {
      logger.error('Error saving settings:', error);
      if (error instanceof SettingsSaveError && error.succeededAreas.length > 0) {
        await refreshControls();
        const failedAreas = error.failures.map(failure => failure.area).join(', ');
        showNotice({
          kind: 'warning',
          message: `${chrome.i18n.getMessage('saveFailed')}: ${failedAreas}`,
        });
        return;
      }

      showNotice({
        kind: 'error',
        message: chrome.i18n.getMessage('saveFailed'),
      });
    }
  });

  whitelistToggle.addEventListener('change', async () => {
    const nextEnabled = whitelistToggle.checked;
    await runSaveAction({
      action: async () => {
        await saveSettings({ whitelistEnabled: nextEnabled });
        logger.debug('Whitelist enabled:', nextEnabled);
      },
      logger,
      logMessage: 'Error saving whitelist toggle:',
      onError: () => {
        whitelistToggle.checked = !nextEnabled;
      },
    });
  });

  addCurrentPageBtn.addEventListener('click', async () => {
    await runSaveAction({
      action: async () => {
        const tabs = await chrome.tabs.query({ active: true, currentWindow: true });
        if (tabs.length > 0 && tabs[0].url) {
          const url = new URL(tabs[0].url);
          await addWhitelistRule(url.hostname + url.pathname);
          showNotice({ kind: 'success', message: chrome.i18n.getMessage('pageAdded') });
        }
      },
      controls: [addCurrentPageBtn],
      logger,
      errorMessage: chrome.i18n.getMessage('whitelistAddFailed'),
      logMessage: 'Error adding current URL:',
    });
  });

  addCurrentDomainBtn.addEventListener('click', async () => {
    await runSaveAction({
      action: async () => {
        const tabs = await chrome.tabs.query({ active: true, currentWindow: true });
        if (tabs.length > 0 && tabs[0].url) {
          const url = new URL(tabs[0].url);
          await addWhitelistRule(`${url.hostname}/*`);
          showNotice({ kind: 'success', message: chrome.i18n.getMessage('domainAdded') });
        }
      },
      controls: [addCurrentDomainBtn],
      logger,
      errorMessage: chrome.i18n.getMessage('whitelistAddFailed'),
      logMessage: 'Error adding current domain:',
    });
  });

  addParentPathBtn.addEventListener('click', async () => {
    await runSaveAction({
      action: async () => {
        const tabs = await chrome.tabs.query({ active: true, currentWindow: true });
        if (tabs.length > 0 && tabs[0].url) {
          const url = new URL(tabs[0].url);
          const pathParts = url.pathname.split('/').filter(Boolean);
          const parentPath = pathParts.length > 1 ? pathParts.slice(0, -1).join('/') : '';
          await addWhitelistRule(`${url.hostname}/${parentPath}/*`);
          showNotice({ kind: 'success', message: chrome.i18n.getMessage('parentPathAdded') });
        }
      },
      controls: [addParentPathBtn],
      logger,
      errorMessage: chrome.i18n.getMessage('whitelistAddFailed'),
      logMessage: 'Error adding parent path:',
    });
  });

  openSettingsBtn.addEventListener('click', () => {
    chrome.runtime.openOptionsPage();
  });
});
