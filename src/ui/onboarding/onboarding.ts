import './onboarding.css';
import '../common-vars.css';
import {
  BUILTIN_MODES,
  DEFAULT_RECOMMENDED_PRESET_MODE_ID,
  RECOMMENDED_PRESET_MODES,
  getLocalSettings,
  getSyncedSettings,
  saveLocalSettings,
  saveSettings,
} from '../../utils/settings';
import { themeManager } from '../theme-manager';
import type { BenchmarkRunState, PerformanceTier, RecommendedPresetModeId } from '../../types';
import type { BenchmarkProgress } from '../../core/gpu-benchmark';
import { showNotice } from '../shared/notice';
import { createLogger } from '../../utils/logger';
import { runSaveAction } from '../shared/save-action';

const logger = createLogger('onboarding');

const TIER_DISPLAY = (): Record<PerformanceTier, { icon: string; name: string }> => ({
  performance: { icon: '🚀', name: chrome.i18n.getMessage('tierPerformance') },
  balanced: { icon: '⚖️', name: chrome.i18n.getMessage('tierBalanced') },
  quality: { icon: '🎨', name: chrome.i18n.getMessage('tierQuality') },
  ultra: { icon: '🔬', name: chrome.i18n.getMessage('tierUltra') },
});

type TierSelectionSource = 'current' | 'benchmark' | 'default' | 'manual';
type OnboardingStep = 'benchmark' | 'tier' | 'mode' | 'complete';

const DEFAULT_ONBOARDING_STEPS: readonly OnboardingStep[] = [
  'benchmark',
  'tier',
  'complete',
];

const RECOMMENDED_PRESET_DESCRIPTION_KEYS: Record<RecommendedPresetModeId, string> = {
  'recommended-detail-preserving': 'recommendedDetailPreservingDesc',
  'recommended-compression-cleanup': 'recommendedCompressionCleanupDesc',
  'recommended-soft-style': 'recommendedSoftStyleDesc',
};

let selectedTier: PerformanceTier = 'balanced';
let tierSelectionSource: TierSelectionSource = 'current';
let selectedModeId: RecommendedPresetModeId = DEFAULT_RECOMMENDED_PRESET_MODE_ID;
let modeMigrationNeeded = false;
let activeSteps: OnboardingStep[] = [...DEFAULT_ONBOARDING_STEPS];

const isUpgradeMode = new URLSearchParams(window.location.search).getAll('mode').includes('upgrade');

const PERFORMANCE_TIERS: readonly PerformanceTier[] = [
  'performance',
  'balanced',
  'quality',
  'ultra',
];

function normalizePerformanceTier(value: unknown): PerformanceTier {
  return PERFORMANCE_TIERS.includes(value as PerformanceTier)
    ? value as PerformanceTier
    : 'balanced';
}

function renderStepIndicator(): void {
  const indicator = document.getElementById('step-indicator');
  if (!indicator) {
    return;
  }

  indicator.textContent = '';
  activeSteps.forEach((step, index) => {
    const stepElement = document.createElement('div');
    stepElement.className = 'step';
    stepElement.dataset.stepKey = step;
    stepElement.textContent = String(index + 1);
    if (index === 0) {
      stepElement.classList.add('active');
      stepElement.setAttribute('aria-current', 'step');
    }
    indicator.appendChild(stepElement);

    if (index < activeSteps.length - 1) {
      const line = document.createElement('div');
      line.className = 'step-line';
      indicator.appendChild(line);
    }
  });
}

function updateModeOptionSelection(): void {
  document.querySelectorAll<HTMLElement>('.mode-migration-option').forEach(option => {
    const input = option.querySelector<HTMLInputElement>('input[type="radio"]');
    option.classList.toggle('selected', input?.checked === true);
  });
}

