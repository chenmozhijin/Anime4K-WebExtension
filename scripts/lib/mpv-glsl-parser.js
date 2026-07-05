function parseLumaScaleExpression(line, axis) {
  const dimension = axis === 'WIDTH' ? 'w' : 'h';
  const plain = new RegExp(`^//!${axis}\\s+LUMA\\.${dimension}\\s*$`);
  if (plain.test(line)) {
    return 1;
  }

  const multiplied = line.match(new RegExp(`^//!${axis}\\s+LUMA\\.${dimension}\\s+(\\d+)\\s+\\*\\s*$`));
  if (multiplied) {
    return Number(multiplied[1]);
  }

  throw new Error(`Unsupported ${axis.toLowerCase()} expression: ${line}`);
}

function createStage(desc) {
  const sharedLines = [];
  return {
    desc,
    components: 4,
    binds: [],
    save: null,
    widthScale: 1,
    heightScale: 1,
    bodyLines: sharedLines,
    code: sharedLines,
  };
}

function parseMpvHookStages(source, options = {}) {
  const {
    parseDimensions = false,
    strictDirectives = false,
  } = options;
  const lines = source.split(/\r?\n/);
  const stages = [];
  let current = null;

  for (const line of lines) {
    const desc = line.match(/^\/\/!DESC\s+(.+)$/);
    if (desc) {
      current = createStage(desc[1]);
      stages.push(current);
      continue;
    }

    if (!current) {
      continue;
    }

    const components = line.match(/^\/\/!COMPONENTS\s+(\d+)$/);
    if (components) {
      current.components = Number(components[1]);
      continue;
    }

    const bind = line.match(/^\/\/!BIND\s+(\S+)$/);
    if (bind) {
      current.binds.push(bind[1]);
      continue;
    }

    const save = line.match(/^\/\/!SAVE\s+(\S+)$/);
    if (save) {
      current.save = save[1];
      continue;
    }

    if (line.startsWith('//!WIDTH')) {
      if (!parseDimensions) {
        throw new Error(`${current.desc}: unsupported WIDTH directive: ${line}`);
      }
      current.widthScale = parseLumaScaleExpression(line, 'WIDTH');
      continue;
    }

    if (line.startsWith('//!HEIGHT')) {
      if (!parseDimensions) {
        throw new Error(`${current.desc}: unsupported HEIGHT directive: ${line}`);
      }
      current.heightScale = parseLumaScaleExpression(line, 'HEIGHT');
      continue;
    }

    if (line.startsWith('//!')) {
      if (strictDirectives) {
        throw new Error(`${current.desc}: unsupported hook directive: ${line}`);
      }
      continue;
    }

    current.bodyLines.push(line);
  }

  return stages;
}

module.exports = {
  parseLumaScaleExpression,
  parseMpvHookStages,
};
