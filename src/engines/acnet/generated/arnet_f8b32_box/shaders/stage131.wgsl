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

  var result: vec4f = vec4f(-0.62957036, 0.28153175, -0.1068452, 0.11796981);
      result += mat4x4<f32>(0.031080073, 0.19903603, -0.31705642, -0.05165833, -0.07327837, -0.20825933, -0.13201179, -0.016960928, 0.030874329, -0.049135353, 0.2192652, 0.0029071926, -0.051108643, 0.09634134, 0.04641239, -0.11373653) * sample_TMP2_TEX_0(pixel.xy, vec2i(0, 0));
      result += mat4x4<f32>(0.003271213, -0.01670001, -0.10522001, 0.09100773, 0.15313718, 0.06972528, 0.055080622, -0.15745775, -0.18136069, -0.18588825, 0.108645275, -0.036763318, 0.013519999, 0.12249395, 0.18428843, 0.18579865) * sample_TMP2_TEX_1(pixel.xy, vec2i(0, 0));
      result = max(result, vec4f(0.0)) + vec4f(0.47897997, 1.1109252, 0.90104693, 1.4677116) * min(result, vec4f(0.0));
      result = result + sample_FEAT_TEX_1(pixel.xy, vec2i(0, 0));
  textureStore(out_tex, pixel.xy, result);
}