function renderModeMigrationOptions(): void {
  const optionsContainer = document.getElementById('mode-migration-options');
  if (!optionsContainer) {
    return;
  }

  optionsContainer.textContent = '';
  RECOMMENDED_PRESET_MODES.forEach(mode => {
    const inputId = `mode-migration-${mode.id}`;
    const option = document.createElement('label');
    option.className = 'mode-migration-option';
    option.htmlFor = inputId;

    const radio = document.createElement('input');
    radio.type = 'radio';
    radio.id = inputId;
    radio.name = 'recommended-mode';
    radio.value = mode.id;
    radio.checked = mode.id === selectedModeId;
    radio.addEventListener('change', () => {
      if (radio.checked) {
        selectedModeId = mode.id;
        updateModeOptionSelection();
      }
    });

    const content = document.createElement('span');
    content.className = 'mode-migration-option-content';

    const name = document.createElement('span');
    name.className = 'mode-migration-option-name';
    name.textContent = chrome.i18n.getMessage(mode.nameKey) || mode.name;

    const family = document.createElement('span');
    family.className = 'mode-migration-option-family';
    family.textContent = mode.effectFamily;

    const description = document.createElement('span');
    description.className = 'mode-migration-option-description';
    description.textContent = chrome.i18n.getMessage(RECOMMENDED_PRESET_DESCRIPTION_KEYS[mode.id]);

    content.append(name, family, description);
    option.append(radio, content);
    optionsContainer.appendChild(option);
  });

  updateModeOptionSelection();
}

function configureModeMigration(currentMode?: typeof BUILTIN_MODES[number]): void {
  modeMigrationNeeded = isUpgradeMode && currentMode !== undefined;
  selectedModeId = DEFAULT_RECOMMENDED_PRESET_MODE_ID;
  activeSteps = modeMigrationNeeded
    ? ['benchmark', 'tier', 'mode', 'complete']
    : [...DEFAULT_ONBOARDING_STEPS];

  const modeStep = document.getElementById('step-mode-migration');
  if (modeStep) {
    modeStep.hidden = !modeMigrationNeeded;
  }

  const currentModeElement = document.getElementById('mode-migration-current');
  if (currentModeElement) {
    currentModeElement.textContent = currentMode
      ? chrome.i18n.getMessage('onboardingModeMigrationCurrent', [currentMode.name])
      : '';
  }

  renderModeMigrationOptions();
  renderStepIndicator();
}

async function initializeModeMigration(): Promise<void> {
  if (!isUpgradeMode) {
    configureModeMigration();
    return;
  }

  try {
    const syncedSettings = await getSyncedSettings();
    const currentMode = BUILTIN_MODES.find(mode => mode.id === syncedSettings.selectedModeId);
    configureModeMigration(currentMode);
  } catch (error) {
    logger.error('Failed to determine whether mode migration is needed:', error);
    configureModeMigration();
  }
}

function applyModeUi(): void {
  const header = document.querySelector<HTMLElement>('.onboarding-header');
  header?.classList.toggle('upgrade-mode', isUpgradeMode);

  const keepTierHint = document.getElementById('upgrade-keep-tier');
  if (keepTierHint) {
    keepTierHint.hidden = !isUpgradeMode;
  }

  if (!isUpgradeMode) {
    return;
  }

  const upgradeTitle = chrome.i18n.getMessage('onboardingUpgradeTitle');
  const upgradeDescription = chrome.i18n.getMessage('onboardingUpgradeDesc');
  const keepTierDescription = chrome.i18n.getMessage('onboardingUpgradeKeepTier');
  const title = document.getElementById('onboarding-title');
  const description = document.getElementById('onboarding-desc');
  const pageTitle = document.querySelector('title');

  if (title && upgradeTitle) {
    title.textContent = upgradeTitle;
  }
  if (description && upgradeDescription) {
    description.textContent = upgradeDescription;
  }
  if (keepTierHint && keepTierDescription) {
    keepTierHint.textContent = keepTierDescription;
  }
  if (pageTitle && upgradeTitle) {
    pageTitle.textContent = upgradeTitle;
  }
}

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', applyModeUi, { once: true });
} else {
  applyModeUi();
}

