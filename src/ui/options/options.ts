import './options.css';
import '../common-vars.css';
import { getSettings, saveSettings } from '../../utils/settings';
import { WhitelistRule, validateRulePattern, removeWhitelistRule, updateWhitelistRule } from '../../utils/whitelist';
import { AVAILABLE_EFFECTS } from '../../utils/effects-map';
import type { EnhancementMode, EnhancementEffect } from '../../types';

document.addEventListener('DOMContentLoaded', async () => {
  // 应用国际化
  document.querySelectorAll<HTMLElement>('[data-i18n]').forEach(element => {
    const key = element.getAttribute('data-i18n');
    if (key) {
      const message = chrome.i18n.getMessage(key);
      if (message) {
        if (element.tagName === 'TITLE') {
          document.title = message;
        } else {
          element.textContent = message;
        }
      }
    }
  });

  // --- 导航逻辑 ---
  const menuItems = document.querySelectorAll('.menu-item');
  const sections = document.querySelectorAll('.content-section');

  menuItems.forEach(item => {
    item.addEventListener('click', (e) => {
      e.preventDefault();
      
      // 移除所有菜单项的 active 类
      menuItems.forEach(i => i.classList.remove('active'));
      // 为当前点击的菜单项添加 active 类
      item.classList.add('active');

      const sectionName = item.getAttribute('data-section');

      // 隐藏所有内容区域
      sections.forEach(section => section.classList.remove('active'));
      // 显示目标内容区域
      const targetSection = document.getElementById(`${sectionName}-section`);
      if (targetSection) {
        targetSection.classList.add('active');
      }
    });
  });

  // --- 模式编辑器逻辑 ---
  const modesContainer = document.getElementById('modes-container') as HTMLElement;
  const addModeBtn = document.getElementById('add-mode-btn') as HTMLButtonElement;

  let draggedElement: HTMLElement | null = null;
  let draggedModeId: string | null = null;
  let draggedEffectIndex: number | null = null;

  const renderModes = async () => {
    const settings = await getSettings();
    modesContainer.innerHTML = '';

    settings.enhancementModes.forEach(mode => {
      const card = document.createElement('div');
      card.className = 'mode-card';
      card.dataset.modeId = mode.id;
      card.draggable = true;

      // --- 拖拽模式排序 ---
      card.addEventListener('dragstart', (e) => {
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

      card.addEventListener('dragleave', () => {
        card.classList.remove('drag-over');
      });

      card.addEventListener('drop', async (e) => {
        e.preventDefault();
        card.classList.remove('drag-over');
        if (!draggedModeId || draggedModeId === mode.id) return;

        const settings = await getSettings();
        const fromIndex = settings.enhancementModes.findIndex(m => m.id === draggedModeId);
        const toIndex = settings.enhancementModes.findIndex(m => m.id === mode.id);

        if (fromIndex > -1 && toIndex > -1) {
          const [movedMode] = settings.enhancementModes.splice(fromIndex, 1);
          settings.enhancementModes.splice(toIndex, 0, movedMode);
          await saveSettings(settings);
          renderModes();
          notifyUpdate();
        }
      });


      const cardHeader = document.createElement('div');
      cardHeader.className = 'mode-card-header';
      
      const modeName = document.createElement('h2');
      modeName.textContent = mode.name;
      modeName.contentEditable = String(!mode.isBuiltIn);
      modeName.addEventListener('blur', async (e) => {
        const newName = (e.target as HTMLElement).textContent || '';
        if (newName && newName !== mode.name) {
          mode.name = newName;
          await saveSettings(settings);
          notifyUpdate(mode.id);
        }
      });

      const deleteBtn = document.createElement('button');
      deleteBtn.textContent = chrome.i18n.getMessage('delete') || 'Delete';
      deleteBtn.className = 'btn btn-danger';
      deleteBtn.style.display = mode.isBuiltIn ? 'none' : 'block';
      deleteBtn.onclick = async () => {
        if (confirm(chrome.i18n.getMessage('deleteModeConfirm', [mode.name]))) {
          const deletedModeId = mode.id;
          settings.enhancementModes = settings.enhancementModes.filter(m => m.id !== deletedModeId);
          if (settings.selectedModeId === deletedModeId) {
            settings.selectedModeId = 'builtin-mode-a'; // Fallback to default
          }
          await saveSettings(settings);
          renderModes();
          notifyUpdate(deletedModeId);
        }
      };

      cardHeader.appendChild(modeName);
      cardHeader.appendChild(deleteBtn);
      card.appendChild(cardHeader);

      // --- 效果列表 ---
      const effectsList = document.createElement('ul');
      effectsList.className = 'effects-list';

      mode.effects.forEach((effect, index) => {
        const effectItem = document.createElement('li');
        effectItem.className = 'effect-item';
        effectItem.textContent = effect.name;
        
        if (!mode.isBuiltIn) {
          effectItem.draggable = true;

          // --- 拖拽效果排序 ---
          effectItem.addEventListener('dragstart', (e) => {
            e.stopPropagation(); // 防止触发卡片的拖拽
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

            if (draggedModeId !== mode.id || draggedEffectIndex === null || draggedEffectIndex === index) {
              return;
            }

            const settings = await getSettings();
            const targetMode = settings.enhancementModes.find(m => m.id === mode.id);
            if (targetMode) {
              const [movedEffect] = targetMode.effects.splice(draggedEffectIndex, 1);
              targetMode.effects.splice(index, 0, movedEffect);
              await saveSettings(settings);
              renderModes();
              notifyUpdate();
            }
          });

          const removeEffectBtn = document.createElement('button');
          removeEffectBtn.textContent = '×';
          removeEffectBtn.className = 'btn-remove-effect';
          removeEffectBtn.title = 'Remove effect';
          removeEffectBtn.onclick = async () => {
            mode.effects.splice(index, 1);
            await saveSettings(settings);
            renderModes();
            notifyUpdate(mode.id);
          };
          effectItem.appendChild(removeEffectBtn);
        }
        effectsList.appendChild(effectItem);
      });
      card.appendChild(effectsList);

      // --- 添加效果下拉菜单 (仅限自定义模式) ---
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
          if (effectToAdd) {
            mode.effects.push(effectToAdd);
            await saveSettings(settings);
            renderModes();
            notifyUpdate(mode.id);
          }
        };

        addEffectContainer.appendChild(effectSelect);
        card.appendChild(addEffectContainer);
      }

      modesContainer.appendChild(card);
    });
  };

  const notifyUpdate = (modifiedModeId?: string) => {
    chrome.runtime.sendMessage({ type: 'SETTINGS_UPDATED', modifiedModeId });
  };

  addModeBtn.addEventListener('click', async () => {
    const settings = await getSettings();
    const newMode: EnhancementMode = {
      id: `custom-${Date.now()}`,
      name: chrome.i18n.getMessage('newCustomModeName') || 'New Custom Mode',
      isBuiltIn: false,
      effects: [],
    };
    settings.enhancementModes.push(newMode);
    await saveSettings(settings);
    renderModes();
    // 新增模式不需要通知更新，因为它还没有被任何视频使用
  });


  // --- 白名单逻辑 ---
  
  // 监听白名单更新消息
  chrome.runtime.onMessage.addListener((message) => {
    if (message.type === 'WHITELIST_UPDATED') {
      renderRules();
    }
  });

  const rulesContainer = document.getElementById('rules-container') as HTMLElement;
  const addRuleBtn = document.getElementById('add-rule') as HTMLButtonElement;
  const importBtn = document.getElementById('import-btn') as HTMLButtonElement;
  const exportBtn = document.getElementById('export-btn') as HTMLButtonElement;
  const doImportBtn = document.getElementById('do-import') as HTMLButtonElement;
  const doExportBtn = document.getElementById('do-export') as HTMLButtonElement;
  const importExportData = document.getElementById('import-export-data') as HTMLTextAreaElement;

  if (!rulesContainer || !addRuleBtn || !importBtn || !exportBtn || !doImportBtn || !doExportBtn || !importExportData) {
    console.error('Required elements not found');
    return;
  }

  // 渲染白名单规则列表
  const renderRules = async () => {
    const settings = await getSettings();
    rulesContainer.innerHTML = '';

    settings.whitelist.forEach((rule) => {
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
          renderRules();
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
      });
      enabledCell.appendChild(enabledCheckbox);
      
      const actionsCell = document.createElement('td');
      const deleteBtn = document.createElement('button');
      deleteBtn.textContent = chrome.i18n.getMessage('delete') || 'Delete';
      deleteBtn.className = 'action-btn';
      deleteBtn.addEventListener('click', async () => {
        await removeWhitelistRule(rule.pattern);
        renderRules();
      });
      actionsCell.appendChild(deleteBtn);
      
      row.appendChild(patternCell);
      row.appendChild(enabledCell);
      row.appendChild(actionsCell);
      rulesContainer.appendChild(row);
    });
  };

  // 添加新规则
  addRuleBtn.addEventListener('click', async () => {
    const settings = await getSettings();
    const newRule: WhitelistRule = { pattern: '*.example.com/*', enabled: true };
    settings.whitelist.push(newRule);
    await saveSettings(settings);
    renderRules();
  });

  // 导出白名单
  exportBtn.addEventListener('click', async () => {
    const settings = await getSettings();
    importExportData.value = JSON.stringify(settings.whitelist, null, 2);
  });

  // 导入白名单
  importBtn.addEventListener('click', () => {
    importExportData.value = '';
    importExportData.focus();
  });

  // 执行导入
  doImportBtn.addEventListener('click', async () => {
    try {
      const rules = JSON.parse(importExportData.value);
      if (!Array.isArray(rules)) throw new Error('Invalid format');
      
      // 验证每个规则
      for (const rule of rules) {
        if (typeof rule !== 'object' || 
            typeof rule.pattern !== 'string' || 
            typeof rule.enabled !== 'boolean') {
          throw new Error('Invalid rule format');
        }
      }
      
      const settings = await getSettings();
      settings.whitelist = rules;
      await saveSettings(settings);
      renderRules();
      alert(chrome.i18n.getMessage('importSuccess') || 'Import successful');
    } catch (error) {
      console.error('Import failed:', error);
      alert(chrome.i18n.getMessage('importError') || 'Import failed: invalid format');
    }
  });

  // 执行导出
  doExportBtn.addEventListener('click', async () => {
    const settings = await getSettings();
    importExportData.value = JSON.stringify(settings.whitelist, null, 2);
  });

  // 初始化渲染
  renderModes();
  renderRules();
});