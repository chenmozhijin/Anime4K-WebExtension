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

  var result: vec4f = vec4f(-0.13614878, 0.14549226, 0.07731599, -0.105041295);
      result += mat4x4<f32>(-0.19460592, -0.05868211, -0.21977781, -0.20488416, -0.19782399, 0.035155315, -0.2233499, -0.38561088, -0.070225015, -0.0678174, -0.036537267, 0.09629294, 0.09404503, 0.11410057, -0.0922236, -0.044084035) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.21324573, 0.09970862, -0.119497746, -0.48265243, -0.103020504, 0.008693679, -0.55990726, -0.22275515, 0.004051886, 0.20841292, -0.26916915, -0.13720258, -0.048420157, 0.05638605, 0.1050126, 0.002706711) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.012970856, -0.16570346, -0.022886798, -0.24721673, -0.12752582, -0.087378375, -0.061083607, 0.30169174, -0.10970647, 0.012610851, 0.015870841, 0.35664916, -0.0132809235, 0.010319682, 0.061412413, 0.076878764) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.04341457, 0.17017458, -0.018234642, -0.029687654, -0.25227425, 0.24897762, 0.24259858, -0.16169943, -0.039400443, -0.11203684, 0.3420889, 0.600977, -0.02326348, -0.42825693, -0.18428674, 0.4905346) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.36409107, 0.44518423, 0.5034323, 1.2441674, -1.0508702, 0.058814995, 0.5936466, 0.5551916, -0.043167815, -0.15385346, 1.3938586, 0.6976365, 0.08925728, -0.26426995, 1.0382477, -0.22374584) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.029967656, -0.2450117, 0.1646992, 0.05843209, 0.3832199, -0.3484426, 0.035746627, 0.14813048, -0.039425734, 0.109355256, 0.009651419, 0.21597078, -0.14461413, -0.2019153, -0.22001576, 0.072565086) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.017606854, 0.0013063744, 0.0024171171, 0.24255802, -0.027928947, 0.10961335, 0.12372016, -0.12457602, 0.14510652, 0.17589727, 0.2706523, -0.077249646, 0.032811593, -0.1763314, 0.032259747, 0.52797043) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.036484253, -0.20467182, -0.28532487, 0.15186238, 0.2457833, 0.05324048, 0.1634646, -0.065820575, 0.2252592, 0.15858863, 0.3732214, 0.22864282, 0.2118214, -0.03572808, 0.16355407, -0.37038556) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.07052298, 0.041270826, -0.07109841, -0.6508626, 0.07758409, -0.07038007, 0.10001255, 0.060436938, 0.008715045, 0.21425183, -0.03646794, 0.21990426, -0.020931186, -0.066087835, -0.07744076, -0.08196915) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.08506243, -0.047010582, 0.20303504, 0.28724045, 0.011949664, -0.245578, 0.014240855, -0.46343505, 0.019347014, -0.05903285, -0.11122692, 0.017050708, 0.055253502, -0.008673464, 0.22328193, 0.029799264) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.086050056, 0.040218357, 0.40961462, 0.1868578, 0.002933079, -0.018682623, -0.1503751, -0.0002568582, -0.00092587824, -0.054135133, 0.21497487, -0.16236414, -0.16052052, -0.2903938, -0.38567823, 0.019117406) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.11111628, -0.06061538, 0.17191823, -0.17937894, 0.08476499, 0.24762388, 0.02123985, -0.29833287, -0.05439328, -0.007250776, 0.06150616, 0.12920411, -0.06683284, 0.21304236, 0.020231469, 0.10617252) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.16796544, 0.017379617, -0.033744067, -0.07152145, 0.31688806, -1.2945712, -0.23801543, 0.1069665, -0.21135502, 0.26181558, 0.050203193, -0.5285891, -0.025624244, 0.14111607, 0.0924609, 0.22436236) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.6132086, -0.23064533, -0.37346262, -0.35698685, 0.32799616, -0.31065908, -0.16061537, 0.28466046, -0.1187386, -0.12644652, 0.065122865, -0.28423694, -0.07961615, -0.6554357, 0.23747727, 0.63429546) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.27276367, 0.3689346, 0.17616169, 0.09592082, 0.12876807, -0.14351095, 0.01346339, 0.15254775, -0.019374596, -0.07148266, -0.07134818, -0.058841687, 0.066152655, -0.5234273, -0.030435245, 0.015730245) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.027326647, 0.08516869, -0.040599216, -0.007838668, -0.038058292, -0.52551687, 0.0051898733, 0.089726776, 0.006796089, 0.13932143, 0.052194197, -0.074821904, 0.051205948, -0.07614385, -0.028310534, -0.046230707) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.09146335, 0.00045893382, -0.113080055, 0.30147478, 0.1638207, -0.15646045, -0.01955142, 0.20639558, -0.21198578, 0.15434834, -0.26842594, -0.015004386, 0.10737044, -0.4111296, 0.13387707, -0.29357213) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.12062473, -0.1436911, -0.063058116, 0.07168503, 0.032780766, -0.04795195, -0.1214457, -0.17799394, -0.029402448, 0.07580952, 0.024148125, -0.045899026, 0.026083736, -0.23761146, -0.0066368426, -0.26267138) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
