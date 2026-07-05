const WG_X: u32 = 8u;
const WG_Y: u32 = 8u;
const BT709_LUMA: vec3f = vec3f(0.2126, 0.7152, 0.0722);

fn luma709(color: vec3f) -> f32 {
  return dot(color, BT709_LUMA);
}

@group(0) @binding(0) var tex_TMP2_TEX_0: texture_2d<f32>;

fn sample_TMP2_TEX_0(pos: vec2u, offset: vec2i) -> vec4f {
  let size = vec2i(textureDimensions(tex_TMP2_TEX_0));
  let coord = clamp(vec2i(pos) + offset, vec2i(0, 0), size - vec2i(1, 1));
  return textureLoad(tex_TMP2_TEX_0, coord, 0);
}

@group(0) @binding(1) var tex_TMP2_TEX_1: texture_2d<f32>;

fn sample_TMP2_TEX_1(pos: vec2u, offset: vec2i) -> vec4f {
  let size = vec2i(textureDimensions(tex_TMP2_TEX_1));
  let coord = clamp(vec2i(pos) + offset, vec2i(0, 0), size - vec2i(1, 1));
  return textureLoad(tex_TMP2_TEX_1, coord, 0);
}

@group(0) @binding(2) var tex_FEAT_TEX_1: texture_2d<f32>;

fn sample_FEAT_TEX_1(pos: vec2u, offset: vec2i) -> vec4f {
  let size = vec2i(textureDimensions(tex_FEAT_TEX_1));
  let coord = clamp(vec2i(pos) + offset, vec2i(0, 0), size - vec2i(1, 1));
  return textureLoad(tex_FEAT_TEX_1, coord, 0);
}

@group(0) @binding(3) var out_tex: texture_storage_2d<rgba16float, write>;

@compute
@workgroup_size(WG_X, WG_Y)
fn computeMain(@builtin(global_invocation_id) pixel: vec3u) {
  let outputSize = textureDimensions(out_tex);
  if (pixel.x >= outputSize.x || pixel.y >= outputSize.y) {
    return;
  }

  var result: vec4f = vec4f(-0.11261539, 0.048078272, -1.4211719, 0.27446055);
      result += mat4x4<f32>(0.033146497, 0.046566498, 0.04569705, -0.17962763, 0.029046694, 0.07263678, -0.028358947, 0.025714453, 0.0019260251, -0.2634658, 0.00808108, -0.13656262, 0.06741688, 0.08525936, 0.018521113, 0.104377545) * sample_TMP2_TEX_0(pixel.xy, vec2i(0, 0));
      result += mat4x4<f32>(-0.009679619, -0.006813549, -0.018045276, 0.02409027, -0.049412947, -0.008037672, 0.04414096, 0.013085905, 0.056485638, 0.13365653, 0.12519623, -0.055870343, -0.050626613, -0.028004069, -0.063653074, 0.06812175) * sample_TMP2_TEX_1(pixel.xy, vec2i(0, 0));
      result = max(result, vec4f(0.0)) + vec4f(-0.10017512, 1.0521656, 0.054709636, 1.1723586) * min(result, vec4f(0.0));
      result = result + sample_FEAT_TEX_1(pixel.xy, vec2i(0, 0));
  textureStore(out_tex, pixel.xy, result);
}
