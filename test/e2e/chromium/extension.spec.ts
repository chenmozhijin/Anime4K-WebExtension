import { expect, test } from './fixtures';
import type { Page } from '@playwright/test';

test('@smoke loads popup, options and onboarding pages', async ({ extensionApp }) => {
  const popupPage = await extensionApp.openPopup();
  await popupPage.expectLoaded();

  const optionsPage = await extensionApp.openOptions();
  await optionsPage.expectLoaded();
  await optionsPage.openSection('modes');
  await expect(optionsPage.page.locator('#modes-container')).toBeVisible();

  const onboardingPage = await extensionApp.openOnboarding();
  await onboardingPage.expectLoaded();
});

test('@smoke syncs custom modes from options into popup', async ({ extensionApp }) => {
  const optionsPage = await extensionApp.openOptions();
  await optionsPage.openSection('modes');
  await optionsPage.addMode();
  await expect(optionsPage.page.locator('#modes-container .mode-card[data-mode-id^="custom-"]')).toHaveCount(1);

  const popupPage = await extensionApp.openPopup();
  const customOption = popupPage.page.locator('#mode-select option[value^="custom-"]');
  await expect(customOption).toHaveCount(1);

  const customModeId = await customOption.first().getAttribute('value');
  expect(customModeId).toBeTruthy();

  await popupPage.selectMode(customModeId!);
  await expect(popupPage.page.locator('.tier-btn').first()).toBeDisabled();
});

test('@smoke offers compatibility-mode migration in the upgrade onboarding flow', async ({ extensionApp }) => {
  await extensionApp.setStorage({
    sync: {
      selectedModeId: 'builtin-mode-a',
    },
    local: {
      performanceTier: 'quality',
      gpuBenchmarkResult: {
        tier: 'quality',
        scores: {},
        maxScores: {},
        timestamp: 1,
        adapterInfo: 'test adapter',
      },
      benchmarkRunState: {
        status: 'completed',
      },
    },
  });

  const onboardingPage = await extensionApp.openOnboarding('upgrade');
  await onboardingPage.page.setViewportSize({ width: 1280, height: 900 });
  await expect(onboardingPage.page.locator('#step-indicator .step')).toHaveCount(4);
  await expect(onboardingPage.page.locator('#onboarding-title')).not.toHaveText('welcomeTitle');
  expect(await hasNoHorizontalOverflow(onboardingPage.page)).toBe(true);

  await onboardingPage.page.setViewportSize({ width: 360, height: 900 });
  await onboardingPage.page.locator('#skip-test').click();
  await expect(onboardingPage.page.locator('#step-2')).toHaveClass(/active/);
  await onboardingPage.page.locator('#confirm-tier').click();
  await expect(onboardingPage.page.locator('#step-mode-migration')).toBeVisible();
  await expect(onboardingPage.page.locator('#mode-migration-options input[type="radio"]')).toHaveCount(3);
  await expect(onboardingPage.page.locator('#mode-migration-recommended-detail-preserving')).toBeChecked();
  expect(await hasNoHorizontalOverflow(onboardingPage.page)).toBe(true);
  expect(await modeOptionsAvoidButtons(onboardingPage.page)).toBe(true);

  await onboardingPage.page.locator('#mode-migration-recommended-soft-style').check();
  await onboardingPage.page.locator('#apply-mode-migration').click();
  await expect(onboardingPage.page.locator('#step-3')).toHaveClass(/active/);

  const persistedSettings = await onboardingPage.page.evaluate(async () => {
    const [sync, local] = await Promise.all([
      chrome.storage.sync.get(['selectedModeId']),
      chrome.storage.local.get(['performanceTier', 'hasCompletedOnboarding']),
    ]);
    return { sync, local };
  });
  expect(persistedSettings.sync.selectedModeId).toBe('recommended-soft-style');
  expect(persistedSettings.local.performanceTier).toBe('quality');
  expect(persistedSettings.local.hasCompletedOnboarding).toBe(true);

  await onboardingPage.page.close();
});

async function hasNoHorizontalOverflow(page: Page): Promise<boolean> {
  return page.evaluate(() => document.documentElement.scrollWidth <= window.innerWidth + 1);
}

async function modeOptionsAvoidButtons(page: Page): Promise<boolean> {
  return page.evaluate(() => {
    const options = document.getElementById('mode-migration-options')?.getBoundingClientRect();
    const buttons = document.querySelector('#step-mode-migration .button-group')?.getBoundingClientRect();
    return Boolean(options && buttons && options.bottom <= buttons.top + 1);
  });
}
