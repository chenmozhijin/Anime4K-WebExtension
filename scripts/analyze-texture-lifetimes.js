const fs = require('node:fs');
const path = require('node:path');
const { parseMpvHookStages } = require('./lib/mpv-glsl-parser');

const repoRoot = path.resolve(__dirname, '..');
const sourceRoot = path.join(repoRoot, '.reference', 'ACNetGLSL', 'glsl');
const outputArgIndex = process.argv.indexOf('--output');
const outputPath = outputArgIndex >= 0 ? process.argv[outputArgIndex + 1] : null;
const nativeSize = { width: 1920, height: 1080 };
const bytesPerPixel = 8;

function analyzeStages(stages) {
  const versions = [{
    symbol: 'LUMA',
    producer: -1,
    lastUse: -1,
    widthScale: 1,
    heightScale: 1,
  }];
  const current = new Map([['LUMA', 0]]);
  let finalVersion = null;

  stages.forEach((stage, stageIndex) => {
    const inputs = stage.binds.map((binding) => {
      const version = current.get(binding);
      if (version === undefined) {
        throw new Error(`${stage.desc}: missing binding ${binding}`);
      }
      return version;
    });
    for (const version of new Set(inputs)) {
      versions[version].lastUse = stageIndex;
    }

    const outputVersion = versions.length;
    const outputName = stage.save ?? `__FINAL_${stageIndex}`;
    versions.push({
      symbol: outputName,
      producer: stageIndex,
      lastUse: stageIndex,
      widthScale: stage.widthScale,
      heightScale: stage.heightScale,
    });
    if (stage.save) {
      current.set(outputName, outputVersion);
    } else {
      finalVersion = outputVersion;
    }
  });

  if (finalVersion === null) {
    throw new Error('Model has no final stage.');
  }
  versions[finalVersion].lastUse = stages.length;

  const slotsByShape = new Map();
  let peakBytes = 0;
  for (const version of versions) {
    if (version.producer < 0) {
      continue;
    }
    const key = `${version.widthScale}|${version.heightScale}`;
    const slots = slotsByShape.get(key) ?? [];
    let slot = slots.find(candidate => candidate.lastUse < version.producer);
    if (!slot) {
      slot = { lastUse: version.lastUse };
      slots.push(slot);
      slotsByShape.set(key, slots);
      peakBytes += nativeSize.width * version.widthScale
        * nativeSize.height * version.heightScale * bytesPerPixel;
    } else {
      slot.lastUse = version.lastUse;
    }
  }

  return {
    stageCount: stages.length,
    logicalTextureVersions: versions.length - 1,
    peakIntermediateSlots: [...slotsByShape.values()].reduce((total, slots) => total + slots.length, 0),
    peakOneXIntermediateSlots: slotsByShape.get('1|1')?.length ?? 0,
    peakIntermediateBytes1080p: peakBytes,
  };
}

function collectModels() {
  const models = [];
  for (const family of ['acnet', 'acnet-legacy', 'arnet']) {
    const directory = path.join(sourceRoot, family);
    for (const name of fs.readdirSync(directory).filter(file => file.endsWith('.glsl')).sort()) {
      const source = fs.readFileSync(path.join(directory, name), 'utf8');
      const stages = parseMpvHookStages(source, { parseDimensions: true });
      models.push({
        family,
        model: path.basename(name, '.glsl'),
        ...analyzeStages(stages),
      });
    }
  }
  return models;
}

const models = collectModels();
const arnetF8B64 = models.find(model => model.model === 'arnet_f8b64');
if (!arnetF8B64 || arnetF8B64.peakOneXIntermediateSlots > 7) {
  throw new Error(`ARNet F8B64 lifetime target failed: ${JSON.stringify(arnetF8B64)}`);
}

const report = {
  schemaVersion: 1,
  generatedAt: new Date().toISOString(),
  nativeSize,
  format: 'rgba16float',
  acceptance: {
    arnetF8B64MaxIntermediateSlots: 7,
    arnetF8B64ActualIntermediateSlots: arnetF8B64.peakOneXIntermediateSlots,
  },
  models,
};
const json = `${JSON.stringify(report, null, 2)}\n`;
if (outputPath) {
  const absoluteOutput = path.resolve(repoRoot, outputPath);
  fs.mkdirSync(path.dirname(absoluteOutput), { recursive: true });
  fs.writeFileSync(absoluteOutput, json, 'utf8');
}
process.stdout.write(json);
