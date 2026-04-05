import './options.css';
import '../common-vars.css';
import { BUILTIN_MODES, getSettings, saveSettings, synchronizeEffectsForCustomModes, getEffectsForMode, getLocalSettings, saveLocalSettings } from '../../utils/settings';
import { WhitelistRule, validateRulePattern, removeWhitelistRule, updateWhitelistRule, addWhitelistRule } from '../../utils/whitelist';
import { AVAILABLE_EFFECTS } from '../../utils/effects-map';
import type { Anime4KWebExtSettings, EnhancementMode, EnhancementEffect, CustomMode, PerformanceTier, EffectDescriptor } from '../../types';
import { themeManager } from '../theme-manager';
import { Sidebar } from './Sidebar';
import { createEffectReference } from '../../core/effects/reference';
import { getEffectDescriptor, validateEffectChain } from '../../core/effects/registry';
import { showNotice } from '../shared/notice';
import { createLogger } from '../../utils/logger';

// --- 全局状态 ---
let settingsState: Anime4KWebExtSettings;
let currentTier: PerformanceTier = 'balanced'; // 当前性能档位
const logger = createLogger('options');

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
const themeSelect = document.getElementById('theme-select') as HTMLSelectElement;
const versionNumberSpan = document.getElementById('version-number') as HTMLSpanElement;

// --- 智能功能 UI 元素 ---
const runBenchmarkBtn = document.getElementById('run-benchmark-btn') as HTMLButtonElement;
const gpuTierDisplay = document.getElementById('gpu-tier-display') as HTMLSpanElement;

// --- 拖放状态 ---
let draggedElement: HTMLElement | null = null;
let draggedModeId: string | null = null;
let draggedEffectIndex: number | null = null;
let activePromptNotice: HTMLElement | null = null;

const replacePromptNotice = (notice: HTMLElement): HTMLElement => {
  activePromptNotice?.remove();
  activePromptNotice = notice;
  return notice;
};

const getEffectLabel = (effect: EnhancementEffect): string => {
  const descriptor = getEffectDescriptor(effect);
  if (!descriptor) {
    return effect.id;
  }

  return descriptor.backendId === 'anime4k'
    ? descriptor.name
    : `${descriptor.backendId}: ${descriptor.name}`;
};

const validateCustomMode = (mode: CustomMode): string | null => {
  const validation = validateEffectChain(mode.effects);
  return validation.valid ? null : validation.errors[0] ?? 'Invalid effect chain';
};

const getTierDisplayName = (tier: PerformanceTier): string => {
  const tierKey = `tier${tier.charAt(0).toUpperCase()}${tier.slice(1)}` as const;
  return chrome.i18n.getMessage(tierKey);
};

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

const rebuildEnhancementModes = () => {
  settingsState.customModes = synchronizeEffectsForCustomModes(settingsState.customModes);
  settingsState.enhancementModes = [...BUILTIN_MODES, ...settingsState.customModes];
};

const saveCustomModesState = async (modifiedModeId?: string, persistSelectedModeId = false) => {
  rebuildEnhancementModes();
  renderModesUI();

  if (modifiedModeId) {
    const modifiedMode = settingsState.customModes.find(mode => mode.id === modifiedModeId);
    if (modifiedMode) {
      const validationError = validateCustomMode(modifiedMode);
      if (validationError) {
        throw new Error(validationError);
      }
    }
  }

  const settingsToPersist: Partial<Anime4KWebExtSettings> = {
    customModes: settingsState.customModes,
  };

  if (persistSelectedModeId) {
    settingsToPersist.selectedModeId = settingsState.selectedModeId;
  }

  await saveSettings(settingsToPersist);
  notifyUpdate(modifiedModeId);
};

