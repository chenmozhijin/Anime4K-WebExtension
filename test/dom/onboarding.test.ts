import { beforeEach, describe, expect, it, vi } from 'vitest';
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { flushPromises } from '../support/async';
import { installChromeMock } from '../support/chrome';

const onboardingHtml = readFileSync(resolve(process.cwd(), 'src/ui/onboarding/onboarding.html'), 'utf8');

function setDocumentFromHtml(html: string): void {
  const body = html.match(/<body[^>]*>([\s\S]*)<\/body>/i)?.[1] ?? html;
  const title = html.match(/<title[^>]*>[\s\S]*<\/title>/i)?.[0] ?? '<title></title>';
  document.head.innerHTML = title;
  document.body.innerHTML = body;
}

type OnboardingSetup = {
  chromeMock: ReturnType<typeof installChromeMock>;
  saveLocalSettings: ReturnType<typeof vi.fn>;
  saveSettings: ReturnType<typeof vi.fn>;
  getLocalSettings: ReturnType<typeof vi.fn>;
  getSyncedSettings: ReturnType<typeof vi.fn>;
  showNotice: ReturnType<typeof vi.fn>;
  runGPUBenchmark: ReturnType<typeof vi.fn>;
};

function setupOnboarding(options: {
  mode?: 'initial' | 'upgrade';
  localSettings?: Record<string, unknown>;
  syncedSettings?: Record<string, unknown>;
  benchmark?: ReturnType<typeof vi.fn>;
  saveLocalSettings?: ReturnType<typeof vi.fn>;
  saveSettings?: ReturnType<typeof vi.fn>;
} = {}): OnboardingSetup {
  setDocumentFromHtml(onboardingHtml);
  window.history.replaceState({}, '', options.mode === 'upgrade' ? '/onboarding.html?mode=upgrade' : '/onboarding.html');

  const chromeMock = installChromeMock();
  const saveLocalSettings = options.saveLocalSettings ?? vi.fn().mockResolvedValue(undefined);
  const saveSettings = options.saveSettings ?? vi.fn().mockResolvedValue(undefined);
  const getLocalSettings = vi.fn().mockResolvedValue(options.localSettings ?? {
    performanceTier: 'balanced',
    gpuBenchmarkResult: null,
    benchmarkRunState: { status: 'idle' },
  });
  const getSyncedSettings = vi.fn().mockResolvedValue(options.syncedSettings ?? {
    selectedModeId: 'recommended-detail-preserving',
  });
  const showNotice = vi.fn(() => document.createElement('div'));
  const runGPUBenchmark = options.benchmark ?? vi.fn().mockResolvedValue({
    tier: 'quality',
    frames: 120,
  });

  vi.doMock('../../src/utils/settings', () => ({
    BUILTIN_MODES: [
      { id: 'builtin-mode-a', name: 'Mode A', isBuiltIn: true, backendId: 'anime4k', presetKey: 'A', baseMode: 'A' },
      { id: 'builtin-mode-b', name: 'Mode B', isBuiltIn: true, backendId: 'anime4k', presetKey: 'B', baseMode: 'B' },
      { id: 'builtin-mode-c', name: 'Mode C', isBuiltIn: true, backendId: 'anime4k', presetKey: 'C', baseMode: 'C' },
      { id: 'builtin-mode-aa', name: 'Mode A+A', isBuiltIn: true, backendId: 'anime4k', presetKey: 'A+A', baseMode: 'A+A' },
      { id: 'builtin-mode-bb', name: 'Mode B+B', isBuiltIn: true, backendId: 'anime4k', presetKey: 'B+B', baseMode: 'B+B' },
      { id: 'builtin-mode-ca', name: 'Mode C+A', isBuiltIn: true, backendId: 'anime4k', presetKey: 'C+A', baseMode: 'C+A' },
    ],
    DEFAULT_RECOMMENDED_PRESET_MODE_ID: 'recommended-detail-preserving',
    RECOMMENDED_PRESET_MODES: [
      { id: 'recommended-detail-preserving', name: 'Detail Preserving', nameKey: 'recommendedDetailPreserving', effectFamily: 'CuNNy' },
      { id: 'recommended-compression-cleanup', name: 'Compression Cleanup', nameKey: 'recommendedCompressionCleanup', effectFamily: 'ARNet' },
      { id: 'recommended-soft-style', name: 'Soft Style', nameKey: 'recommendedSoftStyle', effectFamily: 'ArtCNN' },
    ],
    saveLocalSettings,
    getLocalSettings,
    saveSettings,
    getSyncedSettings,
  }));
  vi.doMock('../../src/ui/theme-manager', () => ({
    themeManager: {
      getTheme: vi.fn(),
      ready: vi.fn().mockResolvedValue(undefined),
    },
  }));
  vi.doMock('../../src/ui/shared/notice', () => ({
    showNotice,
  }));
  vi.doMock('../../src/utils/logger', () => ({
    createLogger: () => ({
      debug: vi.fn(),
      info: vi.fn(),
      warn: vi.fn(),
      error: vi.fn(),
    }),
  }));
  vi.doMock('../../src/core/gpu-benchmark', () => ({
    runGPUBenchmark,
  }));

  return {
    chromeMock,
    saveLocalSettings,
    saveSettings,
    getLocalSettings,
    getSyncedSettings,
    showNotice,
    runGPUBenchmark,
  };
}

