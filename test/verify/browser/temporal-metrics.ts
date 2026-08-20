export interface TemporalThresholds {
  meanAbs: number;
  maxAbs: number;
  psnr: number;
  ssim: number;
  deltaE2000P99: number;
  deltaE2000Max: number;
  temporalChangeP99: number;
}

export const defaultTemporalThresholds: Readonly<TemporalThresholds> = Object.freeze({
  meanAbs: 0.25 / 255,
  maxAbs: 2 / 255,
  psnr: 50,
  ssim: 0.9995,
  deltaE2000P99: 0.5,
  deltaE2000Max: 2,
  temporalChangeP99: 1 / 255,
});

export interface TemporalFrameMetrics {
  frameIndex: number;
  passed: boolean;
  meanAbs: number;
  maxAbs: number;
  psnr: number;
  ssim: number;
  deltaE2000P99: number;
  deltaE2000Max: number;
  edgeWeightedMeanAbs: number;
  darkMeanAbs: number;
  borderMeanAbs: number;
  borderMaxAbs: number;
  alphaMaxAbs: number;
  nonFiniteCount: number;
  baselineRange: { min: number; max: number };
  candidateRange: { min: number; max: number };
  candidateAlphaRange: { min: number; max: number };
}

export interface TemporalMetricsSummary {
  passed: boolean;
  thresholds: TemporalThresholds;
  frameCount: number;
  failedFrameIndices: number[];
  meanAbs: number;
  maxAbs: number;
  maxFrameMeanAbs: number;
  minPsnr: number;
  minSsim: number;
  maxDeltaE2000P99: number;
  maxDeltaE2000: number;
  maxEdgeWeightedMeanAbs: number;
  maxDarkMeanAbs: number;
  borderMeanAbs: number;
  borderMaxAbs: number;
  alphaMaxAbs: number;
  nonFiniteCount: number;
  baselineRange: { min: number; max: number };
  candidateRange: { min: number; max: number };
  candidateAlphaRange: { min: number; max: number };
  temporalChangeP99: number;
  temporalChangeMax: number;
  temporalSampleCount: number;
  outputTemporalMeanAbs: number;
  outputTemporalP99: number;
  outputTemporalMax: number;
  outputTemporalSampleCount: number;
  frames: TemporalFrameMetrics[];
}

const LUMA = [0.2126, 0.7152, 0.0722] as const;
const TEMPORAL_HISTOGRAM_RANGE = 4;
const TEMPORAL_HISTOGRAM_BINS = 65537;

function lumaAt(values: ArrayLike<number>, pixel: number): number {
  const offset = pixel * 4;
  return values[offset] * LUMA[0] + values[offset + 1] * LUMA[1] + values[offset + 2] * LUMA[2];
}

function computeSsim(reference: ArrayLike<number>, candidate: ArrayLike<number>, width: number): number {
  const pixelCount = reference.length / 4;
  const height = pixelCount / width;
  const windowSize = 8;
  const c1 = 0.01 ** 2;
  const c2 = 0.03 ** 2;
  let sum = 0;
  let windows = 0;

  for (let top = 0; top < height; top += windowSize) {
    for (let left = 0; left < width; left += windowSize) {
      const right = Math.min(width, left + windowSize);
      const bottom = Math.min(height, top + windowSize);
      const count = (right - left) * (bottom - top);
      let meanA = 0;
      let meanB = 0;
      for (let y = top; y < bottom; y += 1) {
        for (let x = left; x < right; x += 1) {
          const pixel = y * width + x;
          meanA += lumaAt(reference, pixel);
          meanB += lumaAt(candidate, pixel);
        }
      }
      meanA /= count;
      meanB /= count;
      let varianceA = 0;
      let varianceB = 0;
      let covariance = 0;
      for (let y = top; y < bottom; y += 1) {
        for (let x = left; x < right; x += 1) {
          const pixel = y * width + x;
          const a = lumaAt(reference, pixel) - meanA;
          const b = lumaAt(candidate, pixel) - meanB;
          varianceA += a * a;
          varianceB += b * b;
          covariance += a * b;
        }
      }
      const divisor = Math.max(1, count - 1);
      varianceA /= divisor;
      varianceB /= divisor;
      covariance /= divisor;
      sum += ((2 * meanA * meanB + c1) * (2 * covariance + c2))
        / ((meanA * meanA + meanB * meanB + c1) * (varianceA + varianceB + c2));
      windows += 1;
    }
  }
  return windows ? sum / windows : 1;
}