const isInteractiveModeElement = (target: EventTarget | null): boolean => {
  return target instanceof HTMLElement
    && target.closest('button, input, select, textarea, label, a, [contenteditable="true"]') !== null;
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

  modesContainer.textContent = ''; // 清除现有卡片

  settingsState.enhancementModes.forEach(mode => {
    const isCustomMode = !mode.isBuiltIn;
    const card = document.createElement('div');
    card.className = 'mode-card collapsed';
    card.classList.toggle('sortable-mode-card', isCustomMode);
    card.dataset.modeId = mode.id;

    const updateCardDraggableState = () => {
      card.draggable = isCustomMode && card.classList.contains('collapsed');
    };

    // --- 模式排序的拖放功能 ---
    card.addEventListener('dragstart', (e) => {
      if (!card.draggable || isInteractiveModeElement(e.target)) {
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
      const isModeCardDrag = draggedElement?.classList.contains('mode-card') ?? false;
      if (!isCustomMode || !isModeCardDrag || draggedElement === card) return;

      e.preventDefault();
      const target = card;
      target.classList.add('drag-over');
    });

    card.addEventListener('dragleave', () => card.classList.remove('drag-over'));

    card.addEventListener('drop', async (e) => {
      const isModeCardDrag = draggedElement?.classList.contains('mode-card') ?? false;
      if (!isCustomMode || !isModeCardDrag) return;

      e.preventDefault();
      card.classList.remove('drag-over');
      if (!draggedModeId || draggedModeId === mode.id) return;

      const fromIndex = settingsState.customModes.findIndex(m => m.id === draggedModeId);
      const toIndex = settingsState.customModes.findIndex(m => m.id === mode.id);

      if (fromIndex > -1 && toIndex > -1) {
        const [movedMode] = settingsState.customModes.splice(fromIndex, 1);
        settingsState.customModes.splice(toIndex, 0, movedMode);
        await saveCustomModesState(movedMode.id);
      }
    });

    // --- 卡片头部 ---
    const cardHeader = document.createElement('div');
    cardHeader.className = 'mode-card-header';

    const toggleBtn = document.createElement('button');
    toggleBtn.className = 'btn-toggle-collapse';

    // Create SVG icon safely
    const svgNS = "http://www.w3.org/2000/svg";
    const svg = document.createElementNS(svgNS, "svg");
    svg.setAttribute("class", "menu-icon");
    svg.setAttribute("width", "20");
    svg.setAttribute("height", "20");
    svg.setAttribute("viewBox", "0 0 24 24");
    svg.setAttribute("fill", "none");
    svg.setAttribute("stroke", "currentColor");
    svg.setAttribute("stroke-width", "2");
    svg.setAttribute("stroke-linecap", "round");
    svg.setAttribute("stroke-linejoin", "round");

    const polyline = document.createElementNS(svgNS, "polyline");
    polyline.setAttribute("points", "9 18 15 12 9 6");
    svg.appendChild(polyline);

    toggleBtn.appendChild(svg);
    toggleBtn.title = chrome.i18n.getMessage('expandCollapse');
    toggleBtn.addEventListener('click', () => {
      card.classList.toggle('collapsed');
      updateCardDraggableState();
    });

    const modeName = document.createElement('h2');
    modeName.textContent = mode.name;
    modeName.contentEditable = String(!mode.isBuiltIn);
    modeName.draggable = false;
    modeName.title = mode.isBuiltIn
      ? chrome.i18n.getMessage('builtInModeCannotRename')
      : chrome.i18n.getMessage('clickToRename');
    modeName.addEventListener('dragstart', (e) => e.preventDefault());
    modeName.addEventListener('blur', async (e) => {
      if (mode.isBuiltIn) return;
      const newName = (e.target as HTMLElement).textContent?.trim() || '';
      const targetMode = settingsState.customModes.find(m => m.id === mode.id);
      if (targetMode && newName && newName !== targetMode.name) {
        targetMode.name = newName;
        await saveCustomModesState(mode.id);
      } else {
        (e.target as HTMLElement).textContent = mode.name;
      }
    });

    const deleteBtn = document.createElement('button');
    deleteBtn.textContent = chrome.i18n.getMessage('delete');
    deleteBtn.className = 'btn btn-danger';
    deleteBtn.style.display = mode.isBuiltIn ? 'none' : 'block';
    deleteBtn.onclick = async () => {
      replacePromptNotice(showNotice({
        kind: 'warning',
        message: chrome.i18n.getMessage('deleteModeConfirm', [mode.name]),
        timeoutMs: 0,
        actions: [
          {
            label: chrome.i18n.getMessage('delete'),
            emphasis: 'danger',
            onClick: async () => {
              const deletedModeId = mode.id;
              settingsState.customModes = settingsState.customModes.filter(m => m.id !== deletedModeId);
              const shouldPersistSelectedModeId = settingsState.selectedModeId === deletedModeId;
              if (settingsState.selectedModeId === deletedModeId) {
                settingsState.selectedModeId = 'builtin-mode-a';
              }
              await saveCustomModesState(deletedModeId, shouldPersistSelectedModeId);
            },
          },
        ],
      }));
    };

    cardHeader.appendChild(toggleBtn);
    cardHeader.appendChild(modeName);
    cardHeader.appendChild(deleteBtn);
    card.appendChild(cardHeader);

    // --- 摘要（折叠时显示）---
    const summary = document.createElement('div');
    summary.className = 'mode-summary';
    // 根据模式类型获取效果链
    const modeEffects = getEffectsForMode(mode, currentTier);
    summary.textContent = modeEffects.length > 0
      ? modeEffects.map((effect: EnhancementEffect) => getEffectLabel(effect)).join(' > ')
      : chrome.i18n.getMessage('noEffects');
    card.appendChild(summary);

    // --- 卡片内容（展开时显示）---
    const cardContent = document.createElement('div');
    cardContent.className = 'mode-card-content';
    const effectsList = document.createElement('ul');
    effectsList.className = 'effects-list';

    modeEffects.forEach((effect: EnhancementEffect, index: number) => {
      const effectItem = document.createElement('li');
      effectItem.className = 'effect-item';
      const effectName = document.createElement('span');
      effectName.textContent = getEffectLabel(effect);
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

          const targetMode = settingsState.customModes.find(m => m.id === mode.id);
          if (targetMode) {
            const [movedEffect] = targetMode.effects.splice(draggedEffectIndex, 1);
            targetMode.effects.splice(index, 0, movedEffect);
            await saveCustomModesState(mode.id);
          }
        });

        // --- 效果操作按钮 ---
        const effectActions = document.createElement('div');
        effectActions.className = 'effect-actions';

        const createMoveBtn = (dir: 'up' | 'down') => {
          const btn = document.createElement('button');

          // Create SVG arrow icon safely
          const svgNS = "http://www.w3.org/2000/svg";
          const arrowSvg = document.createElementNS(svgNS, "svg");
          arrowSvg.setAttribute("width", "12");
          arrowSvg.setAttribute("height", "12");
          arrowSvg.setAttribute("viewBox", "0 0 24 24");
          arrowSvg.setAttribute("fill", "currentColor");

          const arrowPath = document.createElementNS(svgNS, "path");
          // Use path data for up/down triangles
          if (dir === 'up') {
            arrowPath.setAttribute("d", "M12 4l-8 8h16z"); // Up triangle
          } else {
            arrowPath.setAttribute("d", "M12 20l-8-8h16z"); // Down triangle
          }
          arrowSvg.appendChild(arrowPath);

          btn.appendChild(arrowSvg);
          btn.className = 'btn-move-effect';
          btn.title = chrome.i18n.getMessage(dir === 'up' ? 'moveUp' : 'moveDown');
          btn.disabled = (dir === 'up' && index === 0) || (dir === 'down' && index === mode.effects.length - 1);
          btn.onclick = async () => {
            const targetMode = settingsState.customModes.find(m => m.id === mode.id);
            if (targetMode) {
              const newIndex = dir === 'up' ? index - 1 : index + 1;
              const [movedEffect] = targetMode.effects.splice(index, 1);
              targetMode.effects.splice(newIndex, 0, movedEffect);
              await saveCustomModesState(mode.id);
            }
          };
          return btn;
        };

        const removeEffectBtn = document.createElement('button');
        removeEffectBtn.textContent = '×';
        removeEffectBtn.className = 'btn-remove-effect';
        removeEffectBtn.title = chrome.i18n.getMessage('removeEffect');
        removeEffectBtn.onclick = async () => {
          const targetMode = settingsState.customModes.find(m => m.id === mode.id);
          if (targetMode) {
            targetMode.effects.splice(index, 1);
            await saveCustomModesState(mode.id);
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
      defaultOption.textContent = chrome.i18n.getMessage('addEffect');
      defaultOption.disabled = true;
      defaultOption.selected = true;
      effectSelect.appendChild(defaultOption);

      AVAILABLE_EFFECTS.forEach(availEffect => {
        const option = document.createElement('option');
        option.value = availEffect.id;
        option.textContent = availEffect.backendId === 'anime4k'
          ? availEffect.name
          : `${availEffect.backendId}: ${availEffect.name}`;
        effectSelect.appendChild(option);
      });

      effectSelect.onchange = async (e) => {
        const selectedEffectId = (e.target as HTMLSelectElement).value;
        const effectToAdd = AVAILABLE_EFFECTS.find((ef: EffectDescriptor) => ef.id === selectedEffectId);
        const targetMode = settingsState.customModes.find(m => m.id === mode.id);

        if (targetMode && effectToAdd) {
          targetMode.effects.push(createEffectReference(effectToAdd));
          const validationError = validateCustomMode(targetMode);
          if (validationError) {
            targetMode.effects.pop();
            showNotice({
              kind: 'error',
              message: validationError,
            });
            (e.target as HTMLSelectElement).value = defaultOption.value;
            return;
          }
          await saveCustomModesState(mode.id);
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

    updateCardDraggableState();

    modesContainer.appendChild(card);
  });
};

/**
 * 根据当前的 settingsState 渲染白名单规则 UI。
 */
const renderRulesUI = () => {
  rulesContainer.textContent = ''; // 清除现有规则
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
        showNotice({
          kind: 'error',
          message: chrome.i18n.getMessage('invalidPattern'),
        });
        (e.target as HTMLInputElement).value = rule.pattern;
      }
    });
    patternCell.appendChild(patternInput);

    const enabledCell = document.createElement('td');
    enabledCell.className = 'cell-center';
    const switchLabel = document.createElement('label');
    switchLabel.className = 'switch';
    const enabledCheckbox = document.createElement('input');
    enabledCheckbox.type = 'checkbox';
    enabledCheckbox.checked = rule.enabled;
    enabledCheckbox.addEventListener('change', async (e) => {
      const enabled = (e.target as HTMLInputElement).checked;
      await updateWhitelistRule(rule.pattern, enabled);
      rule.enabled = enabled; // 更新状态
    });
    const sliderSpan = document.createElement('span');
    sliderSpan.className = 'slider round';
    switchLabel.appendChild(enabledCheckbox);
    switchLabel.appendChild(sliderSpan);
    enabledCell.appendChild(switchLabel);

    const actionsCell = document.createElement('td');
    const deleteBtn = document.createElement('button');
    deleteBtn.textContent = chrome.i18n.getMessage('delete');
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

const renderGeneralSettingsUI = async () => {
  crossOriginFixToggle.checked = settingsState.enableCrossOriginFix;
  themeSelect.value = themeManager.getTheme();


  // 智能功能 UI
  const localSettings = await getLocalSettings();

  // 档位显示
  const tierIcons: Record<PerformanceTier, string> = {
    performance: `🚀 ${chrome.i18n.getMessage('tierPerformance')}`,
    balanced: `⚖️ ${chrome.i18n.getMessage('tierBalanced')}`,
    quality: `🎨 ${chrome.i18n.getMessage('tierQuality')}`,
    ultra: `🔬 ${chrome.i18n.getMessage('tierUltra')}`,
  };
  if (gpuTierDisplay) {
    gpuTierDisplay.textContent = tierIcons[localSettings.performanceTier];
  }
};

const renderAboutSectionUI = () => {
  if (versionNumberSpan) {
    const manifest = chrome.runtime.getManifest();
    versionNumberSpan.textContent = manifest.version;
  }
}

const refreshUiFromStorage = async () => {
  settingsState = await getSettings();
  const localSettings = await getLocalSettings();
  if (localSettings.benchmarkRunState.status === 'interrupted') {
    showNotice({
      kind: 'warning',
      message: chrome.i18n.getMessage('benchmarkFallbackApplied', [getTierDisplayName('performance')]),
      timeoutMs: 5000,
    });
  }
  currentTier = localSettings.performanceTier;
  renderModesUI();
  renderRulesUI();
  await renderGeneralSettingsUI();
};

const setupEventListeners = () => {
  // --- 常规设置监听器 ---
  crossOriginFixToggle.addEventListener('change', async (e) => {
    const enabled = (e.target as HTMLInputElement).checked;
    settingsState.enableCrossOriginFix = enabled;
    await saveSettings({ enableCrossOriginFix: enabled });
    notifyUpdate();
  });

  // --- 主题切换监听器 ---
  themeSelect.addEventListener('change', (e) => {
    const selectedTheme = (e.target as HTMLSelectElement).value as 'light' | 'dark' | 'auto';
    themeManager.setTheme(selectedTheme);
  });

  // --- 智能功能监听器 ---
  if (runBenchmarkBtn) {
    runBenchmarkBtn.addEventListener('click', async () => {
      runBenchmarkBtn.disabled = true;
      runBenchmarkBtn.textContent = chrome.i18n.getMessage('testing');

      // 显示进度条
      const progressContainer = document.getElementById('benchmark-progress');
      const progressFill = document.getElementById('benchmark-progress-fill');
      const progressText = document.getElementById('benchmark-progress-text');
      if (progressContainer) progressContainer.style.display = 'block';

      try {
        const { runGPUBenchmark } = await import('../../core/gpu-benchmark');
        const result = await runGPUBenchmark((progress) => {
          // 更新进度条
          if (progressFill) progressFill.style.width = `${progress.progress * 100}%`;
          if (progressText) {
            if (progress.completed) {
              progressText.textContent = chrome.i18n.getMessage('testComplete');
            } else {
              // 将 tier 键名转换为国际化文本
              const tierKey = `tier${progress.tier.charAt(0).toUpperCase()}${progress.tier.slice(1)}` as const;
              const tierName = chrome.i18n.getMessage(tierKey);
              progressText.textContent = chrome.i18n.getMessage('testingTier', [tierName]);
            }
          }
        });

        // 询问用户是否应用推荐档位
        const tierNames: Record<PerformanceTier, string> = {
          performance: `🚀 ${chrome.i18n.getMessage('tierPerformance')}`,
          balanced: `⚖️ ${chrome.i18n.getMessage('tierBalanced')}`,
          quality: `🎨 ${chrome.i18n.getMessage('tierQuality')}`,
          ultra: `🔬 ${chrome.i18n.getMessage('tierUltra')}`,
        };
        const previousTier = currentTier;
        replacePromptNotice(showNotice({
          kind: 'success',
          message: chrome.i18n.getMessage('benchmarkApplyRecommendation', [tierNames[result.tier]]),
          timeoutMs: 0,
          actions: [
            {
              label: chrome.i18n.getMessage('benchmarkApplyNow'),
              emphasis: 'primary',
              onClick: async () => {
                await saveLocalSettings({
                  performanceTier: result.tier,
                  gpuBenchmarkResult: result,
                });
                currentTier = result.tier;
                await renderGeneralSettingsUI();
                renderModesUI();
                notifyUpdate();
                showNotice({
                  kind: 'success',
                  message: chrome.i18n.getMessage('benchmarkRecommendationApplied', [tierNames[result.tier]]),
                });
              },
            },
            {
              label: chrome.i18n.getMessage('benchmarkKeepCurrent'),
              onClick: () => {
                showNotice({
                  kind: 'info',
                  message: chrome.i18n.getMessage(
                    'benchmarkRecommendationSkipped',
                    [getTierDisplayName(previousTier)],
                  ),
                });
              },
            },
          ],
        }));
      } catch (error) {
        logger.error('Benchmark failed:', error);
        const errorMsg = error instanceof Error ? error.message : String(error);
        showNotice({
          kind: 'error',
          message: `${chrome.i18n.getMessage('testFailed')}: ${errorMsg}`,
          timeoutMs: 7000,
        });
      }

      // 隐藏进度条
      if (progressContainer) progressContainer.style.display = 'none';
      runBenchmarkBtn.disabled = false;
      runBenchmarkBtn.textContent = chrome.i18n.getMessage('runTest');
    });
  }

  // --- 模式监听器 ---
  addModeBtn.addEventListener('click', async () => {
    const newMode: CustomMode = {
      id: `custom-${Date.now()}`,
      name: chrome.i18n.getMessage('newCustomModeName'),
      isBuiltIn: false,
      effects: [],
    };
    settingsState.customModes.unshift(newMode);
    await saveCustomModesState(newMode.id);
  });

  // --- 白名单监听器 ---
  addRuleBtn.addEventListener('click', async () => {
    const newPattern = '*.example.com/*';
    // 从 UI 端防止重复添加
    if (settingsState.whitelist.some(r => r.pattern === newPattern)) {
      showNotice({ kind: 'warning', message: chrome.i18n.getMessage('ruleAlreadyExists') });
      return;
    }
    await addWhitelistRule(newPattern, true);
    // 重新获取状态以反映更改
    settingsState.whitelist = (await getSettings()).whitelist;
    renderRulesUI();
  });

  // --- 模式导入/导出监听器 ---
  exportModesBtn.addEventListener('click', () => {
    downloadJSON(settingsState.customModes, 'anime4k-modes.json');
  });

  importModesBtn.addEventListener('click', async () => {
    try {
      const json = await openFile();
      const importedModes = JSON.parse(json) as EnhancementMode[];

      if (!Array.isArray(importedModes)) throw new Error('Invalid format: not an array');

      const newModes: CustomMode[] = [];
      for (const mode of importedModes) {
        if (typeof mode !== 'object' || typeof mode.name !== 'string' || !Array.isArray((mode as any).effects)) {
          logger.warn('Skipping invalid mode object on import.', mode);
          continue;
        }

        const newMode: CustomMode = {
          id: `custom-${Date.now()}-${Math.random().toString(36).substring(2, 9)}`,
          name: mode.name,
          isBuiltIn: false,
          effects: (mode as any).effects,
        };
        newModes.push(newMode);
      }

      // 同步自定义模式的效果
      const syncedNewModes = synchronizeEffectsForCustomModes(newModes);
      for (const mode of syncedNewModes) {
        const validationError = validateCustomMode(mode);
        if (validationError) {
          throw new Error(validationError);
        }
      }
      settingsState.customModes = [...settingsState.customModes, ...syncedNewModes];

      await saveCustomModesState();
      showNotice({ kind: 'success', message: chrome.i18n.getMessage('importSuccess') });
    } catch (error) {
      if (error instanceof Error && error.message === 'No file selected') {
        logger.debug('Mode import cancelled.');
        return;
      }
      logger.error('Mode import failed:', error);
      showNotice({ kind: 'error', message: chrome.i18n.getMessage('importError') });
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
          logger.warn('Skipping invalid whitelist rule on import.', rule);
        }
      }

      settingsState.whitelist = validRules;
      await saveSettings({ whitelist: settingsState.whitelist });
      renderRulesUI();
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

  // --- 消息监听器 ---
  chrome.runtime.onMessage.addListener(async (message) => {
    if (message.type === 'SETTINGS_UPDATED') {
      // 重新获取设置和本地设置以更新档位和效果链显示
      await refreshUiFromStorage();
      logger.debug('Settings updated.', { tier: currentTier });
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

    void refreshUiFromStorage();
  });
};

/**
 * 主初始化函数。
 */
document.addEventListener('DOMContentLoaded', async () => {
  // 初始化主题
  themeManager.getTheme(); // 这会自动应用保存的主题

  setupInternationalization();

  // 初始化侧边栏
  try {
    const sidebar = new Sidebar();
    sidebar.initialize();
  } catch (error) {
    logger.error('Failed to initialize sidebar:', error);
  }

  if (!modesContainer || !addModeBtn || !importModesBtn || !exportModesBtn || !rulesContainer || !addRuleBtn || !importBtn || !exportBtn) {
    logger.error('Required UI elements not found. Aborting initialization.');
    return;
  }

  // 从存储加载初始状态
  settingsState = await getSettings();

  // 读取本地设置获取当前档位
  const localSettings = await getLocalSettings();
  currentTier = localSettings.performanceTier;

  // 从状态进行初始 UI 渲染
  renderModesUI();
  renderRulesUI();
  renderGeneralSettingsUI();
  renderAboutSectionUI();

  // 附加所有事件监听器
  setupEventListeners();
});
