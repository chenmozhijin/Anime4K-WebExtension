import type { GPUBenchmarkResult, PerformanceMonitorMode, PerformanceTier } from '../../../types';
import { saveLocalSettings, saveSettings } from '../../../utils/settings';
import { themeManager } from '../../theme-manager';
import { showNotice } from '../../shared/notice';
import { createLogger } from '../../../utils/logger';
import { getTierDisplayName } from './helpers';

const logger = createLogger('options:general');

type GeneralSectionDeps = {
  getCrossOriginFixEnabled(): boolean;
  setCrossOriginFixEnabled(enabled: boolean): void;
  getCurrentTier(): PerformanceTier;
  setCurrentTier(tier: PerformanceTier): void;
  setBenchmarkResult(result: GPUBenchmarkResult): void;
  getPerformanceMonitorMode(): PerformanceMonitorMode;
  setPerformanceMonitorMode(mode: PerformanceMonitorMode): void;
  notifyUpdate(modifiedModeId?: string): void;
  renderModes(): void;
};

export interface GeneralSectionController {
  bindEvents(): void;
  render(): Promise<void>;
}

export function createGeneralSection(deps: GeneralSectionDeps): GeneralSectionController {
  const crossOriginFixToggle = document.getElementById('cross-origin-fix-toggle') as HTMLInputElement | null;
  const themeSelect = document.getElementById('theme-select') as HTMLSelectElement | null;
  const versionNumberSpan = document.getElementById('version-number') as HTMLSpanElement | null;
  const runBenchmarkBtn = document.getElementById('run-benchmark-btn') as HTMLButtonElement | null;
  const gpuTierDisplay = document.getElementById('gpu-tier-display') as HTMLSpanElement | null;
  const performanceMonitorModeGroup = document.getElementById('performance-monitor-mode') as HTMLDivElement | null;

  if (!crossOriginFixToggle || !themeSelect || !versionNumberSpan || !runBenchmarkBtn || !gpuTierDisplay || !performanceMonitorModeGroup) {
    throw new Error('General section elements not found');
  }

  const requiredCrossOriginFixToggle = crossOriginFixToggle;
  const requiredThemeSelect = themeSelect;
  const requiredVersionNumberSpan = versionNumberSpan;
  const requiredRunBenchmarkBtn = runBenchmarkBtn;
  const requiredGpuTierDisplay = gpuTierDisplay;
  const requiredPerformanceMonitorModeGroup = performanceMonitorModeGroup;

  function renderPerformanceMonitorMode(): void {
    const mode = deps.getPerformanceMonitorMode();
    requiredPerformanceMonitorModeGroup.querySelectorAll<HTMLButtonElement>('[data-monitor-mode]').forEach(button => {
      const isActive = button.dataset.monitorMode === mode;
      button.classList.toggle('active', isActive);
      button.setAttribute('aria-checked', String(isActive));
      button.setAttribute('role', 'radio');
    });
  }

  async function render(): Promise<void> {
    requiredCrossOriginFixToggle.checked = deps.getCrossOriginFixEnabled();
    requiredThemeSelect.value = themeManager.getTheme();
    requiredVersionNumberSpan.textContent = chrome.runtime.getManifest().version;
    renderPerformanceMonitorMode();

    const tierIcons: Record<PerformanceTier, string> = {
      performance: `🚀 ${chrome.i18n.getMessage('tierPerformance')}`,
      balanced: `⚖️ ${chrome.i18n.getMessage('tierBalanced')}`,
      quality: `🎨 ${chrome.i18n.getMessage('tierQuality')}`,
      ultra: `🔬 ${chrome.i18n.getMessage('tierUltra')}`,
    };

    requiredGpuTierDisplay.textContent = tierIcons[deps.getCurrentTier()];
  }

  function bindEvents(): void {
    requiredCrossOriginFixToggle.addEventListener('change', async event => {
      const enabled = (event.target as HTMLInputElement).checked;
      const previousEnabled = deps.getCrossOriginFixEnabled();
      deps.setCrossOriginFixEnabled(enabled);
      try {
        await saveSettings({ enableCrossOriginFix: enabled });
        deps.notifyUpdate();
      } catch (error) {
        logger.error('Failed to save cross-origin compatibility setting:', error);
        deps.setCrossOriginFixEnabled(previousEnabled);
        requiredCrossOriginFixToggle.checked = previousEnabled;
        showNotice({
          kind: 'error',
          message: chrome.i18n.getMessage('saveFailed'),
        });
      }
    });

    requiredThemeSelect.addEventListener('change', event => {
      themeManager.setTheme((event.target as HTMLSelectElement).value as 'light' | 'dark' | 'auto');
    });

    requiredPerformanceMonitorModeGroup.addEventListener('click', async event => {
      const target = event.target as HTMLElement;
      const button = target.closest<HTMLButtonElement>('[data-monitor-mode]');
      if (!button) {
        return;
      }

      const nextMode = button.dataset.monitorMode as PerformanceMonitorMode;
      if (!nextMode || nextMode === deps.getPerformanceMonitorMode()) {
        return;
      }

      const previousMode = deps.getPerformanceMonitorMode();
      deps.setPerformanceMonitorMode(nextMode);
      renderPerformanceMonitorMode();

      try {
        await saveSettings({ performanceMonitorMode: nextMode });
        deps.notifyUpdate();
      } catch (error) {
        logger.error('Failed to save performance monitor setting:', error);
        deps.setPerformanceMonitorMode(previousMode);
        renderPerformanceMonitorMode();
        showNotice({
          kind: 'error',
          message: chrome.i18n.getMessage('saveFailed'),
        });
      }
    });

    requiredRunBenchmarkBtn.addEventListener('click', async () => {
      requiredRunBenchmarkBtn.disabled = true;
      requiredRunBenchmarkBtn.textContent = chrome.i18n.getMessage('testing');

      const progressContainer = document.getElementById('benchmark-progress');
      const progressFill = document.getElementById('benchmark-progress-fill');
      const progressText = document.getElementById('benchmark-progress-text');
      if (progressContainer) {
        progressContainer.style.display = 'block';
      }

      try {
        const { runGPUBenchmark } = await import('../../../core/gpu-benchmark');
        const result = await runGPUBenchmark(progress => {
          if (progressFill) {
            progressFill.style.width = `${progress.progress * 100}%`;
          }

          if (!progressText) {
            return;
          }

          if (progress.completed) {
            progressText.textContent = chrome.i18n.getMessage('testComplete');
            return;
          }

          const tierKey = `tier${progress.tier.charAt(0).toUpperCase()}${progress.tier.slice(1)}` as const;
          progressText.textContent = chrome.i18n.getMessage('testingTier', [chrome.i18n.getMessage(tierKey)]);
        });

        const tierNames: Record<PerformanceTier, string> = {
          performance: `🚀 ${chrome.i18n.getMessage('tierPerformance')}`,
          balanced: `⚖️ ${chrome.i18n.getMessage('tierBalanced')}`,
          quality: `🎨 ${chrome.i18n.getMessage('tierQuality')}`,
          ultra: `🔬 ${chrome.i18n.getMessage('tierUltra')}`,
        };
        const previousTier = deps.getCurrentTier();
        showNotice({
          kind: 'success',
          message: chrome.i18n.getMessage('benchmarkApplyRecommendation', [tierNames[result.tier]]),
          timeoutMs: 0,
          actions: [
            {
              label: chrome.i18n.getMessage('benchmarkApplyNow'),
              emphasis: 'primary',
              onClick: async () => {
                try {
                  await saveLocalSettings({
                    performanceTier: result.tier,
                    gpuBenchmarkResult: result,
                  });
                  deps.setCurrentTier(result.tier);
                  deps.setBenchmarkResult(result);
                  await render();
                  deps.renderModes();
                  deps.notifyUpdate();
                  showNotice({
                    kind: 'success',
                    message: chrome.i18n.getMessage('benchmarkRecommendationApplied', [tierNames[result.tier]]),
                  });
                } catch (error) {
                  logger.error('Failed to save benchmark recommendation:', error);
                  showNotice({
                    kind: 'error',
                    message: chrome.i18n.getMessage('saveFailed'),
                  });
                }
              },
            },
            {
              label: chrome.i18n.getMessage('benchmarkKeepCurrent'),
              onClick: () => {
                showNotice({
                  kind: 'info',
                  message: chrome.i18n.getMessage('benchmarkRecommendationSkipped', [getTierDisplayName(previousTier)]),
                });
              },
            },
          ],
        });
      } catch (error) {
        logger.error('Benchmark failed:', error);
        const errorMsg = error instanceof Error ? error.message : String(error);
        showNotice({
          kind: 'error',
          message: `${chrome.i18n.getMessage('testFailed')}: ${errorMsg}`,
          timeoutMs: 7000,
        });
      }

      if (progressContainer) {
        progressContainer.style.display = 'none';
      }
      requiredRunBenchmarkBtn.disabled = false;
      requiredRunBenchmarkBtn.textContent = chrome.i18n.getMessage('runTest');
    });
  }

  return {
    bindEvents,
    render,
  };
}
