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

  var result: vec4f = vec4f(0.08966861, 0.15652633, 0.15510318, -0.06954588);
      result += mat4x4<f32>(-0.042338714, 0.02254768, -0.07243781, -0.110057354, -0.042711932, -0.03919806, 0.030073537, 0.011147599, -0.06649447, 0.4280152, 0.18273413, -0.005981856, 0.31169307, -0.13488835, 0.2617487, 0.59400934) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.09977542, -0.25761947, -0.10621839, 0.027723609, -0.042158585, 0.074406914, 0.0982434, -0.23708685, -0.13182712, 0.28705528, 0.16727473, -0.25314644, 0.106593736, 0.04085693, 0.015711702, 0.28621086) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.066313416, 0.077822484, 0.16123582, 0.032007445, 0.16196036, 0.04785935, -0.04552019, 0.07767645, -0.19084495, -0.31187254, -0.41165307, -0.44816524, -0.05198497, 0.77642494, 0.3542262, -0.07018504) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.06830029, 0.02761023, -0.15546407, 0.05669685, 0.07615039, -0.011239634, -0.123093225, 0.09399439, 0.1322314, 0.5526541, 0.45512834, 0.6580856, 0.12076706, -0.27488676, -0.019538091, 0.27264202) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.71171427, -0.13317986, -0.27058277, -0.13045445, 0.5468141, -0.01146675, -0.5400385, -0.15005067, -0.081110775, 0.113514796, -0.23096253, -0.044290766, 0.08490338, -0.106479876, -0.09918032, -0.1510113) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.108517215, 0.030623557, -0.06916897, 0.07157992, 0.009073757, 0.09670917, 0.0810233, -0.024765251, -0.26761585, -0.274874, -0.29895315, -0.57966155, -0.42764106, 0.16016872, 0.05414561, -0.574317) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.04785569, -0.013753487, -0.010197623, 0.23257394, 0.06635636, 0.0077237356, 0.0004964549, -0.0047490634, 0.2850591, -0.018695297, 0.32215267, 0.6198828, 0.1889776, -0.5391149, -0.2287752, 0.18175316) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.14285035, 0.022191582, -0.073473305, 0.054353096, -0.34559909, 0.078614034, 0.20232971, -0.0419661, 0.26185426, -0.16816728, 0.076868355, 0.1898542, -0.08901364, -0.10659271, -0.11610184, -0.13927294) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.04741992, 0.06517749, -0.036351647, -0.07096071, -0.059644572, 0.16867341, 0.09946716, -0.06306234, 0.037450064, -0.6190185, -0.34692243, -0.18003222, -0.2425688, 0.12222865, -0.25303748, -0.444218) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.082783595, 0.09767415, -0.049588874, -0.09120467, -0.071704224, -0.031256292, 0.0175506, -0.22900864, -0.039434683, 0.1600085, 0.23119791, -0.041053005, 0.46381518, -0.12499985, -0.40138167, 0.4735524) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.16609699, 0.034220826, -0.0019469713, -0.490048, -0.05841024, -0.19919671, -0.044845805, -0.26237157, -0.09883063, 0.2501304, 0.15839575, -0.13664953, 0.17971784, 0.1463908, 0.17492779, 0.08592998) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.030685937, 0.14751436, 0.18254611, 0.05417983, 0.0119469, -0.12794046, -0.023958126, 0.014756096, 0.008002548, 0.2615791, 0.08282663, 0.07748554, -0.10256809, 0.07796166, 0.09970857, -0.23966376) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.027105303, 0.015347947, -0.025505945, -0.015660571, 0.14118947, -0.22962976, -0.17146112, -0.02511353, 0.00669296, 0.2752958, 0.12358322, 0.25652698, 0.054920133, 0.13601534, 0.08882178, -0.029442092) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.053012785, 0.09508675, 0.2779022, 0.382261, -0.11618563, -0.1750179, 0.13265754, 0.25220525, -0.5345837, 0.12573852, -0.35455212, -0.5646448, -0.05801121, -0.028572189, -0.089218035, -0.2580772) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.12549976, 0.011289677, -0.029958675, -0.40904167, 0.09659105, -0.2978968, -0.2233584, -0.0050392044, -0.19912037, 0.34171197, 0.071425855, 0.19846565, -0.027658189, 0.037605494, -0.015121195, 0.1348194) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.099465944, 0.026870972, -0.15622084, -0.3019409, 0.2279742, -0.09737315, -0.10805942, 0.030581001, 0.06670888, 0.25296748, 0.19123521, 0.07659188, 0.036757015, -0.089034416, -0.18507972, -0.038182538) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.061435655, 0.0066202627, 0.0004264307, -0.17086653, 0.17332391, -0.16567785, -0.11991525, -0.034159094, -0.3627912, 0.34222406, 0.29961002, 0.23786888, -0.112396345, -0.18439125, -0.16190593, -0.23165108) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.015384994, 0.071773164, 0.06589773, -0.096874565, 0.013262126, -0.051967006, -0.06592285, -0.048732452, -0.06578977, 0.23020706, 0.2192656, 0.0711023, -0.19960196, -0.018426571, 0.11191093, -0.041441906) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
