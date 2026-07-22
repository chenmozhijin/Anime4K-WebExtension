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

  var result: vec4f = vec4f(0.2519549, -0.08756564, 0.49853227, -0.029945659);
      result += mat4x4<f32>(0.09091114, 0.019274568, -0.12246772, -0.098284945, 0.12781005, -0.07975965, 0.23016317, 0.31626746, 0.07618979, -0.044553816, 0.14555614, -0.08895688, -0.020195441, 0.2328805, 0.03282648, -0.29232782) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.4914893, 0.11505671, 0.046166703, -0.16030581, -0.20253311, -0.12450272, -0.15800478, 0.41864496, 0.056106556, 0.028816927, 0.057749853, -0.14301659, -0.078432165, 0.16959101, -0.22876973, -0.61725515) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.52414596, -0.059566237, -0.1995072, -0.038737185, -0.062490348, -0.0009389782, 0.1779548, -0.1461667, -0.014471535, -0.34440267, -0.0254858, -0.51823103, -0.12528083, -0.012800308, -0.0463204, -0.17022151) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.14907184, 0.13342188, 0.15544476, -0.20527816, 0.190165, -0.093960166, -0.12870598, 0.36425468, 0.2786105, -0.16249101, -0.13590793, 0.108220704, 0.17941044, 0.12990507, 0.13214643, -0.09732179) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.32805946, 0.0844884, -0.28946462, -0.03561979, 0.36090112, -0.49760026, -0.6987391, -0.009675845, -0.740949, -0.22831853, 0.6533587, -0.21894437, -0.02072698, 0.3414659, -0.5370781, -0.28665152) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.008041168, -0.042285394, -0.4302372, 0.05807943, 0.38914335, -0.057731543, -0.21830802, -0.22337888, 0.48474848, -0.20003879, 0.0029472872, -0.42553693, -0.10279143, 0.24289852, -0.15791564, -0.07359459) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.031731293, -0.16412872, 0.20598665, -0.15453726, -0.0028980076, 0.058165785, -0.08785358, -0.03747609, -0.043755624, -0.12803599, 0.08430479, -0.16528755, -0.07228054, -0.020239111, -0.17929572, 0.0025747619) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.20702776, -0.29250234, -0.3408686, -0.27323303, 0.1565333, 0.08944627, 0.53435427, -0.17069386, -0.0740948, -0.16617481, 0.2416856, 0.024668626, -0.22157992, 0.06448095, 0.019996367, -0.22309728) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.2750056, 0.1589539, 0.15006843, -0.1621676, -0.10332353, -0.0571658, 0.022540469, 0.03890965, 0.16877133, -0.004118974, 0.15395494, -0.32486722, 0.123099685, -0.031863406, 0.09675294, -0.028471302) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.1949307, -0.1262145, -0.037257288, 0.026750823, -0.21447995, 0.024036363, -0.1273803, 0.045519095, -0.0573585, -0.04073612, -0.06377392, -0.11080305, 0.045177642, -0.095851794, -0.18611516, 0.21818319) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.09699301, -0.042629026, -0.036809254, 0.01564525, 0.09967149, -0.05646432, 0.087140135, 0.005995016, -0.31824094, -0.033822026, 0.12647352, -0.054930367, 0.42813843, 0.08539457, -0.16619459, 0.10482039) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.13355072, -0.1398708, -0.0535573, -0.013974081, -0.09811669, 0.065450095, 0.12138858, 0.14440864, 0.395299, -0.3014649, -0.08687099, -0.1712357, -0.17523703, -0.10419107, -0.022919776, -0.07295364) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.3583923, 0.20271356, 0.07793007, -0.24301155, -0.31042212, 0.23732007, -0.17276785, -0.23999928, 0.24065487, -0.22023919, -0.4366141, 0.58161026, -0.108157985, -0.22389396, 0.09413943, -0.14458662) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.21946962, 0.19744064, 0.17899306, 0.57837015, -0.43174395, 0.5382358, -0.096654564, -0.041815612, -0.14122425, -0.035595104, -0.017977988, 0.11895852, -0.018205827, 0.2161415, -0.17525733, -0.39580378) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.20543826, 0.028349113, -0.107877836, -0.06283416, -0.24875186, 0.04345355, 0.0684472, 0.09135805, 0.32029498, -0.041014366, 0.38148054, 0.43634972, -0.49170062, 0.045019966, 0.17060433, 0.22288452) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.098896764, -0.0745146, -0.098031536, -0.005049592, -0.106265344, 0.09814443, 0.39199772, -0.10718638, -0.22362246, 0.36535066, -0.14643857, -0.5449362, 0.22096305, -0.017985612, 0.2595698, 0.017525416) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.3690752, -0.026919361, 0.094163805, 0.10050452, -0.46962908, 0.35198364, 0.18498518, 0.17807995, -0.5514368, 0.39219773, 0.70178145, -0.44629836, -0.0819333, -0.016724462, 0.09550119, -0.07380345) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.01474241, 0.0050134705, -0.04199746, -0.06627894, -0.3839062, 0.12917379, 0.174631, 0.07886594, 0.0057149096, -0.19864379, -0.2551633, 0.025764206, 0.014774413, -0.21551472, -0.2629304, -0.04914636) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