function srgbToLinear(value: number): number {
  const clamped = Math.min(1, Math.max(0, value));
  return clamped <= 0.04045 ? clamped / 12.92 : ((clamped + 0.055) / 1.055) ** 2.4;
}

function rgbToLab(r: number, g: number, b: number): [number, number, number] {
  const lr = srgbToLinear(r);
  const lg = srgbToLinear(g);
  const lb = srgbToLinear(b);
  const x = (0.4124564 * lr + 0.3575761 * lg + 0.1804375 * lb) / 0.95047;
  const y = 0.2126729 * lr + 0.7151522 * lg + 0.072175 * lb;
  const z = (0.0193339 * lr + 0.119192 * lg + 0.9503041 * lb) / 1.08883;
  const f = (value: number) => value > 216 / 24389
    ? Math.cbrt(value)
    : (24389 / 27 * value + 16) / 116;
  const fx = f(x);
  const fy = f(y);
  const fz = f(z);
  return [116 * fy - 16, 500 * (fx - fy), 200 * (fy - fz)];
}

function deltaE2000(left: [number, number, number], right: [number, number, number]): number {
  const [l1, a1, b1] = left;
  const [l2, a2, b2] = right;
  const c1 = Math.hypot(a1, b1);
  const c2 = Math.hypot(a2, b2);
  const cBar = (c1 + c2) / 2;
  const g = 0.5 * (1 - Math.sqrt(cBar ** 7 / (cBar ** 7 + 25 ** 7)));
  const ap1 = (1 + g) * a1;
  const ap2 = (1 + g) * a2;
  const cp1 = Math.hypot(ap1, b1);
  const cp2 = Math.hypot(ap2, b2);
  const hue = (a: number, b: number) => {
    const angle = Math.atan2(b, a) * 180 / Math.PI;
    return angle < 0 ? angle + 360 : angle;
  };
  const hp1 = hue(ap1, b1);
  const hp2 = hue(ap2, b2);
  const deltaL = l2 - l1;
  const deltaC = cp2 - cp1;
  let deltaHAngle = hp2 - hp1;
  if (cp1 * cp2 === 0) deltaHAngle = 0;
  else if (deltaHAngle > 180) deltaHAngle -= 360;
  else if (deltaHAngle < -180) deltaHAngle += 360;
  const deltaH = 2 * Math.sqrt(cp1 * cp2) * Math.sin(deltaHAngle * Math.PI / 360);
  const lBar = (l1 + l2) / 2;
  const cPrimeBar = (cp1 + cp2) / 2;
  let hBar = hp1 + hp2;
  if (cp1 * cp2 === 0) hBar = hp1 + hp2;
  else if (Math.abs(hp1 - hp2) <= 180) hBar /= 2;
  else if (hBar < 360) hBar = (hBar + 360) / 2;
  else hBar = (hBar - 360) / 2;
  const t = 1
    - 0.17 * Math.cos((hBar - 30) * Math.PI / 180)
    + 0.24 * Math.cos(2 * hBar * Math.PI / 180)
    + 0.32 * Math.cos((3 * hBar + 6) * Math.PI / 180)
    - 0.20 * Math.cos((4 * hBar - 63) * Math.PI / 180);
  const deltaTheta = 30 * Math.exp(-(((hBar - 275) / 25) ** 2));
  const rc = 2 * Math.sqrt(cPrimeBar ** 7 / (cPrimeBar ** 7 + 25 ** 7));
  const sl = 1 + (0.015 * (lBar - 50) ** 2) / Math.sqrt(20 + (lBar - 50) ** 2);
  const sc = 1 + 0.045 * cPrimeBar;
  const sh = 1 + 0.015 * cPrimeBar * t;
  const rt = -Math.sin(2 * deltaTheta * Math.PI / 180) * rc;
  const dl = deltaL / sl;
  const dc = deltaC / sc;
  const dh = deltaH / sh;
  return Math.sqrt(dl * dl + dc * dc + dh * dh + rt * dc * dh);
}

