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

  var result: vec4f = vec4f(-0.20093288, -0.12871861, 0.2481858, 0.14514318);
      result += mat4x4<f32>(0.01903416, -0.02851133, 0.06887451, -0.15012036, -0.040625628, -0.10082408, 0.1026232, 0.21352036, -0.17371462, 0.32372165, 0.1384814, 0.24423268, 0.0420603, -0.23803352, -0.08527271, 0.19768754) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.102181904, 0.10277162, -0.050615262, -0.112323, 0.09942424, 0.042857647, 0.31248948, 0.39933065, -0.3655855, 0.1721771, -0.37473342, -0.015332333, 0.006180018, -0.0325373, 0.19135971, -0.13137415) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.006054069, 0.023179132, 0.06618223, -1.0688726e-05, 0.09752965, 0.10478201, -0.07604353, -0.060670644, 0.12385128, 0.21494399, -0.005767689, 0.034487657, -0.01774352, -0.22083658, -0.05869709, 0.13415192) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.3461281, -0.018486915, -0.25256127, -0.4558192, 0.12773313, -0.56126994, -0.17770652, -0.32096133, -0.009793741, 0.3749855, 0.2167047, 0.30605018, -0.07622091, -0.49351895, -0.18424481, -0.38021165) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.0823248, 0.044012584, 0.13214743, -0.13538362, 0.13643907, -0.56258154, -0.76488465, 0.36558598, -0.26444203, 0.0029036305, 0.18378308, 0.18481833, -0.25215095, 0.046361305, -0.11235956, 0.112160616) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.017394438, -0.16261166, 0.20167103, -0.08067014, -0.03890436, -0.28001156, -0.1439124, 0.3472613, -0.29645926, -0.34602687, -0.08073501, 0.2310135, 0.06554689, -0.12208394, 0.31363773, -0.17613767) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.1390645, 0.0837583, -0.14446184, -0.063176274, -0.17299135, -0.380539, 0.1911113, 0.05889616, 0.103086814, 0.14616458, -0.072818875, -0.020124812, -0.22436963, -0.13912702, 0.009670149, -0.040205885) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.054208204, -0.043803867, 0.11387342, 0.06890112, 0.0038497185, 0.08861675, 0.16149236, 0.15946303, -0.18340206, -0.28838253, -0.06525466, -0.05642312, -0.006010702, 0.24658279, 0.1328526, -0.044867154) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.03351712, -0.0052129705, 0.06418185, -0.047902722, 0.085550345, 0.19189608, -0.15101868, 0.07131089, 0.25761443, -0.095915645, -0.12421413, 0.071552895, -0.10232403, -0.13839698, 0.06437544, 0.03172497) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.08058645, -0.10580678, -0.008682169, -0.038813613, -0.018177135, -0.059241675, 0.043070942, -0.02517716, -0.10340811, -0.10126962, -0.02368909, 0.28703338, 0.03880827, 0.13956562, 0.019311048, -0.08301437) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.118269816, 0.18254647, 0.021119805, -0.12946059, 0.1398119, 0.08603742, -0.20466511, 0.271701, -0.10247561, -0.39910725, 0.35586658, 0.051376887, 0.23431565, 0.3004048, 0.1367596, -0.06562852) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.010614379, 0.24885578, 0.3077592, -0.030952686, 0.13911001, -0.12356678, -0.022749536, -0.08340773, 0.0413433, -0.17807648, 0.039262645, 0.07679959, 0.16484745, 0.11653314, 0.13983397, -0.13021421) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.09988019, 0.013184836, -0.12348207, -0.19286844, 0.011495487, 0.0988643, 0.019401697, 0.351818, -0.006515489, -0.27468142, -0.18119279, -0.05332373, 0.27716896, 0.0076058665, -0.18852358, -0.52451724) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.21625602, 0.54433984, -0.345294, -0.50376076, -0.048300046, 0.10575661, 0.15264067, 0.71136415, 0.075722314, 0.03826406, 0.047939304, -0.13898568, 0.014847376, -0.024903324, -0.24396907, -0.26651993) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.04302426, 0.20411049, 0.42403802, 0.070483655, 0.21106419, 0.5900464, -0.22849466, -0.023105849, 0.14620484, -0.09001163, 0.07642922, 0.08434699, 0.16903676, 0.013994863, 0.03329657, 0.00063171925) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.031272728, 0.3123319, -0.15257217, 0.05306731, 0.06726183, 0.20417777, 0.044284105, -0.19305122, 0.0065635443, -0.05874401, -0.09426733, 0.15073268, 0.06397513, 0.05130393, 0.01092414, -0.0827358) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.12439116, 0.4074971, -0.4498688, -0.31948766, -0.052721757, 0.038117997, 0.364204, 0.04337003, -0.057829652, -0.1702992, -0.1245851, 0.050520822, -0.0476532, 0.030545056, -0.014638071, -0.1731245) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.016894292, 0.021842321, -0.05251217, 0.11583763, -0.08111305, -0.2277836, 0.23713925, 0.091739886, -0.045566604, 0.2348632, 0.04105856, 0.11342739, -0.07142238, 0.02260604, 0.10846154, -0.028932685) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
