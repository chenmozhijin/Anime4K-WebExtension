// popup.ts
import './popup.css';
import '../common-vars.css';
import { getSettings, saveSettings, getLocalSettings, saveLocalSettings, BUILTIN_MODES } from '../../utils/settings';
import { addWhitelistRule, setDefaultWhitelist } from '../../utils/whitelist';
import { themeManager } from '../theme-manager';
import type { PerformanceTier, EnhancementMode, CustomMode } from '../../types';

// 当前档位状态
let currentTier: PerformanceTier = 'balanced';

document.addEventListener('DOMContentLoaded', async () => {
  // 初始化主题
  themeManager.getTheme(); // 这会自动应用保存的主题

  // 设置文档语言
  document.documentElement.setAttribute('lang', chrome.i18n.getMessage('@@ui_locale') || 'en');

  // 设置版本信息
  const versionInfo = document.getElementById('version-info');
  if (versionInfo) {
    const manifest = chrome.runtime.getManifest();
    versionInfo.textContent = manifest.version;
  }

  // 应用国际化
  document.querySelectorAll<HTMLElement>('[data-i18n]').forEach(element => {
    const key = element.getAttribute('data-i18n');
    if (key) {
      const message = chrome.i18n.getMessage(key);
      if (message) {
        element.textContent = message;
      }
    }
  });

  // 应用 title 国际化
  document.querySelectorAll<HTMLElement>('[data-i18n-title]').forEach(element => {
    const key = element.getAttribute('data-i18n-title');
    if (key) {
      const message = chrome.i18n.getMessage(key);
      if (message) {
        element.setAttribute('title', message);
      }
    }
  });

  // 获取 DOM 元素
  const tierButtons = document.querySelectorAll<HTMLButtonElement>('.tier-btn');
  const modeSelect = document.getElementById('mode-select') as HTMLSelectElement;
  const resolutionSelect = document.getElementById('resolution-select') as HTMLSelectElement;
  const saveButton = document.getElementById('save-settings') as HTMLButtonElement;
  const whitelistToggle = document.getElementById('whitelist-toggle') as HTMLInputElement;
  const addCurrentPageBtn = document.getElementById('add-current-page') as HTMLButtonElement;
  const addCurrentDomainBtn = document.getElementById('add-current-domain') as HTMLButtonElement;
  const addParentPathBtn = document.getElementById('add-parent-path') as HTMLButtonElement;
  const openSettingsBtn = document.getElementById('open-settings') as HTMLButtonElement;

  if (!modeSelect || !resolutionSelect || !saveButton || !whitelistToggle ||
    !addCurrentPageBtn || !addCurrentDomainBtn || !addParentPathBtn || !openSettingsBtn) {
    console.error('Required elements not found');
    return;
  }

  // 渲染模式下拉菜单
  const renderModeSelect = (settings: { enhancementModes: EnhancementMode[], customModes: CustomMode[], selectedModeId: string }) => {
    modeSelect.innerHTML = '';

    // 内置模式组
    const builtInGroup = document.createElement('optgroup');
    builtInGroup.label = chrome.i18n.getMessage('builtInModes') || 'Built-in Modes';
    BUILTIN_MODES.forEach(mode => {
      const option = document.createElement('option');
      option.value = mode.id;
      option.textContent = mode.name;
      builtInGroup.appendChild(option);
    });
    modeSelect.appendChild(builtInGroup);

    // 自定义模式组（如果有）
    if (settings.customModes && settings.customModes.length > 0) {
      const customGroup = document.createElement('optgroup');
      customGroup.label = chrome.i18n.getMessage('customModes') || 'Custom Modes';
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

  // 更新档位按钮状态
  const updateTierButtons = (tier: PerformanceTier) => {
    tierButtons.forEach(btn => {
      const btnTier = btn.getAttribute('data-tier') as PerformanceTier;
      btn.classList.toggle('active', btnTier === tier);
    });
  };

  // 更新档位选择器的禁用状态（自定义模式时禁用）
  const updateTierButtonsDisabled = (isCustomMode: boolean) => {
    tierButtons.forEach(btn => {
      btn.disabled = isCustomMode;
      btn.classList.toggle('disabled', isCustomMode);
    });
  };

  // 加载设置
  let currentSettings;
  let localSettings;
  try {
    [currentSettings, localSettings] = await Promise.all([
      getSettings(),
      getLocalSettings(),
    ]);

    currentTier = localSettings.performanceTier;
    updateTierButtons(currentTier);
    renderModeSelect(currentSettings);
    resolutionSelect.value = currentSettings.targetResolutionSetting;
    whitelistToggle.checked = currentSettings.whitelistEnabled;

    // 检查是否选择了自定义模式
    const isCustomMode = currentSettings.selectedModeId.startsWith('custom-');
    updateTierButtonsDisabled(isCustomMode);

    // 如果白名单为空，则设置默认规则
    if (currentSettings.whitelist.length === 0) {
      await setDefaultWhitelist();
      currentSettings = await getSettings();
    }
  } catch (error) {
    console.error('Error loading settings:', error);
    modeSelect.value = 'builtin-mode-a';
    resolutionSelect.value = 'x2';
    whitelistToggle.checked = false;
  }

  // 档位按钮点击事件（只更新 UI 状态，保存在点击保存按钮时执行）
  tierButtons.forEach(btn => {
    btn.addEventListener('click', () => {
      const tier = btn.getAttribute('data-tier') as PerformanceTier;
      if (tier && tier !== currentTier) {
        currentTier = tier;
        updateTierButtons(tier);
        console.log('Performance tier selected:', tier);
      }
    });
  });

  // 模式选择变化时更新档位按钮状态
  modeSelect.addEventListener('change', () => {
    const isCustomMode = modeSelect.value.startsWith('custom-');
    updateTierButtonsDisabled(isCustomMode);
  });

  // "保存"按钮点击事件
  saveButton.addEventListener('click', async () => {
    const selectedModeId = modeSelect.value;
    const selectedResolution = resolutionSelect.value;

    try {
      const updatedSettings = {
        selectedModeId,
        targetResolutionSetting: selectedResolution,
      };
      await saveSettings(updatedSettings);

      // 保存档位
      await saveLocalSettings({ performanceTier: currentTier });

      console.log('Settings saved:', { ...updatedSettings, performanceTier: currentTier });

      // 移除已存在的状态消息（避免叠加）
      const existingStatus = document.querySelector('.save-status');
      if (existingStatus) {
        existingStatus.remove();
      }

      // 显示保存成功的状态消息
      const status = document.createElement('div');
      status.className = 'save-status';
      status.textContent = chrome.i18n.getMessage('settingsSaved') || 'Settings saved!';
      saveButton.parentElement?.appendChild(status);

      // 通知当前活动标签页的内容脚本设置已更新
      chrome.tabs.query({ active: true, currentWindow: true }, (tabs) => {
        if (tabs[0]?.id) {
          chrome.tabs.sendMessage(tabs[0].id, {
            type: 'SETTINGS_UPDATED',
            settings: {
              selectedModeId,
              targetResolution: selectedResolution,
              performanceTier: currentTier,
            }
          }, (response) => {
            if (chrome.runtime.lastError) {
              console.warn('Message send error:', chrome.runtime.lastError.message);
            } else {
              console.log('Content script response:', response);
            }
          });
        }
      });

      // 状态消息显示后关闭弹窗
      setTimeout(() => {
        status.remove();
        window.close();
      }, 1500);

    } catch (error) {
      console.error('Error saving settings:', error);
      alert('Failed to save settings');
    }
  });

  // 白名单启用/禁用开关的更改事件
  whitelistToggle.addEventListener('change', async () => {
    try {
      await saveSettings({ whitelistEnabled: whitelistToggle.checked });
      console.log('Whitelist enabled:', whitelistToggle.checked);
    } catch (error) {
      console.error('Error saving whitelist toggle:', error);
    }
  });

  // "添加到白名单"按钮的事件处理
  addCurrentPageBtn.addEventListener('click', async () => {
    try {
      const tabs = await chrome.tabs.query({ active: true, currentWindow: true });
      if (tabs.length > 0 && tabs[0].url) {
        const url = new URL(tabs[0].url);
        const cleanUrl = url.hostname + url.pathname;
        await addWhitelistRule(cleanUrl);
        alert(chrome.i18n.getMessage('pageAdded') || 'URL added to whitelist');
      }
    } catch (error) {
      console.error('Error adding current URL:', error);
      alert('Failed to add URL to whitelist');
    }
  });

  addCurrentDomainBtn.addEventListener('click', async () => {
    try {
      const tabs = await chrome.tabs.query({ active: true, currentWindow: true });
      if (tabs.length > 0 && tabs[0].url) {
        const url = new URL(tabs[0].url);
        await addWhitelistRule(`${url.hostname}/*`);
        alert(chrome.i18n.getMessage('domainAdded') || 'Domain added to whitelist');
      }
    } catch (error) {
      console.error('Error adding current domain:', error);
      alert('Failed to add domain to whitelist');
    }
  });

  addParentPathBtn.addEventListener('click', async () => {
    try {
      const tabs = await chrome.tabs.query({ active: true, currentWindow: true });
      if (tabs.length > 0 && tabs[0].url) {
        const url = new URL(tabs[0].url);
        const pathParts = url.pathname.split('/').filter(p => p);
        const parentPath = pathParts.length > 1 ? pathParts.slice(0, -1).join('/') : '';
        await addWhitelistRule(`${url.hostname}/${parentPath}/*`);
        alert(chrome.i18n.getMessage('parentPathAdded') || 'Parent path added to whitelist');
      }
    } catch (error) {
      console.error('Error adding parent path:', error);
      alert('Failed to add parent path to whitelist');
    }
  });

  openSettingsBtn.addEventListener('click', () => {
    chrome.runtime.openOptionsPage();
  });
});