function percentile(values: number[], fraction: number): number {
  values.sort((a, b) => a - b);
  return values[Math.min(values.length - 1, Math.floor(values.length * fraction))] ?? 0;
}

export class TemporalMetricsAccumulator {
  private readonly histogram = new Float64Array(TEMPORAL_HISTOGRAM_BINS);
  private readonly outputTemporalHistogram = new Float64Array(TEMPORAL_HISTOGRAM_BINS);
  private previousError: Float32Array | null = null;
  private previousReferenceLuma: Float32Array | null = null;
  private totalAbs = 0;
  private sampleCount = 0;
  private maxAbs = 0;
  private temporalSampleCount = 0;
  private temporalChangeMax = 0;
  private outputTemporalAbs = 0;
  private outputTemporalMax = 0;
  private outputTemporalSampleCount = 0;
  private borderAbs = 0;
  private borderSampleCount = 0;
  private borderMaxAbs = 0;
  private alphaMaxAbs = 0;
  private nonFiniteCount = 0;
  private baselineMin = Infinity;
  private baselineMax = -Infinity;
  private candidateMin = Infinity;
  private candidateMax = -Infinity;
  private candidateAlphaMin = Infinity;
  private candidateAlphaMax = -Infinity;
  private readonly frames: TemporalFrameMetrics[] = [];

  constructor(
    private readonly width: number,
    private readonly height: number,
    private readonly thresholds: TemporalThresholds = { ...defaultTemporalThresholds },
    private readonly motionOnly = false,
  ) {}

