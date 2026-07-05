const defaultRawTolerance = {
  meanAbs: 1 / 255,
  maxAbs: 4 / 255,
};

/**
 * @typedef {Object} EffectVerificationSourceMeta
 * @property {string} referenceShader
 * @property {'luma-math' | 'rgb-math'} validationMode
 * @property {'luma' | 'rgba'} outputMode
 * @property {number} expectedScale
 * @property {number} referenceTimeoutMs
 * @property {{ channels: 'luma' | 'rgba', meanAbs: number, maxAbs: number, checkAlpha: boolean }} compare
 *
 * @typedef {Object} EffectSourceMeta
 * @property {string} backendId
 * @property {Object=} descriptor Production descriptor for catalog-backed effects.
 * @property {Object=} model Production generated model metadata for generated effects.
 * @property {EffectVerificationSourceMeta} verification Verify-only source metadata.
 */

const rawRgbaCompare = {
  channels: 'rgba',
  ...defaultRawTolerance,
  checkAlpha: true,
};

const rawLumaCompare = {
  channels: 'luma',
  ...defaultRawTolerance,
  checkAlpha: false,
};

const anime4kReferenceShaders = new Map([
  ['DoG', '.reference/Anime4K/glsl/Deblur/Anime4K_Deblur_DoG.glsl'],
  ['BilateralMean', '.reference/Anime4K/glsl/Denoise/Anime4K_Denoise_Bilateral_Mean.glsl'],
  ['CNNS', '.reference/Anime4K/glsl/Restore/Anime4K_Restore_CNN_S.glsl'],
  ['CNNM', '.reference/Anime4K/glsl/Restore/Anime4K_Restore_CNN_M.glsl'],
  ['CNNL', '.reference/Anime4K/glsl/Restore/Anime4K_Restore_CNN_L.glsl'],
  ['CNNSoftM', '.reference/Anime4K/glsl/Restore/Anime4K_Restore_CNN_Soft_M.glsl'],
  ['CNNSoftVL', '.reference/Anime4K/glsl/Restore/Anime4K_Restore_CNN_Soft_VL.glsl'],
  ['CNNVL', '.reference/Anime4K/glsl/Restore/Anime4K_Restore_CNN_VL.glsl'],
  ['CNNUL', '.reference/Anime4K/glsl/Restore/Anime4K_Restore_CNN_UL.glsl'],
  ['GANUUL', '.reference/Anime4K/glsl/Restore/Anime4K_Restore_GAN_UUL.glsl'],
  ['CNNx2S', '.reference/Anime4K/glsl/Upscale/Anime4K_Upscale_CNN_x2_S.glsl'],
  ['CNNx2M', '.reference/Anime4K/glsl/Upscale/Anime4K_Upscale_CNN_x2_M.glsl'],
  ['CNNx2L', '.reference/Anime4K/glsl/Upscale/Anime4K_Upscale_CNN_x2_L.glsl'],
  ['CNNx2VL', '.reference/Anime4K/glsl/Upscale/Anime4K_Upscale_CNN_x2_VL.glsl'],
  ['DenoiseCNNx2VL', '.reference/Anime4K/glsl/Upscale+Denoise/Anime4K_Upscale_Denoise_CNN_x2_VL.glsl'],
  ['CNNx2UL', '.reference/Anime4K/glsl/Upscale/Anime4K_Upscale_CNN_x2_UL.glsl'],
  ['GANx3L', '.reference/Anime4K/glsl/Upscale/Anime4K_Upscale_GAN_x3_L.glsl'],
  ['GANx4UUL', '.reference/Anime4K/glsl/Upscale/Anime4K_Upscale_GAN_x4_UUL.glsl'],
  ['ClampHighlights', '.reference/Anime4K/glsl/Restore/Anime4K_Clamp_Highlights.glsl'],
]);

const artcnnReferenceShaders = new Map([
  ['C4F16', '.reference/ArtCNN/GLSL/ArtCNN_C4F16.glsl'],
  ['C4F16_DS', '.reference/ArtCNN/GLSL/ArtCNN_C4F16_DS.glsl'],
  ['C4F16_DN', '.reference/ArtCNN/GLSL/ArtCNN_C4F16_DN.glsl'],
  ['C4F32', '.reference/ArtCNN/GLSL/ArtCNN_C4F32.glsl'],
  ['C4F32_DS', '.reference/ArtCNN/GLSL/ArtCNN_C4F32_DS.glsl'],
  ['C4F32_DN', '.reference/ArtCNN/GLSL/ArtCNN_C4F32_DN.glsl'],
]);

