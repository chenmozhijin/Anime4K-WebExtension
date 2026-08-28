import type {
  NijiLucidSettings,
  CustomMode,
  EnhancementEffect,
  EnhancementMode,
  PerformanceTier,
} from '../../../types';
import {
  buildEnhancementModes,
  DEFAULT_RECOMMENDED_PRESET_MODE_ID,
  getEffectsForMode,
  saveSettings,
  synchronizeEffectsForCustomModes,
} from '../../../utils/settings';
import { AVAILABLE_EFFECTS } from '../../../utils/effects-map';
import { createEffectReference } from '../../../core/effects/reference';
import { getEffectDescriptor, validateEffectChain } from '../../../core/effects/registry';
import { showNotice } from '../../shared/notice';
import { createLogger } from '../../../utils/logger';
import { downloadJSON, openFile } from './helpers';
import { renderEffectBrowser, type EffectBrowserState } from './effect-browser';
import { summarizeEffectChain } from './effect-presentation';
import { runSaveAction } from '../../shared/save-action';

const logger = createLogger('options:modes');

type ModesSectionDeps = {
  getSettingsState(): NijiLucidSettings;
  getCurrentTier(): PerformanceTier;
  notifyUpdate(modifiedModeId?: string): void;
};

export interface ModesSectionController {
  bindEvents(): void;
  render(): void;
}

