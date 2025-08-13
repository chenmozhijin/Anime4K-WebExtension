import './options.css';
import '../common-vars.css';
import { getSettings, saveSettings, synchronizeEffectsForAllModes } from '../../utils/settings';
import { WhitelistRule, validateRulePattern, removeWhitelistRule, updateWhitelistRule, addWhitelistRule } from '../../utils/whitelist';
import { AVAILABLE_EFFECTS } from '../../utils/effects-map';
import type { EnhancementMode, EnhancementEffect } from '../../types';

import { Anime4KWebExtSettings } from '../../types';

// --- 全局状态 ---
let settingsState: Anime4KWebExtSettings;

// --- UI 元素 ---
const modesContainer = document.getElementById('modes-container') as HTMLElement;
const addModeBtn = document.getElementById('add-mode-btn') as HTMLButtonElement;
const importModesBtn = document.getElementById('import-modes-btn') as HTMLButtonElement;
const exportModesBtn = document.getElementById('export-modes-btn') as HTMLButtonElement;
const rulesContainer = document.getElementById('rules-container') as HTMLElement;
const addRuleBtn = document.getElementById('add-rule') as HTMLButtonElement;
const importBtn = document.getElementById('import-btn') as HTMLButtonElement;
const exportBtn = document.getElementById('export-btn') as HTMLButtonElement;
const crossOriginFixToggle = document.getElementById('cross-origin-fix-toggle') as HTMLInputElement;
const versionNumberSpan = document.getElementById('version-number') as HTMLSpanElement;
const sidebar = document.querySelector('.sidebar') as HTMLElement;
const sidebarToggle = document.querySelector('.sidebar-toggle') as HTMLButtonElement;
const overlay = document.querySelector('.main-content-overlay') as HTMLElement;

// --- 拖放状态 ---
let draggedElement: HTMLElement | null = null;
let draggedModeId: string | null = null;
let draggedEffectIndex: number | null = null;

// --- 文件助手函数 ---
const downloadJSON = (data: unknown, filename: string) => {
  const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = filename;
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  URL.revokeObjectURL(url);
};

const openFile = (): Promise<string> => {
  return new Promise((resolve, reject) => {
    const input = document.createElement('input');
    input.type = 'file';
    input.accept = '.json,application/json';
    input.onchange = (e) => {
      const file = (e.target as HTMLInputElement).files?.[0];
      if (file) {
        const reader = new FileReader();
        reader.onload = (event) => {
          resolve(event.target?.result as string);
        };
        reader.onerror = (error) => {
          reject(error);
        };
        reader.readAsText(file);
      } else {
        reject(new Error('No file selected'));
      }
    };
    input.click();
  });
};

/**
 * 根据当前的 settingsState 渲染增强模式 UI。
 */
