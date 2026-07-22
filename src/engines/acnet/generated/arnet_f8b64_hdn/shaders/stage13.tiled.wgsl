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

  var result: vec4f = vec4f(-0.26228353, 0.0873869, 0.17143025, -0.1891192);
      result += mat4x4<f32>(0.035958845, 0.06823006, 0.18975784, 0.3398428, -0.05263177, 0.041420545, -0.17844188, -0.30842963, 0.0080403425, 0.13546242, 0.1117672, 0.09965833, -0.27561435, -0.46361578, -0.17372496, -0.6278184) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.3012392, 0.23705629, 0.08822147, -0.18484162, -0.0809373, 0.026718594, -0.71932477, -0.45401257, 0.17968136, -0.084681086, -0.047060046, 0.5884896, 0.06139591, 0.18897344, 0.6792774, -0.2540809) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.1431207, 0.1603543, 0.09875082, 0.0625997, 0.14970112, -0.24140924, 0.07980682, 0.0571222, -0.0018291272, -0.056822, 0.4356755, 0.42694387, -0.13037238, -0.043638635, -0.0054964186, 0.6985864) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.21898368, -0.28809357, -0.018676173, -0.18414165, -0.30129144, 0.4382314, -0.018892799, -0.33189535, 0.083869345, -0.09113084, 0.25233763, 0.304919, -0.101025365, -0.71197194, -0.23242974, 0.26479524) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.37148044, -0.19926672, 0.7233344, 0.26514587, -0.68033653, 0.06292176, 0.47367728, 0.8836114, 0.21831508, -0.13187297, -0.04841061, 0.48913696, 0.48394093, 0.55214214, -0.48190042, -0.31051898) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.028602382, -0.09456254, 0.25465462, -0.06506874, 0.21007891, -0.48220196, -0.16840184, 0.27310565, -0.037255023, -0.1302852, 0.16178705, -0.21158239, -0.3408789, 0.0949395, 0.21073861, -0.19806837) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.06232473, 0.28545326, 0.22920541, 0.26536107, 0.0058238585, 0.24547103, 0.12375506, 0.06277544, 0.15507561, -0.21456107, 0.05367099, 0.25279182, -0.050152447, -0.2260853, -0.011119031, 0.018991094) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.031362135, 0.23443067, -0.06001691, 0.17650023, 0.14703122, 0.22472586, 0.417313, 0.14419237, 0.23465107, -0.024463767, 0.05545718, -0.16802193, 0.095458254, 0.096069336, -0.31556454, 0.07003828) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.040169664, 0.18956695, -0.09631781, 0.0590895, 0.11519395, -0.21866232, 0.023507519, 0.2041287, -0.37448674, -0.21019132, -0.21767862, 0.056013476, -0.1855119, 0.09023883, 0.025252188, -0.22139046) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.11381022, -0.2100851, -0.25754592, -0.10611288, -0.27610207, 0.10080849, -0.0960705, -0.1344081, 0.1374757, -0.27209294, 0.12733637, -0.20710139, -0.037646353, -0.05559009, 0.27350643, -0.10940818) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.0028959555, -0.0054709986, 0.17486216, 0.040074263, -0.0089390725, -0.17097414, -0.22038758, 0.0025821775, -0.1636095, -0.22502002, 0.22690926, 0.10293575, -0.09898822, -0.3485665, -0.5797392, -0.2643601) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.04400832, 0.021285625, -0.28632632, -0.06483092, 0.009508253, -0.4339335, 0.14681485, -0.14138483, -0.22410007, 0.015800733, 0.20755649, -0.06306287, 0.088140845, 0.030150155, 0.22016583, 0.19104216) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.051565975, -0.24045649, -0.0023368567, 0.169623, -0.28950822, 0.5755672, 0.16273876, -0.3882626, -0.08865889, -0.5028593, -0.22896978, -0.44645604, -0.22320004, 0.10298228, -0.044106536, -0.8214169) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.68676996, -0.063299194, -0.18605065, -0.47837117, -0.30520114, -0.055874966, -0.05363301, 0.41231155, -0.4090146, -0.2720453, 0.13741964, 0.22820246, -0.4891642, -0.030407693, 0.0010508262, 0.50967336) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.18011254, 0.30993524, -0.081620276, 0.0944954, -0.0016008642, -0.23101231, -0.17881191, 0.14923683, -0.14667198, 0.26836658, 0.030552935, 0.2447963, 0.173212, -0.22098218, -0.21432242, 0.15182012) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.15884961, 0.12536092, -0.006320808, -0.11199401, 0.008001645, 0.095839925, 0.044324473, 0.34993652, -0.09575789, -0.019230625, -0.4254283, 0.31316003, 0.110052176, -0.20828062, -0.21633057, -0.20457456) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.010167352, -0.17540826, 0.2059093, 0.07953027, -0.23410574, -0.255314, -0.05660006, 0.35759595, 0.121606655, 0.050266255, 0.24781953, -0.18592143, 0.30906728, 0.4286437, 0.4403348, -0.26968303) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.25793976, -0.19584228, 0.1898649, 0.34110507, -0.019655585, -0.036936752, -0.025079459, 0.031873178, -0.07495436, 0.3101511, -0.104410134, -0.00049079186, 0.009318588, 0.41982982, -0.023651544, -0.57429034) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