export function createModesSection(deps: ModesSectionDeps): ModesSectionController {
  const modesContainer = document.getElementById('modes-container') as HTMLElement | null;
  const addModeBtn = document.getElementById('add-mode-btn') as HTMLButtonElement | null;
  const importModesBtn = document.getElementById('import-modes-btn') as HTMLButtonElement | null;
  const exportModesBtn = document.getElementById('export-modes-btn') as HTMLButtonElement | null;

  let draggedElement: HTMLElement | null = null;
  let draggedModeId: string | null = null;
  let draggedEffectIndex: number | null = null;
  let activePromptNotice: HTMLElement | null = null;
  let effectBrowserState: EffectBrowserState = {
    modeId: null,
    backendId: 'all',
    query: '',
  };

  if (!modesContainer || !addModeBtn || !importModesBtn || !exportModesBtn) {
    throw new Error('Modes section elements not found');
  }

  const requiredModesContainer = modesContainer;
  const requiredAddModeBtn = addModeBtn;
  const requiredImportModesBtn = importModesBtn;
  const requiredExportModesBtn = exportModesBtn;

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

    return descriptor.name;
  };

  const validateCustomMode = (mode: CustomMode): string | null => {
    const validation = validateEffectChain(mode.effects);
    return validation.valid ? null : validation.errors[0] ?? 'Invalid effect chain';
  };

  type ModesSnapshot = {
    customModes: CustomMode[];
    selectedModeId: string;
    effectBrowserState: EffectBrowserState;
  };

  const cloneEffect = (effect: EnhancementEffect): EnhancementEffect => ({
    ...effect,
    ...(effect.params ? { params: { ...effect.params } } : {}),
  });

  const cloneCustomMode = (mode: CustomMode): CustomMode => ({
    ...mode,
    effects: mode.effects.map(cloneEffect),
  });

  const captureModesSnapshot = (): ModesSnapshot => {
    const settingsState = deps.getSettingsState();
    return {
      customModes: settingsState.customModes.map(cloneCustomMode),
      selectedModeId: settingsState.selectedModeId,
      effectBrowserState: { ...effectBrowserState },
    };
  };

  const restoreModesSnapshot = (snapshot: ModesSnapshot): void => {
    const settingsState = deps.getSettingsState();
    settingsState.customModes = snapshot.customModes.map(cloneCustomMode);
    settingsState.enhancementModes = buildEnhancementModes(settingsState.customModes);
    settingsState.selectedModeId = snapshot.selectedModeId;
    effectBrowserState = { ...snapshot.effectBrowserState };
    render();
  };

  const isInteractiveModeElement = (target: EventTarget | null): boolean => {
    return target instanceof HTMLElement
      && target.closest('button, input, select, textarea, label, a, [contenteditable="true"]') !== null;
  };

  const persistCustomModes = async (
    modifiedModeId?: string,
    persistSelectedModeId = false,
    rollbackSnapshot?: ModesSnapshot,
  ) => {
    const settingsState = deps.getSettingsState();
    settingsState.customModes = synchronizeEffectsForCustomModes(settingsState.customModes);
    settingsState.enhancementModes = buildEnhancementModes(settingsState.customModes);
    render();

    if (modifiedModeId) {
      const modifiedMode = settingsState.customModes.find(mode => mode.id === modifiedModeId);
      if (modifiedMode) {
        const validationError = validateCustomMode(modifiedMode);
        if (validationError) {
          throw new Error(validationError);
        }
      }
    }

    const settingsToPersist: Partial<NijiLucidSettings> = {
      customModes: settingsState.customModes,
    };

    if (persistSelectedModeId) {
      settingsToPersist.selectedModeId = settingsState.selectedModeId;
    }

    const result = await runSaveAction({
      action: async () => {
        await saveSettings(settingsToPersist);
        deps.notifyUpdate(modifiedModeId);
      },
      logger,
      logMessage: 'Failed to persist custom modes.',
      onError: () => {
        if (rollbackSnapshot) {
          restoreModesSnapshot(rollbackSnapshot);
        }
      },
    });
    return result !== null;
  };

  function render(): void {
    const settingsState = deps.getSettingsState();
    const currentTier = deps.getCurrentTier();
    const expandedModeIds = new Set<string>();

    requiredModesContainer.querySelectorAll('.mode-card:not(.collapsed)').forEach(card => {
      const modeId = (card as HTMLElement).dataset.modeId;
      if (modeId) {
        expandedModeIds.add(modeId);
      }
    });

    requiredModesContainer.textContent = '';

    const modeGroups: Array<{
      id: 'custom' | 'recommended' | 'compatibility';
      labelKey: string;
      fallbackLabel: string;
      modes: EnhancementMode[];
    }> = [
      {
        id: 'custom',
        labelKey: 'customModes',
        fallbackLabel: 'Custom Modes',
        modes: [],
      },
      {
        id: 'recommended',
        labelKey: 'recommendedPresets',
        fallbackLabel: 'Recommended Presets',
        modes: [],
      },
      {
        id: 'compatibility',
        labelKey: 'compatibilityModes',
        fallbackLabel: 'Compatibility Modes',
        modes: [],
      },
    ];

    settingsState.enhancementModes.forEach(mode => {
      if (!mode.isBuiltIn) {
        modeGroups[0].modes.push(mode);
      } else if ('isRecommended' in mode && mode.isRecommended === true) {
        modeGroups[1].modes.push(mode);
      } else {
        modeGroups[2].modes.push(mode);
      }
    });

    const modeGroupCards = new Map<typeof modeGroups[number]['id'], HTMLElement>();
    modeGroups.forEach(group => {
      const groupSection = document.createElement('section');
      groupSection.className = 'mode-group';
      groupSection.dataset.modeGroup = group.id;

      const groupHeader = document.createElement('div');
      groupHeader.className = 'mode-group-header';
      const groupTitle = document.createElement('h2');
      groupTitle.className = 'mode-group-title';
      groupTitle.textContent = chrome.i18n.getMessage(group.labelKey) || group.fallbackLabel;
      groupHeader.appendChild(groupTitle);

      const groupCards = document.createElement('div');
      groupCards.className = 'mode-group-cards';
      groupSection.append(groupHeader, groupCards);
      requiredModesContainer.appendChild(groupSection);
      modeGroupCards.set(group.id, groupCards);
    });

    modeGroups.forEach(group => group.modes.forEach(mode => {
      const isCustomMode = !mode.isBuiltIn;
      const card = document.createElement('div');
      card.className = 'mode-card collapsed';
      card.classList.toggle('sortable-mode-card', isCustomMode);
      card.dataset.modeId = mode.id;

      const updateCardDraggableState = () => {
        card.draggable = isCustomMode && card.classList.contains('collapsed');
      };

      card.addEventListener('dragstart', event => {
        if (!card.draggable || isInteractiveModeElement(event.target)) {
          event.preventDefault();
          return;
        }

        draggedElement = card;
        draggedModeId = mode.id;
        event.dataTransfer!.effectAllowed = 'move';
        event.dataTransfer!.setData('text/plain', mode.id);
        setTimeout(() => card.classList.add('dragging'), 0);
      });

      card.addEventListener('dragend', () => {
        card.classList.remove('dragging');
        draggedElement = null;
        draggedModeId = null;
      });

      card.addEventListener('dragover', event => {
        const isModeCardDrag = draggedElement?.classList.contains('mode-card') ?? false;
        if (!isCustomMode || !isModeCardDrag || draggedElement === card) {
          return;
        }

        event.preventDefault();
        card.classList.add('drag-over');
      });

      card.addEventListener('dragleave', () => card.classList.remove('drag-over'));

      card.addEventListener('drop', async event => {
        const isModeCardDrag = draggedElement?.classList.contains('mode-card') ?? false;
        if (!isCustomMode || !isModeCardDrag) {
          return;
        }

        event.preventDefault();
        card.classList.remove('drag-over');
        if (!draggedModeId || draggedModeId === mode.id) {
          return;
        }

        const fromIndex = settingsState.customModes.findIndex(item => item.id === draggedModeId);
        const toIndex = settingsState.customModes.findIndex(item => item.id === mode.id);
        if (fromIndex > -1 && toIndex > -1) {
          const snapshot = captureModesSnapshot();
          const [movedMode] = settingsState.customModes.splice(fromIndex, 1);
          settingsState.customModes.splice(toIndex, 0, movedMode);
          await persistCustomModes(movedMode.id, false, snapshot);
        }
      });

      const cardHeader = document.createElement('div');
      cardHeader.className = 'mode-card-header';
      const toggleBtn = document.createElement('button');
      toggleBtn.className = 'btn-toggle-collapse';
      toggleBtn.title = chrome.i18n.getMessage('expandCollapse');

      const svgNS = 'http://www.w3.org/2000/svg';
      const svg = document.createElementNS(svgNS, 'svg');
      svg.setAttribute('class', 'menu-icon');
      svg.setAttribute('width', '20');
      svg.setAttribute('height', '20');
      svg.setAttribute('viewBox', '0 0 24 24');
      svg.setAttribute('fill', 'none');
      svg.setAttribute('stroke', 'currentColor');
      svg.setAttribute('stroke-width', '2');
      svg.setAttribute('stroke-linecap', 'round');
      svg.setAttribute('stroke-linejoin', 'round');
      const polyline = document.createElementNS(svgNS, 'polyline');
      polyline.setAttribute('points', '9 18 15 12 9 6');
      svg.appendChild(polyline);
      toggleBtn.appendChild(svg);
      toggleBtn.addEventListener('click', () => {
        card.classList.toggle('collapsed');
        if (card.classList.contains('collapsed') && effectBrowserState.modeId === mode.id) {
          effectBrowserState = {
            modeId: null,
            backendId: 'all',
            query: '',
          };
          render();
          return;
        }
        updateCardDraggableState();
      });

      const modeName = document.createElement('h2');
      modeName.textContent = mode.name;
      modeName.contentEditable = String(!mode.isBuiltIn);
      modeName.draggable = false;
      modeName.title = mode.isBuiltIn
        ? chrome.i18n.getMessage('builtInModeCannotRename')
        : chrome.i18n.getMessage('clickToRename');
      modeName.addEventListener('dragstart', event => event.preventDefault());
      modeName.addEventListener('blur', async event => {
        if (mode.isBuiltIn) {
          return;
        }

        const newName = (event.target as HTMLElement).textContent?.trim() || '';
        const targetMode = settingsState.customModes.find(item => item.id === mode.id);
        if (targetMode && newName && newName !== targetMode.name) {
          const snapshot = captureModesSnapshot();
          targetMode.name = newName;
          const persisted = await persistCustomModes(mode.id, false, snapshot);
          if (!persisted) {
            (event.target as HTMLElement).textContent = snapshot.customModes.find(item => item.id === mode.id)?.name ?? mode.name;
          }
        } else {
          (event.target as HTMLElement).textContent = mode.name;
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
          actions: [{
            label: chrome.i18n.getMessage('delete'),
            emphasis: 'danger',
            onClick: async () => {
              const snapshot = captureModesSnapshot();
              const deletedModeId = mode.id;
              settingsState.customModes = settingsState.customModes.filter(item => item.id !== deletedModeId);
              const shouldPersistSelectedModeId = settingsState.selectedModeId === deletedModeId;
              if (shouldPersistSelectedModeId) {
                settingsState.selectedModeId = DEFAULT_RECOMMENDED_PRESET_MODE_ID;
              }
              await persistCustomModes(deletedModeId, shouldPersistSelectedModeId, snapshot);
            },
          }],
        }));
      };

      cardHeader.append(toggleBtn, modeName, deleteBtn);
      card.appendChild(cardHeader);

      const summary = document.createElement('div');
      summary.className = 'mode-summary';
      const modeEffects = getEffectsForMode(mode, currentTier);
      const chainSummary = summarizeEffectChain(modeEffects, getEffectLabel);
      summary.textContent = chainSummary || chrome.i18n.getMessage('noEffects');
      card.appendChild(summary);

      const cardContent = document.createElement('div');
      cardContent.className = 'mode-card-content';
      const effectsList = document.createElement('ul');
      effectsList.className = 'effects-list';

      modeEffects.forEach((effect, index) => {
        const effectItem = document.createElement('li');
        effectItem.className = 'effect-item';
        const effectName = document.createElement('span');
        effectName.textContent = getEffectLabel(effect);
        effectItem.appendChild(effectName);

        if (!mode.isBuiltIn) {
          effectItem.draggable = true;
          effectItem.addEventListener('dragstart', event => {
            event.stopPropagation();
            draggedElement = effectItem;
            draggedModeId = mode.id;
            draggedEffectIndex = index;
            event.dataTransfer!.effectAllowed = 'move';
            setTimeout(() => effectItem.classList.add('dragging'), 0);
          });
          effectItem.addEventListener('dragend', event => {
            event.stopPropagation();
            effectItem.classList.remove('dragging');
            draggedElement = null;
            draggedModeId = null;
            draggedEffectIndex = null;
          });
          effectItem.addEventListener('dragover', event => {
            event.preventDefault();
            event.stopPropagation();
            if (draggedModeId === mode.id) {
              effectItem.classList.add('drag-over');
            }
          });
          effectItem.addEventListener('dragleave', event => {
            event.stopPropagation();
            effectItem.classList.remove('drag-over');
          });
          effectItem.addEventListener('drop', async event => {
            event.preventDefault();
            event.stopPropagation();
            effectItem.classList.remove('drag-over');
            if (draggedModeId !== mode.id || draggedEffectIndex === null || draggedEffectIndex === index) {
              return;
            }

            const targetMode = settingsState.customModes.find(item => item.id === mode.id);
            if (targetMode) {
              const snapshot = captureModesSnapshot();
              const [movedEffect] = targetMode.effects.splice(draggedEffectIndex, 1);
              targetMode.effects.splice(index, 0, movedEffect);
              await persistCustomModes(mode.id, false, snapshot);
            }
          });

          const effectActions = document.createElement('div');
          effectActions.className = 'effect-actions';
          const createMoveBtn = (direction: 'up' | 'down') => {
            const btn = document.createElement('button');
            const arrowSvg = document.createElementNS(svgNS, 'svg');
            arrowSvg.setAttribute('width', '12');
            arrowSvg.setAttribute('height', '12');
            arrowSvg.setAttribute('viewBox', '0 0 24 24');
            arrowSvg.setAttribute('fill', 'currentColor');
            const arrowPath = document.createElementNS(svgNS, 'path');
            arrowPath.setAttribute('d', direction === 'up' ? 'M12 4l-8 8h16z' : 'M12 20l-8-8h16z');
            arrowSvg.appendChild(arrowPath);
            btn.appendChild(arrowSvg);
            btn.className = 'btn-move-effect';
            btn.title = chrome.i18n.getMessage(direction === 'up' ? 'moveUp' : 'moveDown');
            btn.disabled = (direction === 'up' && index === 0) || (direction === 'down' && index === mode.effects.length - 1);
            btn.onclick = async () => {
              const targetMode = settingsState.customModes.find(item => item.id === mode.id);
              if (!targetMode) {
                return;
              }

              const snapshot = captureModesSnapshot();
              const newIndex = direction === 'up' ? index - 1 : index + 1;
              const [movedEffect] = targetMode.effects.splice(index, 1);
              targetMode.effects.splice(newIndex, 0, movedEffect);
              await persistCustomModes(mode.id, false, snapshot);
            };
            return btn;
          };
          const removeEffectBtn = document.createElement('button');
          removeEffectBtn.textContent = 'x';
          removeEffectBtn.className = 'btn-remove-effect';
          removeEffectBtn.title = chrome.i18n.getMessage('removeEffect');
          removeEffectBtn.onclick = async () => {
            const targetMode = settingsState.customModes.find(item => item.id === mode.id);
            if (!targetMode) {
              return;
            }

            const snapshot = captureModesSnapshot();
            targetMode.effects.splice(index, 1);
            await persistCustomModes(mode.id, false, snapshot);
          };
          effectActions.append(createMoveBtn('up'), createMoveBtn('down'), removeEffectBtn);
          effectItem.appendChild(effectActions);
        }

        effectsList.appendChild(effectItem);
      });

      cardContent.appendChild(effectsList);

      if (!mode.isBuiltIn) {
        const addEffectContainer = renderEffectBrowser({
          modeId: mode.id,
          effects: AVAILABLE_EFFECTS,
          state: effectBrowserState,
          onToggle: () => {
            effectBrowserState = effectBrowserState.modeId === mode.id
              ? { modeId: null, backendId: 'all', query: '' }
              : { modeId: mode.id, backendId: 'all', query: '' };
            render();
          },
          onBackendChange: backendId => {
            effectBrowserState = {
              ...effectBrowserState,
              modeId: mode.id,
              backendId,
            };
          },
          onQueryChange: query => {
            effectBrowserState = {
              ...effectBrowserState,
              modeId: mode.id,
              query,
            };
          },
          onAddEffect: async effectToAdd => {
            const targetMode = settingsState.customModes.find(item => item.id === mode.id);
            if (targetMode && effectToAdd) {
              const snapshot = captureModesSnapshot();
              targetMode.effects.push(createEffectReference(effectToAdd));
              const validationError = validateCustomMode(targetMode);
              if (validationError) {
                targetMode.effects.pop();
                showNotice({ kind: 'error', message: validationError });
                return;
              }
              await persistCustomModes(mode.id, false, snapshot);
            }
          },
        });
        cardContent.appendChild(addEffectContainer);
      }

      card.appendChild(cardContent);

      if (expandedModeIds.has(mode.id)) {
        card.classList.remove('collapsed');
      }

      updateCardDraggableState();
      modeGroupCards.get(group.id)?.appendChild(card);
    }));
  }

  function bindEvents(): void {
    requiredAddModeBtn.addEventListener('click', async () => {
      const settingsState = deps.getSettingsState();
      const newMode: CustomMode = {
        id: `custom-${Date.now()}`,
        name: chrome.i18n.getMessage('newCustomModeName'),
        isBuiltIn: false,
        effects: [],
      };
      const snapshot = captureModesSnapshot();
      settingsState.customModes.unshift(newMode);
      await persistCustomModes(newMode.id, false, snapshot);
    });

    requiredExportModesBtn.addEventListener('click', () => {
      downloadJSON(deps.getSettingsState().customModes, 'nijilucid-modes.json');
    });

    requiredImportModesBtn.addEventListener('click', async () => {
      try {
        const json = await openFile();
        const importedModes = JSON.parse(json) as EnhancementMode[];
        if (!Array.isArray(importedModes)) {
          throw new Error('Invalid format: not an array');
        }

        const newModes: CustomMode[] = [];
        for (const mode of importedModes) {
          if (typeof mode !== 'object' || typeof mode.name !== 'string' || !Array.isArray((mode as { effects?: unknown[] }).effects)) {
            logger.warn('Skipping invalid mode object on import.', mode);
            continue;
          }

          newModes.push({
            id: `custom-${Date.now()}-${Math.random().toString(36).substring(2, 9)}`,
            name: mode.name,
            isBuiltIn: false,
            effects: (mode as CustomMode).effects,
          });
        }

        const syncedNewModes = synchronizeEffectsForCustomModes(newModes);
        for (const mode of syncedNewModes) {
          const validationError = validateCustomMode(mode);
          if (validationError) {
            throw new Error(validationError);
          }
        }

        const settingsState = deps.getSettingsState();
        const nextCustomModes = synchronizeEffectsForCustomModes([...settingsState.customModes, ...syncedNewModes]);

        await saveSettings({ customModes: nextCustomModes });
        settingsState.customModes = nextCustomModes;
        settingsState.enhancementModes = buildEnhancementModes(nextCustomModes);
        render();
        deps.notifyUpdate();
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
  }

  return {
    bindEvents,
    render,
  };
}