const renderModesUI = () => {
  // 1. 重新渲染前保留展开状态
  const expandedModeIds = new Set<string>();
  modesContainer.querySelectorAll('.mode-card:not(.collapsed)').forEach(card => {
    const modeId = (card as HTMLElement).dataset.modeId;
    if (modeId) expandedModeIds.add(modeId);
  });

  modesContainer.innerHTML = ''; // 清除现有卡片

  settingsState.enhancementModes.forEach(mode => {
    const card = document.createElement('div');
    card.className = 'mode-card collapsed';
    card.dataset.modeId = mode.id;
    card.draggable = true;

    // --- 模式排序的拖放功能 ---
    card.addEventListener('dragstart', (e) => {
      if (!card.classList.contains('collapsed')) {
        e.preventDefault();
        return;
      }
      draggedElement = card;
      draggedModeId = mode.id;
      e.dataTransfer!.effectAllowed = 'move';
      e.dataTransfer!.setData('text/plain', mode.id);
      setTimeout(() => card.classList.add('dragging'), 0);
    });

    card.addEventListener('dragend', () => {
      card.classList.remove('dragging');
      draggedElement = null;
      draggedModeId = null;
    });

    card.addEventListener('dragover', (e) => {
      e.preventDefault();
      const target = card;
      if (draggedElement && draggedElement !== target) {
        target.classList.add('drag-over');
      }
    });

    card.addEventListener('dragleave', () => card.classList.remove('drag-over'));

    card.addEventListener('drop', async (e) => {
      e.preventDefault();
      card.classList.remove('drag-over');
      if (!draggedModeId || draggedModeId === mode.id) return;

      const fromIndex = settingsState.enhancementModes.findIndex(m => m.id === draggedModeId);
      const toIndex = settingsState.enhancementModes.findIndex(m => m.id === mode.id);

      if (fromIndex > -1 && toIndex > -1) {
        const [movedMode] = settingsState.enhancementModes.splice(fromIndex, 1);
        settingsState.enhancementModes.splice(toIndex, 0, movedMode);
        
        renderModesUI(); // 从状态重新渲染
        await saveSettings({ enhancementModes: settingsState.enhancementModes }); // 持久化更改
        notifyUpdate();
      }
    });

    // --- 卡片头部 ---
    const cardHeader = document.createElement('div');
    cardHeader.className = 'mode-card-header';

    const toggleBtn = document.createElement('button');
    toggleBtn.className = 'btn-toggle-collapse';
    toggleBtn.innerHTML = `<svg xmlns="http://www.w3.org/2000/svg" class="menu-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"></polyline></svg>`;
    toggleBtn.title = chrome.i18n.getMessage('expandCollapse') || 'Expand/Collapse';
    toggleBtn.addEventListener('click', () => {
      card.classList.toggle('collapsed');
    });

    const modeName = document.createElement('h2');
    modeName.textContent = mode.name;
    modeName.contentEditable = String(!mode.isBuiltIn);
    modeName.title = mode.isBuiltIn ? (chrome.i18n.getMessage('builtInModeCannotRename') || 'Built-in modes cannot be renamed.') : (chrome.i18n.getMessage('clickToRename') || 'Click to rename');
    modeName.addEventListener('blur', async (e) => {
      if (mode.isBuiltIn) return;
      const newName = (e.target as HTMLElement).textContent?.trim() || '';
      const targetMode = settingsState.enhancementModes.find(m => m.id === mode.id);
      if (targetMode && newName && newName !== targetMode.name) {
        targetMode.name = newName;
        mode.name = newName; // 更新本地对象以保持一致性
        await saveSettings({ enhancementModes: settingsState.enhancementModes });
        notifyUpdate(mode.id);
      } else {
        (e.target as HTMLElement).textContent = mode.name;
      }
    });

    const deleteBtn = document.createElement('button');
    deleteBtn.textContent = chrome.i18n.getMessage('delete') || 'Delete';
    deleteBtn.className = 'btn btn-danger';
    deleteBtn.style.display = mode.isBuiltIn ? 'none' : 'block';
    deleteBtn.onclick = async () => {
      if (confirm(chrome.i18n.getMessage('deleteModeConfirm', [mode.name]))) {
        const deletedModeId = mode.id;
        settingsState.enhancementModes = settingsState.enhancementModes.filter(m => m.id !== deletedModeId);
        if (settingsState.selectedModeId === deletedModeId) {
          settingsState.selectedModeId = 'builtin-mode-a'; // 回退到默认模式
        }
        renderModesUI();
        await saveSettings({
          enhancementModes: settingsState.enhancementModes,
          selectedModeId: settingsState.selectedModeId
        });
        notifyUpdate(deletedModeId);
      }
    };

    cardHeader.appendChild(toggleBtn);
    cardHeader.appendChild(modeName);
    cardHeader.appendChild(deleteBtn);
    card.appendChild(cardHeader);

    // --- 摘要（折叠时显示）---
    const summary = document.createElement('div');
    summary.className = 'mode-summary';
    summary.textContent = mode.effects.map(e => e.name.split('/').pop()).join(' > ') || (chrome.i18n.getMessage('noEffects') || 'No effects');
    card.appendChild(summary);

    // --- 卡片内容（展开时显示）---
    const cardContent = document.createElement('div');
    cardContent.className = 'mode-card-content';
    const effectsList = document.createElement('ul');
    effectsList.className = 'effects-list';

    mode.effects.forEach((effect, index) => {
      const effectItem = document.createElement('li');
      effectItem.className = 'effect-item';
      const effectName = document.createElement('span');
      effectName.textContent = effect.name;
      effectItem.appendChild(effectName);

      if (!mode.isBuiltIn) {
        effectItem.draggable = true;

        // --- 效果排序的拖放功能 ---
        effectItem.addEventListener('dragstart', (e) => {
          e.stopPropagation();
          draggedElement = effectItem;
          draggedModeId = mode.id;
          draggedEffectIndex = index;
          e.dataTransfer!.effectAllowed = 'move';
          setTimeout(() => effectItem.classList.add('dragging'), 0);
        });

        effectItem.addEventListener('dragend', (e) => {
          e.stopPropagation();
          effectItem.classList.remove('dragging');
          draggedElement = null;
          draggedModeId = null;
          draggedEffectIndex = null;
        });

        effectItem.addEventListener('dragover', (e) => {
          e.preventDefault();
          e.stopPropagation();
          if (draggedModeId === mode.id) {
            effectItem.classList.add('drag-over');
          }
        });

        effectItem.addEventListener('dragleave', (e) => {
          e.stopPropagation();
          effectItem.classList.remove('drag-over');
        });

        effectItem.addEventListener('drop', async (e) => {
          e.preventDefault();
          e.stopPropagation();
          effectItem.classList.remove('drag-over');
          if (draggedModeId !== mode.id || draggedEffectIndex === null || draggedEffectIndex === index) return;

          const targetMode = settingsState.enhancementModes.find(m => m.id === mode.id);
          if (targetMode && !targetMode.isBuiltIn) {
            const [movedEffect] = targetMode.effects.splice(draggedEffectIndex, 1);
            targetMode.effects.splice(index, 0, movedEffect);
            renderModesUI();
            await saveSettings({ enhancementModes: settingsState.enhancementModes });
            notifyUpdate(mode.id);
          }
        });

        // --- 效果操作按钮 ---
        const effectActions = document.createElement('div');
        effectActions.className = 'effect-actions';

        const createMoveBtn = (dir: 'up' | 'down') => {
          const btn = document.createElement('button');
          btn.innerHTML = dir === 'up' ? '&#9650;' : '&#9660;';
          btn.className = 'btn-move-effect';
          btn.title = chrome.i18n.getMessage(dir === 'up' ? 'moveUp' : 'moveDown') || (dir === 'up' ? 'Move Up' : 'Move Down');
          btn.disabled = (dir === 'up' && index === 0) || (dir === 'down' && index === mode.effects.length - 1);
          btn.onclick = async () => {
            const targetMode = settingsState.enhancementModes.find(m => m.id === mode.id);
            if (targetMode && !targetMode.isBuiltIn) {
              const newIndex = dir === 'up' ? index - 1 : index + 1;
              const [movedEffect] = targetMode.effects.splice(index, 1);
              targetMode.effects.splice(newIndex, 0, movedEffect);
              renderModesUI();
              await saveSettings({ enhancementModes: settingsState.enhancementModes });
              notifyUpdate(mode.id);
            }
          };
          return btn;
        };

        const removeEffectBtn = document.createElement('button');
        removeEffectBtn.textContent = '×';
        removeEffectBtn.className = 'btn-remove-effect';
        removeEffectBtn.title = chrome.i18n.getMessage('removeEffect') || 'Remove effect';
        removeEffectBtn.onclick = async () => {
          const targetMode = settingsState.enhancementModes.find(m => m.id === mode.id);
          if (targetMode && !targetMode.isBuiltIn) {
            targetMode.effects.splice(index, 1);
            renderModesUI();
            await saveSettings({ enhancementModes: settingsState.enhancementModes });
            notifyUpdate(mode.id);
          }
        };

        effectActions.appendChild(createMoveBtn('up'));
        effectActions.appendChild(createMoveBtn('down'));
        effectActions.appendChild(removeEffectBtn);
        effectItem.appendChild(effectActions);
      }
      effectsList.appendChild(effectItem);
    });
    cardContent.appendChild(effectsList);

    // --- 添加效果下拉菜单（用于自定义模式）---
    if (!mode.isBuiltIn) {
      const addEffectContainer = document.createElement('div');
      addEffectContainer.className = 'add-effect-container';
      const effectSelect = document.createElement('select');
      const defaultOption = document.createElement('option');
      defaultOption.textContent = chrome.i18n.getMessage('addEffect') || 'Add effect...';
      defaultOption.disabled = true;
      defaultOption.selected = true;
      effectSelect.appendChild(defaultOption);

      AVAILABLE_EFFECTS.forEach(availEffect => {
        const option = document.createElement('option');
        option.value = availEffect.id;
        option.textContent = availEffect.name;
        effectSelect.appendChild(option);
      });

      effectSelect.onchange = async (e) => {
        const selectedEffectId = (e.target as HTMLSelectElement).value;
        const effectToAdd = AVAILABLE_EFFECTS.find(ef => ef.id === selectedEffectId);
        const targetMode = settingsState.enhancementModes.find(m => m.id === mode.id);

        if (targetMode && !targetMode.isBuiltIn && effectToAdd) {
          targetMode.effects.push(effectToAdd);
          renderModesUI();
          await saveSettings({ enhancementModes: settingsState.enhancementModes });
          notifyUpdate(mode.id);
        }
        (e.target as HTMLSelectElement).value = defaultOption.value; // 重置下拉菜单
      };
      addEffectContainer.appendChild(effectSelect);
      cardContent.appendChild(addEffectContainer);
    }
    
    card.appendChild(cardContent);

    // 2. 渲染后恢复展开状态
    if (expandedModeIds.has(mode.id)) {
      card.classList.remove('collapsed');
    }

    modesContainer.appendChild(card);
  });
};