const staticBackendSourceMeta = {
  anime4k: {
    referenceShaders: anime4kReferenceShaders,
    verification: {
      validationMode: 'rgb-math',
      outputMode: 'rgba',
      referenceTimeoutMs: 180_000,
      compare: rawRgbaCompare,
    },
  },
  artcnn: {
    referenceShaders: artcnnReferenceShaders,
    verification: {
      validationMode: 'luma-math',
      outputMode: 'luma',
      referenceTimeoutMs: 180_000,
      compare: rawLumaCompare,
    },
  },
};

const generatedBackendSourceMeta = {
  acnet: {
    expectedScale: 2,
    verification: {
      validationMode: 'luma-math',
      outputMode: 'luma',
      referenceTimeoutMs: 180_000,
      compare: rawLumaCompare,
    },
  },
  cunny: {
    expectedScale: 2,
    verification: {
      validationMode: 'luma-math',
      outputMode: 'luma',
      referenceTimeoutMs: 300_000,
      compare: rawLumaCompare,
    },
  },
};

function descriptorScale(descriptor) {
  return descriptor.dimensionBehavior?.kind === 'scale'
    ? descriptor.dimensionBehavior.scale ?? 1
    : 1;
}

function createStaticEffectSourceMeta(backendId, descriptors) {
  const backendMeta = staticBackendSourceMeta[backendId];
  if (!backendMeta) {
    throw new Error(`No static effect source metadata registered for backend ${backendId}.`);
  }

  return descriptors.map(descriptor => {
    const referenceShader = backendMeta.referenceShaders.get(descriptor.key);
    if (!referenceShader) {
      throw new Error(`No ${descriptor.backendId} reference shader registered for ${descriptor.key}.`);
    }
    return {
      backendId,
      descriptor,
      verification: {
        ...backendMeta.verification,
        referenceShader,
        expectedScale: descriptorScale(descriptor),
      },
    };
  });
}

function createGeneratedEffectSourceMeta(backendId, productionMetas, referenceMetas) {
  const backendMeta = generatedBackendSourceMeta[backendId];
  if (!backendMeta) {
    throw new Error(`No generated effect source metadata registered for backend ${backendId}.`);
  }
  const referencesByKey = new Map(referenceMetas.map(model => [model.key, model]));

  return productionMetas.map(model => {
    const reference = referencesByKey.get(model.key);
    if (!reference) {
      throw new Error(`No ${backendId} reference metadata registered for ${model.key}.`);
    }
    if (
      reference.id !== model.id
      || reference.directory !== model.directory
      || reference.stageCount !== model.stageCount
    ) {
      throw new Error(`${backendId} production/reference metadata mismatch for ${model.key}.`);
    }
    return {
      backendId,
      model,
      verification: {
        ...backendMeta.verification,
        referenceShader: reference.sourceFile,
        expectedScale: backendMeta.expectedScale,
      },
    };
  });
}

function sourceMetaToManifestEntry(sourceMeta) {
  const source = sourceMeta.descriptor ?? sourceMeta.model;
  return {
    id: source.id,
    backendId: sourceMeta.backendId,
    key: source.key,
    referenceShader: sourceMeta.verification.referenceShader,
    expectedScale: sourceMeta.verification.expectedScale,
    validationMode: sourceMeta.verification.validationMode,
    outputMode: sourceMeta.verification.outputMode,
    referenceTimeoutMs: sourceMeta.verification.referenceTimeoutMs,
    compare: sourceMeta.verification.compare,
  };
}

module.exports = {
  anime4kReferenceShaders,
  artcnnReferenceShaders,
  createGeneratedEffectSourceMeta,
  createStaticEffectSourceMeta,
  generatedBackendSourceMeta,
  rawLumaCompare,
  rawRgbaCompare,
  sourceMetaToManifestEntry,
  staticBackendSourceMeta,
};
