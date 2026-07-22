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

  var result: vec4f = vec4f(0.07298786, 0.09503288, 0.23082511, -0.3692585);
      result += mat4x4<f32>(-0.07957345, -0.14556105, 0.07785266, -0.069729134, 0.012348777, -0.13377044, -0.02199428, 0.14039049, -0.1996084, -0.14868763, 0.06914067, 0.15664603, 0.15764053, 0.19509083, 0.37197047, 0.17853598) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.0007883606, 0.047674324, -0.1369003, -0.09354168, -0.03071142, 0.065475754, 0.092647575, 0.1233775, -0.25170088, -0.23775938, 0.053579204, 0.1933766, -0.0721982, 0.09367896, 0.021695662, 0.2028465) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.13228458, -0.089939944, -0.13482983, 0.15274918, 0.08065384, -0.1323961, -0.27533537, 0.0439162, -0.045610163, -0.0992774, 0.023485193, 0.10918518, -0.20658971, -0.2730586, 0.2771922, 0.6153705) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.117254205, 0.10175291, 0.011414371, 0.115603074, 0.060754422, -0.39858398, -0.079962246, 0.057761077, -0.23164888, -0.33697304, -0.16781957, 0.34339118, -0.06327563, -0.102778606, -0.032358002, 0.07077678) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.2137229, -0.1840332, 0.1963797, 0.70170635, -0.09192241, -0.3236831, 0.071600206, -0.36103246, -0.2462905, -0.17157927, -0.12102811, 0.32618397, -0.23654822, -0.12355214, -0.02715903, 0.16501136) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.06374365, -0.0075209453, 0.10342607, -0.18199517, -0.37490702, 0.091896966, 0.13064541, 0.08723982, -0.10484581, -0.19683431, -0.16494608, 0.2482245, -0.002385025, -0.14967726, -0.21360302, 0.06711295) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.02117658, 0.33555195, 0.07318924, 0.22013839, -0.05359914, -0.12787195, 0.16987206, 0.12005078, -0.24158646, -0.3308174, -0.007979533, 0.39347678, 0.119917996, 0.19029284, -0.26594105, 0.012267395) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.33875722, -0.26124978, -0.15440202, -0.06914238, 0.13537809, -0.20966116, -0.1475171, 0.023797316, -0.42045605, -0.37395605, -0.15363239, 0.45286638, 0.094216675, 0.07497253, -0.30015326, -0.16524312) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.36121073, 0.35150343, -0.23497516, -0.2234243, 0.08326517, -0.071307726, -0.23559964, -0.013540811, -0.17149575, -0.12984158, -0.08615138, 0.11424087, 0.004332492, -0.37270173, -0.25665528, 0.0945068) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.027191507, 0.12086852, -0.014277529, 0.0055599017, -0.02418773, -0.14525364, -0.14023882, -0.09673656, 0.1304542, 0.056701943, -0.12085749, -0.2781389, -0.1325471, -0.17856723, 0.007740902, 0.24265064) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.055373542, 0.047411367, 0.07669831, 0.06774684, 0.0049621044, 0.4134753, -0.21147881, 0.12571612, -0.02793726, 0.10881691, 0.023237975, 0.44072452, 0.09316771, -0.051427774, 0.16465898, 0.25960442) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.007094207, 0.029009473, 0.03975594, 0.05843265, 0.01366705, -0.01653429, -0.047789786, -0.19091251, -0.03727163, 0.014982316, -0.0041222717, 0.039410103, -0.06854257, 0.08566061, 0.02361168, -0.0067840596) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.013470881, 0.05964884, -0.10109083, 0.21952836, 0.009821929, -0.27341545, -0.028307369, -0.106454976, -0.29635885, 0.004029933, 0.15696557, -0.17641883, -0.08068273, -0.35528284, -0.10174628, 0.29121837) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.02663511, 0.14915362, -0.121988855, 0.22699633, 0.046733864, 0.34549618, 0.026393883, -0.080728084, -0.24682009, -0.07049626, -0.30353358, -0.24075057, 0.23803443, -0.47280502, 0.42086, 0.51778036) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.15151344, -0.10518665, -0.014828412, 0.15848386, 0.06495086, 0.29029506, 0.066877805, -0.37297124, 0.16506545, -0.1147887, 0.32843328, 0.08789511, 0.06459438, 0.2793324, 0.12229781, -0.21370895) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.00036948474, 0.04477261, 0.05987153, 0.16010492, 0.098904975, 0.2677563, 0.15860468, -0.2085705, -0.0040685083, 0.13536014, 0.098327935, -0.016352165, 0.010654717, -0.15735096, -0.33785236, 0.22686383) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.22716661, -0.3034827, 0.071419716, 0.51438653, -0.12827691, -0.301951, 0.23338178, 0.1016279, -0.00013896768, -0.0104190335, -0.1841801, 0.098412134, 0.0917098, -0.0885003, -0.85662293, 0.56509495) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.0069052563, -0.20462534, -0.07136804, 0.27773407, -0.09057975, 0.11603101, -0.022082323, -0.093412325, -0.15985638, -0.1235616, 0.36087346, 0.034592647, 0.0973812, 0.049037267, 0.0028395148, -0.1416424) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
