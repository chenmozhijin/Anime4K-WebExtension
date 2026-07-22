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

  var result: vec4f = vec4f(0.12194844, -0.01619044, 0.14466755, 0.045887638);
      result += mat4x4<f32>(0.13460867, 0.1502951, -0.052859172, -0.0027258184, -0.19144958, 0.015179498, 0.042467408, -0.25410277, 0.024758996, -0.08032897, 0.0954816, 0.035837196, 0.22668009, -0.021586934, 0.1413955, 0.027320396) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.36093828, 0.18170801, 0.05380068, 0.40673518, 0.22532111, -0.081162296, -0.16883546, -0.23320737, -0.08598553, 0.15358554, 0.012598634, -0.1391125, 0.053913467, 0.05699031, -0.09325107, -0.030880587) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.027757553, 0.015543031, -0.017435513, -0.16154717, -0.24562597, 0.05109516, -0.09252963, 0.044239294, 0.089440905, -0.016982188, -0.30531362, 0.042947594, -0.048270963, 0.19606274, 0.04891792, -0.037278946) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.23863646, -0.4523954, -0.0997447, 0.358326, 0.16286978, -0.08585426, 0.08055183, -0.3147163, 0.11729383, 0.06516888, 0.16078338, 0.18654168, 0.6673335, 0.12052509, 0.24264334, 0.34490976) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.17143111, -0.3193715, -0.048834786, 0.060907174, 0.29383698, -0.21326078, -0.3412972, -0.16994298, -0.19088519, 0.32414103, -0.17467143, -0.5019374, 0.07306967, -0.49056205, 0.22335653, -0.4592075) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.1890337, -0.10001611, -0.33046734, -0.35253656, -0.0959134, 0.11579865, 0.28626445, 0.13774012, 0.008634047, 0.59709287, 0.12586792, 0.1387553, 0.07462767, -0.12104292, -0.3464757, -0.37351) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.32378972, 0.25894287, 0.15439533, -0.32769957, -0.04355178, 0.09167452, -0.058779847, -0.048465073, 0.25433874, -0.02818133, 0.11771309, -0.08472911, 0.14485766, -0.16730057, 0.1605243, -0.030018436) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.624627, 0.0655754, -0.14625534, -0.026829094, -0.019304823, -0.12375713, -0.07845153, -0.17606874, 0.47258002, 0.19092472, 0.26876926, -0.32148185, 0.047827233, 0.022654785, -0.09816394, -0.5245481) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.28946808, 0.10227498, 0.2563559, 0.046148185, 0.33251888, 0.016259791, 0.06435911, -0.035420123, -0.32861292, 0.26307827, 0.31324708, 0.057165474, -0.17566122, -0.10264012, 0.19047168, -0.14056134) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.052754533, 0.021754393, -0.19369781, -0.10532885, 0.06427208, 0.0058155437, 0.13809764, -0.091304466, 0.10947294, 0.029232172, -0.08591339, 0.0636846, -0.04970611, 0.11440478, -0.09589482, -0.08546289) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.12823011, -0.04799915, -0.18553033, -0.068196304, 0.079124965, -0.0034802693, 0.16813706, -0.08552354, 0.05931922, 0.0064559504, 0.025406133, 0.26074544, -0.25300813, 0.07907666, -0.22861522, -0.49403173) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.07826407, 0.028869204, 0.100845166, 0.22973464, 0.038508836, 0.07979958, 0.13742714, -0.026624504, 0.11357141, -0.009185276, 0.06583142, 0.13064146, -0.15655845, -0.028345766, -0.10485457, -0.19401428) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.051106125, 0.37927684, 0.058270916, -0.22185656, 0.12565707, -0.08459858, -0.037006248, -0.09739179, 0.0056263814, 0.13920586, -0.119056985, 0.15790386, -0.030000435, -0.26817507, -0.13951306, 0.003520705) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.4714122, -0.18315788, -0.10169979, 0.6665836, 0.36679342, 0.11197943, 0.44779208, -0.14506432, -0.79321057, 0.046958867, -0.2518014, -0.5552404, 0.5057527, 0.035377305, -0.56795067, 0.66897345) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.116362326, -0.17681798, -0.28883728, 0.036058813, -0.05333591, -0.053545456, -0.2581815, -0.4296912, 0.09532405, -0.1182438, -0.21795735, -0.02314059, -0.1506645, 0.031013098, -0.14626808, 0.003942769) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.050590843, 0.05715372, 0.010506949, 0.0023000687, -0.022520807, 0.12049792, 0.10172791, -0.053858712, -0.033300795, -0.073563114, 0.19989471, -0.041004337, 0.27367502, 0.18800798, -0.21455754, -0.0039077513) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.21728317, -0.23490177, -0.35505536, 0.108694784, -0.1679336, -0.19599703, -0.3248284, -0.21807687, -0.18507554, 0.092807405, -0.32865825, 0.12461429, 0.24064556, -0.0030441065, -0.16139826, -0.100614004) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.11723319, 0.05648317, -0.19593942, 0.058598347, 0.18818629, -0.031242782, 0.015904207, -0.35017523, 0.050549567, 0.05801188, 0.082433134, -0.030673714, 0.05396208, -0.029503504, -0.61768776, -0.18620056) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
