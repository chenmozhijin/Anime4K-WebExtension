const fs = require('node:fs');
const path = require('node:path');
const { repoRoot } = require('./verify/lib/manifest');
const { createBuiltInFixtures } = require('./verify/lib/fixtures');

const defaultRoot = path.join(repoRoot, 'test-results', 'verify', 'effects');
const supportedValidationModes = new Set(['luma-math', 'rgb-math']);
const diagnosticFixtureIds = new Set(
  createBuiltInFixtures()
    .filter(fixture => fixture.diagnosticOnly)
    .map(fixture => fixture.id),
);

function parseArgs(argv) {
  const args = {
    root: defaultRoot,
    format: 'markdown',
    output: null,
    since: null,
    runId: null,
    includeDiagnostic: false,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === '--root') args.root = path.resolve(argv[++index]);
    else if (arg.startsWith('--root=')) args.root = path.resolve(arg.slice('--root='.length));
    else if (arg === '--format') args.format = argv[++index];
    else if (arg.startsWith('--format=')) args.format = arg.slice('--format='.length);
    else if (arg === '--output') args.output = path.resolve(argv[++index]);
    else if (arg.startsWith('--output=')) args.output = path.resolve(arg.slice('--output='.length));
    else if (arg === '--since') args.since = parseDate(argv[++index], '--since');
    else if (arg.startsWith('--since=')) args.since = parseDate(arg.slice('--since='.length), '--since');
    else if (arg === '--run-id') args.runId = argv[++index];
    else if (arg.startsWith('--run-id=')) args.runId = arg.slice('--run-id='.length);
    else if (arg === '--include-diagnostic') args.includeDiagnostic = true;
    else throw new Error(`Unknown verify:report option: ${arg}`);
  }
  if (args.format !== 'markdown' && args.format !== 'json') {
    throw new Error('--format must be markdown or json.');
  }
  return args;
}

function parseDate(value, name) {
  const timestamp = Date.parse(value);
  if (!Number.isFinite(timestamp)) {
    throw new Error(`${name} must be a valid date or ISO timestamp.`);
  }
  return new Date(timestamp);
}

function walkMetrics(root) {
  if (!fs.existsSync(root)) return [];
  const metrics = [];
  const stack = [root];
  while (stack.length > 0) {
    const current = stack.pop();
    for (const entry of fs.readdirSync(current, { withFileTypes: true })) {
      const fullPath = path.join(current, entry.name);
      if (entry.isDirectory()) {
        stack.push(fullPath);
      } else if (entry.isFile() && entry.name === 'metrics.json') {
        metrics.push(fullPath);
      }
    }
  }
  return metrics.sort();
}

function toBackend(effectId) {
  return String(effectId).split('/')[0] || 'unknown';
}

function fixtureBaseId(fixtureId) {
  return String(fixtureId).replace(/_\d+x\d+$/, '');
}