/**
 * 根据当前的 settingsState 渲染白名单规则 UI。
 */
const renderRulesUI = () => {
  rulesContainer.innerHTML = ''; // 清除现有规则
  settingsState.whitelist.forEach((rule) => {
    const row = document.createElement('tr');
    
    const patternCell = document.createElement('td');
    const patternInput = document.createElement('input');
    patternInput.type = 'text';
    patternInput.value = rule.pattern;
    patternInput.className = 'pattern-input';
    patternInput.addEventListener('change', async (e) => {
      const newPattern = (e.target as HTMLInputElement).value;
      if (validateRulePattern(newPattern)) {
        await updateWhitelistRule(rule.pattern, newPattern);
        rule.pattern = newPattern; // 更新状态
      } else {
        alert(chrome.i18n.getMessage('invalidPattern') || 'Invalid pattern format');
        (e.target as HTMLInputElement).value = rule.pattern;
      }
    });
    patternCell.appendChild(patternInput);
    
    const enabledCell = document.createElement('td');
    const enabledCheckbox = document.createElement('input');
    enabledCheckbox.type = 'checkbox';
    enabledCheckbox.checked = rule.enabled;
    enabledCheckbox.addEventListener('change', async (e) => {
      const enabled = (e.target as HTMLInputElement).checked;
      await updateWhitelistRule(rule.pattern, enabled);
      rule.enabled = enabled; // 更新状态
    });
    enabledCell.appendChild(enabledCheckbox);
    
    const actionsCell = document.createElement('td');
    const deleteBtn = document.createElement('button');
    deleteBtn.textContent = chrome.i18n.getMessage('delete') || 'Delete';
    deleteBtn.className = 'action-btn';
    deleteBtn.addEventListener('click', async () => {
      await removeWhitelistRule(rule.pattern);
      settingsState.whitelist = settingsState.whitelist.filter(r => r.pattern !== rule.pattern);
      renderRulesUI();
    });
    actionsCell.appendChild(deleteBtn);
    
    row.appendChild(patternCell);
    row.appendChild(enabledCell);
    row.appendChild(actionsCell);
    rulesContainer.appendChild(row);
  });
};

