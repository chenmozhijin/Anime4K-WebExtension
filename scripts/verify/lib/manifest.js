const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const {
  createGeneratedEffectSourceMeta,
  createStaticEffectSourceMeta,
  sourceMetaToManifestEntry,
} = require('./effect-source-meta');

const repoRoot = path.resolve(__dirname, '../../..');

function extractExportArray(source, exportName, relativePath) {
  const declaration = `export const ${exportName}`;
  const declarationIndex = source.indexOf(declaration);
  if (declarationIndex < 0) {
    throw new Error(`Unable to find ${exportName} in ${relativePath}.`);
  }
  const equalsIndex = source.indexOf('=', declarationIndex);
  if (equalsIndex < 0) {
    throw new Error(`Unable to find ${exportName} assignment in ${relativePath}.`);
  }
  const start = source.indexOf('[', equalsIndex);
  if (start < 0) {
    throw new Error(`Unable to find ${exportName} array in ${relativePath}.`);
  }

  let depth = 0;
  let quote = null;
  let escaped = false;
  for (let index = start; index < source.length; index += 1) {
    const char = source[index];
    if (quote) {
      if (escaped) {
        escaped = false;
      } else if (char === '\\') {
        escaped = true;
      } else if (char === quote) {
        quote = null;
      }
      continue;
    }
    if (char === '"' || char === "'" || char === '`') {
      quote = char;
      continue;
    }
    if (char === '[') depth += 1;
    if (char === ']') {
      depth -= 1;
      if (depth === 0) {
        return source.slice(start, index + 1);
      }
    }
  }
  throw new Error(`Unable to parse ${exportName} array in ${relativePath}.`);
}

function readCatalogDescriptors(relativePath, exportName) {
  const source = fs.readFileSync(path.join(repoRoot, relativePath), 'utf8');
  const sourceMetaExportName = exportName.replace(/EffectDescriptors$/, 'EffectSourceMetas');
  if (sourceMetaExportName !== exportName && source.includes(`export const ${sourceMetaExportName}`)) {
    const arraySource = extractExportArray(source, sourceMetaExportName, relativePath);
    const metas = vm.runInNewContext(`(${arraySource})`, Object.freeze({
      anime4kBackendId: 'anime4k',
      artcnnBackendId: 'artcnn',
      effectSourceMeta: descriptor => ({ descriptor }),
    }));
    return metas.map(meta => meta.descriptor);
  }

  const arraySource = extractExportArray(source, exportName, relativePath);
  return vm.runInNewContext(`(${arraySource})`, Object.freeze({
    anime4kBackendId: 'anime4k',
    artcnnBackendId: 'artcnn',
  }));
}

function readGeneratedModelMetas(relativePath, exportName) {
  const source = fs.readFileSync(path.join(repoRoot, relativePath), 'utf8');
  const match = new RegExp(`export const ${exportName}: [^=]+ = (\\[[\\s\\S]*?\\]);`).exec(source);
  if (!match) {
    throw new Error(`Unable to parse generated model metadata from ${relativePath}.`);
  }
  return JSON.parse(match[1]);
}

function readAcnetReferences() {
  const productionMetas = readGeneratedModelMetas(
    'src/engines/acnet/generated/models.ts',
    'acnetGeneratedModelMetas',
  );
  const referenceMetas = readGeneratedModelMetas(
    'src/engines/acnet/generated/reference-models.ts',
    'acnetGeneratedReferenceModelMetas',
  );
  return createGeneratedEffectSourceMeta('acnet', productionMetas, referenceMetas)
    .map(sourceMetaToManifestEntry);
}

function readCunnyReferences() {
  const productionMetas = readGeneratedModelMetas(
    'src/engines/cunny/generated/models.ts',
    'cunnyGeneratedModelMetas',
  );
  const referenceMetas = readGeneratedModelMetas(
    'src/engines/cunny/generated/reference-models.ts',
    'cunnyGeneratedReferenceModelMetas',
  );
  return createGeneratedEffectSourceMeta('cunny', productionMetas, referenceMetas)
    .map(sourceMetaToManifestEntry);
}

function createManifest() {
  const anime4kDescriptors = readCatalogDescriptors('src/engines/anime4k/catalog.ts', 'anime4kEffectDescriptors');
  const artcnnDescriptors = readCatalogDescriptors('src/engines/artcnn/catalog.ts', 'artcnnEffectDescriptors');
  return [
    ...createStaticEffectSourceMeta('anime4k', anime4kDescriptors).map(sourceMetaToManifestEntry),
    ...createStaticEffectSourceMeta('artcnn', artcnnDescriptors).map(sourceMetaToManifestEntry),
    ...readAcnetReferences(),
    ...readCunnyReferences(),
  ];
}

module.exports = {
  createManifest,
  readCatalogDescriptors,
  readGeneratedModelMetas,
  repoRoot,
};
