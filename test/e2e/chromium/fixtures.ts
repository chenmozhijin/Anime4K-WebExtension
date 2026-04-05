import http from 'node:http';
import type net from 'node:net';
import path from 'node:path';
import { chromium, expect, test as base } from '@playwright/test';
import { ExtensionApp } from './page-objects/extension-app';
import { getSiteScenario, resolveScenarioRoute } from '../sites/scenarios';

const extensionPath = path.resolve(__dirname, '../../../dist-chrome');

type SiteServer = {
  baseUrl: string;
  scenarioUrl: (scenarioId: string) => string;
};

type ExtensionFixtures = {
  extensionId: string;
  extensionApp: ExtensionApp;
  siteServer: SiteServer;
};

export const test = base.extend<ExtensionFixtures>({
  context: async ({}, use, testInfo) => {
    const userDataDir = testInfo.outputPath('chromium-user-data');
    const chromiumArgs = [
      `--disable-extensions-except=${extensionPath}`,
      `--load-extension=${extensionPath}`,
    ];
    if (process.env.RUN_GPU_TESTS) {
      chromiumArgs.unshift('--enable-unsafe-webgpu');
    }
    const context = await chromium.launchPersistentContext(userDataDir, {
      channel: 'chromium',
      headless: true,
      args: chromiumArgs,
    });

    await use(context);
    await context.close();
  },
  extensionId: async ({ context }, use) => {
    let [serviceWorker] = context.serviceWorkers();
    if (!serviceWorker) {
      serviceWorker = await context.waitForEvent('serviceworker');
    }

    await use(new URL(serviceWorker.url()).host);
  },
  extensionApp: async ({ context, extensionId }, use) => {
    const extensionApp = new ExtensionApp(context, extensionId);
    await extensionApp.resetStorage();
    await use(extensionApp);
  },
  siteServer: async ({}, use) => {
    const sockets = new Set<net.Socket>();
    const server = http.createServer((req, res) => {
      const requestUrl = new URL(req.url ?? '/', 'http://127.0.0.1');
      const route = resolveScenarioRoute(requestUrl.pathname);
      if (!route) {
        res.writeHead(404, { 'Content-Type': 'text/plain; charset=utf-8' });
        res.end('Not found');
        return;
      }

      res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
      res.end(route.html);
    });
    server.on('connection', socket => {
      sockets.add(socket);
      socket.on('close', () => {
        sockets.delete(socket);
      });
    });

    await new Promise<void>(resolve => server.listen(0, '127.0.0.1', () => resolve()));
    const address = server.address();
    const port = typeof address === 'object' && address ? address.port : 0;
    const baseUrl = `http://127.0.0.1:${port}`;

    await use({
      baseUrl,
      scenarioUrl: (scenarioId: string) => `${baseUrl}${getSiteScenario(scenarioId).path}`,
    });
    sockets.forEach(socket => socket.destroy());
    await new Promise<void>((resolve, reject) => server.close(error => (error ? reject(error) : resolve())));
  },
});

export { expect };
