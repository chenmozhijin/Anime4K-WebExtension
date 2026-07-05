const http = require('node:http');
const { chromium } = require('@playwright/test');

function startProbeServer() {
  const server = http.createServer((_req, res) => {
    res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
    res.end('<!doctype html><title>WebGPU probe</title>');
  });
  return new Promise(resolve => {
    server.listen(0, '127.0.0.1', () => {
      const address = server.address();
      const port = typeof address === 'object' && address ? address.port : 0;
      resolve({
        url: `http://127.0.0.1:${port}`,
        close: () => new Promise((closeResolve, reject) => {
          server.close(error => (error ? reject(error) : closeResolve()));
        }),
      });
    });
  });
}

async function probeWebGpu() {
  let browser = null;
  let server = null;
  try {
    server = await startProbeServer();
    try {
      browser = await chromium.launch({
        channel: 'chromium',
        headless: true,
        args: ['--enable-unsafe-webgpu', '--enable-features=Vulkan,WebGPUDeveloperFeatures'],
      });
    } catch {
      browser = await chromium.launch({
        headless: true,
        args: ['--enable-unsafe-webgpu', '--enable-features=Vulkan,WebGPUDeveloperFeatures'],
      });
    }
    const page = await browser.newPage();
    await page.goto(server.url);
    const result = await page.evaluate(async () => {
      if (!navigator.gpu) return { available: false, summary: 'navigator.gpu is not available.' };
      const adapter = await navigator.gpu.requestAdapter();
      if (!adapter) return { available: false, summary: 'No WebGPU adapter.' };
      return { available: true, summary: 'WebGPU adapter is available.' };
    });
    await browser.close();
    await server.close();
    return result;
  } catch (error) {
    if (browser) await browser.close().catch(() => {});
    if (server) await server.close().catch(() => {});
    return { available: false, summary: error instanceof Error ? error.message : String(error) };
  }
}

async function main() {
  let ok = true;
  console.log('Effect verification environment');

  try {
    require.resolve('@playwright/test');
    console.log('[ok] Playwright package is installed.');
  } catch {
    ok = false;
    console.log('[missing] Playwright package is not installed.');
  }

  const webgpu = await probeWebGpu();
  if (webgpu.available) {
    console.log(`[ok] WebGPU: ${webgpu.summary}`);
  } else {
    ok = false;
    console.log(`[missing] WebGPU: ${webgpu.summary}`);
  }

  process.exitCode = ok ? 0 : 1;
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
