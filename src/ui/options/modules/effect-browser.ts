import type { EffectDescriptor } from '../../../types';
import {
  EffectBrowserBackendId,
  getEffectPresentationGroups,
} from './effect-presentation';

export interface EffectBrowserState {
  modeId: string | null;
  backendId: EffectBrowserBackendId;
  query: string;
}

export interface RenderEffectBrowserOptions {
  modeId: string;
  effects: readonly EffectDescriptor[];
  state: EffectBrowserState;
  onToggle(): void;
  onBackendChange(backendId: EffectBrowserBackendId): void;
  onQueryChange(query: string): void;
  onAddEffect(effect: EffectDescriptor): void | Promise<void>;
}

const backendTabs: Array<{ id: EffectBrowserBackendId; labelKey: string; fallback: string }> = [
  { id: 'all', labelKey: 'effectBrowserAll', fallback: 'All' },
  { id: 'anime4k', labelKey: '', fallback: 'Anime4K' },
  { id: 'artcnn', labelKey: '', fallback: 'ArtCNN' },
  { id: 'acnet', labelKey: '', fallback: 'ACNet' },
  { id: 'cunny', labelKey: '', fallback: 'CuNNy' },
];

function getMessage(key: string, fallback: string): string {
  if (!key) {
    return fallback;
  }

  return chrome.i18n.getMessage(key) || fallback;
}

function getAddEffectLabel(): string {
  return `+ ${getMessage('addEffect', 'Add effect').replace(/(?:\.\.\.|…)$/, '')}`;
}

function createElement<K extends keyof HTMLElementTagNameMap>(
  tagName: K,
  className?: string,
): HTMLElementTagNameMap[K] {
  const element = document.createElement(tagName);
  if (className) {
    element.className = className;
  }
  return element;
}

function createDomId(modeId: string, suffix: string): string {
  return `effect-browser-${modeId.replace(/[^a-z0-9_-]/gi, '-')}-${suffix}`;
}