document.addEventListener('DOMContentLoaded', async () => {
  await themeManager.ready();
  applyI18n();
  applyModeUi();
  await initializeModeMigration();

  const localSettings = await getLocalSettings();
  selectedTier = normalizePerformanceTier(localSettings.performanceTier);
  tierSelectionSource = 'current';

  if (localSettings.benchmarkRunState?.status === 'interrupted') {
    showNotice({
      kind: 'warning',
      message: chrome.i18n.getMessage(
        'benchmarkFallbackApplied',
        [chrome.i18n.getMessage('tierPerformance')],
      ),
      timeoutMs: 5000,
    });
  }

  const startTestBtn = document.getElementById('start-test') as HTMLButtonElement | null;
  const skipTestBtn = document.getElementById('skip-test') as HTMLButtonElement | null;
  const confirmTierBtn = document.getElementById('confirm-tier') as HTMLButtonElement | null;
  const applyModeMigrationBtn = document.getElementById('apply-mode-migration') as HTMLButtonElement | null;
  const skipModeMigrationBtn = document.getElementById('skip-mode-migration') as HTMLButtonElement | null;
  const finishBtn = document.getElementById('finish') as HTMLButtonElement | null;
  const openOptionsBtn = document.getElementById('open-options') as HTMLButtonElement | null;
  const tierButtons = document.querySelectorAll<HTMLButtonElement>('.tier-btn');

  if (!startTestBtn || !skipTestBtn || !confirmTierBtn || !applyModeMigrationBtn
    || !skipModeMigrationBtn || !finishBtn || !openOptionsBtn) {
    logger.error('Required onboarding elements not found.');
    return;
  }

  startTestBtn.addEventListener('click', async () => {
    startTestBtn.disabled = true;
    skipTestBtn.style.display = 'none';
    const benchmarkAttemptStartedAt = Date.now();

    const testStatus = document.getElementById('test-status') as HTMLElement | null;
    const progressContainer = document.getElementById('progress-container') as HTMLElement | null;
    const progressFill = document.getElementById('progress-fill') as HTMLElement | null;
    const progressText = document.getElementById('progress-text') as HTMLElement | null;

    if (testStatus) {
      testStatus.style.display = 'none';
    }
    if (progressContainer) {
      progressContainer.style.display = 'block';
    }

    try {
      const { runGPUBenchmark } = await import('../../core/gpu-benchmark');
      const completedBenchmark = await runGPUBenchmark((progress: BenchmarkProgress) => {
        if (progressFill) {
          progressFill.style.width = `${progress.progress * 100}%`;
        }
        if (progressText) {
          if (progress.completed) {
            progressText.textContent = chrome.i18n.getMessage('testComplete');
          } else {
            const tierKey = `tier${progress.tier.charAt(0).toUpperCase()}${progress.tier.slice(1)}` as const;
            progressText.textContent = chrome.i18n.getMessage('testingTier', [chrome.i18n.getMessage(tierKey)]);
          }
        }
      });

      const saved = await runSaveAction({
        action: () => saveLocalSettings({ gpuBenchmarkResult: completedBenchmark }),
        controls: [startTestBtn],
        logger,
        logMessage: 'Failed to save onboarding benchmark result.',
      });
      if (saved === null) {
        return;
      }

      selectedTier = completedBenchmark.tier;
      tierSelectionSource = 'benchmark';
      updateResultDisplay();
      goToStep('tier');
    } catch (error) {
      logger.error('Benchmark failed:', error);
      if (progressText) {
        progressText.textContent = chrome.i18n.getMessage(
          isUpgradeMode ? 'testFailed' : 'testFailedDefault',
        );
      }

      if (isUpgradeMode) {
        tierSelectionSource = 'current';
        const saved = await runSaveAction({
          action: async () => {
            const benchmarkRunState = await resolveUpgradeFailureState(benchmarkAttemptStartedAt);
            await saveLocalSettings({
              gpuBenchmarkResult: null,
              benchmarkRunState,
            });
          },
          controls: [startTestBtn],
          logger,
          logMessage: 'Failed to save upgrade benchmark failure state.',
        });
        if (saved === null) {
          return;
        }
      } else {
        selectedTier = 'balanced';
        tierSelectionSource = 'default';
      }

      showNotice({
        kind: 'warning',
        message: chrome.i18n.getMessage('benchmarkInterrupted'),
        timeoutMs: 5000,
      });

      window.setTimeout(() => goToStep('tier'), 2000);
    } finally {
      startTestBtn.disabled = false;
      skipTestBtn.style.display = '';
    }
  });

  skipTestBtn.addEventListener('click', async () => {
    if (isUpgradeMode) {
      tierSelectionSource = 'current';
      const saved = await runSaveAction({
        action: () => saveLocalSettings({
          gpuBenchmarkResult: null,
          benchmarkRunState: {
            status: 'idle',
            fallbackTierApplied: null,
          },
        }),
        controls: [skipTestBtn],
        logger,
        logMessage: 'Failed to save skipped upgrade onboarding state.',
      });
      if (saved === null) {
        return;
      }
    } else {
      selectedTier = 'balanced';
      tierSelectionSource = 'default';
    }
    goToStep('tier');
  });

  tierButtons.forEach(btn => {
    btn.addEventListener('click', () => {
      selectedTier = normalizePerformanceTier(btn.getAttribute('data-tier'));
      tierSelectionSource = 'manual';
      updateTierButtons();
    });
  });

  confirmTierBtn.addEventListener('click', async () => {
    const saved = await runSaveAction({
      action: () => saveLocalSettings({
        performanceTier: selectedTier,
        ...(modeMigrationNeeded ? {} : { hasCompletedOnboarding: true }),
      }),
      controls: [confirmTierBtn],
      logger,
      logMessage: 'Failed to save onboarding completion.',
    });
    if (saved === null) {
      return;
    }
    notifySettingsUpdated();
    goToStep(modeMigrationNeeded ? 'mode' : 'complete');
  });

  applyModeMigrationBtn.addEventListener('click', async () => {
    const selectedMode = RECOMMENDED_PRESET_MODES.find(mode => mode.id === selectedModeId);
    if (!selectedMode) {
      logger.error('Selected recommended preset is not available:', selectedModeId);
      showNotice({ kind: 'error', message: chrome.i18n.getMessage('saveFailed') });
      return;
    }

    const modeSaved = await runSaveAction({
      action: () => saveSettings({ selectedModeId: selectedMode.id }),
      controls: [applyModeMigrationBtn, skipModeMigrationBtn],
      logger,
      logMessage: 'Failed to save onboarding recommended preset.',
    });
    if (modeSaved === null) {
      return;
    }

    const completionSaved = await runSaveAction({
      action: () => saveLocalSettings({ hasCompletedOnboarding: true }),
      controls: [applyModeMigrationBtn, skipModeMigrationBtn],
      logger,
      logMessage: 'Failed to save onboarding completion after mode migration.',
    });
    if (completionSaved === null) {
      return;
    }

    notifySettingsUpdated();
    goToStep('complete');
  });

  skipModeMigrationBtn.addEventListener('click', async () => {
    const saved = await runSaveAction({
      action: () => saveLocalSettings({ hasCompletedOnboarding: true }),
      controls: [applyModeMigrationBtn, skipModeMigrationBtn],
      logger,
      logMessage: 'Failed to complete onboarding while keeping compatibility mode.',
    });
    if (saved === null) {
      return;
    }

    notifySettingsUpdated();
    goToStep('complete');
  });

  finishBtn.addEventListener('click', () => {
    window.close();
  });

  openOptionsBtn.addEventListener('click', () => {
    chrome.runtime.openOptionsPage();
    window.close();
  });
}, { once: true });

