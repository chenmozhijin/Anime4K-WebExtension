const WG_X: u32 = 8u;
const WG_Y: u32 = 8u;
const BT709_LUMA: vec3f = vec3f(0.2126, 0.7152, 0.0722);

fn luma709(color: vec3f) -> f32 {
  return dot(color, BT709_LUMA);
}

@group(0) @binding(0) var tex_TMP1_TEX_0: texture_2d<f32>;

fn sample_TMP1_TEX_0(pos: vec2u, offset: vec2i) -> vec4f {
  let size = vec2i(textureDimensions(tex_TMP1_TEX_0));
  let coord = clamp(vec2i(pos) + offset, vec2i(0, 0), size - vec2i(1, 1));
  return textureLoad(tex_TMP1_TEX_0, coord, 0);
}

@group(0) @binding(1) var tex_TMP1_TEX_1: texture_2d<f32>;

fn sample_TMP1_TEX_1(pos: vec2u, offset: vec2i) -> vec4f {
  let size = vec2i(textureDimensions(tex_TMP1_TEX_1));
  let coord = clamp(vec2i(pos) + offset, vec2i(0, 0), size - vec2i(1, 1));
  return textureLoad(tex_TMP1_TEX_1, coord, 0);
}

@group(0) @binding(2) var tex_TMP2_TEX_0: texture_2d<f32>;

fn sample_TMP2_TEX_0(pos: vec2u, offset: vec2i) -> vec4f {
  let size = vec2i(textureDimensions(tex_TMP2_TEX_0));
  let coord = clamp(vec2i(pos) + offset, vec2i(0, 0), size - vec2i(1, 1));
  return textureLoad(tex_TMP2_TEX_0, coord, 0);
}
var<workgroup> tile_TMP1_TEX_0: array<array<vec4f, 10>, 10>;
var<workgroup> tile_TMP1_TEX_1: array<array<vec4f, 10>, 10>;
var<workgroup> tile_TMP2_TEX_0: array<array<vec4f, 10>, 10>;

@group(0) @binding(3) var out_tex: texture_storage_2d<rgba16float, write>;

