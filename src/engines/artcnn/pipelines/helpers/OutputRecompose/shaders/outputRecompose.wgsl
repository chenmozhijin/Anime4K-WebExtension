const WG_X: u32 = 12u;
const WG_Y: u32 = 16u;
const KR: f32 = 0.2126;
const KG: f32 = 0.7152;
const KB: f32 = 0.0722;
const CB_SCALE: f32 = 2.0 * (1.0 - KB);
const CR_SCALE: f32 = 2.0 * (1.0 - KR);
const G_CB_COEFF: f32 = 2.0 * KB * (1.0 - KB) / KG;
const G_CR_COEFF: f32 = 2.0 * KR * (1.0 - KR) / KG;

@group(0) @binding(0) var linearSampler: sampler;
@group(0) @binding(1) var sourceTex: texture_2d<f32>;
@group(0) @binding(2) var lumaTex: texture_2d<f32>;
@group(0) @binding(3) var outTex: texture_storage_2d<rgba16float, write>;

fn rgbToY(rgb: vec3f) -> f32 {
  return dot(rgb, vec3f(KR, KG, KB));
}

fn sampleBaseColor(pixel: vec2u, outputSize: vec2u) -> vec3f {
  let uv = (vec2f(pixel) + vec2f(0.5)) / vec2f(outputSize);
  return textureSampleLevel(sourceTex, linearSampler, uv, 0.0).rgb;
}

fn getEnhancedLuma(pixel: vec2u) -> f32 {
  let stagePos = pixel / vec2u(2u, 2u);
  let stageValue = textureLoad(lumaTex, vec2i(stagePos), 0);
  let lane = (pixel.y % 2u) * 2u + (pixel.x % 2u);
  return clamp(stageValue[lane], 0.0, 1.0);
}

@compute
@workgroup_size(WG_X, WG_Y)
fn computeMain(@builtin(global_invocation_id) pixel: vec3u) {
  let outputSize = textureDimensions(outTex);
  if (pixel.x >= outputSize.x || pixel.y >= outputSize.y) {
    return;
  }

  let baseRgb = sampleBaseColor(pixel.xy, outputSize);
  let yBase = rgbToY(baseRgb);
  let cb = (baseRgb.b - yBase) / CB_SCALE;
  let cr = (baseRgb.r - yBase) / CR_SCALE;
  let yNew = getEnhancedLuma(pixel.xy);

  let rgb = clamp(vec3f(
    yNew + CR_SCALE * cr,
    yNew - G_CB_COEFF * cb - G_CR_COEFF * cr,
    yNew + CB_SCALE * cb
  ), vec3f(0.0), vec3f(1.0));

  textureStore(outTex, pixel.xy, vec4f(rgb, 1.0));
}

