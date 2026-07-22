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

  var result: vec4f = vec4f(0.37723106, -0.2660941, 0.38799146, 0.078478515);
      result += mat4x4<f32>(-0.024804505, 0.031612616, -0.12614813, 0.035321593, -0.07622137, 0.2741172, -0.20082952, -0.12112842, 0.1266744, -0.11951652, 0.1682305, 0.012705623, 0.16998073, -0.18259051, 0.076687366, 0.010780404) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.193669, 0.004077638, -0.087931, -0.038497493, -0.09272762, 0.03337746, -0.05836037, -0.10582472, -0.14844452, 0.04973003, 0.14791541, 0.22656867, -0.043693136, 0.2660853, 0.16259062, 0.12374188) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.07990333, -0.07525691, -0.05918728, 0.055667255, -0.01799328, 0.08445559, -0.02075575, -0.0994066, 0.22096911, -0.17661339, -0.09552158, 0.109884456, 0.055571437, -0.10459425, 0.101159625, 0.113987386) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.3625597, 0.37471458, -0.17967223, 0.21160385, -0.365841, 0.27072972, 0.018468207, -0.015581309, -0.022479396, -0.1435982, -0.061253373, -0.2950863, -0.27301928, 0.21869256, -0.02263642, -0.39620304) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.0070190737, 0.43123862, -0.29151806, -0.08183731, 0.5665611, -0.01436368, 0.21878111, -0.09009872, 0.0046413224, 0.2878012, -0.5214914, -0.2802939, -0.036893878, 0.34206063, -0.23742707, -0.09434155) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.24004443, -0.3107067, -0.20679168, 0.036759842, 0.4048602, 0.36503446, 0.33465853, 0.14949761, 0.07089988, 0.13729374, 0.076264024, 0.19702213, -0.10767861, -0.072157554, -0.012370035, -0.02157452) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.007783528, -0.2516361, -0.119913705, 0.05495082, -0.026995156, 0.19222558, -0.06283596, -0.042412035, -0.2933488, 0.13541403, 0.03432872, 0.07467886, -0.84500194, 0.26282498, -0.12596896, 0.03579611) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.4284896, -0.3666417, -0.05348908, 0.060885552, 0.11982815, -0.20911369, -0.09267341, 0.0800216, 0.11865599, -0.4371233, 0.18903735, 0.47271207, -0.042003643, -0.2122226, -0.21413462, -0.21556674) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.1850124, -0.15265705, -0.077460654, 0.0686277, 0.71410954, -0.36925885, -0.023382317, 0.15032046, -0.20832428, 0.12752503, 0.0846482, -0.029301526, 0.25197393, 0.23129058, -0.08657492, -0.08551231) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.033687234, -0.061297476, -0.25041288, 0.005871313, 0.07705859, -0.23808007, 0.013017277, -0.03196444, 0.081180036, -0.20506798, 0.016089275, 0.16783069, -0.12924573, 0.0039260443, 0.021870188, -0.11942183) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.17537531, -0.353961, -0.19479729, -0.018168503, 0.061130125, -0.050778516, -0.13573818, 0.1197017, 0.03584131, -0.09010148, -0.028117035, -0.10810544, -0.05561648, 0.05753005, -0.011625942, 0.15741402) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.008001133, -0.039454065, -0.09390166, 0.028029546, -0.046206895, -0.033139016, 0.040438626, 0.2092595, 0.0019155036, 0.08286953, 0.020926146, 0.10023745, -0.0034834503, 0.022072064, -0.14029574, -0.120399036) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.3525101, 0.08961671, -0.08463015, 0.05950797, -0.028336942, -0.41329405, -0.1346705, -0.119656295, 0.31547782, -0.51827466, -0.026748324, 0.27181467, 0.22386424, -0.17653559, -0.011394377, -0.26223347) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.44805813, 0.17476605, 0.2651483, 0.24442849, 0.29280898, 0.03369312, 0.36881503, -0.06800182, 0.54184115, 0.20588166, 0.39052725, 0.62929845, 0.25358367, -0.33294275, -0.23286264, 0.23933113) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.06606093, -0.16484046, -0.08182526, 0.063849136, -0.057829414, -0.367049, 0.16291828, 0.29833934, -0.16994582, 0.1603341, -0.101710275, -0.04847311, 0.011473404, -0.030300908, -0.0048245555, 0.17813899) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.54118043, 0.18052985, -0.20596461, -0.43559593, 0.12615973, -0.113264136, -0.102937534, -0.14433542, 0.19673656, 0.026160035, -0.03090072, 0.013846399, 0.059441984, 0.30981326, -0.081883185, -0.020927161) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.074438624, 0.4503344, 0.3027434, 0.30399352, 0.63077396, -5.0267714e-05, -0.21642223, -0.44094136, -0.12598126, -0.121341445, -0.045188937, 0.14924929, -0.17734526, 0.12775968, -0.16468999, -0.15969308) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.13124758, -0.354129, 0.059430555, 0.121206574, -0.16913772, 0.07835135, -0.121205516, -0.14791389, -0.07182323, 0.014514283, 0.0067257793, 0.047494333, 0.001531797, 0.10872149, -0.12183851, -0.04114508) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
