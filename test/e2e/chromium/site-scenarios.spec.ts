import type { FrameLocator, Page } from '@playwright/test';
import { expect, test } from './fixtures';
import { getSiteScenario } from '../sites/scenarios';

function overlayLocator(target: Page | FrameLocator) {
  return target.locator('[data-anime4k-overlay-host]');
}

async function shadowOverlayCount(page: Page): Promise<number> {
  return page.evaluate(() => {
    const host = document.getElementById('shadow-host');
    return host?.shadowRoot?.querySelectorAll('[data-anime4k-overlay-host]').length ?? 0;
  });
}

async function bodyOverlayCount(page: Page): Promise<number> {
  return page.evaluate(() => document.body.querySelectorAll(':scope > [data-anime4k-overlay-host]').length);
}

function whitelistPatternFor(url: string, suffix: '*' | '' = '*'): string {
  const parsedUrl = new URL(url);
  return `${parsedUrl.hostname}${parsedUrl.pathname}${suffix}`;
}

async function expectOverlayVisible(target: Page | FrameLocator): Promise<void> {
  await expect.poll(async () => overlayLocator(target).count()).toBeGreaterThan(0);
}

async function expectOverlayHidden(target: Page | FrameLocator): Promise<void> {
  await expect.poll(async () => overlayLocator(target).count()).toBe(0);
}

async function expectShadowOverlayVisible(page: Page): Promise<void> {
  await expect.poll(async () => shadowOverlayCount(page)).toBeGreaterThan(0);
  await expect.poll(async () => bodyOverlayCount(page)).toBe(0);
}

async function expectShadowOverlayHidden(page: Page): Promise<void> {
  await expect.poll(async () => shadowOverlayCount(page)).toBe(0);
  await expect.poll(async () => bodyOverlayCount(page)).toBe(0);
}

test('@smoke @site activates on a plain HTML5 page and reacts to whitelist changes', async ({
  context,
  extensionApp,
  siteServer,
}) => {
  const page = await context.newPage();
  await page.goto(siteServer.scenarioUrl('plain-html5'));
  await expectOverlayVisible(page);

  await extensionApp.setStorage({
    sync: {
      whitelistEnabled: true,
      whitelist: [{ pattern: 'example.com/*', enabled: true }],
    },
  });
  await expectOverlayHidden(page);

  await extensionApp.setStorage({
    sync: {
      whitelistEnabled: true,
      whitelist: [{ pattern: whitelistPatternFor(page.url()), enabled: true }],
    },
  });
  await expectOverlayVisible(page);
});

test('@smoke @site re-evaluates whitelist state on SPA navigation', async ({
  context,
  extensionApp,
  siteServer,
}) => {
  const scenario = getSiteScenario('spa-route');
  await extensionApp.setStorage({
    sync: {
      whitelistEnabled: true,
      whitelist: [{ pattern: '127.0.0.1/sites/spa-route/allowed*', enabled: true }],
    },
  });

  const page = await context.newPage();
  await page.goto(`${siteServer.baseUrl}${scenario.path}`);
  await expectOverlayVisible(page);

  await page.locator('#navigate-disallowed').click();
  await expect(page).toHaveURL(/\/sites\/spa-route\/disallowed$/);
  await expectOverlayHidden(page);
});

test('@smoke @site discovers videos rendered inside open shadow DOM and reacts to whitelist changes', async ({
  context,
  extensionApp,
  siteServer,
}) => {
  const page = await context.newPage();
  await page.goto(siteServer.scenarioUrl('shadow-dom'));
  await expectShadowOverlayVisible(page);

  await extensionApp.setStorage({
    sync: {
      whitelistEnabled: true,
      whitelist: [{ pattern: 'example.com/*', enabled: true }],
    },
  });
  await expectShadowOverlayHidden(page);

  await extensionApp.setStorage({
    sync: {
      whitelistEnabled: true,
      whitelist: [{ pattern: whitelistPatternFor(page.url()), enabled: true }],
    },
  });
  await expectShadowOverlayVisible(page);
});

test('@site discovers videos inserted after initial page load', async ({ context, siteServer }) => {
  const page = await context.newPage();
  await page.goto(siteServer.scenarioUrl('delayed-video'));

  await expectOverlayVisible(page);
});

test('@site injects into nested iframe video pages', async ({ context, siteServer }) => {
  const scenario = getSiteScenario('iframe-video');
  const page = await context.newPage();
  await page.goto(siteServer.scenarioUrl('iframe-video'));

  await expectOverlayVisible(page.frameLocator(scenario.frameSelector!));
});
