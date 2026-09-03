const fs = require('node:fs');
const path = require('node:path');

const repoRoot = path.resolve(__dirname, '..');
const defaultOutput = path.join(
  repoRoot,
  'test-results',
  'verify',
  'optimization-summary.json',
);

const reportFiles = Object.freeze({
  rawMath: 'test-results/verify/effects/raw-math-report.json',
  optimizationAudit: 'test-results/verify/effects/optimization-audit-report.json',
  terminalAudit: 'test-results/verify/effects/summary.json',
  wgsl: 'test-results/verify/wgsl-compilation.json',
  presets: 'test-results/verify/presets/report.json',
  kernelVariants: 'test-results/verify/kernel-variants.json',
  externalTexture: 'test-results/verify/external-texture.json',
  temporal: 'test-results/verify/temporal.json',
  textureLifetimes: 'test-results/performance/texture-lifetimes.json',
  performanceMatrix: 'test-results/performance/gpu-benchmark-matrix.json',
  performanceLayers: 'test-results/performance/gpu-benchmark-layers.json',
});

const processingPassTargets = Object.freeze({
  performance: 34,
  balanced: 36,
  quality: 36,
  ultra: 53,
});

function parseArgs(argv) {
  const args = {
    root: repoRoot,
    output: defaultOutput,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === '--root') args.root = path.resolve(argv[++index]);
    else if (arg.startsWith('--root=')) args.root = path.resolve(arg.slice(7));
    else if (arg === '--output') args.output = path.resolve(argv[++index]);
    else if (arg.startsWith('--output=')) args.output = path.resolve(arg.slice(9));
    else throw new Error(`Unknown optimization report option: ${arg}`);
  }
  return args;
}

function loadJson(root, relativePath) {
  const filePath = path.join(root, relativePath);
  if (!fs.existsSync(filePath)) {
    return { filePath, relativePath, missing: true, data: null };
  }
  try {
    return {
      filePath,
      relativePath,
      missing: false,
      data: JSON.parse(fs.readFileSync(filePath, 'utf8')),
    };
  } catch (error) {
    return {
      filePath,
      relativePath,
      missing: false,
      data: null,
      error: error instanceof Error ? error.message : String(error),
    };
  }
}

function reportCheck(input, passed, details = {}) {
  return {
    passed: Boolean(input.data) && passed,
    missing: input.missing,
    error: input.error ?? null,
    ...details,
  };
}

function summarizeEffectAudit(input, requiredArgument = null) {
  const data = input.data;
  const commandMatched = requiredArgument === null
    || String(data?.command ?? '').includes(requiredArgument);
  return reportCheck(
    input,
    data?.failureCount === 0 && data?.caseCount > 0 && commandMatched,
    {
      caseCount: data?.caseCount ?? 0,
      failureCount: data?.failureCount ?? null,
      requiredArgument,
      commandMatched,
    },
  );
}

function summarizePerformanceMatrix(input) {
  const data = input.data;
  const optimizedVariant = data?.variants?.find(variant => variant.id === 'optimized');
  const optimizedComparison = data?.comparisons?.find(comparison => comparison.variant === 'optimized');
  const variantTiers = new Map(
    (optimizedVariant?.report?.tiers ?? []).map(tier => [tier.tier, tier]),
  );
  const tiers = (optimizedComparison?.tiers ?? []).map(tier => {
    const variantTier = variantTiers.get(tier.tier);
    // Baseline/non-terminal plans include a separate presentation pass. Remove only
    // that pass when comparing against the documented processing-pass targets.
    const presentationPassCount = variantTier?.terminalPresented ? 0 : 1;
    const processingPassCount = Math.max(0, tier.candidate.passCount - presentationPassCount);
    const target = processingPassTargets[tier.tier] ?? null;
    return {
      tier: tier.tier,
      baselineTotalPassCount: tier.baseline.passCount,
      candidateTotalPassCount: tier.candidate.passCount,
      terminalPresented: Boolean(variantTier?.terminalPresented),
      presentationPassCount,
      processingPassCount,
      processingPassTarget: target,
      structurePassed: target === null || processingPassCount <= target,
      gpuP50GainPercent: tier.gpuP50GainPercent,
      gpuP95GainPercent: tier.gpuP95GainPercent,
      gpuP99GainPercent: tier.gpuP99GainPercent,
      peakTextureReductionPercent: tier.peakTextureReductionPercent,
      acceptance: tier.acceptance,
    };
  });
  const measurement = data?.measurement ?? {};
  const measurementPassed = measurement.warmupFrames >= 60
    && measurement.warmupMinimumMs >= 2000
    && measurement.frames >= 300
    && measurement.repeats >= 5
    && measurement.pairedComparison === true;
  const passed = tiers.length === Object.keys(processingPassTargets).length
    && tiers.every(tier => tier.structurePassed && tier.acceptance?.passed)
    && measurementPassed;
  return reportCheck(input, passed, {
    measurement,
    measurementPassed,
    tiers,
  });
}

function summarizePerformanceLayers(input) {
  const data = input.data;
  const cases = [];
  for (const [layer, reports] of Object.entries(data?.layers ?? {})) {
    for (const report of reports) {
      const comparison = report.comparisons?.find(item => item.variant === 'optimized');
      for (const tier of comparison?.tiers ?? []) {
        cases.push({
          layer,
          workload: report.measurement?.workloadId ?? tier.tier,
          tier: tier.tier,
          gpuP50GainPercent: tier.gpuP50GainPercent,
          gpuP95GainPercent: tier.gpuP95GainPercent,
          gpuP99GainPercent: tier.gpuP99GainPercent,
          peakTextureReductionPercent: tier.peakTextureReductionPercent,
          passReductionPercent: tier.passReductionPercent,
          meetsPrimaryTarget: Boolean(tier.acceptance?.meetsPrimaryTarget),
          noMajorRegression: Boolean(tier.acceptance?.noMajorRegression),
        });
      }
    }
  }
  const regressionGuardPassed = cases.length > 0 && cases.every(item => item.noMajorRegression);
  return reportCheck(input, regressionGuardPassed, {
    measurement: data?.measurement ?? null,
    caseCount: cases.length,
    primaryTargetCount: cases.filter(item => item.meetsPrimaryTarget).length,
    regressionGuardPassed,
    primaryTargetExceptions: cases.filter(item => !item.meetsPrimaryTarget),
    cases,
  });
}

