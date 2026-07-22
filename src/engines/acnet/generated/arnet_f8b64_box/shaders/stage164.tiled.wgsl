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

  var result: vec4f = vec4f(0.042177394, 0.16160123, 0.11961412, -0.17587565);
      result += mat4x4<f32>(0.12560986, -0.25590158, -0.0969517, 0.21117336, -0.1611638, 0.083786316, 0.08152367, -0.03759125, 0.15275303, 0.04525293, 0.0019467626, 0.101025075, -0.035334688, 0.046609223, -0.21188301, 0.20859556) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.08561406, -0.15988338, -0.056522567, 0.14245558, -0.025882782, -0.1480541, -0.03284936, -0.07556862, -0.094922274, -0.019645156, 0.22432819, -0.28792182, -0.119436644, -0.022014657, -0.2769216, 0.40328252) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.032882452, -0.08617528, 0.011147804, 0.101637445, 0.13710707, 0.03919273, -0.01975531, 0.12574127, -0.21169735, 0.2419607, 0.31547463, -0.20197356, 0.030775812, 0.009401278, -0.13320374, 0.22923379) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.14755659, -0.15842679, -0.04791455, 0.34383935, -0.21004511, 0.036375146, 0.096299164, -0.22500376, -0.2282879, 0.25246823, 0.45797208, -0.47102144, 0.062410727, -0.09363738, -0.2020868, 0.22776836) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.15837508, -0.27741697, 0.019643411, 0.3333649, -0.4433516, -0.24802487, -0.61482507, -0.0478964, 0.27667445, -0.13744004, -0.35873407, 0.14915378, -0.41600537, 0.0069264774, -1.0184097, 0.051089652) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.112016365, -0.094922304, 0.11434763, 0.2400912, -0.040581, 0.13640636, 0.13234788, 0.07332596, -0.10481521, 0.1316206, -0.108988404, 0.24687226, 0.0067302478, -0.08748267, -0.090825945, 0.2257377) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.1439968, -0.3845317, -0.1350072, 0.23501766, -0.06666871, 0.14345977, 0.024714237, -0.014276916, 0.5881324, 0.06236387, 0.066334434, 0.060709063, -0.024759019, 0.038401775, -0.107649334, 0.15702139) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.23415011, -0.1971829, 0.017924815, 0.32920974, -0.069284804, 0.044076405, 0.015058393, 0.031055966, 0.016597038, 0.048571568, 0.22981746, 0.00029068615, 0.0048804474, -0.09907534, -0.18558247, 0.054341298) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.13077578, -0.1309582, 0.045944467, 0.21071638, 0.059503116, 0.07454104, 0.09497795, 0.01661505, -0.13387047, 0.03807348, 0.39973685, -0.010619354, -0.076541536, 0.068694025, -0.12434889, -0.017896898) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.052745763, -0.08733139, -0.057960954, 0.15253112, 0.2675412, -0.41226935, -0.20063625, 0.16995709, 0.1886991, -0.047967955, -0.14761011, 0.013745213, 0.10146456, -0.19764362, -0.06631894, 0.23285095) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.00980715, -0.23146516, -0.1269311, 0.08709128, 0.060178388, -0.13745089, -0.2960005, -0.024809476, 0.52027094, -0.12977071, -0.15424767, -0.085782, -0.09770864, 0.14216556, 0.007336712, 0.05687917) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.11962385, -0.23910798, -0.03790622, 0.1081339, -0.08226002, 0.003938273, 0.062546216, 0.12220647, 0.043178625, -0.06489918, -0.08700135, 0.08109076, 0.15640774, -0.07014064, 0.03678839, 0.102816194) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.0005988068, -0.109155245, -0.018490717, 0.040346697, 0.11009197, 0.29039088, -0.0880182, 0.16977115, 0.53335917, 0.040401615, -0.09810131, -0.15377522, -0.061506487, -0.22921568, -0.12043948, -0.06553217) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.025125358, -0.18218777, -0.14363599, 0.16010629, -0.52207166, -0.13494895, -0.014424948, -0.4417604, 0.17996655, -0.11120168, 0.26720443, -0.13302492, 0.13006498, 0.45862415, 0.5833515, -0.6469159) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.007826878, -0.24475276, -0.12652944, 0.21008736, -0.44017607, -0.2602483, -0.23672822, -0.03508209, 0.08208776, 0.080751754, 0.048477467, 0.32732177, -0.13901967, -0.05989423, -0.094761245, -0.088373296) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.08206414, -0.15536234, -0.10897187, 0.04775373, 0.1311871, -0.18776149, -0.24364747, 0.27059215, 0.07083762, 0.031011937, 0.05533838, -0.20415622, 0.05817112, -0.23367286, -0.27552125, 0.06534761) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.09529093, -0.10111692, -0.122643374, 0.047300063, -0.014367442, -0.047208346, -0.14742318, -0.09812798, -0.046721317, -0.07114567, 0.11909384, -0.37443298, -0.14033557, 0.04794232, -0.26407716, 0.02617654) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.04289339, -0.16449232, -0.07718168, 0.10042379, -0.14384227, 0.061788604, -0.060966156, -0.17949694, 0.05154342, 0.077287406, -0.03700957, 0.14066835, -0.0088668335, -0.046257176, -0.08126488, 0.00052809715) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