async function loadOnboarding(): Promise<void> {
  await import('../../src/ui/onboarding/onboarding');
  document.dispatchEvent(new Event('DOMContentLoaded'));
  await flushPromises(8);
}

describe('onboarding UI', () => {
  beforeEach(() => {
    vi.resetModules();
    vi.restoreAllMocks();
    document.head.innerHTML = '';
    document.body.innerHTML = '';
    window.history.replaceState({}, '', '/');
  });

  it('keeps the welcome header and applies the ordinary benchmark tier only on confirmation', async () => {
    const { chromeMock, saveLocalSettings, runGPUBenchmark } = setupOnboarding({
      localSettings: {
        performanceTier: 'balanced',
        benchmarkRunState: { status: 'interrupted' },
      },
    });
    const closeSpy = vi.spyOn(window, 'close').mockImplementation(() => undefined);

    await loadOnboarding();

    expect(document.getElementById('onboarding-title')?.textContent).toBe('welcomeTitle');
    expect(document.title).toBe('onboardingTitle');
    expect(document.getElementById('upgrade-keep-tier')?.hidden).toBe(true);
    expect(document.getElementById('confirm-tier')?.textContent).toBe('onboardingApplyTier');

    document.getElementById('start-test')?.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    await vi.dynamicImportSettled();
    await flushPromises(12);

    expect(runGPUBenchmark).toHaveBeenCalledTimes(1);
    expect(saveLocalSettings).toHaveBeenCalledWith({
      gpuBenchmarkResult: { tier: 'quality', frames: 120 },
    });
    expect(saveLocalSettings.mock.calls[0]?.[0]).not.toHaveProperty('performanceTier');
    expect(document.getElementById('step-2')?.classList.contains('active')).toBe(true);

    document.getElementById('confirm-tier')?.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    await flushPromises();

    expect(saveLocalSettings).toHaveBeenCalledWith({
      performanceTier: 'quality',
      hasCompletedOnboarding: true,
    });
    expect(chromeMock.__mock.runtimeMessages).toContainEqual({ type: 'SETTINGS_UPDATED' });
    expect(document.getElementById('step-3')?.classList.contains('active')).toBe(true);

    document.getElementById('open-options')?.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    expect(chromeMock.__mock.openOptionsPageCalls).toHaveLength(1);
    expect(closeSpy).toHaveBeenCalledTimes(1);
  });

  it('replaces the welcome header and places the keep-tier hint beside the upgrade action', async () => {
    setupOnboarding({
      mode: 'upgrade',
      localSettings: {
        performanceTier: 'quality',
        gpuBenchmarkResult: { tier: 'balanced' },
        benchmarkRunState: { status: 'completed' },
        hasCompletedOnboarding: true,
      },
    });

    await loadOnboarding();

    expect(document.getElementById('onboarding-title')?.textContent).toBe('onboardingUpgradeTitle');
    expect(document.getElementById('onboarding-desc')?.textContent).toBe('onboardingUpgradeDesc');
    expect(document.title).toBe('onboardingUpgradeTitle');
    expect(document.getElementById('onboarding-title')?.textContent).not.toBe('welcomeTitle');
    expect(document.querySelector('.onboarding-header')?.classList.contains('upgrade-mode')).toBe(true);
    expect(document.getElementById('upgrade-keep-tier')?.hidden).toBe(false);
    expect(document.getElementById('confirm-tier')?.textContent).toBe('onboardingApplyTier');

    const hint = document.getElementById('upgrade-keep-tier')!;
    const buttons = document.querySelector('#step-1 .button-group')!;
    expect(Boolean(hint.compareDocumentPosition(buttons) & Node.DOCUMENT_POSITION_FOLLOWING)).toBe(true);
  });

  it('adds a four-step mode migration flow only for upgrade users on compatibility modes', async () => {
    setupOnboarding({
      mode: 'upgrade',
      syncedSettings: {
        selectedModeId: 'builtin-mode-ca',
      },
      localSettings: {
        performanceTier: 'quality',
        benchmarkRunState: { status: 'idle' },
      },
    });

    await loadOnboarding();

    expect(document.querySelectorAll('#step-indicator .step')).toHaveLength(4);
    expect(document.querySelectorAll('#step-indicator .step-line')).toHaveLength(3);
    expect(document.getElementById('step-mode-migration')?.hidden).toBe(false);
    expect(document.getElementById('mode-migration-current')?.textContent)
      .toBe('onboardingModeMigrationCurrent');
    expect(document.querySelectorAll('#mode-migration-options input[type="radio"]')).toHaveLength(3);
    expect(document.querySelector<HTMLInputElement>('#mode-migration-recommended-detail-preserving')?.checked).toBe(true);
  });

  it('defers onboarding completion until a compatibility-mode migration is applied', async () => {
    const { saveLocalSettings, saveSettings, chromeMock } = setupOnboarding({
      mode: 'upgrade',
      syncedSettings: {
        selectedModeId: 'builtin-mode-a',
      },
      localSettings: {
        performanceTier: 'ultra',
        benchmarkRunState: { status: 'idle' },
      },
    });

    await loadOnboarding();
    document.getElementById('skip-test')?.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    await flushPromises(8);
    document.getElementById('confirm-tier')?.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    await flushPromises(6);

    expect(document.getElementById('step-mode-migration')?.classList.contains('active')).toBe(true);
    expect(saveLocalSettings).toHaveBeenLastCalledWith({ performanceTier: 'ultra' });
    expect(saveLocalSettings.mock.calls.some(([value]) => value.hasCompletedOnboarding === true)).toBe(false);

    const compressionRadio = document.getElementById('mode-migration-recommended-compression-cleanup') as HTMLInputElement;
    compressionRadio.checked = true;
    compressionRadio.dispatchEvent(new Event('change', { bubbles: true }));
    document.getElementById('apply-mode-migration')?.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    await flushPromises(8);

    expect(saveSettings).toHaveBeenCalledWith({ selectedModeId: 'recommended-compression-cleanup' });
    expect(saveLocalSettings).toHaveBeenLastCalledWith({ hasCompletedOnboarding: true });
    expect(document.getElementById('step-3')?.classList.contains('active')).toBe(true);
    expect(chromeMock.__mock.runtimeMessages).toContainEqual({ type: 'SETTINGS_UPDATED' });
  });

  it('skips compatibility-mode migration without changing the selected mode', async () => {
    const { saveLocalSettings, saveSettings } = setupOnboarding({
      mode: 'upgrade',
      syncedSettings: {
        selectedModeId: 'builtin-mode-bb',
      },
      localSettings: {
        performanceTier: 'balanced',
        benchmarkRunState: { status: 'idle' },
      },
    });

    await loadOnboarding();
    document.getElementById('skip-test')?.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    await flushPromises(8);
    document.getElementById('confirm-tier')?.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    await flushPromises(6);
    document.getElementById('skip-mode-migration')?.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    await flushPromises(6);

    expect(saveSettings).not.toHaveBeenCalled();
    expect(saveLocalSettings).toHaveBeenLastCalledWith({ hasCompletedOnboarding: true });
    expect(document.getElementById('step-3')?.classList.contains('active')).toBe(true);
  });

  it('stays on the migration step when the recommended preset cannot be saved', async () => {
    const saveSettings = vi.fn().mockRejectedValue(new Error('sync save failed'));
    const { saveLocalSettings, showNotice } = setupOnboarding({
      mode: 'upgrade',
      saveSettings,
      syncedSettings: {
        selectedModeId: 'builtin-mode-c',
      },
      localSettings: {
        performanceTier: 'quality',
        benchmarkRunState: { status: 'idle' },
      },
    });

    await loadOnboarding();
    document.getElementById('skip-test')?.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    await flushPromises(8);
    document.getElementById('confirm-tier')?.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    await flushPromises(6);
    document.getElementById('apply-mode-migration')?.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    await flushPromises(6);

    expect(document.getElementById('step-mode-migration')?.classList.contains('active')).toBe(true);
    expect(saveLocalSettings.mock.calls.some(([value]) => value.hasCompletedOnboarding === true)).toBe(false);
    expect(showNotice).toHaveBeenCalledWith({ kind: 'error', message: 'saveFailed' });
  });

  it('can retry completion after the recommended preset was saved', async () => {
    const saveLocalSettings = vi.fn()
      .mockResolvedValueOnce(undefined)
      .mockResolvedValueOnce(undefined)
      .mockRejectedValueOnce(new Error('completion failed'))
      .mockResolvedValue(undefined);
    const { saveSettings, showNotice } = setupOnboarding({
      mode: 'upgrade',
      saveLocalSettings,
      syncedSettings: {
        selectedModeId: 'builtin-mode-a',
      },
    });

    await loadOnboarding();
    document.getElementById('skip-test')?.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    await flushPromises(8);
    document.getElementById('confirm-tier')?.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    await flushPromises(6);

    document.getElementById('apply-mode-migration')?.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    await flushPromises(8);

    expect(saveSettings).toHaveBeenCalledWith({ selectedModeId: 'recommended-detail-preserving' });
    expect(document.getElementById('step-mode-migration')?.classList.contains('active')).toBe(true);
    expect(showNotice).toHaveBeenCalledWith({ kind: 'error', message: 'saveFailed' });

    document.getElementById('apply-mode-migration')?.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    await flushPromises(8);

    expect(saveSettings).toHaveBeenCalledTimes(2);
    expect(document.getElementById('step-3')?.classList.contains('active')).toBe(true);
  });

  it('saves an upgrade benchmark result without applying its tier before confirmation', async () => {
    const { saveLocalSettings, runGPUBenchmark } = setupOnboarding({
      mode: 'upgrade',
      localSettings: {
        performanceTier: 'quality',
        gpuBenchmarkResult: null,
        benchmarkRunState: { status: 'idle' },
      },
    });

    await loadOnboarding();
    document.getElementById('start-test')?.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    await vi.dynamicImportSettled();
    await flushPromises(12);

    expect(runGPUBenchmark).toHaveBeenCalledTimes(1);
    expect(saveLocalSettings).toHaveBeenCalledWith({
      gpuBenchmarkResult: { tier: 'quality', frames: 120 },
    });
    expect(saveLocalSettings.mock.calls[0]?.[0]).not.toHaveProperty('performanceTier');

    document.getElementById('confirm-tier')?.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    await flushPromises(4);

    expect(saveLocalSettings).toHaveBeenLastCalledWith({
      performanceTier: 'quality',
      hasCompletedOnboarding: true,
    });
  });

  it('keeps the existing tier and clears the old result when an upgrade user skips', async () => {
    const { saveLocalSettings } = setupOnboarding({
      mode: 'upgrade',
      localSettings: {
        performanceTier: 'ultra',
        gpuBenchmarkResult: { tier: 'quality' },
        benchmarkRunState: { status: 'completed' },
      },
    });

    await loadOnboarding();
    document.getElementById('skip-test')?.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    await flushPromises(8);

    expect(saveLocalSettings).toHaveBeenCalledWith({
      gpuBenchmarkResult: null,
      benchmarkRunState: {
        status: 'idle',
        fallbackTierApplied: null,
      },
    });
    expect(document.getElementById('step-2')?.classList.contains('active')).toBe(true);
    expect(document.getElementById('step-1')?.classList.contains('active')).toBe(false);
    expect(document.getElementById('upgrade-keep-tier')?.hidden).toBe(true);
    expect(document.getElementById('result-desc')?.textContent).toBe('onboardingUpgradeTierKept');

    document.getElementById('confirm-tier')?.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    await flushPromises(4);

    expect(saveLocalSettings).toHaveBeenLastCalledWith({
      performanceTier: 'ultra',
      hasCompletedOnboarding: true,
    });
  });

  it('keeps the existing tier and preserves a benchmark failure state after an upgrade failure', async () => {
    const benchmark = vi.fn().mockRejectedValue(new Error('validation failure'));
    const { saveLocalSettings, getLocalSettings, runGPUBenchmark } = setupOnboarding({
      mode: 'upgrade',
      benchmark,
      localSettings: {
        performanceTier: 'quality',
        gpuBenchmarkResult: { tier: 'balanced' },
        benchmarkRunState: { status: 'idle' },
      },
    });
    getLocalSettings.mockResolvedValueOnce({
      performanceTier: 'quality',
      gpuBenchmarkResult: { tier: 'balanced' },
      benchmarkRunState: { status: 'idle' },
    }).mockResolvedValueOnce({
      performanceTier: 'quality',
      gpuBenchmarkResult: { tier: 'balanced' },
      benchmarkRunState: {
        status: 'failed',
        failureReason: 'validation',
        startedAt: 123,
        endedAt: 456,
        fallbackTierApplied: null,
      },
    });

    await loadOnboarding();
    document.getElementById('start-test')?.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    await vi.dynamicImportSettled();
    await flushPromises(12);

    expect(runGPUBenchmark).toHaveBeenCalledTimes(1);
    expect(saveLocalSettings).toHaveBeenCalledWith({
      gpuBenchmarkResult: null,
      benchmarkRunState: {
        status: 'failed',
        failureReason: 'validation',
        startedAt: 123,
        endedAt: 456,
        fallbackTierApplied: null,
      },
    });
  });

  it('fills a minimal failed state when an upgrade benchmark fails before persisting one', async () => {
    const benchmark = vi.fn().mockRejectedValue(new Error('WebGPU not supported'));
    const { saveLocalSettings } = setupOnboarding({
      mode: 'upgrade',
      benchmark,
      localSettings: {
        performanceTier: 'performance',
        gpuBenchmarkResult: { tier: 'performance' },
        benchmarkRunState: { status: 'idle' },
      },
    });

    await loadOnboarding();
    document.getElementById('start-test')?.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    await vi.dynamicImportSettled();
    await flushPromises(12);

    expect(saveLocalSettings).toHaveBeenCalledWith(expect.objectContaining({
      gpuBenchmarkResult: null,
      benchmarkRunState: expect.objectContaining({
        status: 'failed',
        fallbackTierApplied: null,
      }),
    }));
    expect(document.getElementById('progress-text')?.textContent).toBe('testFailed');
  });

  it('keeps the ordinary tier and benchmark result unchanged until a failed test is confirmed', async () => {
    const benchmark = vi.fn().mockRejectedValue(new Error('validation failure'));
    const { saveLocalSettings, runGPUBenchmark } = setupOnboarding({
      benchmark,
      localSettings: {
        performanceTier: 'quality',
        gpuBenchmarkResult: { tier: 'quality' },
        benchmarkRunState: { status: 'completed' },
      },
    });

    await loadOnboarding();
    document.getElementById('start-test')?.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    await vi.dynamicImportSettled();
    await flushPromises(12);

    expect(runGPUBenchmark).toHaveBeenCalledTimes(1);
    expect(saveLocalSettings).not.toHaveBeenCalled();
    expect(document.getElementById('progress-text')?.textContent).toBe('testFailedDefault');

    document.getElementById('confirm-tier')?.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    await flushPromises(4);

    expect(saveLocalSettings).toHaveBeenLastCalledWith({
      performanceTier: 'balanced',
      hasCompletedOnboarding: true,
    });
  });

  it('keeps ordinary skip pending and applies the default tier only on confirmation', async () => {
    const { saveLocalSettings } = setupOnboarding({
      localSettings: {
        performanceTier: 'ultra',
        gpuBenchmarkResult: { tier: 'ultra' },
        benchmarkRunState: { status: 'completed' },
      },
    });

    await loadOnboarding();
    document.getElementById('skip-test')?.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    await flushPromises(8);

    expect(saveLocalSettings).not.toHaveBeenCalled();
    expect(document.getElementById('result-desc')?.textContent).toBe('defaultTier');

    document.getElementById('confirm-tier')?.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    await flushPromises(4);

    expect(saveLocalSettings).toHaveBeenLastCalledWith({
      performanceTier: 'balanced',
      hasCompletedOnboarding: true,
    });
  });

  it('keeps the ordinary benchmark result pending while the selected tier waits for confirmation', async () => {
    const { saveLocalSettings } = setupOnboarding({
      localSettings: {
        performanceTier: 'quality',
        gpuBenchmarkResult: { tier: 'quality' },
        benchmarkRunState: { status: 'completed' },
      },
    });

    await loadOnboarding();
    document.getElementById('start-test')?.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    await vi.dynamicImportSettled();
    await flushPromises(12);

    expect(saveLocalSettings).toHaveBeenCalledTimes(1);
    expect(saveLocalSettings).toHaveBeenCalledWith({
      gpuBenchmarkResult: { tier: 'quality', frames: 120 },
    });
    expect(saveLocalSettings.mock.calls[0]?.[0]).not.toHaveProperty('performanceTier');

    const qualityButton = document.querySelector<HTMLButtonElement>('.tier-btn[data-tier="quality"]');
    qualityButton?.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    expect(document.getElementById('result-desc')?.textContent).toBe('manuallySelected');
  });

  it('keeps onboarding on the current step when completion save fails', async () => {
    const saveLocalSettings = vi.fn().mockRejectedValue(new Error('local save failed'));
    const { showNotice } = setupOnboarding({
      saveLocalSettings,
      localSettings: {
        performanceTier: 'balanced',
        benchmarkRunState: { status: 'idle' },
      },
    });

    await loadOnboarding();
    document.getElementById('confirm-tier')?.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    await flushPromises();

    expect(saveLocalSettings).toHaveBeenCalledWith({
      performanceTier: 'balanced',
      hasCompletedOnboarding: true,
    });
    expect(document.getElementById('step-3')?.classList.contains('active')).toBe(false);
    expect(showNotice).toHaveBeenCalledWith({ kind: 'error', message: 'saveFailed' });
  });
});
