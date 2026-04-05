import path from 'node:path';
import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: path.join(__dirname, 'test/e2e/chromium'),
  outputDir: path.join(__dirname, 'test-results/playwright'),
  timeout: 60_000,
  expect: {
    timeout: 10_000,
  },
  fullyParallel: false,
  retries: process.env.CI ? 2 : 0,
  reporter: process.env.CI ? [['github'], ['html', { open: 'never' }]] : 'list',
  use: {
    headless: true,
    trace: 'retain-on-failure',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },
});