function applyI18n(): void {
  document.querySelectorAll<HTMLElement>('[data-i18n]').forEach(el => {
    const key = el.getAttribute('data-i18n');
    if (!key) {
      return;
    }

    const message = chrome.i18n.getMessage(key);
    if (message) {
      el.textContent = message;
    }
  });
}

function notifySettingsUpdated(): void {
  void chrome.runtime.sendMessage({ type: 'SETTINGS_UPDATED' }).catch(error => {
    logger.warn('Failed to notify the extension about onboarding settings:', error);
  });
}

function goToStep(step: OnboardingStep): void {
  const targetIndex = activeSteps.indexOf(step);
  if (targetIndex < 0) {
    logger.warn('Attempted to navigate to an inactive onboarding step:', step);
    return;
  }

  const keepTierHint = document.getElementById('upgrade-keep-tier');
  if (keepTierHint) {
    keepTierHint.hidden = !isUpgradeMode || step !== 'benchmark';
  }

  document.querySelectorAll<HTMLElement>('.step').forEach(el => {
    const stepKey = el.dataset.stepKey as OnboardingStep | undefined;
    const index = stepKey ? activeSteps.indexOf(stepKey) : -1;
    el.classList.remove('active', 'completed');
    el.removeAttribute('aria-current');
    if (index >= 0 && index < targetIndex) {
      el.classList.add('completed');
    }
    if (index === targetIndex) {
      el.classList.add('active');
      el.setAttribute('aria-current', 'step');
    }
  });

  document.querySelectorAll<HTMLElement>('.step-content').forEach(el => {
    const stepKey = el.dataset.stepKey as OnboardingStep | undefined;
    el.classList.toggle('active', stepKey === step);
    if (stepKey === 'mode') {
      el.hidden = !modeMigrationNeeded;
    } else {
      el.hidden = false;
    }
  });

  if (step === 'tier') {
    updateTierButtons();
  }
}

