function clampByte(value) {
  return Math.max(0, Math.min(255, Math.round(value)));
}

function makePixels(width, height, pixelFn) {
  const rgba = new Uint8Array(width * height * 4);
  for (let y = 0; y < height; y += 1) {
    for (let x = 0; x < width; x += 1) {
      const [r, g, b, a = 255] = pixelFn(x, y, width, height);
      const offset = (y * width + x) * 4;
      rgba[offset] = clampByte(r);
      rgba[offset + 1] = clampByte(g);
      rgba[offset + 2] = clampByte(b);
      rgba[offset + 3] = clampByte(a);
    }
  }
  return rgba;
}

function makeGrayPixels(width, height, valueFn) {
  return makePixels(width, height, (x, y, w, h) => {
    const value = valueFn(x, y, w, h);
    return [value, value, value, 255];
  });
}

function deterministicNoiseRgb(x, y) {
  const value = (Math.imul(x + 17, 1103515245) ^ Math.imul(y + 31, 12345)) >>> 0;
  return [
    value & 0xff,
    (value >>> 8) & 0xff,
    (value >>> 16) & 0xff,
  ];
}

function createBuiltInFixtures() {
  const width = 64;
  const height = 48;
  return [
    {
      id: 'constant_midgray',
      width,
      height,
      rgba: makePixels(width, height, () => [96, 128, 160, 255]),
    },
    {
      id: 'gradient',
      width,
      height,
      rgba: makePixels(width, height, (x, y, w, h) => [
        (x / (w - 1)) * 255,
        (y / (h - 1)) * 255,
        ((x + y) / (w + h - 2)) * 255,
        255,
      ]),
    },
    {
      id: 'checker_edges',
      width,
      height,
      rgba: makePixels(width, height, (x, y) => {
        const checker = ((Math.floor(x / 4) + Math.floor(y / 4)) % 2) * 255;
        const line = x === 17 || y === 23 || x === y ? 255 : checker;
        return [line, checker, 255 - checker, 255];
      }),
    },
    {
      id: 'luma_gradient',
      width,
      height,
      rgba: makeGrayPixels(width, height, (x, y, w, h) => (
        ((x / (w - 1)) * 0.65 + (y / (h - 1)) * 0.35) * 255
      )),
    },
    {
      id: 'luma_checker_edges',
      width,
      height,
      rgba: makeGrayPixels(width, height, (x, y) => {
        const checker = ((Math.floor(x / 4) + Math.floor(y / 4)) % 2) * 255;
        return x === 17 || y === 23 || x === y ? 255 : checker;
      }),
    },
    {
      id: 'deterministic_noise',
      width,
      height,
      rgba: makePixels(width, height, (x, y) => [
        ...deterministicNoiseRgb(x, y),
        255,
      ]),
    },
    {
      id: 'deterministic_noise_alpha',
      diagnosticOnly: true,
      width,
      height,
      rgba: makePixels(width, height, (x, y) => {
        const [r, g, b] = deterministicNoiseRgb(x, y);
        const a = ((x + y) % 9 === 0) ? 128 : 255;
        return [r, g, b, a];
      }),
    },
  ];
}

module.exports = {
  createBuiltInFixtures,
};
