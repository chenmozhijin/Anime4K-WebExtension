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

fn rgbToY(rgb: vec3f) -> f32 {
  return dot(rgb, vec3f(KR, KG, KB));
}

fn quantizeRgba16(value: vec4f) -> vec4f {
  return vec4f(
    unpack2x16float(pack2x16float(value.rg)),
    unpack2x16float(pack2x16float(value.ba))
  );
}

@fragment
fn fragmentMain(@builtin(position) position: vec4f) -> @location(0) vec4f {
  let pixel = vec2u(position.xy);
  let outputSize = textureDimensions(lumaTex) * vec2u(2u, 2u);
  let baseRgb = textureSampleLevel(
    sourceTex,
    linearSampler,
    position.xy / vec2f(outputSize),
    0.0
  ).rgb;
  let yBase = rgbToY(baseRgb);
  let cb = (baseRgb.b - yBase) / CB_SCALE;
  let cr = (baseRgb.r - yBase) / CR_SCALE;
  let stagePos = pixel / vec2u(2u, 2u);
  let stageValue = textureLoad(lumaTex, vec2i(stagePos), 0);
  let lane = (pixel.y % 2u) * 2u + (pixel.x % 2u);
  let yNew = clamp(stageValue[lane], 0.0, 1.0);

  let rgb = clamp(vec3f(
    yNew + CR_SCALE * cr,
    yNew - G_CB_COEFF * cb - G_CR_COEFF * cr,
    yNew + CB_SCALE * cb
  ), vec3f(0.0), vec3f(1.0));

  return quantizeRgba16(vec4f(rgb, 1.0));
}