@compute
@workgroup_size(WG_X, WG_Y)
fn computeMain(
  @builtin(global_invocation_id) pixel: vec3u,
  @builtin(local_invocation_id) localId: vec3u,
) {
  let outputSize = textureDimensions(out_tex);

  let groupOrigin = pixel.xy - localId.xy;
  for (var tileY = localId.y; tileY < 10u; tileY += WG_Y) {
    for (var tileX = localId.x; tileX < 10u; tileX += WG_X) {
      tile_TMP1_TEX_0[tileY][tileX] = sample_TMP1_TEX_0(
        groupOrigin,
        vec2i(i32(tileX) - 1, i32(tileY) - 1),
      );
      tile_TMP1_TEX_1[tileY][tileX] = sample_TMP1_TEX_1(
        groupOrigin,
        vec2i(i32(tileX) - 1, i32(tileY) - 1),
      );
      tile_TMP2_TEX_0[tileY][tileX] = sample_TMP2_TEX_0(
        groupOrigin,
        vec2i(i32(tileX) - 1, i32(tileY) - 1),
      );
    }
  }
  workgroupBarrier();

  if (pixel.x >= outputSize.x || pixel.y >= outputSize.y) {
    return;
  }

  var result: vec4f = vec4f(-0.029498307, 0.58116174, 0.15461044, -0.29053593);
      result += mat4x4<f32>(-0.04337484, 0.12939887, -0.2913569, 0.12994446, -0.094370745, -0.386051, 0.059564482, 0.13748586, 0.18352544, 0.5605786, -0.24191363, -0.009689114, 0.112083375, -0.34642315, 0.12207784, -0.5504383) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.013787835, -0.051431213, 0.2329048, 0.17868172, -0.12162862, -0.38538602, 0.18344653, 0.19656964, 0.042943798, 0.1726602, -0.16236684, -0.121247664, 0.049650546, 0.12744541, 0.02109685, -0.044604637) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.029608719, -0.0018253913, -0.28362927, -0.03744375, -0.14647174, -0.32413477, 0.23105317, 0.17157093, 0.1220589, 0.14083222, -0.3063852, -0.23143733, 0.07684181, -0.41817287, 0.12905242, -0.35339284) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.14884168, -0.38708663, 0.15308827, -0.36554646, -0.12241064, -0.44150153, 0.069641255, 0.15663862, 0.05349274, 0.045096256, -0.23990314, -0.09494071, -0.1648967, 0.23446149, -0.31967077, 0.8122929) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.7793085, -0.33433744, 0.2531774, 0.066593856, -0.18878485, -0.64170134, 0.20957123, 0.27901256, 0.34285963, 0.6530954, -0.43357486, -0.25496736, -0.48362333, 0.20613067, -0.22040087, 1.2127913) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.094429, 0.43555307, -0.32629734, -0.17963663, -0.09123909, -0.38229296, 0.17091687, 0.09361638, 0.057540264, 0.05560528, -0.035778068, -0.10323557, 0.10119455, 0.0558202, 0.012715017, -0.26820317) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.11628187, 0.19522347, 0.16844796, 0.09950729, -0.15939862, -0.42204154, 0.059019383, 0.21580747, 0.14689356, 0.08994655, 0.017270587, -0.030719388, -0.17102668, 0.06345215, 0.003819918, 0.28393364) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.13257843, -0.25932077, 0.11547854, -0.02968047, -0.16507657, -0.38796043, 0.18397228, 0.28616264, 0.20174202, 0.3767073, -0.26639313, -0.35400668, -0.08538276, 0.2989723, -0.13062865, 0.6926097) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.04724228, 0.3127009, 0.14959115, 0.08335257, -0.15754472, -0.3869975, 0.110127114, 0.13710415, 0.123437464, 0.358674, 0.0040969695, 0.019605182, 0.15568353, -0.1472269, -0.003932718, -0.48832494) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.14214498, 0.54261136, -0.06068081, 0.13151778, -0.021422097, 0.35605392, 0.14627543, -0.04442629, 0.03218174, -0.011833543, -0.1943737, -0.1913109, 0.039233327, -0.025000017, -0.035123006, 0.22787087) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.005473683, 0.09666842, -0.1859259, -0.14595091, 0.30045003, -0.28599513, -0.04302658, -0.035876825, 0.15346137, 0.21880612, -0.3783456, -0.26205122, 0.004457987, -0.0018802827, 0.112783894, 0.055466477) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.14197683, 0.40481222, -0.25126576, 0.09868174, 0.05163612, 0.041476928, 0.046290886, -0.012336907, -0.0010025577, 0.045235977, -0.014282886, 0.05170659, -0.08614045, -0.5807445, 0.104527466, 0.13017839) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.28039983, 0.7326317, -0.20616157, -0.006679549, 0.1747129, 0.12882118, 0.39756092, 0.0076306993, -0.0138403755, 0.06722679, -0.07732597, -0.44221666, -0.14235331, -0.6466758, 0.03783741, 0.2132172) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.004595194, 0.67999727, -0.06856862, -0.11100622, -0.27612382, 0.30479437, 0.56312627, 0.123745926, -0.20667917, 1.1413172, 0.41133848, 0.4899225, 0.12747756, -0.7918031, 0.05447799, -0.30254474) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.16164182, 0.58872944, -0.33402345, -0.054907437, -0.0761129, 0.30867466, -0.07329284, 0.11019272, 0.16667376, 0.5149465, -0.29034698, -0.25183144, 0.03136129, -0.22913575, -0.07435269, -0.06478759) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.1678706, 0.52152735, -0.15987566, -0.124892026, -0.06459543, -0.23602122, -0.25810978, 0.013108406, 0.14836909, 0.17664786, -0.1169137, -0.015339088, 0.06891294, 0.11694915, 0.45866314, -0.1308034) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.18355648, 0.8716058, -0.098812185, -0.0828452, -0.05850259, -0.15945362, -0.59604555, -0.0935715, 0.34247187, 0.39277017, -0.45489222, -0.23557703, -0.2792528, -0.70681924, 0.60537153, 0.36553216) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.032105904, 0.20420264, -0.089573815, 0.111302026, 0.033736274, 0.19863628, -0.16927998, 0.10241347, 0.050166845, 0.2593567, -0.060220946, -0.11656761, -0.15972339, -0.28285605, 0.08416531, 0.23474117) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
