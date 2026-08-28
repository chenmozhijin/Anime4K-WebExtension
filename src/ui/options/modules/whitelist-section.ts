import type { WhitelistRule } from '../../../types';
import { saveSettings } from '../../../utils/settings';
import {
  addWhitelistRule,
  removeWhitelistRule,
  updateWhitelistRule,
  validateRulePattern,
} from '../../../utils/whitelist';
import { showNotice } from '../../shared/notice';
import { createLogger } from '../../../utils/logger';
import { downloadJSON, openFile } from './helpers';
import { runSaveAction } from '../../shared/save-action';

const logger = createLogger('options:whitelist');

type WhitelistSectionDeps = {
  getWhitelistRules(): WhitelistRule[];
  setWhitelistRules(rules: WhitelistRule[]): void;
  refreshAll(): Promise<void>;
};

export interface WhitelistSectionController {
  bindEvents(): void;
  render(): void;
}

export function createWhitelistSection(deps: WhitelistSectionDeps): WhitelistSectionController {
  const rulesContainer = document.getElementById('rules-container') as HTMLElement | null;
  const addRuleBtn = document.getElementById('add-rule') as HTMLButtonElement | null;
  const importBtn = document.getElementById('import-btn') as HTMLButtonElement | null;
  const exportBtn = document.getElementById('export-btn') as HTMLButtonElement | null;

  if (!rulesContainer || !addRuleBtn || !importBtn || !exportBtn) {
    throw new Error('Whitelist section elements not found');
  }

  const requiredRulesContainer = rulesContainer;
  const requiredAddRuleBtn = addRuleBtn;
  const requiredImportBtn = importBtn;
  const requiredExportBtn = exportBtn;

  function render(): void {
    requiredRulesContainer.textContent = '';
    deps.getWhitelistRules().forEach(rule => {
      const row = document.createElement('tr');

      const patternCell = document.createElement('td');
      const patternInput = document.createElement('input');
      patternInput.type = 'text';
      patternInput.value = rule.pattern;
      patternInput.className = 'pattern-input';
      patternInput.addEventListener('change', async event => {
        const input = event.target as HTMLInputElement;
        const newPattern = input.value;
        if (!validateRulePattern(newPattern)) {
          showNotice({ kind: 'error', message: chrome.i18n.getMessage('invalidPattern') });
          input.value = rule.pattern;
          return;
        }

        await runSaveAction({
          action: async () => {
            await updateWhitelistRule(rule.pattern, newPattern);
            rule.pattern = newPattern;
          },
          logger,
          logMessage: 'Failed to update whitelist rule pattern.',
          onError: () => {
            input.value = rule.pattern;
          },
        });
      });
      patternCell.appendChild(patternInput);

      const enabledCell = document.createElement('td');
      enabledCell.className = 'cell-center';
      const switchLabel = document.createElement('label');
      switchLabel.className = 'switch';
      const enabledCheckbox = document.createElement('input');
      enabledCheckbox.type = 'checkbox';
      enabledCheckbox.checked = rule.enabled;
      enabledCheckbox.addEventListener('change', async event => {
        const checkbox = event.target as HTMLInputElement;
        const enabled = checkbox.checked;
        await runSaveAction({
          action: async () => {
            await updateWhitelistRule(rule.pattern, enabled);
            rule.enabled = enabled;
          },
          logger,
          logMessage: 'Failed to update whitelist rule enabled state.',
          onError: () => {
            checkbox.checked = rule.enabled;
          },
        });
      });
      const sliderSpan = document.createElement('span');
      sliderSpan.className = 'slider round';
      switchLabel.append(enabledCheckbox, sliderSpan);
      enabledCell.appendChild(switchLabel);

      const actionsCell = document.createElement('td');
      const deleteBtn = document.createElement('button');
      deleteBtn.textContent = chrome.i18n.getMessage('delete');
      deleteBtn.className = 'action-btn';
      deleteBtn.addEventListener('click', async () => {
        await runSaveAction({
          action: async () => {
            await removeWhitelistRule(rule.pattern);
            deps.setWhitelistRules(deps.getWhitelistRules().filter(item => item.pattern !== rule.pattern));
            render();
          },
          controls: [deleteBtn],
          logger,
          logMessage: 'Failed to remove whitelist rule.',
        });
      });
      actionsCell.appendChild(deleteBtn);

      row.append(patternCell, enabledCell, actionsCell);
      requiredRulesContainer.appendChild(row);
    });
  }

  function bindEvents(): void {
    requiredAddRuleBtn.addEventListener('click', async () => {
      const newPattern = '*.example.com/*';
      if (deps.getWhitelistRules().some(rule => rule.pattern === newPattern)) {
        showNotice({ kind: 'warning', message: chrome.i18n.getMessage('ruleAlreadyExists') });
        return;
      }

      await runSaveAction({
        action: async () => {
          await addWhitelistRule(newPattern, true);
          await deps.refreshAll();
        },
        controls: [requiredAddRuleBtn],
        logger,
        logMessage: 'Failed to add whitelist rule.',
      });
    });

    requiredExportBtn.addEventListener('click', () => {
      downloadJSON(deps.getWhitelistRules(), 'nijilucid-whitelist.json');
    });

    requiredImportBtn.addEventListener('click', async () => {
      try {
        const json = await openFile();
        const rules = JSON.parse(json);
        if (!Array.isArray(rules)) {
          throw new Error('Invalid format: not an array');
        }

        const validRules: WhitelistRule[] = [];
        for (const rule of rules) {
          if (
            typeof rule === 'object'
            && typeof (rule as Partial<WhitelistRule>).pattern === 'string'
            && typeof (rule as Partial<WhitelistRule>).enabled === 'boolean'
            && validateRulePattern((rule as WhitelistRule).pattern)
          ) {
            validRules.push(rule as WhitelistRule);
          } else {
            logger.warn('Skipping invalid whitelist rule on import.', rule);
          }
        }

        await saveSettings({ whitelist: validRules });
        deps.setWhitelistRules(validRules);
        render();
        showNotice({ kind: 'success', message: chrome.i18n.getMessage('importSuccess') });
      } catch (error) {
        if (error instanceof Error && error.message === 'No file selected') {
          logger.debug('Whitelist import cancelled.');
          return;
        }

        logger.error('Whitelist import failed:', error);
        showNotice({ kind: 'error', message: chrome.i18n.getMessage('importError') });
      }
    });
  }

  return {
    bindEvents,
    render,
  };
}
