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

async function totalOverlayCount(page: Page): Promise<number> {
  return page.evaluate(() => document.querySelectorAll('[data-anime4k-overlay-host]').length);
}

async function videoOverlaySlotCount(page: Page): Promise<number> {
  return page.evaluate(() => {
    const video = document.getElementById('fixture-video');
    if (!video) {
      return 0;
    }
    const slot = video.getAttribute('data-anime4k-overlay-slot');
    return slot
      ? document.querySelectorAll(`[data-anime4k-overlay-host][data-anime4k-overlay-slot="${slot}"]`).length
      : 0;
  });
}

async function orphanOverlayHostCount(page: Page): Promise<number> {
  return page.evaluate(() => {
    const videoSlots = new Set(
      Array.from(document.querySelectorAll('video[data-anime4k-overlay-slot]'))
        .map(video => video.getAttribute('data-anime4k-overlay-slot'))
        .filter(Boolean),
    );
    return Array.from(document.querySelectorAll('[data-anime4k-overlay-host]'))
      .filter(host => {
        const slot = host.getAttribute('data-anime4k-overlay-slot');
        return !slot || !videoSlots.has(slot);
      })
      .length;
  });
}

async function bodyStrategyOverlayCount(page: Page): Promise<number> {
  return page.evaluate(() => document.body.querySelectorAll(':scope > [data-anime4k-overlay-host]').length);
}

