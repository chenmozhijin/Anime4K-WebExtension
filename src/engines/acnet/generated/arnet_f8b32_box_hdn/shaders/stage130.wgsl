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

@group(0) @binding(2) var tex_FEAT_TEX_0: texture_2d<f32>;

fn sample_FEAT_TEX_0(pos: vec2u, offset: vec2i) -> vec4f {
  let size = vec2i(textureDimensions(tex_FEAT_TEX_0));
  let coord = clamp(vec2i(pos) + offset, vec2i(0, 0), size - vec2i(1, 1));
  return textureLoad(tex_FEAT_TEX_0, coord, 0);
}

@group(0) @binding(3) var out_tex: texture_storage_2d<rgba16float, write>;

@compute
@workgroup_size(WG_X, WG_Y)
fn computeMain(@builtin(global_invocation_id) pixel: vec3u) {
  let outputSize = textureDimensions(out_tex);
  if (pixel.x >= outputSize.x || pixel.y >= outputSize.y) {
    return;
  }

  var result: vec4f = vec4f(-1.0506786, -0.07992661, -0.10760133, -0.6508269);
      result += mat4x4<f32>(-0.047401465, 0.042227093, -0.12985557, -0.19917934, 0.012567021, 0.10320404, 0.09799899, -0.051808104, -0.07945407, 0.01587386, -0.17708804, -0.08573158, -0.10234252, 0.029071279, -0.09667946, -0.10330489) * sample_TMP2_TEX_0(pixel.xy, vec2i(0, 0));
      result += mat4x4<f32>(-0.124917045, -0.044295505, 0.06475141, -0.021046046, 0.043845423, -0.14562286, 0.22932547, 0.054253686, -0.0061486196, -0.06488927, 0.0058783097, -0.27014735, 0.0345281, 0.27258816, 0.17144227, 0.017122854) * sample_TMP2_TEX_1(pixel.xy, vec2i(0, 0));
      result = max(result, vec4f(0.0)) + vec4f(0.11393463, 0.30161336, 0.6595873, 0.1357725) * min(result, vec4f(0.0));
      result = result + sample_FEAT_TEX_0(pixel.xy, vec2i(0, 0));
  textureStore(out_tex, pixel.xy, result);
}
