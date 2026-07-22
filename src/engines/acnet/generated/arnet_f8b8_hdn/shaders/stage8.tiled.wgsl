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

  var result: vec4f = vec4f(-0.023504527, -0.13449308, -0.04867333, 0.17150784);
      result += mat4x4<f32>(-0.6225934, -0.018400423, -0.04023944, 0.021851256, -0.10871245, 0.035981588, 0.025247984, -0.10662101, 0.16068737, 0.007845494, -0.09436731, -0.018687762, -0.3528369, -0.14845806, -0.018212186, 0.026821615) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.24929331, 0.19162352, -0.36805114, -0.19584468, 0.013108479, 0.030583387, -0.037073303, 0.045266744, 0.10336228, 0.28845435, -0.08872513, -0.18781039, -0.08656043, -0.27915785, -0.19922301, 0.16700493) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.37880492, -0.14317277, 0.19020748, 0.0888321, -0.15159899, 0.056947976, -0.12055987, 0.0299883, 0.08186656, 0.045474146, -0.030492632, -0.059363127, -0.014440956, 0.12683426, -0.025499154, -0.029282786) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.09347563, -0.76874685, 0.52900237, -0.06979726, 0.043927945, -0.13654305, 0.25697723, 0.06642915, 0.05976368, 0.25143176, 0.04182545, -0.08346332, -0.22049673, -0.04382794, -0.0071422937, -0.12525198) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.56457, -0.5377382, -0.428226, 0.08625958, -0.053220227, -0.22827192, -0.068333335, 0.46839678, 0.20723724, 0.42362309, -0.26825348, -0.37862876, -0.5255531, -0.1874631, 0.051165715, 0.37756673) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.091699935, -0.022514468, 0.2989509, 0.054543294, -0.40370643, 0.03468342, -0.17287125, 0.2572904, 0.005094077, 0.032086603, -0.11814993, 0.008387446, 0.15763117, 0.08253946, -0.07691747, -0.055653043) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.22604683, 0.0012536423, -0.5188465, 0.20636377, 0.12728043, 0.06129944, 0.08358684, 0.018939817, 0.55178535, 0.4233629, -0.33926213, -0.30546802, -0.09170977, -0.12562846, -0.18365452, 0.07149459) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.00028324328, -0.054440223, 0.09042494, -0.029179484, -0.22667226, -0.18161927, -0.29302147, 0.019095251, 0.32153133, 0.39012787, -0.29312032, -0.2671412, 0.04315318, -0.024047665, -0.33050248, 0.059737906) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.06554432, 0.009044927, 0.12275584, 0.008023252, -0.35574472, -0.19272879, 0.09704436, 0.29831398, 0.06514132, 0.09064899, -0.1444242, 0.049918674, -0.069527805, 0.06131431, -0.12850823, 0.033606105) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.104963906, 0.026414815, 0.11883279, -0.015055742, -0.16765384, 0.29276276, 0.22963145, -0.29455665, 0.36502513, -0.22072397, 0.11005971, 0.058096938, 0.01296877, -0.28814062, 0.19105048, 0.22525173) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.23828976, 0.34773925, -0.018412044, -0.35173652, -0.07261749, 0.36731902, -0.027686348, -0.31634986, 0.06605628, -0.15656042, 0.2987623, 0.06959542, -0.4792041, 0.10613693, 0.30798662, -0.09048429) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.027467903, 0.2589, 0.050236102, -0.13991348, -0.17363271, 0.009975023, -0.24166301, -0.16140312, 0.22376905, 0.05709825, 0.026893096, -0.02378407, 0.31792337, 0.05511011, -0.06988454, -0.08261011) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.13134503, 0.2667933, -0.31671512, -0.056461923, -0.0999033, 0.027019745, 0.08421425, -0.030600503, 0.17276992, 0.3083502, -0.67807895, 0.0693487, 0.31512508, -0.06611861, -0.14761074, 0.2081343) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.6084977, 0.4499002, -0.38458344, -0.19916068, 0.72285455, 0.22517431, -0.31901008, -0.3655381, -0.92522174, 0.09677216, 0.22472098, 0.10709792, -0.1665043, 0.7284085, 0.10636121, 0.44234788) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.40633106, 0.25726765, 0.0027885577, -0.2506358, 0.03752665, 0.12660687, -0.055749077, -0.16804942, -0.02802382, 0.19344158, 0.02682357, 0.011260621, 0.3509828, 0.024868393, -0.22921899, -0.05572085) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.042446677, 0.16821392, -0.19233465, -0.09169207, -0.1864463, -0.05302192, 0.15893736, -0.038409114, 0.00049107627, -0.028372552, 0.12105208, -0.12639382, 0.12468555, -0.023312053, -0.11448743, 0.21219586) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.23336351, 0.051520552, -0.061507683, -0.0037232, -0.08331881, -0.06060422, 0.11055846, -0.06884905, 0.020270444, 0.050218645, -0.19163714, 0.33663985, 0.014556811, 0.09286221, 0.15712626, 0.03979301) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.152249, 0.10323368, -0.07268123, -0.18853788, -0.025452541, -0.014159065, 0.25579122, -0.10198929, -0.07856318, -0.111634076, -0.013489205, 0.18943071, 0.33717626, 0.15190896, -0.102270976, -0.12812749) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