function readPerceptualF16Default(root) {
  const flagsPath = path.join(root, 'src', 'core', 'optimization-flags.ts');
  if (!fs.existsSync(flagsPath)) return null;
  const source = fs.readFileSync(flagsPath, 'utf8');
  const match = source.match(/perceptualShaderF16:\s*(true|false),/);
  return match ? match[1] === 'true' : null;
}

function buildOptimizationReport(root = repoRoot) {
  const inputs = Object.fromEntries(
    Object.entries(reportFiles).map(([id, relativePath]) => [id, loadJson(root, relativePath)]),
  );
  const checks = {
    rawMath: summarizeEffectAudit(inputs.rawMath),
    optimizationAudit: summarizeEffectAudit(inputs.optimizationAudit, '--optimization-audit'),
    terminalAudit: summarizeEffectAudit(inputs.terminalAudit, '--terminal-audit'),
    wgsl: reportCheck(
      inputs.wgsl,
      inputs.wgsl.data?.failureCount === 0 && inputs.wgsl.data?.fileCount > 0,
      {
        fileCount: inputs.wgsl.data?.fileCount ?? 0,
        failureCount: inputs.wgsl.data?.failureCount ?? null,
      },
    ),
    presets: reportCheck(
      inputs.presets,
      inputs.presets.data?.passed === true && inputs.presets.data?.cases?.length > 0,
      {
        caseCount: inputs.presets.data?.cases?.length ?? 0,
        reportPassed: inputs.presets.data?.passed ?? null,
      },
    ),
    kernelVariants: reportCheck(
      inputs.kernelVariants,
      inputs.kernelVariants.data?.failureCount === 0
        && inputs.kernelVariants.data?.caseCount > 0,
      {
        caseCount: inputs.kernelVariants.data?.caseCount ?? 0,
        failureCount: inputs.kernelVariants.data?.failureCount ?? null,
      },
    ),
    externalTexture: reportCheck(
      inputs.externalTexture,
      inputs.externalTexture.data?.failureCount === 0
        && inputs.externalTexture.data?.caseCount >= 12,
      {
        caseCount: inputs.externalTexture.data?.caseCount ?? 0,
        failureCount: inputs.externalTexture.data?.failureCount ?? null,
      },
    ),
    temporal: reportCheck(
      inputs.temporal,
      inputs.temporal.data?.failureCount === 0
        && inputs.temporal.data?.caseCount >= 24
        && inputs.temporal.data?.framesPerCase >= 300
        && inputs.temporal.data?.profiles?.includes('optimized')
        && inputs.temporal.data?.profiles?.includes('external'),
      {
        caseCount: inputs.temporal.data?.caseCount ?? 0,
        framesPerCase: inputs.temporal.data?.framesPerCase ?? 0,
        processedFrames: (inputs.temporal.data?.caseCount ?? 0)
          * (inputs.temporal.data?.framesPerCase ?? 0),
        profiles: inputs.temporal.data?.profiles ?? [],
        failureCount: inputs.temporal.data?.failureCount ?? null,
      },
    ),
    textureLifetimes: reportCheck(
      inputs.textureLifetimes,
      inputs.textureLifetimes.data?.acceptance?.arnetF8B64ActualIntermediateSlots
        <= inputs.textureLifetimes.data?.acceptance?.arnetF8B64MaxIntermediateSlots,
      {
        modelCount: inputs.textureLifetimes.data?.models?.length ?? 0,
        acceptance: inputs.textureLifetimes.data?.acceptance ?? null,
      },
    ),
    performanceMatrix: summarizePerformanceMatrix(inputs.performanceMatrix),
    performanceLayers: summarizePerformanceLayers(inputs.performanceLayers),
  };
  const localValidationPassed = Object.values(checks).every(check => check.passed);
  const perceptualShaderF16Default = readPerceptualF16Default(root);
  return {
    schemaVersion: 1,
    localValidationPassed,
    runtimePolicy: {
      perceptualShaderF16Default,
      uncertifiedPerceptualShaderF16Disabled: perceptualShaderF16Default === false,
      noResolutionOrEffectDowngrade: true,
    },
    checks,
  };
}

function writeJsonAtomic(filePath, value) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  const temporaryPath = `${filePath}.${process.pid}.tmp`;
  fs.writeFileSync(temporaryPath, `${JSON.stringify(value, null, 2)}\n`);
  fs.rmSync(filePath, { force: true });
  fs.renameSync(temporaryPath, filePath);
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  const report = buildOptimizationReport(args.root);
  writeJsonAtomic(args.output, report);
  console.log(`Optimization validation report: ${args.output}`);
  console.log(`Local validation: ${report.localValidationPassed ? 'PASS' : 'FAIL'}`);
  if (!report.localValidationPassed) {
    process.exitCode = 1;
  }
}

module.exports = {
  buildOptimizationReport,
  parseArgs,
  processingPassTargets,
  reportFiles,
};

if (require.main === module) {
  try {
    main();
  } catch (error) {
    console.error(error instanceof Error ? error.message : error);
    process.exitCode = 1;
  }
}
