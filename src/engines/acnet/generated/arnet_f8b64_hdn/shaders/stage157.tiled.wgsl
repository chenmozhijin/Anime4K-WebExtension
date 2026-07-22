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

  var result: vec4f = vec4f(0.17460342, 0.2978018, 0.6260526, 0.078379825);
      result += mat4x4<f32>(0.048952926, -0.16272908, 0.13264509, 0.0649707, -0.15532485, 0.24128221, -0.2811305, 0.018119399, 0.1546674, -0.23711196, 0.1580971, 0.109030314, -0.112083025, 0.1573358, -0.180299, 0.031542547) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.08375107, -0.620426, 0.37952995, -0.03880375, -0.25973594, 0.33320352, -0.40483797, -0.018663337, 0.18798117, -0.34460658, 0.10955053, 0.16960533, -0.21632321, 0.2521777, -0.4118535, -0.036682468) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.13268127, -0.25217623, 0.6408179, -0.2011395, -0.21921399, 0.23839931, -0.38487303, 0.013165574, 0.11653388, -0.1531482, 0.06136014, 0.12752049, -0.1542727, 0.22674206, -0.33077568, 0.026355483) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.16799524, -0.20228957, 0.15379953, 0.036982615, -0.20326021, 0.24843514, -0.38530588, -0.0073902737, 0.18352965, -0.41343537, 0.23698284, 0.13251308, -0.23184702, 0.3340088, -0.3480651, -0.036886286) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.2271397, 0.23401779, 0.7070631, 0.12673335, -0.27442855, 0.38038388, -0.45829406, -0.04076191, 0.28128394, -0.45844895, 0.22339326, 0.21078694, -0.28603163, 0.5791715, -0.50404656, -0.0763174) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.07096753, -0.22069421, 0.15690652, 0.019245021, -0.26497322, 0.32615143, -0.5247918, 0.021264255, 0.20210856, -0.37387836, 0.22283621, 0.20264046, -0.23554532, 0.24768592, -0.39312735, -0.03048698) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.0038196885, 0.14285128, 0.012742845, -0.039509922, -0.11098749, 0.143097, -0.21272178, -0.013419959, 0.109336264, -0.25089717, 0.109463416, 0.093565665, -0.15765601, 0.23116055, -0.289876, -0.006443894) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.004034576, -0.36249933, 0.17389984, -0.07220671, -0.14425799, 0.23692782, -0.27461722, 0.016390584, 0.17853111, -0.37705252, 0.11150445, 0.18798819, -0.18189089, 0.32584545, -0.33301768, 0.0010624158) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.051709633, -0.20496991, 0.12338378, 0.038771424, -0.075865015, 0.15224747, -0.22791354, 0.038358286, 0.13201188, -0.21257572, 0.11665737, 0.103590906, -0.16964176, 0.34978178, -0.34579834, -0.09832984) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.2146822, -0.12758374, -0.12147941, -0.20696977, 0.08537034, 0.16169004, 0.26158535, -0.17255618, 0.060624473, -0.21256977, -0.12065572, 0.198478, -0.25555077, -0.57808334, -0.18135048, -0.034032334) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.014964587, 0.14578651, -0.046932682, 0.06376215, 0.13549876, 0.30912325, -0.3303747, 0.08366384, 0.17110881, -0.37506822, -0.06909205, 0.30013284, -0.20470616, -0.13046885, 0.05236579, -0.028592361) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.15574315, 0.7004093, -0.1606749, 0.3206062, -0.016127046, 0.095451765, -0.03381312, -0.10444814, 0.06929902, -0.35654402, -0.11194239, 0.22964242, -0.11907052, -0.02232132, -0.03533961, 0.05044716) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.103624366, -0.17213367, 0.06097405, 0.06946773, 0.06950114, -0.05481809, 0.08646142, 0.14081362, 0.13309954, -0.37123352, -0.0074312612, 0.2698529, -0.3372261, 0.16152439, -0.51811713, 0.009509183) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.15329784, 0.3998311, 0.08997456, 0.20484233, 0.029790957, -0.38977414, -0.23333083, 0.095716245, 0.23185578, -0.50536644, 0.00534982, 0.384498, -0.049438443, -0.27581388, 0.25370595, -0.24913085) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.1393013, 0.36672068, 0.23559152, -0.030585237, -0.07275252, -0.077426285, -0.20942189, 0.12941608, 0.19847392, -0.53683287, 0.031191962, 0.3236286, 0.08513477, 0.115328975, 0.15454404, 0.18508291) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.22741313, -0.47695297, -0.024354026, -0.32175505, 0.12225352, 0.13826217, 0.09671753, -0.079186976, 0.078958586, -0.30087057, 0.06357197, 0.14407916, -0.13770866, -0.18304098, -0.7729908, 0.40167585) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.20239502, -0.2502937, 0.24278237, 0.116083466, 0.06598512, 0.10271562, 0.27629122, 0.0024964504, 0.11665252, -0.43560287, -0.06549967, 0.2763343, 0.014946523, 0.27146348, 0.07071422, 0.15533555) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.14798188, -0.17962101, -0.098621406, -0.13478075, 0.092440575, -0.07815787, 0.1302953, 0.029024512, 0.09175068, -0.37388515, -0.082501814, 0.279238, -0.11449636, -0.33556896, -0.29242644, 0.2852579) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
