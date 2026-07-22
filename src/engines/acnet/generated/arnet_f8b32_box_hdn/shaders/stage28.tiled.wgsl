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

  var result: vec4f = vec4f(-0.2706014, -0.02014091, 0.34272534, 0.089680284);
      result += mat4x4<f32>(0.034191225, -0.05088253, -0.04293315, -0.028423514, -0.023786003, -0.16745326, 0.22003263, -0.079907514, 0.10242313, -0.05743934, 0.16534095, 0.55437386, 0.13812797, -0.19680999, -0.15020607, 0.25899446) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.040843263, -0.011975149, -0.03298684, 0.035919417, -0.17600347, 0.0691377, 0.24679573, -0.0051715733, -0.13144726, 0.15714583, -0.032815676, -0.012468273, -0.035905533, 0.2899881, -0.18177474, -0.13519663) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.06722783, -0.07775267, 0.06569213, 0.15354823, 0.12662396, 0.059337504, -0.007997028, -0.16449232, -0.033782728, 0.14832494, 0.029772216, -0.0384698, -0.058398694, -0.10408594, -0.07183799, -0.07824374) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.1423725, 0.30654484, -0.23513184, -0.17309311, 0.21108629, -0.016318498, -0.22896332, -0.54619634, -0.14795953, 0.18908975, 0.20831126, 0.1753555, -0.08878404, -0.6097783, -0.4501315, 0.0046161064) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.010430353, 0.37695277, -0.17086388, -0.19066721, 0.10009762, -1.0838776, -0.9990868, 0.1508047, -0.20097181, 0.043777127, 0.52162075, -0.26861832, -0.15871753, -0.22618683, -0.20249218, 0.6689608) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.046756435, -0.14327154, 0.026797399, -0.019757142, 0.022417331, -0.3940297, 0.12330803, 0.44317648, -0.15914157, -0.24739727, -0.0855533, -0.066359386, -0.074155636, -0.07560272, 0.09013304, -0.114470765) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.05416225, -0.062276393, 0.19092222, 0.11717315, -0.18133944, -0.18695617, 0.22142114, 0.04597239, 0.032621324, 0.09721296, -0.040607333, 0.06788794, -0.22439666, -0.0009949339, -0.11661782, -0.077215455) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.1371913, -0.11861573, 0.21806976, -0.04810127, -0.03727767, 0.026254132, -0.07428038, 0.36022273, -0.0040121973, -0.40593472, 0.09343349, -0.0020325044, 0.02570239, 0.31291234, -0.040270634, 0.18405959) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.0022741249, 0.102979854, 0.13079858, -0.074812174, 0.03957461, 0.051632144, 0.01560175, 0.18128079, 0.21026231, 0.006657691, -0.19295536, -0.02782983, -0.024507375, -0.09262518, 0.025157753, 0.056510545) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.067910984, -0.13456358, 0.02011048, -0.2258991, 0.036687963, 0.023336116, 0.12808013, 0.1747763, 0.018249976, -0.12226169, 0.12688388, 0.22459428, 0.00074195844, -0.15915953, 0.11320112, 0.2277084) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.10662254, 0.17228636, -0.0941476, 0.061383028, 0.0020386146, 0.023043863, 0.022477893, -0.07311749, -0.08176176, -0.35881436, 0.34296694, -0.24575666, 0.18218859, -0.042260576, 0.17298952, 0.15819372) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.023584884, 0.14214148, -0.09186551, 0.10987841, 0.083624184, -0.08530456, -0.038949, -0.2149251, 0.053967115, -0.0059381453, -0.17349394, -0.043351643, 0.16798694, 0.09408199, 0.14524074, 0.093000814) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.040384848, -0.03952935, 0.039684482, -0.044682022, 0.017828377, 0.018879924, -0.24380815, 0.24081863, 0.109293476, -0.25754663, -0.2412006, -0.09308098, -0.026604347, -0.11581869, -0.26325142, -0.1958349) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.08630351, 0.27706194, -0.53708756, -0.19784799, 0.08312474, -0.033208407, 0.008501625, 0.7312819, 0.0114242025, 0.16544543, -0.18028753, -0.1956726, 0.0279295, 0.38767713, -0.096041575, -0.283344) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-6.744244e-05, 0.030614106, 0.09136011, 0.0024699217, 0.09099949, 0.10020509, -0.119301334, -0.09529058, 0.1340196, -0.104822, -0.017045775, 0.07949186, 0.05576198, 0.20301655, 0.18644717, -0.060743872) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.10069067, 0.20807543, -0.26681504, 0.08112302, -0.11247435, -0.12784182, 0.3135701, -0.0836718, -0.13944064, 0.027828269, -0.037897106, 0.13207836, 0.016952494, -0.025247116, -0.38498428, -0.037974533) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.16757974, 0.6620304, -0.47837636, -0.28206065, 0.13694203, -0.016772456, 0.7367956, 0.5798664, -0.101576105, 0.07071489, -0.6155441, 0.3636674, -0.002547352, 0.20038974, -0.03765169, -0.08843637) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.12758069, 0.03758044, -0.53912175, 0.302275, 0.033311374, -0.3079747, -0.026663316, 0.28971353, 0.054130644, -0.21802013, 0.37829053, 0.05316396, 0.009846424, 0.00869405, 0.21268657, -0.14583823) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
