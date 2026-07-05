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

  var result: vec4f = vec4f(0.2118794, 0.1738542, -0.71726656, 0.14384384);
      result += mat4x4<f32>(-0.20445006, 0.103117496, 0.0020886858, 0.15965842, -0.22985691, -0.002560914, 0.04347075, -0.17819384, 0.07663162, 0.19626647, 0.0014760625, 0.003919158, -0.11156898, -0.06710556, 0.029167386, 0.022770122) * sample_TMP2_TEX_0(pixel.xy, vec2i(0, 0));
      result += mat4x4<f32>(0.02972641, 0.1469556, -0.037893992, 0.042672858, -0.029516332, -0.16603075, -0.015608794, -0.22113729, 0.018667901, -0.10244827, 0.0042561046, -0.11350439, -0.046499047, -0.119205944, -0.001735935, -0.017587807) * sample_TMP2_TEX_1(pixel.xy, vec2i(0, 0));
      result = max(result, vec4f(0.0)) + vec4f(1.0625366, 1.0595778, 0.065332904, 1.0666873) * min(result, vec4f(0.0));
      result = result + sample_FEAT_TEX_0(pixel.xy, vec2i(0, 0));
  textureStore(out_tex, pixel.xy, result);
}