function updateResultDisplay(): void {
  const resultTier = document.getElementById('result-tier');
  const resultDesc = document.getElementById('result-desc');
  if (!resultTier || !resultDesc) {
    return;
  }

  const display = TIER_DISPLAY()[selectedTier];
  resultTier.textContent = `${display.icon} ${display.name}`;

  switch (tierSelectionSource) {
    case 'benchmark':
      resultDesc.textContent = chrome.i18n.getMessage('resultDesc');
      break;
    case 'manual':
      resultDesc.textContent = chrome.i18n.getMessage('manuallySelected');
      break;
    case 'current':
      resultDesc.textContent = isUpgradeMode
        ? chrome.i18n.getMessage('onboardingUpgradeTierKept')
        : chrome.i18n.getMessage('defaultTier');
      break;
    case 'default':
      resultDesc.textContent = chrome.i18n.getMessage('defaultTier');
      break;
  }

  resultDesc.style.display = 'block';
}

function updateTierButtons(): void {
  document.querySelectorAll<HTMLButtonElement>('.tier-btn').forEach(btn => {
    btn.classList.toggle('active', btn.getAttribute('data-tier') === selectedTier);
  });

  updateResultDisplay();
}

async function resolveUpgradeFailureState(attemptStartedAt: number): Promise<BenchmarkRunState> {
  const latestSettings = await getLocalSettings();
  const latestState: BenchmarkRunState = latestSettings.benchmarkRunState ?? {
    status: 'idle',
    fallbackTierApplied: null,
  };

  return {
    ...latestState,
    status: 'failed',
    fallbackTierApplied: latestState.fallbackTierApplied ?? null,
    startedAt: latestState.startedAt ?? attemptStartedAt,
    endedAt: latestState.endedAt ?? Date.now(),
  };
}
