import './onboarding.css';
import '../common-vars.css';
import { saveLocalSettings, getLocalSettings } from '../../utils/settings';
import { themeManager } from '../theme-manager';
import type { PerformanceTier, GPUBenchmarkResult } from '../../types';
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

let selectedTier: PerformanceTier = 'balanced';
let benchmarkResult: GPUBenchmarkResult | null = null;

document.addEventListener('DOMContentLoaded', async () => {
  await themeManager.ready();
  applyI18n();

  const localSettings = await getLocalSettings();
  selectedTier = localSettings.performanceTier;

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

  const startTestBtn = document.getElementById('start-test') as HTMLButtonElement | null;
  const skipTestBtn = document.getElementById('skip-test') as HTMLButtonElement | null;
  const confirmTierBtn = document.getElementById('confirm-tier') as HTMLButtonElement | null;
  const finishBtn = document.getElementById('finish') as HTMLButtonElement | null;
  const openOptionsBtn = document.getElementById('open-options') as HTMLButtonElement | null;
  const tierButtons = document.querySelectorAll<HTMLButtonElement>('.tier-btn');

  if (!startTestBtn || !skipTestBtn || !confirmTierBtn || !finishBtn || !openOptionsBtn) {
    logger.error('Required onboarding elements not found.');
    return;
  }

  startTestBtn.addEventListener('click', async () => {
    startTestBtn.disabled = true;
    skipTestBtn.style.display = 'none';

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
      benchmarkResult = await runGPUBenchmark((progress: BenchmarkProgress) => {
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

      selectedTier = benchmarkResult.tier;
      const saved = await runSaveAction({
        action: () => saveLocalSettings({
          performanceTier: selectedTier,
          gpuBenchmarkResult: benchmarkResult,
        }),
        controls: [startTestBtn],
        logger,
        logMessage: 'Failed to save onboarding benchmark result.',
      });
      if (saved === null) {
        return;
      }

      updateResultDisplay();
      goToStep(2);
    } catch (error) {
      logger.error('Benchmark failed:', error);
      if (progressText) {
        progressText.textContent = chrome.i18n.getMessage('testFailedDefault');
      }
      selectedTier = 'balanced';
      const saved = await runSaveAction({
        action: () => saveLocalSettings({ performanceTier: selectedTier }),
        controls: [startTestBtn],
        logger,
        logMessage: 'Failed to save onboarding fallback tier.',
      });
      if (saved === null) {
        return;
      }

      showNotice({
        kind: 'warning',
        message: chrome.i18n.getMessage('benchmarkInterrupted'),
        timeoutMs: 5000,
      });

      window.setTimeout(() => goToStep(2), 2000);
    } finally {
      startTestBtn.disabled = false;
      skipTestBtn.style.display = '';
    }
  });

  skipTestBtn.addEventListener('click', async () => {
    selectedTier = 'balanced';
    const saved = await runSaveAction({
      action: () => saveLocalSettings({ performanceTier: selectedTier }),
      controls: [skipTestBtn],
      logger,
      logMessage: 'Failed to save skipped onboarding tier.',
    });
    if (saved === null) {
      return;
    }
    goToStep(2);
  });

  tierButtons.forEach(btn => {
    btn.addEventListener('click', () => {
      selectedTier = btn.getAttribute('data-tier') as PerformanceTier;
      updateTierButtons();
    });
  });

  confirmTierBtn.addEventListener('click', async () => {
    const saved = await runSaveAction({
      action: () => saveLocalSettings({
        performanceTier: selectedTier,
        hasCompletedOnboarding: true,
      }),
      controls: [confirmTierBtn],
      logger,
      logMessage: 'Failed to save onboarding completion.',
    });
    if (saved === null) {
      return;
    }
    chrome.runtime.sendMessage({ type: 'SETTINGS_UPDATED' });
    goToStep(3);
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

function goToStep(step: number): void {
  document.querySelectorAll('.step').forEach((el, index) => {
    el.classList.remove('active', 'completed');
    if (index + 1 < step) {
      el.classList.add('completed');
    }
    if (index + 1 === step) {
      el.classList.add('active');
    }
  });

  document.querySelectorAll('.step-content').forEach((el, index) => {
    el.classList.toggle('active', index + 1 === step);
  });

  if (step === 2) {
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

  if (benchmarkResult && selectedTier === benchmarkResult.tier) {
    resultDesc.textContent = chrome.i18n.getMessage('resultDesc');
  } else if (benchmarkResult) {
    resultDesc.textContent = chrome.i18n.getMessage('manuallySelected');
  } else {
    resultDesc.textContent = chrome.i18n.getMessage('defaultTier');
  }

  resultDesc.style.display = 'block';
}

function updateTierButtons(): void {
  document.querySelectorAll<HTMLButtonElement>('.tier-btn').forEach(btn => {
    btn.classList.toggle('active', btn.getAttribute('data-tier') === selectedTier);
  });

  updateResultDisplay();
}
