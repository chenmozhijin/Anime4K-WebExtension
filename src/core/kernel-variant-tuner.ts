import type {
  GpuCapabilities,
  KernelCorrectnessClass,
  KernelVariant,
} from './gpu-capabilities';
import { isKernelVariantSupported } from './gpu-capabilities';

export interface KernelVariantBenchmarkResult {
  variantId: string;
  medianMs: number;
}

export interface KernelVariantSelection {
  variant: KernelVariant;
  source: 'cache' | 'benchmark' | 'baseline';
  gainPercent: number;
}

export interface KernelVariantTunerOptions {
  capabilities: GpuCapabilities;
  variants: readonly KernelVariant[];
  baselineId: string;
  shaderHash: string;
  cacheNamespace: string;
  benchmark: (variant: KernelVariant) => Promise<number>;
  allowedCorrectness?: readonly KernelCorrectnessClass[];
  budgetMs?: number;
  minimumGainPercent?: number;
  storage?: Pick<Storage, 'getItem' | 'setItem'>;
}

interface CachedSelection {
  variantId: string;
  benchmarkCacheVersion: number;
}

function createCacheKey(options: KernelVariantTunerOptions): string {
  const { capabilities } = options;
  // WebGPU exposes no portable driver version. Browser/adapter identity plus the
  // shader hash and per-variant cache version are the strongest reusable boundary.
  return [
    options.cacheNamespace,
    capabilities.browser.name,
    capabilities.browser.version,
    capabilities.adapter.vendor,
    capabilities.adapter.architecture,
    capabilities.adapter.device,
    options.shaderHash,
  ].join('|');
}

export async function selectKernelVariant(
  options: KernelVariantTunerOptions,
): Promise<KernelVariantSelection> {
  // Perceptual variants are never considered implicitly. Callers must opt in only
  // after their own correctness certification has passed.
  const allowedCorrectness = new Set(options.allowedCorrectness ?? ['exact', 'quantized-equivalent']);
  const supported = options.variants.filter(variant =>
    allowedCorrectness.has(variant.correctness)
    && isKernelVariantSupported(variant, options.capabilities));
  const baseline = supported.find(variant => variant.id === options.baselineId);
  if (!baseline) {
    throw new Error(`Kernel baseline is unavailable: ${options.baselineId}`);
  }

  const storage = options.storage ?? (typeof localStorage === 'undefined' ? undefined : localStorage);
  const cacheKey = createCacheKey(options);
  let cachedRaw: string | null | undefined;
  try {
    cachedRaw = storage?.getItem(cacheKey);
  } catch {
    cachedRaw = null;
  }
  if (cachedRaw) {
    try {
      const cached = JSON.parse(cachedRaw) as CachedSelection;
      const variant = supported.find(candidate =>
        candidate.id === cached.variantId
        && candidate.benchmarkCacheVersion === cached.benchmarkCacheVersion);
      if (variant) {
        return { variant, source: 'cache', gainPercent: 0 };
      }
    } catch {
      // Ignore stale or malformed tuning records.
    }
  }

  const budgetMs = options.budgetMs ?? 300;
  const minimumGainPercent = options.minimumGainPercent ?? 3;
  const startedAt = performance.now();
  const results: KernelVariantBenchmarkResult[] = [];
  for (const variant of supported) {
    // Check between variants so one benchmark is never abandoned mid-command-buffer.
    if (results.length > 0 && performance.now() - startedAt >= budgetMs) {
      break;
    }
    const medianMs = await options.benchmark(variant);
    if (Number.isFinite(medianMs) && medianMs > 0) {
      results.push({ variantId: variant.id, medianMs });
    }
  }

  const baselineResult = results.find(result => result.variantId === baseline.id);
  const fastest = results.reduce<KernelVariantBenchmarkResult | null>(
    (best, result) => !best || result.medianMs < best.medianMs ? result : best,
    null,
  );
  if (!baselineResult || !fastest) {
    return { variant: baseline, source: 'baseline', gainPercent: 0 };
  }

  const gainPercent = (baselineResult.medianMs - fastest.medianMs) / baselineResult.medianMs * 100;
  // Sub-3% differences are commonly clock/cache noise and are not worth making the
  // startup choice less stable across sessions.
  const selected = gainPercent >= minimumGainPercent
    ? supported.find(variant => variant.id === fastest.variantId) ?? baseline
    : baseline;
  try {
    storage?.setItem(cacheKey, JSON.stringify({
      variantId: selected.id,
      benchmarkCacheVersion: selected.benchmarkCacheVersion,
    } satisfies CachedSelection));
  } catch {
    // Storage may be unavailable in private or restricted page contexts.
  }
  return {
    variant: selected,
    source: selected === baseline ? 'baseline' : 'benchmark',
    gainPercent: selected === baseline ? 0 : gainPercent,
  };
}