export function renderEffectBrowser(options: RenderEffectBrowserOptions): HTMLElement {
  const isOpen = options.state.modeId === options.modeId;
  let activeBackend = options.state.backendId;
  let query = options.state.query;
  const browserId = createDomId(options.modeId, 'panel');
  const resultsId = createDomId(options.modeId, 'results');
  const container = createElement('div', 'add-effect-container');
  const toggleButton = createElement('button', 'btn btn-outline btn-toggle-effect-browser');
  toggleButton.type = 'button';
  toggleButton.setAttribute('aria-expanded', String(isOpen));
  toggleButton.setAttribute('aria-controls', browserId);
  toggleButton.textContent = isOpen
    ? getMessage('effectBrowserDone', 'Done')
    : getAddEffectLabel();
  toggleButton.addEventListener('click', options.onToggle);
  container.appendChild(toggleButton);

  if (!isOpen) {
    return container;
  }

  const browser = createElement('div', 'effect-browser');
  browser.id = browserId;
  browser.setAttribute('role', 'region');
  browser.setAttribute('aria-label', getAddEffectLabel());
  browser.addEventListener('keydown', event => {
    if (event.key === 'Escape') {
      event.stopPropagation();
      options.onToggle();
    }
  });
  const toolbar = createElement('div', 'effect-browser-toolbar');

  const searchInput = createElement('input', 'effect-search-input');
  searchInput.type = 'search';
  searchInput.value = query;
  searchInput.placeholder = getMessage('effectSearchPlaceholder', 'Search effects...');
  searchInput.setAttribute('aria-label', getMessage('effectSearchPlaceholder', 'Search effects...'));
  searchInput.setAttribute('aria-controls', resultsId);
  toolbar.appendChild(searchInput);

  const tabs = createElement('div', 'effect-backend-tabs');
  tabs.setAttribute('role', 'tablist');
  tabs.setAttribute('aria-label', getAddEffectLabel());
  const tabButtons = new Map<EffectBrowserBackendId, HTMLButtonElement>();
  const updateTabStates = () => {
    for (const [backendId, button] of tabButtons) {
      const isActive = backendId === activeBackend;
      button.classList.toggle('active', isActive);
      button.setAttribute('aria-selected', String(isActive));
      button.tabIndex = isActive ? 0 : -1;
    }
  };
  const activateTab = (backendId: EffectBrowserBackendId) => {
    activeBackend = backendId;
    options.onBackendChange(backendId);
    updateTabStates();
    renderResults();
    tabButtons.get(backendId)?.focus();
  };
  for (const tab of backendTabs) {
    const tabButton = createElement('button', 'effect-backend-tab');
    tabButton.type = 'button';
    tabButton.textContent = getMessage(tab.labelKey, tab.fallback);
    tabButton.setAttribute('role', 'tab');
    tabButton.setAttribute('aria-controls', resultsId);
    tabButton.addEventListener('click', () => {
      activateTab(tab.id);
    });
    tabButton.addEventListener('keydown', event => {
      const currentIndex = backendTabs.findIndex(item => item.id === activeBackend);
      let nextIndex = currentIndex;
      if (event.key === 'ArrowRight') {
        nextIndex = (currentIndex + 1) % backendTabs.length;
      } else if (event.key === 'ArrowLeft') {
        nextIndex = (currentIndex - 1 + backendTabs.length) % backendTabs.length;
      } else if (event.key === 'Home') {
        nextIndex = 0;
      } else if (event.key === 'End') {
        nextIndex = backendTabs.length - 1;
      } else {
        return;
      }

      event.preventDefault();
      activateTab(backendTabs[nextIndex].id);
    });
    tabButtons.set(tab.id, tabButton);
    tabs.appendChild(tabButton);
  }
  updateTabStates();
  toolbar.appendChild(tabs);
  browser.appendChild(toolbar);

  const results = createElement('div', 'effect-browser-results');
  results.id = resultsId;
  results.setAttribute('role', 'tabpanel');

  const renderResults = () => {
    results.textContent = '';
    const groups = getEffectPresentationGroups({
      effects: options.effects,
      activeBackend,
      query,
    });

    if (groups.length === 0) {
      const empty = createElement('div', 'effect-browser-empty');
      empty.textContent = getMessage('noMatchingEffects', 'No matching effects');
      results.appendChild(empty);
    }

    for (const group of groups) {
      const groupElement = createElement('section', 'effect-result-group');
      const groupTitle = createElement('h3', 'effect-result-group-title');
      groupTitle.textContent = group.label;
      groupElement.appendChild(groupTitle);

      for (const item of group.items) {
        const row = createElement('div', 'effect-result-row');
        const addButton = createElement('button', 'effect-result-add');
        addButton.type = 'button';
        addButton.textContent = '+';
        const addLabel = `${getAddEffectLabel()}: ${item.descriptor.name}`;
        addButton.title = addLabel;
        addButton.setAttribute('aria-label', addLabel);
        addButton.addEventListener('click', () => {
          void options.onAddEffect(item.descriptor);
        });

        const text = createElement('div', 'effect-result-text');
        const name = createElement('div', 'effect-result-name');
        name.textContent = item.descriptor.name;
        const meta = createElement('div', 'effect-result-meta');
        meta.textContent = `${item.backendLabel} / ${item.groupLabel} · ${item.descriptor.category} · ${item.dimensionLabel}`;
        text.append(name, meta);
        row.append(addButton, text);
        groupElement.appendChild(row);
      }

      results.appendChild(groupElement);
    }
  };

  searchInput.addEventListener('input', event => {
    query = (event.target as HTMLInputElement).value;
    options.onQueryChange(query);
    renderResults();
  });

  renderResults();

  browser.appendChild(results);
  container.appendChild(browser);
  return container;
}