  addFrame(reference: ArrayLike<number>, candidate: ArrayLike<number>, frameIndex: number): TemporalFrameMetrics {
    if (reference.length !== candidate.length || reference.length !== this.width * this.height * 4) {
      throw new Error(`Temporal frame ${frameIndex} dimensions do not match ${this.width}x${this.height}.`);
    }
    if (this.motionOnly) return this.addMotionOnlyFrame(reference, candidate, frameIndex);
    const currentError = new Float32Array(reference.length);
    const currentReferenceLuma = new Float32Array(this.width * this.height);
    const deltaEValues = new Array<number>(this.width * this.height);
    let frameAbs = 0;
    let frameSquared = 0;
    let frameMaxAbs = 0;
    let frameNonFinite = 0;
    let frameAlphaMaxAbs = 0;
    let frameBorderAbs = 0;
    let frameBorderSamples = 0;
    let frameBorderMaxAbs = 0;
    let darkAbs = 0;
    let darkSamples = 0;
    let edgeWeightedAbs = 0;
    let edgeWeight = 0;
    let frameBaselineMin = Infinity;
    let frameBaselineMax = -Infinity;
    let frameCandidateMin = Infinity;
    let frameCandidateMax = -Infinity;
    let frameCandidateAlphaMin = Infinity;
    let frameCandidateAlphaMax = -Infinity;

    for (let y = 0; y < this.height; y += 1) {
      for (let x = 0; x < this.width; x += 1) {
        const pixel = y * this.width + x;
        const offset = pixel * 4;
        const border = x === 0 || y === 0 || x === this.width - 1 || y === this.height - 1;
        for (let component = 0; component < 4; component += 1) {
          const index = offset + component;
          const left = reference[index];
          const right = candidate[index];
          if (!Number.isFinite(left) || !Number.isFinite(right)) {
            frameNonFinite += 1;
            currentError[index] = 0;
            continue;
          }
          const signedError = right - left;
          const difference = Math.abs(signedError);
          currentError[index] = signedError;
          frameAbs += difference;
          frameSquared += difference * difference;
          frameMaxAbs = Math.max(frameMaxAbs, difference);
          frameBaselineMin = Math.min(frameBaselineMin, left);
          frameBaselineMax = Math.max(frameBaselineMax, left);
          frameCandidateMin = Math.min(frameCandidateMin, right);
          frameCandidateMax = Math.max(frameCandidateMax, right);
          if (component === 3) {
            frameAlphaMaxAbs = Math.max(frameAlphaMaxAbs, difference);
            frameCandidateAlphaMin = Math.min(frameCandidateAlphaMin, right);
            frameCandidateAlphaMax = Math.max(frameCandidateAlphaMax, right);
          }
          if (border) {
            frameBorderAbs += difference;
            frameBorderSamples += 1;
            frameBorderMaxAbs = Math.max(frameBorderMaxAbs, difference);
          }
          if (this.previousError) {
            // Measure changes in optimization error, not ordinary scene motion. A
            // moving edge is valid when baseline and candidate move together.
            const change = Math.abs(signedError - this.previousError[index]);
            const histogramIndex = Math.min(
              TEMPORAL_HISTOGRAM_BINS - 1,
              Math.floor(change / TEMPORAL_HISTOGRAM_RANGE * (TEMPORAL_HISTOGRAM_BINS - 1)),
            );
            this.histogram[histogramIndex] += 1;
            this.temporalSampleCount += 1;
            this.temporalChangeMax = Math.max(this.temporalChangeMax, change);
          }
        }

        const refLuma = lumaAt(reference, pixel);
        currentReferenceLuma[pixel] = refLuma;
        if (this.previousReferenceLuma) {
          const outputChange = Math.abs(refLuma - this.previousReferenceLuma[pixel]);
          const outputHistogramIndex = Math.min(
            TEMPORAL_HISTOGRAM_BINS - 1,
            Math.floor(outputChange / TEMPORAL_HISTOGRAM_RANGE * (TEMPORAL_HISTOGRAM_BINS - 1)),
          );
          this.outputTemporalHistogram[outputHistogramIndex] += 1;
          this.outputTemporalAbs += outputChange;
          this.outputTemporalMax = Math.max(this.outputTemporalMax, outputChange);
          this.outputTemporalSampleCount += 1;
        }
        const lumaError = Math.abs(refLuma - lumaAt(candidate, pixel));
        if (refLuma < 0.1) {
          darkAbs += lumaError;
          darkSamples += 1;
        }
        const leftLuma = lumaAt(reference, y * this.width + Math.max(0, x - 1));
        const rightLuma = lumaAt(reference, y * this.width + Math.min(this.width - 1, x + 1));
        const topLuma = lumaAt(reference, Math.max(0, y - 1) * this.width + x);
        const bottomLuma = lumaAt(reference, Math.min(this.height - 1, y + 1) * this.width + x);
        const weight = 1 + 4 * Math.min(1, Math.hypot(rightLuma - leftLuma, bottomLuma - topLuma));
        edgeWeightedAbs += lumaError * weight;
        edgeWeight += weight;
        deltaEValues[pixel] = deltaE2000(
          rgbToLab(reference[offset], reference[offset + 1], reference[offset + 2]),
          rgbToLab(candidate[offset], candidate[offset + 1], candidate[offset + 2]),
        );
      }
    }

    const meanAbs = frameAbs / reference.length;
    const mse = frameSquared / reference.length;
    const psnr = mse === 0 ? Infinity : 10 * Math.log10(1 / mse);
    const ssim = computeSsim(reference, candidate, this.width);
    const deltaE2000P99 = percentile(deltaEValues, 0.99);
    const deltaE2000Max = deltaEValues[deltaEValues.length - 1] ?? 0;
    const edgeWeightedMeanAbs = edgeWeight ? edgeWeightedAbs / edgeWeight : 0;
    const darkMeanAbs = darkSamples ? darkAbs / darkSamples : 0;
    const borderMeanAbs = frameBorderSamples ? frameBorderAbs / frameBorderSamples : 0;
    const alphaInRange = frameCandidateAlphaMin >= 1 - this.thresholds.maxAbs
      && frameCandidateAlphaMax <= 1 + this.thresholds.maxAbs;
    const rangePreserved = frameCandidateMin >= frameBaselineMin - this.thresholds.maxAbs
      && frameCandidateMax <= frameBaselineMax + this.thresholds.maxAbs;
    // Acceptance always uses the complete frame. Border, dark-region, and edge
    // metrics prevent a low global mean from hiding localized visible corruption.
    const passed = frameNonFinite === 0
      && meanAbs <= this.thresholds.meanAbs
      && frameMaxAbs <= this.thresholds.maxAbs
      && psnr >= this.thresholds.psnr
      && ssim >= this.thresholds.ssim
      && deltaE2000P99 <= this.thresholds.deltaE2000P99
      && deltaE2000Max <= this.thresholds.deltaE2000Max
      && edgeWeightedMeanAbs <= this.thresholds.meanAbs
      && darkMeanAbs <= this.thresholds.meanAbs
      && frameBorderMaxAbs <= this.thresholds.maxAbs
      && frameAlphaMaxAbs <= this.thresholds.maxAbs
      && alphaInRange
      && rangePreserved;
    const metrics: TemporalFrameMetrics = {
      frameIndex,
      passed,
      meanAbs,
      maxAbs: frameMaxAbs,
      psnr,
      ssim,
      deltaE2000P99,
      deltaE2000Max,
      edgeWeightedMeanAbs,
      darkMeanAbs,
      borderMeanAbs,
      borderMaxAbs: frameBorderMaxAbs,
      alphaMaxAbs: frameAlphaMaxAbs,
      nonFiniteCount: frameNonFinite,
      baselineRange: { min: frameBaselineMin, max: frameBaselineMax },
      candidateRange: { min: frameCandidateMin, max: frameCandidateMax },
      candidateAlphaRange: { min: frameCandidateAlphaMin, max: frameCandidateAlphaMax },
    };

    this.previousError = currentError;
    this.previousReferenceLuma = currentReferenceLuma;
    this.totalAbs += frameAbs;
    this.sampleCount += reference.length;
    this.maxAbs = Math.max(this.maxAbs, frameMaxAbs);
    this.borderAbs += frameBorderAbs;
    this.borderSampleCount += frameBorderSamples;
    this.borderMaxAbs = Math.max(this.borderMaxAbs, frameBorderMaxAbs);
    this.alphaMaxAbs = Math.max(this.alphaMaxAbs, frameAlphaMaxAbs);
    this.nonFiniteCount += frameNonFinite;
    this.baselineMin = Math.min(this.baselineMin, frameBaselineMin);
    this.baselineMax = Math.max(this.baselineMax, frameBaselineMax);
    this.candidateMin = Math.min(this.candidateMin, frameCandidateMin);
    this.candidateMax = Math.max(this.candidateMax, frameCandidateMax);
    this.candidateAlphaMin = Math.min(this.candidateAlphaMin, frameCandidateAlphaMin);
    this.candidateAlphaMax = Math.max(this.candidateAlphaMax, frameCandidateAlphaMax);
    this.frames.push(metrics);
    return metrics;
  }

