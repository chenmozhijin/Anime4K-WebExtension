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

@group(0) @binding(2) var tex_TMP2_TEX_1: texture_2d<f32>;

fn sample_TMP2_TEX_1(pos: vec2u, offset: vec2i) -> vec4f {
  let size = vec2i(textureDimensions(tex_TMP2_TEX_1));
  let coord = clamp(vec2i(pos) + offset, vec2i(0, 0), size - vec2i(1, 1));
  return textureLoad(tex_TMP2_TEX_1, coord, 0);
}
var<workgroup> tile_TMP1_TEX_0: array<array<vec4f, 10>, 10>;
var<workgroup> tile_TMP1_TEX_1: array<array<vec4f, 10>, 10>;
var<workgroup> tile_TMP2_TEX_1: array<array<vec4f, 10>, 10>;

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
      tile_TMP2_TEX_1[tileY][tileX] = sample_TMP2_TEX_1(
        groupOrigin,
        vec2i(i32(tileX) - 1, i32(tileY) - 1),
      );
    }
  }
  workgroupBarrier();

  if (pixel.x >= outputSize.x || pixel.y >= outputSize.y) {
    return;
  }

  var result: vec4f = vec4f(-0.0075256536, 0.21099709, 0.009029948, 0.07814417);
      result += mat4x4<f32>(0.085991636, 0.35969478, -0.0666976, 0.08529156, -0.014899807, 0.008169121, -0.0014056844, 0.046395335, -0.010220301, -0.13325524, -0.07450571, -0.12146139, -0.07393289, -0.12612829, -0.1380706, -0.01892562) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.06451377, -0.17731513, 0.4027743, -0.23176894, 0.018409103, -0.05639482, -0.028058335, 0.12743004, 0.03967535, -0.08301469, -0.07986423, -0.19263114, 0.07771825, 0.02957321, 0.21412401, -0.37021357) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.046639685, 0.15588322, -0.08842783, 0.21703719, -0.021771662, 0.03823148, 0.122492746, -0.08194569, -0.10673822, -0.18560475, 0.011022711, -0.14971204, -0.026153574, -0.05894999, -0.12586452, 0.14767584) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.056307048, -0.3344087, -0.40807208, 0.11819298, 0.04272381, -0.042492934, 0.17273366, -0.013576172, -0.06407112, -0.3718894, -0.32689312, -0.34764087, 0.116470724, 0.35744464, 0.0447185, 0.1422235) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.1512949, -0.17101794, -0.08823961, -0.88605994, 0.30444542, -0.051563874, 0.12292831, 0.26601568, 0.4797319, -0.100589514, 0.021983292, -0.14164567, 0.10042552, -0.16389479, -0.2556227, 0.9110433) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.21265292, 0.12644492, -0.16733587, 0.28511825, 0.05875677, -0.074546866, 0.05457361, 0.0010344104, -0.28775048, -0.19241981, 0.2605153, -0.07847005, 0.011006735, -0.09045882, 0.13798031, -0.2962622) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.026488397, 0.03587728, -0.06834929, 0.19650061, 0.07291255, -0.088207446, 0.0810352, 0.030618919, -0.21500437, -0.2170181, 0.03950381, 0.13854669, -0.22953622, -0.32931697, -0.050069552, -0.2150938) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.052296042, 0.2830034, -0.038774814, 0.13469893, 0.16234781, -0.08937602, 0.12659506, -0.16291666, 0.5513487, 0.5151077, 0.22766748, -0.39006993, -0.20171417, -0.50072193, -0.16868304, -0.20140357) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.028469693, 0.24084775, -0.017421167, 0.2483443, 0.114169575, -0.08579089, 0.040483702, 0.09120791, -0.046207745, -0.16247526, -0.14661013, -0.18783729, -0.06688932, -0.03765291, -0.036719926, -0.15473206) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.07952205, -0.16921356, 0.11292667, -0.003132778, 0.015729208, -0.034790963, 0.0817257, -0.06722269, -0.012127136, 0.13706428, -0.016580736, 0.0023402155, 0.08670597, -0.11969498, 0.0071309875, 0.0821196) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.013834341, -0.16513257, -0.025232673, -0.04541606, -0.10433992, -0.15488148, -0.1504887, 0.15297952, 0.10494479, -0.047823302, -0.21395853, -0.18662952, 0.002366667, 0.22134726, -0.07263716, 0.0057342867) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.14583164, -0.108173825, -0.006425985, -0.05057237, -0.06853076, -0.19656496, 0.09276573, -0.08907025, 0.079752594, -0.036622096, -0.035295565, 0.11459757, 0.043560695, -0.13000613, -0.12756953, 0.09942461) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.31215826, -0.25857875, -0.1925745, 0.09778778, 0.032127485, 0.09827429, 0.15048127, -0.116561554, 0.09743991, 0.19258612, -0.028394677, 0.3106402, 0.016129982, -0.05531289, 0.056353766, -0.01005529) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.076428294, -0.033345457, -0.28128034, 0.23553708, 0.23555638, -0.06699679, 0.18248156, -0.04750753, 0.2798412, 0.033805348, -0.35470742, -0.24143852, -0.0055448385, -0.24868383, 0.34809458, -0.18267757) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.13200997, -0.23188208, 0.09426208, -0.11056241, -0.011030859, -0.069591686, -0.058358464, -0.011674933, 0.24537954, 0.14383653, -0.13235694, 0.13708419, 0.23720983, 0.35429925, -0.13387573, 0.13302548) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.07109379, -0.31826264, -0.11419578, -0.021871561, 0.08384995, -0.15731137, 0.1585278, -0.022046018, 0.012873487, 0.09374875, -0.11690285, 0.1483621, 0.078980654, 0.059979443, -0.04321127, 0.10566412) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.050581668, -0.10197757, -0.05246776, -0.13164493, -0.32524765, -0.9997216, -0.29562953, -0.6456262, 0.0793068, -0.20450483, 0.1608495, 0.075407945, 0.15050714, 0.27786875, 0.080591746, 0.073824145) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.036817282, -0.18090682, 0.13480525, -0.044637967, -0.21834712, -0.10342158, -0.08592292, 0.100024, 0.08518336, -0.04220437, 0.1332997, 0.0067080837, 0.07123144, 0.21197592, 0.09778562, 0.3632901) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
