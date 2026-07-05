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

  var result: vec4f = vec4f(-0.89454806, -0.054508682, -0.08471927, 0.17276286);
      result += mat4x4<f32>(0.08537275, 0.0026192616, -0.00585757, -0.03228309, -0.117589764, -0.0059402985, 0.006967469, -0.012029947, 0.023660976, -0.0015947308, 0.009920912, 0.084194556, 0.0036462059, -0.002195027, -9.652304e-06, -0.023722302) * sample_TMP2_TEX_0(pixel.xy, vec2i(0, 0));
      result += mat4x4<f32>(0.12327622, 0.0033791664, -0.0019384605, -0.06684315, 0.015333904, -0.004605038, -0.0038250932, 0.042136524, 0.059899718, 0.003107593, 0.012521906, -0.17630526, 0.040640384, 0.006482783, 0.008790111, 0.18691614) * sample_TMP2_TEX_1(pixel.xy, vec2i(0, 0));
      result = max(result, vec4f(0.0)) + vec4f(0.06088313, -0.0031670206, -0.018237058, 1.0674733) * min(result, vec4f(0.0));
      result = result + sample_FEAT_TEX_1(pixel.xy, vec2i(0, 0));
  textureStore(out_tex, pixel.xy, result);
}