  private addMotionOnlyFrame(
    reference: ArrayLike<number>,
    candidate: ArrayLike<number>,
    frameIndex: number,
  ): TemporalFrameMetrics {
    const currentReferenceLuma = new Float32Array(this.width * this.height);
    let frameAbs = 0;
    let frameMaxAbs = 0;
    let frameNonFinite = 0;
    let frameBaselineMin = Infinity;
    let frameBaselineMax = -Infinity;
    let frameCandidateMin = Infinity;
    let frameCandidateMax = -Infinity;
    let frameCandidateAlphaMin = Infinity;
    let frameCandidateAlphaMax = -Infinity;

    for (let pixel = 0; pixel < this.width * this.height; pixel += 1) {
      const offset = pixel * 4;
      for (let component = 0; component < 4; component += 1) {
        const left = reference[offset + component];
        const right = candidate[offset + component];
        if (!Number.isFinite(left) || !Number.isFinite(right)) {
          frameNonFinite += 1;
          continue;
        }
        const difference = Math.abs(left - right);
        frameAbs += difference;
        frameMaxAbs = Math.max(frameMaxAbs, difference);
        frameBaselineMin = Math.min(frameBaselineMin, left);
        frameBaselineMax = Math.max(frameBaselineMax, left);
        frameCandidateMin = Math.min(frameCandidateMin, right);
        frameCandidateMax = Math.max(frameCandidateMax, right);
        if (component === 3) {
          frameCandidateAlphaMin = Math.min(frameCandidateAlphaMin, right);
          frameCandidateAlphaMax = Math.max(frameCandidateAlphaMax, right);
        }
      }
      const refLuma = lumaAt(reference, pixel);
      currentReferenceLuma[pixel] = refLuma;
      if (this.previousReferenceLuma) {
        const outputChange = Math.abs(refLuma - this.previousReferenceLuma[pixel]);
        const histogramIndex = Math.min(
          TEMPORAL_HISTOGRAM_BINS - 1,
          Math.floor(outputChange / TEMPORAL_HISTOGRAM_RANGE * (TEMPORAL_HISTOGRAM_BINS - 1)),
        );
        this.outputTemporalHistogram[histogramIndex] += 1;
        this.outputTemporalAbs += outputChange;
        this.outputTemporalMax = Math.max(this.outputTemporalMax, outputChange);
        this.outputTemporalSampleCount += 1;
      }
    }

    const meanAbs = frameAbs / reference.length;
    const passed = frameNonFinite === 0
      && meanAbs <= this.thresholds.meanAbs
      && frameMaxAbs <= this.thresholds.maxAbs;
    const metrics: TemporalFrameMetrics = {
      frameIndex,
      passed,
      meanAbs,
      maxAbs: frameMaxAbs,
      psnr: meanAbs === 0 ? Infinity : 0,
      ssim: meanAbs === 0 ? 1 : 0,
      deltaE2000P99: 0,
      deltaE2000Max: 0,
      edgeWeightedMeanAbs: meanAbs,
      darkMeanAbs: meanAbs,
      borderMeanAbs: 0,
      borderMaxAbs: 0,
      alphaMaxAbs: 0,
      nonFiniteCount: frameNonFinite,
      baselineRange: { min: frameBaselineMin, max: frameBaselineMax },
      candidateRange: { min: frameCandidateMin, max: frameCandidateMax },
      candidateAlphaRange: { min: frameCandidateAlphaMin, max: frameCandidateAlphaMax },
    };
    this.previousReferenceLuma = currentReferenceLuma;
    this.totalAbs += frameAbs;
    this.sampleCount += reference.length;
    this.maxAbs = Math.max(this.maxAbs, frameMaxAbs);
    this.nonFiniteCount += frameNonFinite;
    this.baselineMin = Math.min(this.baselineMin, frameBaselineMin);
    this.baselineMax = Math.max(this.baselineMax, frameBaselineMax);
    this.candidateMin = Math.min(this.candidateMin, frameCandidateMin);
    this.candidateMax = Math.max(this.candidateMax, frameCandidateMax);
    this.candidateAlphaMin = Math.min(this.candidateAlphaMin, frameCandidateAlphaMin);
    this.candidateAlphaMax = Math.max(this.candidateAlphaMax, frameCandidateAlphaMax);
    this.frames.push(metrics);
    return metrics;
  }

