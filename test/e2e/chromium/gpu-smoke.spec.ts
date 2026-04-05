import { expect, test } from './fixtures';

test.describe('gpu smoke', () => {
  test.skip(!process.env.RUN_GPU_TESTS, 'GPU smoke tests are opt-in.');

  test('@gpu-smoke opens onboarding benchmark flow', async ({ extensionApp, context, extensionId }, testInfo) => {
    test.setTimeout(180_000);
    const probe = await extensionApp.probeWebGpu();
    testInfo.annotations.push({
      type: 'webgpu-adapter',
      description: probe.summary,
    });
    test.skip(!probe.available, `Skipping WebGPU smoke: ${probe.summary}.`);
    test.skip(probe.isSoftwareAdapter, `Skipping WebGPU smoke on software adapter: ${probe.summary}.`);

    const page = await context.newPage();
    await page.goto(`chrome-extension://${extensionId}/onboarding.html`);
    await page.locator('#start-test').click();

    await expect(page.locator('#progress-container')).toBeVisible();
    await expect.poll(async () => page.locator('#step-2.active').count(), {
      timeout: 150_000,
    }).toBe(1);
  });

  test('@gpu-benchmark reaches the benchmark result step', async ({ extensionApp, context, extensionId }, testInfo) => {
    test.setTimeout(180_000);
    const probe = await extensionApp.probeWebGpu();
    testInfo.annotations.push({
      type: 'webgpu-adapter',
      description: probe.summary,
    });
    test.skip(!probe.available, `Skipping WebGPU benchmark: ${probe.summary}.`);
    test.skip(probe.isSoftwareAdapter, `Skipping WebGPU benchmark on software adapter: ${probe.summary}.`);

    const page = await context.newPage();
    await page.goto(`chrome-extension://${extensionId}/onboarding.html`);
    await page.locator('#start-test').click();

    await expect.poll(async () => page.locator('#result-tier').textContent(), {
      timeout: 150_000,
    }).not.toBeNull();
  });
});
