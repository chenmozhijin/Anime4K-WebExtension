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

  var result: vec4f = vec4f(-0.14020121, 0.33000958, 0.5210162, 0.032806393);
      result += mat4x4<f32>(0.051181167, 0.07544266, 0.08925678, -0.056204695, 0.027880808, 0.12242668, 0.15380782, 0.086934984, -0.015560961, 0.061104704, -0.18919298, -0.09773228, -0.12434818, -0.22340104, -0.3014086, 0.011422674) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.0681964, -0.122636676, 0.01163825, -0.0665784, 0.06045681, 0.012465961, 0.10125214, 0.10284044, 0.042678125, -0.012305978, -0.26303628, -0.24890947, 0.5946444, 0.14512433, -0.12660244, 0.28513348) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.074417524, -0.028555902, 0.16658673, -0.11328646, 0.091232054, 0.03937144, 0.1166628, -0.083551385, 0.1155422, 0.1247786, 0.032509748, -0.080084845, -0.22211602, -0.3397234, -0.38638505, -0.03208242) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.07405022, 0.068727985, -0.08168773, -0.061631802, 0.35653317, -0.21635208, 0.6094586, -0.11115961, 0.20818555, -0.3343744, -0.3799274, 0.20973645, -0.21492389, -0.12597652, -0.21064988, -0.16915673) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.23304695, -0.20467852, -0.059464436, -0.140064, 0.14287116, -0.18173173, 0.4922608, 0.00075715984, -0.021381624, 0.13092488, -0.04818818, -0.9596306, 0.2181178, 0.45441085, -0.21051408, -0.15408523) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.019910725, -0.3010826, 0.37249574, -0.1099298, -0.019666903, 0.20433295, 0.016489709, 0.07961914, -0.25243765, -0.2817859, 0.060422458, 0.3485761, -0.29516768, -0.1846804, -0.06842161, -0.01284208) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.0025297422, 0.083516814, 0.04683638, 0.012369355, 0.34935927, -0.014179167, 0.41309705, 0.09050484, -0.17768297, -0.1326602, 0.053592812, 0.067390524, 0.013629021, -0.083537266, -0.117811136, -0.22538528) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.09776332, -0.1550444, -0.1254828, 0.1080047, 0.059651516, -0.07736145, 0.2647875, -0.13078217, -0.4886579, -0.19049972, -0.11885188, 0.64153326, -0.07237531, -0.14376935, -0.18723673, 0.15745834) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.09165516, -0.04675317, -0.08906097, -0.065047845, -0.092099875, 0.11724058, 0.14218989, 0.033294108, 0.034048397, 0.099135384, -0.08585625, 0.16146992, -0.05196451, -0.06547683, -0.13434672, -0.06280094) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.014088813, -0.12252321, -0.040515766, 0.16807318, 0.08604373, -0.10573882, -0.029059116, -0.0094293635, -0.077923246, 0.1323401, -0.284246, -0.01650018, -0.050218306, 0.07534338, 0.019937005, -0.089002185) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.08677636, 0.041323017, -0.12418327, 0.13023996, -0.05675909, -0.08217653, 0.16184866, 0.043133643, -0.23226446, 0.047112342, 0.20310925, 0.12132111, -0.15674245, 0.19781637, 0.29542056, -0.16024649) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.07575466, -0.056199916, -0.108704224, 0.15909554, 0.061291754, 0.0039607035, 0.01386237, 0.027050301, 0.17671989, 0.11754804, 0.3095395, 0.15365735, -0.010680512, 0.15477829, 0.006371009, 0.023118684) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.24122335, -0.23273134, -0.11920301, 0.1715663, -0.20557691, 0.022453468, 0.16498579, -0.13393034, -0.24194285, 0.067451954, -0.6206614, -0.013699993, -0.10236044, 0.052984893, 0.15395856, -0.14984599) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.15371922, -0.40027234, -0.12952131, -0.2841742, -0.56144303, -0.62135875, -0.5805677, -0.46954364, 0.3148814, -0.58477736, 0.6586666, -0.5212754, -0.5798124, -0.4411653, -0.32248282, 0.091860265) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.023025416, -0.023173869, 0.019935012, 0.21377616, -0.22940172, -0.004489228, -0.11722809, -0.1120955, 0.23986447, -0.08138366, 0.164368, -0.032509886, -0.1819856, 0.0065109236, -0.05201702, 0.04587112) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.0638272, -0.07868807, 0.1035444, 0.16486505, -0.0237111, 0.088637784, 0.08812717, -0.16990316, -0.18814449, 0.10119909, -0.41256532, 0.09870331, -0.00469582, 0.007840116, -0.0249185, 0.015195624) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.08107718, 0.04879829, 0.08417571, -0.21357551, -0.077603236, 0.20932764, 0.13266864, -0.32661024, -0.028524984, 0.21424188, -0.672019, 0.25260344, 0.13674586, 0.07514743, 0.051994342, -0.1692681) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.086487584, -0.08635513, -0.053728502, 0.16871828, -0.06112221, -0.03090217, -0.157221, -0.08800314, -0.19032106, 0.022257516, -0.12726691, -0.054845154, -0.08941766, -0.10875928, -0.07994288, 0.008473004) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
