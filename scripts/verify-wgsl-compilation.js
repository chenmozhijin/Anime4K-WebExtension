const fs = require('node:fs');
const path = require('node:path');
const { chromium } = require('@playwright/test');
const { startStaticServer } = require('./verify/lib/static-server');

const repoRoot = path.resolve(__dirname, '..');
const filterIndex = process.argv.indexOf('--filter');
const filter = filterIndex >= 0 ? process.argv[filterIndex + 1].toLowerCase() : null;
const outputIndex = process.argv.indexOf('--output');
const output = outputIndex >= 0 ? process.argv[outputIndex + 1] : null;
const quiet = process.argv.includes('--quiet');

function collectWgsl(root) {
  const files = [];
  const stack = [root];
  while (stack.length > 0) {
    const current = stack.pop();
    for (const entry of fs.readdirSync(current, { withFileTypes: true })) {
      const fullPath = path.join(current, entry.name);
      if (entry.isDirectory()) stack.push(fullPath);
      else if (entry.isFile() && entry.name.endsWith('.wgsl')) files.push(fullPath);
    }
  }
  return files.sort();
}

async function main() {
  const files = collectWgsl(path.join(repoRoot, 'src'))
    .filter(file => !filter || file.toLowerCase().includes(filter));
  if (files.length === 0) throw new Error('No WGSL files matched.');
  const server = await startStaticServer(path.join(repoRoot, 'test', 'verify', 'browser'));
  let browser;
  try {
    browser = await chromium.launch({ channel: 'chromium', headless: true, args: ['--enable-unsafe-webgpu'] });
  } catch {
    browser = await chromium.launch({ headless: true, args: ['--enable-unsafe-webgpu'] });
  }
  try {
    const page = await browser.newPage();
    await page.goto(server.url);
    await page.evaluate(async () => {
      const adapter = await navigator.gpu?.requestAdapter();
      if (!adapter) throw new Error('WebGPU adapter unavailable.');
      window.__wgslValidationDevice = await adapter.requestDevice();
    });
    const results = [];
    for (const file of files) {
      const code = fs.readFileSync(file, 'utf8');
      const messages = await page.evaluate(async ({ code, label }) => {
        const device = window.__wgslValidationDevice;
        const module = device.createShaderModule({ label, code });
        const info = await module.getCompilationInfo();
        return info.messages.map(message => ({
          type: message.type,
          message: message.message,
          lineNum: message.lineNum,
          linePos: message.linePos,
        }));
      }, { code, label: path.relative(repoRoot, file) });
      results.push({
        file: path.relative(repoRoot, file).replace(/\\/g, '/'),
        messages,
        passed: !messages.some(message => message.type === 'error'),
      });
    }
    const report = {
      schemaVersion: 1,
      generatedAt: new Date().toISOString(),
      filter,
      fileCount: results.length,
      failureCount: results.filter(result => !result.passed).length,
      results,
    };
    const json = `${JSON.stringify(report, null, 2)}\n`;
    if (output) {
      const outputPath = path.resolve(repoRoot, output);
      fs.mkdirSync(path.dirname(outputPath), { recursive: true });
      fs.writeFileSync(outputPath, json);
    }
    process.stdout.write(quiet
      ? `${JSON.stringify({ fileCount: report.fileCount, failureCount: report.failureCount })}\n`
      : json);
    if (report.failureCount > 0) process.exitCode = 1;
    await page.evaluate(() => window.__wgslValidationDevice.destroy());
  } finally {
    await browser.close();
    await server.close();
  }
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
