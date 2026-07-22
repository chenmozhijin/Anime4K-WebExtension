const LUMA = [0.2126, 0.7152, 0.0722];

function lumaAt(values, pixel, components) {
  if (components === 1) return values[pixel];
  const offset = pixel * components;
  return values[offset] * LUMA[0] + values[offset + 1] * LUMA[1] + values[offset + 2] * LUMA[2];
}

function computePsnr(reference, candidate) {
  let squared = 0;
  for (let index = 0; index < reference.length; index += 1) {
    const delta = reference[index] - candidate[index];
    squared += delta * delta;
  }
  const mse = reference.length ? squared / reference.length : 0;
  return { mse, psnr: mse === 0 ? Infinity : 10 * Math.log10(1 / mse) };
}

function computeSsim(reference, candidate, width, components) {
  const pixelCount = reference.length / components;
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
          meanA += lumaAt(reference, pixel, components);
          meanB += lumaAt(candidate, pixel, components);
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
          const a = lumaAt(reference, pixel, components) - meanA;
          const b = lumaAt(candidate, pixel, components) - meanB;
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

function srgbToLinear(value) {
  const clamped = Math.min(1, Math.max(0, value));
  return clamped <= 0.04045 ? clamped / 12.92 : ((clamped + 0.055) / 1.055) ** 2.4;
}

function rgbToLab(r, g, b) {
  const lr = srgbToLinear(r);
  const lg = srgbToLinear(g);
  const lb = srgbToLinear(b);
  const x = (0.4124564 * lr + 0.3575761 * lg + 0.1804375 * lb) / 0.95047;
  const y = 0.2126729 * lr + 0.7151522 * lg + 0.072175 * lb;
  const z = (0.0193339 * lr + 0.119192 * lg + 0.9503041 * lb) / 1.08883;
  const f = value => value > 216 / 24389 ? Math.cbrt(value) : (24389 / 27 * value + 16) / 116;
  const fx = f(x);
  const fy = f(y);
  const fz = f(z);
  return [116 * fy - 16, 500 * (fx - fy), 200 * (fy - fz)];
}

function deltaE2000(lab1, lab2) {
  const [l1, a1, b1] = lab1;
  const [l2, a2, b2] = lab2;
  const c1 = Math.hypot(a1, b1);
  const c2 = Math.hypot(a2, b2);
  const cBar = (c1 + c2) / 2;
  const g = 0.5 * (1 - Math.sqrt(cBar ** 7 / (cBar ** 7 + 25 ** 7)));
  const ap1 = (1 + g) * a1;
  const ap2 = (1 + g) * a2;
  const cp1 = Math.hypot(ap1, b1);
  const cp2 = Math.hypot(ap2, b2);
  const hp = (a, b) => {
    const angle = Math.atan2(b, a) * 180 / Math.PI;
    return angle < 0 ? angle + 360 : angle;
  };
  const hp1 = hp(ap1, b1);
  const hp2 = hp(ap2, b2);
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

function computeDeltaE(reference, candidate, components) {
  if (components < 3) return null;
  const values = [];
  for (let offset = 0; offset < reference.length; offset += components) {
    values.push(deltaE2000(
      rgbToLab(reference[offset], reference[offset + 1], reference[offset + 2]),
      rgbToLab(candidate[offset], candidate[offset + 1], candidate[offset + 2]),
    ));
  }
  values.sort((a, b) => a - b);
  return {
    p99: values[Math.min(values.length - 1, Math.floor(values.length * 0.99))] ?? 0,
    max: values[values.length - 1] ?? 0,
    mean: values.length ? values.reduce((sum, value) => sum + value, 0) / values.length : 0,
  };
}

function computeRegionalErrors(reference, candidate, width, components) {
  const pixels = reference.length / components;
  const height = pixels / width;
  let darkSum = 0;
  let darkCount = 0;
  let edgeWeightedSum = 0;
  let edgeWeight = 0;
  for (let y = 0; y < height; y += 1) {
    for (let x = 0; x < width; x += 1) {
      const pixel = y * width + x;
      const refLuma = lumaAt(reference, pixel, components);
      const error = Math.abs(refLuma - lumaAt(candidate, pixel, components));
      if (refLuma < 0.1) {
        darkSum += error;
        darkCount += 1;
      }
      const left = lumaAt(reference, y * width + Math.max(0, x - 1), components);
      const right = lumaAt(reference, y * width + Math.min(width - 1, x + 1), components);
      const top = lumaAt(reference, Math.max(0, y - 1) * width + x, components);
      const bottom = lumaAt(reference, Math.min(height - 1, y + 1) * width + x, components);
      const weight = 1 + 4 * Math.min(1, Math.hypot(right - left, bottom - top));
      edgeWeightedSum += error * weight;
      edgeWeight += weight;
    }
  }
  return {
    darkMeanAbs: darkCount ? darkSum / darkCount : 0,
    darkSampleCount: darkCount,
    edgeWeightedMeanAbs: edgeWeight ? edgeWeightedSum / edgeWeight : 0,
  };
}

function computeImageMetrics(reference, candidate, width, components) {
  const { mse, psnr } = computePsnr(reference, candidate);
  return {
    mse,
    psnr,
    ssim: computeSsim(reference, candidate, width, components),
    deltaE2000: computeDeltaE(reference, candidate, components),
    ...computeRegionalErrors(reference, candidate, width, components),
  };
}

module.exports = { computeImageMetrics, deltaE2000, rgbToLab };