const notifyUpdate = (modifiedModeId?: string) => {
  chrome.runtime.sendMessage({ type: 'SETTINGS_UPDATED', modifiedModeId });
};

const setupNavigation = () => {
  const menuItems = document.querySelectorAll('.menu-item');
  const sections = document.querySelectorAll('.content-section');
  menuItems.forEach(item => {
    item.addEventListener('click', (e) => {
      e.preventDefault();
      menuItems.forEach(i => i.classList.remove('active'));
      item.classList.add('active');
      const sectionName = item.getAttribute('data-section');
      sections.forEach(section => section.classList.remove('active'));
      const targetSection = document.getElementById(`${sectionName}-section`);
      if (targetSection) targetSection.classList.add('active');

      // 在小屏设备上，单击菜单项后关闭侧边栏
      if (window.innerWidth <= 900) {
        sidebar.classList.remove('open');
        overlay.classList.remove('active');
      }
    });
  });
};

const setupInternationalization = () => {
  document.querySelectorAll<HTMLElement>('[data-i18n]').forEach(element => {
    const key = element.getAttribute('data-i18n');
    if (key) {
      const message = chrome.i18n.getMessage(key);
      if (message) {
        if (element.tagName === 'TITLE') document.title = message;
        else element.textContent = message;
      }
    }
  });
};