function loadReport(root, options = {}) {
  const files = walkMetrics(root);
  const skipped = [];
  const skippedBeforeSince = [];
  const skippedDiagnostic = [];
  const skippedRunId = [];
  const cases = [];
  for (const metricsPath of files) {
    const modifiedAt = fs.statSync(metricsPath).mtime;
    if (options.since && modifiedAt < options.since) {
      skippedBeforeSince.push({ metricsPath, modifiedAt: modifiedAt.toISOString() });
      continue;
    }
    const metrics = JSON.parse(fs.readFileSync(metricsPath, 'utf8'));
    if (options.runId && metrics.runId !== options.runId) {
      skippedRunId.push({
        metricsPath,
        runId: metrics.runId ?? null,
        effectId: metrics.effectId ?? null,
        fixtureId: metrics.fixtureId ?? null,
      });
      continue;
    }
    if (!options.includeDiagnostic && diagnosticFixtureIds.has(fixtureBaseId(metrics.fixtureId))) {
      skippedDiagnostic.push({
        metricsPath,
        effectId: metrics.effectId ?? null,
        fixtureId: metrics.fixtureId ?? null,
      });
      continue;
    }
    if (!supportedValidationModes.has(metrics.validationMode)) {
      skipped.push({
        metricsPath,
        validationMode: metrics.validationMode ?? null,
        effectId: metrics.effectId ?? null,
        fixtureId: metrics.fixtureId ?? null,
      });
      continue;
    }
    cases.push({
      runId: metrics.runId ?? null,
      backendId: toBackend(metrics.effectId),
      effectId: metrics.effectId,
      fixtureId: metrics.fixtureId,
      validationMode: metrics.validationMode,
      passed: Boolean(metrics.passed),
      meanAbs: metrics.meanAbs ?? null,
      maxAbs: metrics.maxAbs ?? null,
      timings: metrics.timings ?? null,
      reason: metrics.reason ?? null,
      metricsPath,
      artifact: path.dirname(metricsPath),
    });
  }
  const byBackend = new Map();
  for (const item of cases) {
    const existing = byBackend.get(item.backendId) ?? {
      backendId: item.backendId,
      caseCount: 0,
      passedCount: 0,
      failedCount: 0,
      totalMs: 0,
    };
    existing.caseCount += 1;
    if (item.passed) existing.passedCount += 1;
    else existing.failedCount += 1;
    existing.totalMs += item.timings?.totalMs ?? 0;
    byBackend.set(item.backendId, existing);
  }
  return {
    generatedAt: new Date().toISOString(),
    root,
    since: options.since ? options.since.toISOString() : null,
    runId: options.runId ?? null,
    includeDiagnostic: Boolean(options.includeDiagnostic),
    caseCount: cases.length,
    skippedCount: skipped.length,
    skippedBeforeSinceCount: skippedBeforeSince.length,
    skippedDiagnosticCount: skippedDiagnostic.length,
    skippedRunIdCount: skippedRunId.length,
    failureCount: cases.filter(item => !item.passed).length,
    backends: [...byBackend.values()].sort((a, b) => a.backendId.localeCompare(b.backendId)),
    cases,
    skipped,
    skippedBeforeSince,
    skippedDiagnostic,
    skippedRunId,
  };
}

function formatNumber(value) {
  return typeof value === 'number' ? value.toFixed(6) : '';
}

function renderMarkdown(report) {
  const lines = [
    '# Effect Verification Report',
    '',
    `- Generated: ${report.generatedAt}`,
    `- Root: ${report.root}`,
    `- Since: ${report.since ?? ''}`,
    `- Run ID filter: ${report.runId ?? ''}`,
    `- Include diagnostic fixtures: ${report.includeDiagnostic ? 'yes' : 'no'}`,
    `- Cases: ${report.caseCount}`,
    `- Skipped stale/unsupported metrics: ${report.skippedCount ?? 0}`,
    `- Skipped before since: ${report.skippedBeforeSinceCount ?? 0}`,
    `- Skipped diagnostic fixtures: ${report.skippedDiagnosticCount ?? 0}`,
    `- Skipped by run ID: ${report.skippedRunIdCount ?? 0}`,
    `- Failures: ${report.failureCount}`,
    '',
    '## Backends',
    '',
    '| Backend | Cases | Passed | Failed | Total ms |',
    '| --- | ---: | ---: | ---: | ---: |',
    ...report.backends.map(backend => `| ${backend.backendId} | ${backend.caseCount} | ${backend.passedCount} | ${backend.failedCount} | ${backend.totalMs} |`),
    '',
    '## Cases',
    '',
    '| Status | Backend | Effect | Fixture | Mode | Mean Abs | Max Abs | Total ms | Reason |',
    '| --- | --- | --- | --- | --- | ---: | ---: | ---: | --- |',
    ...report.cases.map(item => [
      item.passed ? 'PASS' : 'FAIL',
      item.backendId,
      item.effectId,
      item.fixtureId,
      item.validationMode,
      formatNumber(item.meanAbs),
      formatNumber(item.maxAbs),
      item.timings?.totalMs ?? '',
      item.reason ?? '',
    ].map(value => String(value).replace(/\|/g, '\\|')).join(' | ')).map(row => `| ${row} |`),
    '',
  ];
  return lines.join('\n');
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  const report = loadReport(args.root, {
    since: args.since,
    runId: args.runId,
    includeDiagnostic: args.includeDiagnostic,
  });
  const output = args.format === 'json'
    ? `${JSON.stringify(report, null, 2)}\n`
    : renderMarkdown(report);
  if (args.output) {
    fs.mkdirSync(path.dirname(args.output), { recursive: true });
    fs.writeFileSync(args.output, output);
  } else {
    process.stdout.write(output);
  }
}

module.exports = {
  loadReport,
  parseArgs,
  renderMarkdown,
};

if (require.main === module) {
  main();
}
