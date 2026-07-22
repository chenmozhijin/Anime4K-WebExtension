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

  var result: vec4f = vec4f(0.02284258, 0.10150627, 0.04385285, 0.13121502);
      result += mat4x4<f32>(0.14237708, 0.30793822, -0.014220463, 0.21836215, 0.008013261, 0.0033971185, -0.049516194, -0.20012806, -0.2334159, 0.19106282, -0.11217986, -0.07543806, -0.0610133, -0.35173878, -0.08511527, 0.0034703927) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.043717418, 0.6123166, -0.09534018, 0.1266678, 0.056118764, -0.19508982, 0.13507845, 0.10693357, -0.12365919, 0.26353478, -0.08742379, -0.08319563, 0.03995174, -0.21119499, -0.11418941, -0.052251935) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.4582363, 0.17454357, -0.46852276, -0.11139426, 0.032043163, -0.060711335, -0.20641012, 0.22479072, -0.06790383, 0.1988787, -0.0024798138, -0.020259766, -0.119041376, 0.01417688, -0.43549788, 0.10328992) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.21564032, -0.018328788, -0.123831734, 0.26922444, 0.1942565, -0.13777639, 0.15342958, -0.33226463, -0.19270515, 0.12700745, -0.23018613, 0.043114442, -0.06901122, -0.24330261, 0.049520772, -0.09829952) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.2254421, 0.09677204, 0.35151508, -0.08141178, -0.16745828, -0.47877344, 0.5254614, -0.062296692, -0.21457213, 0.093473114, -0.09284583, -0.13964388, -0.31822357, -0.38655594, -0.01532182, -0.021384727) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.106678545, -0.17385748, 0.028656011, -0.09078636, 0.059843797, 0.12726666, 0.236394, -0.0034703023, -0.09111827, 0.114154, 0.010275816, -0.05310065, -0.090287864, -0.18625325, -0.21239837, 0.20160958) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.18590936, -0.32282895, 0.2500096, -0.08115766, 0.03865045, 0.17305171, -0.019067714, 0.06398496, -0.123246685, 0.17587373, -0.17270684, 0.08611971, -0.15173289, -0.078812756, -0.07551916, 0.03720969) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.024886401, -0.0929697, -0.039105512, 0.04157886, -0.031541515, 0.24212697, -0.0067652888, 0.09036604, -0.17164998, 0.1966546, -0.25845984, 0.045108136, -0.09483693, 0.08388863, -0.18886773, -0.09285132) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.15868038, -0.4940013, 0.07434279, -0.29187226, 0.026751302, -0.05228374, 0.03444054, -0.027701328, -0.11955212, 0.17108141, -0.13696536, 0.01487945, -0.17148644, -0.07915055, -0.31708822, 0.07026817) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.049487762, -0.07299589, 0.36959562, -0.23437856, 0.19057609, 0.3863648, 0.32076985, -0.055955864, 0.28557172, -0.12874162, 0.2517554, -0.016669169, 0.0011650012, 0.13268502, 0.13289618, -0.08065747) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.10919333, -0.11707142, 0.26746666, -0.16940822, -0.005147319, 0.04707788, -0.41468656, 0.28525856, 0.17744045, -0.03255887, -0.07086543, 0.391355, 0.0038999657, -0.3562821, 0.1813048, -0.034013364) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.197556, 0.013765283, 0.15541516, 0.0042201886, 0.0018248592, 0.11558798, -0.05587181, -0.22431546, 0.21657366, 0.5318957, -0.007210935, 0.24269788, 0.24353157, -0.24516524, 0.20636772, -0.11602355) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.51013273, 0.36769047, -0.14001723, 0.23517227, -0.19529003, 0.021052312, -0.27906004, 0.28163347, -0.0446774, -0.4574035, 0.06413086, -0.07238859, -0.18631653, -0.30657688, -0.33201042, -0.26038522) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.050036855, 0.18676654, -0.5057149, 0.15427136, -0.12768584, -0.29422566, -0.15439817, 0.10997019, 0.015794978, 0.23850572, 0.13541205, -0.24902238, -0.10295234, 0.10289205, 0.1745232, -0.07845291) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.36905932, 0.26204762, -0.24548112, -0.25155622, -0.17090128, 0.27443892, -0.4918233, -0.14723237, -0.23257145, 0.24866858, -0.11810227, -0.14862266, -0.3079149, 0.049024135, -0.1568697, 0.31813288) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.2686868, -0.16651908, 0.28148332, -0.2536774, 0.18670557, 0.12643671, -0.05058526, 0.22755304, -0.010775367, -0.45299348, 0.096936874, -0.17133266, 0.20650989, 0.10692916, 0.1421628, -0.17570518) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.009292522, 0.043715302, 0.0033001006, -0.014840176, 0.11007541, -0.06787715, 0.31697214, -0.18000907, -0.28472677, -0.089807265, -0.12050982, -0.059671376, 0.05539905, 0.042878173, 0.18636307, -0.05287937) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.2756298, -0.0054299505, 0.09551957, 0.09278426, 0.1024674, 0.06385035, -0.17550945, 0.1413403, -0.18136516, 0.24723573, -0.23217945, 0.09631807, 0.03497935, -0.14146078, -0.04285322, 0.074569225) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
