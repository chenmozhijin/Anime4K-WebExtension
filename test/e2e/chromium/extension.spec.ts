import { expect, test } from './fixtures';

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
