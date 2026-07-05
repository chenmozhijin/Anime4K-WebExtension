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

  var result: vec4f = vec4f(-0.5870804, 0.3084974, -0.2718446, 0.13113898);
      result += mat4x4<f32>(0.21898693, 0.26051053, -0.36345848, -0.05170579, 0.034639332, -0.20515612, -0.09019602, -0.0079384735, 0.16141197, -0.021119718, 0.20616744, -0.027223352, -0.06653131, 0.05537694, 0.024309915, -0.07521316) * sample_TMP2_TEX_0(pixel.xy, vec2i(0, 0));
      result += mat4x4<f32>(-0.17043492, -0.02985448, -0.11716069, 0.059417523, 0.032688882, 0.046156194, 0.086615965, -0.095064, -0.07898114, -0.16604333, 0.11380082, 0.010347462, -0.06478689, 0.17993073, 0.11639029, 0.22742133) * sample_TMP2_TEX_1(pixel.xy, vec2i(0, 0));
      result = max(result, vec4f(0.0)) + vec4f(0.55862266, 1.1858498, 0.83444655, 1.7434078) * min(result, vec4f(0.0));
      result = result + sample_FEAT_TEX_1(pixel.xy, vec2i(0, 0));
  textureStore(out_tex, pixel.xy, result);
}