const renderGeneralSettingsUI = () => {
  crossOriginFixToggle.checked = settingsState.enableCrossOriginFix;
};

const renderAboutSectionUI = () => {
  if (versionNumberSpan) {
    const manifest = chrome.runtime.getManifest();
    versionNumberSpan.textContent = manifest.version;
  }
}

const setupEventListeners = () => {
  // --- 常规设置监听器 ---
  crossOriginFixToggle.addEventListener('change', async (e) => {
    const enabled = (e.target as HTMLInputElement).checked;
    settingsState.enableCrossOriginFix = enabled;
    await saveSettings({ enableCrossOriginFix: enabled });
    notifyUpdate();
  });

  // --- 模式监听器 ---
  addModeBtn.addEventListener('click', async () => {
    const newMode: EnhancementMode = {
      id: `custom-${Date.now()}`,
      name: chrome.i18n.getMessage('newCustomModeName') || 'New Custom Mode',
      isBuiltIn: false,
      effects: [],
    };
    settingsState.enhancementModes.unshift(newMode);
    renderModesUI();
    await saveSettings({ enhancementModes: settingsState.enhancementModes });
  });

  // --- 白名单监听器 ---
  addRuleBtn.addEventListener('click', async () => {
   const newPattern = '*.example.com/*';
   // 从 UI 端防止重复添加
   if (settingsState.whitelist.some(r => r.pattern === newPattern)) {
     alert(chrome.i18n.getMessage('ruleAlreadyExists') || 'This rule already exists.');
     return;
   }
   await addWhitelistRule(newPattern, true);
   // 重新获取状态以反映更改
   settingsState.whitelist = (await getSettings()).whitelist;
   renderRulesUI();
  });

  // --- 模式导入/导出监听器 ---
  exportModesBtn.addEventListener('click', () => {
    const customModes = settingsState.enhancementModes.filter(mode => !mode.isBuiltIn);
    downloadJSON(customModes, 'anime4k-modes.json');
  });

  importModesBtn.addEventListener('click', async () => {
    try {
      const json = await openFile();
      const importedModes = JSON.parse(json) as EnhancementMode[];
      
      if (!Array.isArray(importedModes)) throw new Error('Invalid format: not an array');

      const newModes: EnhancementMode[] = [];
      for (const mode of importedModes) {
        if (typeof mode !== 'object' || typeof mode.name !== 'string' || !Array.isArray(mode.effects)) {
          console.warn('Skipping invalid mode object on import:', mode);
          continue;
        }
        
        const newMode: EnhancementMode = {
          ...mode,
          id: `custom-${Date.now()}-${Math.random().toString(36).substring(2, 9)}`,
          isBuiltIn: false,
        };
        newModes.push(newMode);
      }

      const allModes = [...settingsState.enhancementModes, ...newModes];
      settingsState.enhancementModes = synchronizeEffectsForAllModes(allModes);
      
      renderModesUI();
      await saveSettings({ enhancementModes: settingsState.enhancementModes });
      notifyUpdate();
      alert(chrome.i18n.getMessage('importSuccess') || 'Import successful');
    } catch (error) {
      if (error instanceof Error && error.message === 'No file selected') {
        console.log('File import cancelled.');
        return;
      }
      console.error('Import failed:', error);
      alert(chrome.i18n.getMessage('importError') || 'Import failed: invalid format or file error.');
    }
  });

  // --- 白名单导入/导出监听器 ---
  exportBtn.addEventListener('click', () => {
    downloadJSON(settingsState.whitelist, 'anime4k-whitelist.json');
  });

  importBtn.addEventListener('click', async () => {
    try {
      const json = await openFile();
      const rules = JSON.parse(json);
      if (!Array.isArray(rules)) throw new Error('Invalid format: not an array');
      
      const validRules: WhitelistRule[] = [];
      for (const rule of rules) {
        if (typeof rule === 'object' && rule.pattern && typeof rule.pattern === 'string' && typeof rule.enabled === 'boolean' && validateRulePattern(rule.pattern)) {
          validRules.push(rule as WhitelistRule);
        } else {
          console.warn('Skipping invalid whitelist rule on import:', rule);
        }
      }
      
      settingsState.whitelist = validRules;
      await saveSettings({ whitelist: settingsState.whitelist });
      renderRulesUI();
      alert(chrome.i18n.getMessage('importSuccess') || 'Import successful');
    } catch (error) {
      if (error instanceof Error && error.message === 'No file selected') {
        console.log('File import cancelled.');
        return;
      }
      console.error('Import failed:', error);
      alert(chrome.i18n.getMessage('importError') || 'Import failed: invalid format or file error.');
    }
  });

  // --- 消息监听器 ---
  chrome.runtime.onMessage.addListener((message) => {
    if (message.type === 'WHITELIST_UPDATED') {
      // 重新获取设置以从扩展的其他部分获取最新的白名单
      getSettings().then(newSettings => {
        settingsState = newSettings;
        renderRulesUI();
      });
    }
  });

  // --- 侧边栏切换监听器 ---
  sidebarToggle.addEventListener('click', () => {
    sidebar.classList.toggle('open');
    overlay.classList.toggle('active');
  });

  overlay.addEventListener('click', () => {
    sidebar.classList.remove('open');
    overlay.classList.remove('active');
  });
};

/**
 * 主初始化函数。
 */
document.addEventListener('DOMContentLoaded', async () => {
  setupInternationalization();
  setupNavigation();
  
  if (!modesContainer || !addModeBtn || !importModesBtn || !exportModesBtn || !rulesContainer || !addRuleBtn || !importBtn || !exportBtn) {
    console.error('Required UI elements not found. Aborting initialization.');
    return;
  }

  // 从存储加载初始状态
  settingsState = await getSettings();

  // 从状态进行初始 UI 渲染
  renderModesUI();
  renderRulesUI();
  renderGeneralSettingsUI();
  renderAboutSectionUI();

  // 附加所有事件监听器
  setupEventListeners();
});