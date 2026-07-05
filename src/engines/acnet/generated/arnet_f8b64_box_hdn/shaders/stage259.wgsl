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

  var result: vec4f = vec4f(-0.7609868, -0.13362622, -0.5374848, 0.18808381);
      result += mat4x4<f32>(0.068956695, 0.010357394, -0.0052764984, -0.010319941, -0.12688409, -0.022990381, -0.025074663, -0.01125811, 0.042983446, 0.01066028, -0.009049193, 0.05554936, -0.0031303114, 0.008366609, 0.014565791, 0.008411988) * sample_TMP2_TEX_0(pixel.xy, vec2i(0, 0));
      result += mat4x4<f32>(0.059625857, 0.0049059405, 0.01710819, -0.0607258, 0.003673296, 7.4597214e-05, 0.0022731354, 0.035619423, 0.06811338, 0.016621547, -0.008326485, -0.19572562, 0.052487455, 0.01756914, 0.0017842046, 0.19322242) * sample_TMP2_TEX_1(pixel.xy, vec2i(0, 0));
      result = max(result, vec4f(0.0)) + vec4f(0.07749131, -0.029097162, 0.00027773186, 1.1024021) * min(result, vec4f(0.0));
      result = result + sample_FEAT_TEX_1(pixel.xy, vec2i(0, 0));
  textureStore(out_tex, pixel.xy, result);
}
