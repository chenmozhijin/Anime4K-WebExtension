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

  var result: vec4f = vec4f(0.21166052, 0.071032725, 0.3986034, -0.3211812);
      result += mat4x4<f32>(-0.05565367, 0.070721425, 0.11016294, -0.13161592, 0.086004324, 0.06479154, -0.032346893, -0.2267753, 0.07255617, -0.27653995, -0.086232714, 0.63945717, 0.004152135, -0.1168006, -0.17419548, 0.024729243) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.27289173, 0.031498622, 0.17332365, -0.2184541, -0.21682078, 0.13043325, 0.41762093, -0.30577222, -0.26655635, -0.31202218, -0.08161148, 1.3453585, 0.051008422, -0.10264378, -0.08734426, -0.26072133) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.030522088, 0.057586294, 0.060239583, -0.07139572, -0.08085651, 0.046705768, -0.1845899, -0.041184045, -0.16924283, -0.103636466, -0.12368995, 0.32537746, 0.17415257, -0.09862, 0.033948973, -0.07373201) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.04398597, 0.053637594, -0.066469684, -0.13749146, -0.09403796, 0.3358546, 0.21869878, -0.29978943, -0.10002875, 0.1716674, 0.21330133, -0.093029685, -0.047268018, -0.23855767, -0.021621559, 0.2618309) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.35516137, 0.4296916, -0.22667925, 0.26948527, 0.4967297, 0.28074503, -0.48463166, 0.47993836, 0.1336204, 0.03924963, -0.3413975, -0.25740942, -0.6560628, 0.16838671, -0.26516488, -0.26963055) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.009528157, 0.13747782, 0.14333886, -0.01070172, 0.26556405, 0.31428063, -0.119342074, -0.49116576, 0.20105396, 0.26330525, 0.27396137, 0.043918934, -0.18816566, 0.16139497, 0.15771163, 0.05239124) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.014810564, 0.089836024, -0.039942026, -0.06458858, -0.014040309, 0.109130524, 0.065071955, -0.2235724, -0.052434776, 0.118464336, 0.08898691, -0.45461896, -0.10378, -0.14675531, 0.06952673, 0.056890365) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.074715875, 0.37936485, 0.34947982, -0.059182655, 0.26357406, 0.04523176, 0.000305891, 0.07913719, 0.50766367, 0.16945873, 0.1942663, -0.7412815, -0.12855558, -0.011264704, -0.17199223, -0.40828875) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.017293964, 0.053795163, -0.08381335, -0.04588694, -0.0052584107, 0.105982974, 0.007038712, 0.014869515, 0.13770592, 0.105783075, -0.037249953, -0.44373477, -0.13886656, 0.08252616, 0.08123666, 0.00089645834) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.23910494, -0.110583685, -0.2604584, 0.23701826, 0.08909194, -0.07304955, -0.08616481, 0.111332975, -0.057968635, 0.058350272, 0.036173835, -0.044664513, -0.00859428, -0.07391575, -0.030739544, 0.0007115206) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.28458893, 0.13779567, 0.13533345, 0.16617166, 0.11489717, -0.18391, -0.22103767, 0.050921746, -0.39411846, 0.32902676, 0.14363131, -0.36308795, -0.032923654, 0.024363786, 0.12916791, 0.075005405) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.076153845, -0.17687422, -0.026531238, 0.029761875, 0.06136782, -0.16879848, -0.1897201, 0.0375467, -0.053381864, -0.07044374, -0.2669979, 0.10693263, 0.061605632, 0.0016690682, -0.02698995, -0.2004421) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.04412924, -0.027788645, -0.13511214, -0.27011257, 0.12388486, -0.20081788, -0.17368197, 0.36934564, 0.1643648, 0.065597214, -0.101362325, -0.28508267, -0.0039085182, -0.09856176, -0.025178473, 0.3354642) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.14093782, -0.29572862, 0.07149069, 0.3049497, -0.05186243, -0.43593162, -0.15533267, 0.36394185, 0.8684717, 0.0014307605, -0.066182256, 0.25883913, -0.45815182, 0.029678483, -0.0017376909, 0.52582335) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.21919365, -0.25629872, -0.0526995, 0.0832903, -0.0030350091, -0.1970139, -0.10685853, 0.14795996, 0.26569927, 0.19021311, 0.016846143, -0.13103142, -0.01433844, -0.09355247, -0.10394116, 0.23741558) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.061954904, 0.04033858, -0.16657266, -0.12395502, 0.080665074, -0.09239966, 0.023284988, 0.2210172, -0.08666127, 0.08801752, 0.055680584, 0.026380852, -0.0736328, 0.11518736, 0.024526086, 0.114365086) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.2253133, 0.0039017866, 0.03102667, 0.22089157, 0.022013187, -0.17284152, -0.044561718, 0.1538899, -0.21364589, -0.0138367675, 0.07094944, 0.14696388, -0.15687145, 0.076665446, -0.046997733, 0.067799665) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.055301484, -0.124154165, -0.064239234, -0.22196758, -0.097655565, -0.08038973, -0.051470958, 0.1484223, -0.16132544, 0.036463413, 0.040227376, 0.08146032, -0.08045271, 0.048471108, 0.14486763, 0.07990636) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
