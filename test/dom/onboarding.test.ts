import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { describe, expect, it, vi } from 'vitest';
import { flushPromises } from '../support/async';
import { installChromeMock } from '../support/chrome';

const onboardingHtml = readFileSync(resolve(process.cwd(), 'src/ui/onboarding/onboarding.html'), 'utf8');

function setDocumentFromHtml(html: string): void {
  const body = html.match(/<body[^>]*>([\s\S]*)<\/body>/i)?.[1] ?? html;
  document.body.innerHTML = body;
}

describe('onboarding UI', () => {
  it('runs the benchmark flow, confirms the tier, and opens options on completion', async () => {
    setDocumentFromHtml(onboardingHtml);
    const chromeMock = installChromeMock();
    const saveLocalSettings = vi.fn().mockResolvedValue(undefined);
    const showNotice = vi.fn(() => document.createElement('div'));
    const runGPUBenchmark = vi.fn(async (onProgress: (progress: any) => void) => {
      onProgress({ progress: 0.25, tier: 'balanced', completed: false });
      onProgress({ progress: 1, tier: 'quality', completed: true });
      return { tier: 'quality', frames: 120 };
    });
    const closeSpy = vi.spyOn(window, 'close').mockImplementation(() => undefined);

    vi.doMock('../../src/utils/settings', () => ({
      saveLocalSettings,
      getLocalSettings: vi.fn().mockResolvedValue({
        performanceTier: 'balanced',
        benchmarkRunState: { status: 'interrupted' },
      }),
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

    await import('../../src/ui/onboarding/onboarding');
    document.dispatchEvent(new Event('DOMContentLoaded'));
    await flushPromises(8);

    expect(showNotice).toHaveBeenCalledWith(expect.objectContaining({
      kind: 'warning',
    }));

    document.getElementById('start-test')?.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    await vi.dynamicImportSettled();
    await flushPromises(12);

    expect(runGPUBenchmark).toHaveBeenCalledTimes(1);
    expect(saveLocalSettings).toHaveBeenCalledWith({
      performanceTier: 'quality',
      gpuBenchmarkResult: { tier: 'quality', frames: 120 },
    });
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

  it('keeps onboarding on the current step when completion save fails', async () => {
    setDocumentFromHtml(onboardingHtml);
    const chromeMock = installChromeMock();
    const saveLocalSettings = vi.fn().mockRejectedValue(new Error('local save failed'));
    const showNotice = vi.fn(() => document.createElement('div'));

    vi.doMock('../../src/utils/settings', () => ({
      saveLocalSettings,
      getLocalSettings: vi.fn().mockResolvedValue({
        performanceTier: 'balanced',
        benchmarkRunState: { status: 'idle' },
      }),
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

    await import('../../src/ui/onboarding/onboarding');
    document.dispatchEvent(new Event('DOMContentLoaded'));
    await flushPromises(8);

    document.getElementById('confirm-tier')?.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    await flushPromises();

    expect(saveLocalSettings).toHaveBeenCalledWith({
      performanceTier: 'balanced',
      hasCompletedOnboarding: true,
    });
    expect(chromeMock.__mock.runtimeMessages).not.toContainEqual({ type: 'SETTINGS_UPDATED' });
    expect(document.getElementById('step-3')?.classList.contains('active')).toBe(false);
    expect(showNotice).toHaveBeenCalledWith({ kind: 'error', message: 'saveFailed' });
  });
});
