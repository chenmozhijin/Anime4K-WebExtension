import './options.css';
import '../common-vars.css';
import { getSettings, saveSettings } from '../../utils/settings';
import { WhitelistRule, validateRulePattern, removeWhitelistRule, updateWhitelistRule } from '../../utils/whitelist';

document.addEventListener('DOMContentLoaded', async () => {
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
  renderRules();
});