  summarize(): TemporalMetricsSummary {
    // Histogram aggregation bounds memory for 300-frame clips while retaining the
    // p99 flicker gate. temporalChangeMax remains diagnostic for isolated spikes.
    const temporalTarget = this.temporalSampleCount * 0.99;
    let temporalCumulative = 0;
    let temporalChangeP99 = 0;
    for (let index = 0; index < this.histogram.length; index += 1) {
      temporalCumulative += this.histogram[index];
      if (temporalCumulative >= temporalTarget) {
        temporalChangeP99 = index / (TEMPORAL_HISTOGRAM_BINS - 1) * TEMPORAL_HISTOGRAM_RANGE;
        break;
      }
    }
    const failedFrameIndices = this.frames.filter(frame => !frame.passed).map(frame => frame.frameIndex);
    const outputTemporalTarget = this.outputTemporalSampleCount * 0.99;
    let outputTemporalCumulative = 0;
    let outputTemporalP99 = 0;
    for (let index = 0; index < this.outputTemporalHistogram.length; index += 1) {
      outputTemporalCumulative += this.outputTemporalHistogram[index];
      if (outputTemporalCumulative >= outputTemporalTarget) {
        outputTemporalP99 = index / (TEMPORAL_HISTOGRAM_BINS - 1) * TEMPORAL_HISTOGRAM_RANGE;
        break;
      }
    }
    const passed = failedFrameIndices.length === 0
      && this.nonFiniteCount === 0
      && temporalChangeP99 <= this.thresholds.temporalChangeP99;
    return {
      passed,
      thresholds: { ...this.thresholds },
      frameCount: this.frames.length,
      failedFrameIndices,
      meanAbs: this.sampleCount ? this.totalAbs / this.sampleCount : 0,
      maxAbs: this.maxAbs,
      maxFrameMeanAbs: Math.max(0, ...this.frames.map(frame => frame.meanAbs)),
      minPsnr: Math.min(Infinity, ...this.frames.map(frame => frame.psnr)),
      minSsim: Math.min(1, ...this.frames.map(frame => frame.ssim)),
      maxDeltaE2000P99: Math.max(0, ...this.frames.map(frame => frame.deltaE2000P99)),
      maxDeltaE2000: Math.max(0, ...this.frames.map(frame => frame.deltaE2000Max)),
      maxEdgeWeightedMeanAbs: Math.max(0, ...this.frames.map(frame => frame.edgeWeightedMeanAbs)),
      maxDarkMeanAbs: Math.max(0, ...this.frames.map(frame => frame.darkMeanAbs)),
      borderMeanAbs: this.borderSampleCount ? this.borderAbs / this.borderSampleCount : 0,
      borderMaxAbs: this.borderMaxAbs,
      alphaMaxAbs: this.alphaMaxAbs,
      nonFiniteCount: this.nonFiniteCount,
      baselineRange: { min: this.baselineMin, max: this.baselineMax },
      candidateRange: { min: this.candidateMin, max: this.candidateMax },
      candidateAlphaRange: { min: this.candidateAlphaMin, max: this.candidateAlphaMax },
      temporalChangeP99,
      temporalChangeMax: this.temporalChangeMax,
      temporalSampleCount: this.temporalSampleCount,
      outputTemporalMeanAbs: this.outputTemporalSampleCount
        ? this.outputTemporalAbs / this.outputTemporalSampleCount
        : 0,
      outputTemporalP99,
      outputTemporalMax: this.outputTemporalMax,
      outputTemporalSampleCount: this.outputTemporalSampleCount,
      frames: this.frames,
    };
  }
}