async function transformedOverlayMetrics(page: Page): Promise<{
  hostTransform: string;
  videoTransform: string;
  widthDelta: number;
  heightDelta: number;
  leftDelta: number;
  topDelta: number;
}> {
  return page.evaluate(() => {
    const video = document.getElementById('fixture-video') as HTMLVideoElement | null;
    const host = document.querySelector('[data-anime4k-overlay-host]') as HTMLElement | null;
    if (!video || !host) {
      throw new Error('Missing transformed scenario video or overlay host.');
    }
    const videoRect = video.getBoundingClientRect();
    const hostRect = host.getBoundingClientRect();
    return {
      hostTransform: host.style.transform,
      videoTransform: getComputedStyle(video).transform,
      widthDelta: Math.abs(hostRect.width - videoRect.width),
      heightDelta: Math.abs(hostRect.height - videoRect.height),
      leftDelta: Math.abs(hostRect.left - videoRect.left),
      topDelta: Math.abs(hostRect.top - videoRect.top),
    };
  });
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

async function overlayButtonState(page: Page): Promise<string | null> {
  return page.locator('[data-anime4k-overlay-host]').first().getAttribute('data-anime4k-button-state');
}

async function expectSingleOverlayForFixtureVideo(page: Page): Promise<void> {
  await expect.poll(async () => totalOverlayCount(page)).toBe(1);
  await expect.poll(async () => videoOverlaySlotCount(page)).toBe(1);
  await expect.poll(async () => orphanOverlayHostCount(page)).toBe(0);
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

test('@site keeps delayed initial reveal and uses a click-through geometric wake region', async ({
  context,
  siteServer,
}) => {
  const page = await context.newPage();
  await page.goto(siteServer.scenarioUrl('youtube-like-delayed-layout'));

  await expectOverlayVisible(page);
  await expect.poll(async () => overlayButtonState(page)).toBe('unrenderable');
  await page.waitForTimeout(3200);
  expect(await overlayButtonState(page)).toBe('unrenderable');

  await expect.poll(async () => overlayButtonState(page)).toBe('visible');
  await page.waitForTimeout(2500);
  expect(await overlayButtonState(page)).toBe('visible');
  await expect.poll(async () => overlayButtonState(page)).toBe('hidden');

  const player = page.locator('#youtube-like-player');
  const controls = page.locator('#youtube-like-control-layer');
  const playerBox = await player.boundingBox();
  expect(playerBox).not.toBeNull();
  const wakeX = playerBox!.x + 72;
  const wakeY = playerBox!.y + playerBox!.height / 2;
  const outsideX = playerBox!.x + playerBox!.width - 20;
  const outsideY = playerBox!.y + 20;

  const hiddenBeforeClick = await player.screenshot();
  await page.mouse.click(wakeX, wakeY);
  await page.mouse.move(outsideX, outsideY);
  await expect(controls).toHaveAttribute('data-click-count', '1');
  const hiddenAfterClick = await player.screenshot();
  expect(hiddenAfterClick.equals(hiddenBeforeClick)).toBe(true);
  expect(await overlayButtonState(page)).toBe('hidden');

  await page.mouse.move(wakeX, wakeY);
  await page.waitForTimeout(100);
  await page.mouse.move(outsideX, outsideY);
  await page.waitForTimeout(180);
  expect(await overlayButtonState(page)).toBe('hidden');

  await page.mouse.move(wakeX, wakeY);
  await page.waitForTimeout(120);
  await page.mouse.move(wakeX + 20, wakeY + 20);
  await expect.poll(async () => overlayButtonState(page)).toBe('visible');
});

test('@site injects into nested iframe video pages', async ({ context, siteServer }) => {
  const scenario = getSiteScenario('iframe-video');
  const page = await context.newPage();
  await page.goto(siteServer.scenarioUrl('iframe-video'));

  await expectOverlayVisible(page.frameLocator(scenario.frameSelector!));
});

test('@site keeps one overlay across source swaps and video remounts', async ({ context, siteServer }) => {
  const page = await context.newPage();
  await page.goto(siteServer.scenarioUrl('source-swap-remount'));
  await expectSingleOverlayForFixtureVideo(page);

  await page.locator('#swap-source').click();
  await expectSingleOverlayForFixtureVideo(page);

  await page.locator('#move-video').click();
  await expectSingleOverlayForFixtureVideo(page);
});

test('@site keeps overlay geometry aligned with transformed videos', async ({ context, siteServer }) => {
  const page = await context.newPage();
  await page.goto(siteServer.scenarioUrl('transformed-video'));
  await expectSingleOverlayForFixtureVideo(page);

  await expect.poll(async () => {
    const metrics = await transformedOverlayMetrics(page);
    return metrics.hostTransform === metrics.videoTransform
      && metrics.hostTransform !== 'none'
      && metrics.widthDelta < 1
      && metrics.heightDelta < 1
      && metrics.leftDelta < 1
      && metrics.topDelta < 1;
  }).toBe(true);
});

test('@site moves an obscured overlay host to body strategy without duplicating it', async ({ context, siteServer }) => {
  const page = await context.newPage();
  await page.goto(siteServer.scenarioUrl('obscured-controls'));

  await expectSingleOverlayForFixtureVideo(page);
  await expect.poll(async () => bodyStrategyOverlayCount(page)).toBe(1);
});

test('@site keeps one overlay when a video enters fullscreen', async ({ context, siteServer }) => {
  const page = await context.newPage();
  await page.goto(siteServer.scenarioUrl('fullscreen-video'));
  await expectSingleOverlayForFixtureVideo(page);

  await page.locator('#enter-fullscreen').click();
  await page.waitForFunction(() => (
    Boolean(document.fullscreenElement)
    || document.getElementById('fullscreen-shell')?.getAttribute('data-fullscreen-result') === 'failed'
  ), null, { timeout: 5000 });
  const entered = await page.evaluate(() => Boolean(document.fullscreenElement));
  test.skip(!entered, 'Fullscreen API and synthetic fullscreen shim are unavailable in this browser.');

  await expectSingleOverlayForFixtureVideo(page);
  await expect.poll(async () => page.evaluate(() => {
    const shell = document.getElementById('fullscreen-shell');
    const host = document.querySelector('[data-anime4k-overlay-host]');
    return Boolean(shell && host && host.parentElement === shell);
  })).toBe(true);
});
