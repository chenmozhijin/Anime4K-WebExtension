export interface OptimizationFeatureFlags {
  textureLifetimeReuse: boolean;
  vectorizedPixelShuffle: boolean;
  fusedPixelShuffleRecompose: boolean;
  cunnyWorkgroupTile: boolean;
  fusedClampHighlights: boolean;
  acnetWorkgroupTile: boolean;
  anime4kWorkgroupTile: boolean;
  multiOutputDispatch: boolean;
  ganMultiOutputDispatch: boolean;
  fusedModelTail: boolean;
  terminalDirect: boolean;
  externalTexture: boolean;
  perceptualShaderF16: boolean;
  kernelAutotune: boolean;
}

export type OptimizationCorrectnessClass = 'exact' | 'quantized-equivalent' | 'perceptual';

// This classification is a release gate. A flag must pass the matching verifier
// before its default may be enabled; performance wins never override this class.
export const optimizationCorrectnessClasses: Readonly<
  Record<keyof OptimizationFeatureFlags, OptimizationCorrectnessClass>
> = Object.freeze({
  textureLifetimeReuse: 'exact',
  vectorizedPixelShuffle: 'quantized-equivalent',
  fusedPixelShuffleRecompose: 'quantized-equivalent',
  cunnyWorkgroupTile: 'exact',
  fusedClampHighlights: 'quantized-equivalent',
  acnetWorkgroupTile: 'exact',
  anime4kWorkgroupTile: 'exact',
  multiOutputDispatch: 'exact',
  ganMultiOutputDispatch: 'exact',
  fusedModelTail: 'quantized-equivalent',
  terminalDirect: 'perceptual',
  externalTexture: 'perceptual',
  perceptualShaderF16: 'perceptual',
  kernelAutotune: 'exact',
});

export const defaultOptimizationFeatureFlags: Readonly<OptimizationFeatureFlags> = Object.freeze({
  textureLifetimeReuse: true,
  vectorizedPixelShuffle: true,
  fusedPixelShuffleRecompose: true,
  // Shared-memory variants remain available for experiments, but formal Turing
  // measurements regressed CuNNy and ACNet. Do not re-enable without paired A/B data.
  cunnyWorkgroupTile: false,
  fusedClampHighlights: true,
  acnetWorkgroupTile: false,
  anime4kWorkgroupTile: false,
  multiOutputDispatch: true,
  // The dense GAN head can exceed binding/register sweet spots on current browsers.
  ganMultiOutputDispatch: false,
  fusedModelTail: true,
  terminalDirect: true,
  // External textures have separate color-conversion semantics and stay opt-in
  // until the copy/direct video fixture matrix is certified for the target platform.
  externalTexture: false,
  // Reserved for a future certified arithmetic-f16 implementation. Adapter support
  // alone is insufficient; this must remain false until the full hardware matrix passes.
  perceptualShaderF16: false,
  kernelAutotune: true,
});

export function resolveOptimizationFeatureFlags(
  overrides?: Partial<OptimizationFeatureFlags>,
): OptimizationFeatureFlags {
  return { ...defaultOptimizationFeatureFlags, ...overrides };
}
