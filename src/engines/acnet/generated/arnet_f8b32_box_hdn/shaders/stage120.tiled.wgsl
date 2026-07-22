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

  var result: vec4f = vec4f(0.21825942, -0.38188815, -0.4674987, 0.27918217);
      result += mat4x4<f32>(0.0024180252, 0.055618368, -0.066925734, 0.02586132, 0.11060097, -0.2231425, -0.05508338, -0.61141264, 0.030481486, -0.0889844, -0.066541016, -0.009485866, 0.0125441635, -0.033426736, -0.0058219633, -0.032118276) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.18560284, 0.26946637, 0.04225566, 0.5702917, 0.079149365, -0.13428208, -0.16529237, 0.55145615, 0.17943883, -0.057615396, -0.064402275, -0.50888383, 0.13168572, -0.029942684, -0.17856975, -0.4538359) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.008536255, 0.101367354, 0.044119697, 0.07432327, 0.051664557, -0.105333656, -0.17492498, -0.079324536, -0.024246538, 0.05102048, 0.070107654, 0.07096734, -0.07907675, -0.0161031, -0.021493044, 0.22696154) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.043445576, -0.09202389, -0.18364993, -0.016116604, 0.06255788, 0.07631408, -0.056414038, -0.3294421, -0.025184073, -0.280334, 0.091626704, -0.46227083, 0.08290588, 0.0063376334, -0.036137342, -0.016827118) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.14556922, -0.073325545, -0.41756296, -0.22743717, 0.09188114, 0.46790293, 0.36546353, 0.17847174, -0.08363545, 0.056566454, -0.4879755, -0.40602535, -0.34348196, 0.7098185, 0.0032444992, 0.15116404) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.020025704, -0.12152535, 0.078346774, -0.086844094, -0.18366759, -0.20790134, -0.20469524, 0.21240434, -0.019824963, 0.047686893, 0.061736915, -0.15609698, 0.07479235, 0.44685593, -0.027808586, 0.01611744) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.014347035, 0.048937995, -0.060029645, 0.06004119, -0.14414164, 0.13926382, -0.004462306, 0.12252264, -0.022762947, 0.12462944, -0.019655012, 0.09732692, -0.007440806, -0.044257604, -0.016479688, -0.03438084) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.016703889, -0.088446215, 0.042454906, 0.13414638, 0.15209566, 0.5661903, 0.17337063, 0.2261243, -0.1196696, -0.18146108, 0.16539894, 0.19561186, -0.048202205, -0.006118942, -0.018893564, -0.083535746) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.051422644, -0.00497632, 0.032198112, 0.030709503, 0.048058774, 0.10267674, -0.32282275, 0.14161459, 0.07288034, 0.01830829, -0.03376941, 0.1259351, 0.0145875625, 0.028589455, -0.013981945, 0.016094655) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.012788444, -0.0050118617, -0.008068495, 0.07927159, 0.066948466, -0.1165647, -0.009487406, -0.10522694, 0.03171845, 0.05294323, 0.034469545, 0.045942474, 0.019227775, -0.09490069, 0.0042241756, -0.08476639) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.018373819, -0.030817777, -0.0011059064, -0.01380133, -0.025018394, -0.46477988, -0.21849465, 0.03117245, 0.12623462, -0.23485263, -0.09206951, -0.21323566, 0.0473324, -0.071787894, -0.06210442, -0.014310499) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.004204287, -0.04474574, -0.033652183, 0.13026106, -0.023705045, -0.2647977, -0.08350581, -0.17865387, -0.16011076, -0.16542612, -0.17683129, 0.36402127, -0.008956776, -0.041290946, -0.047889333, 0.007358645) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.030513266, 0.107405014, 0.09264365, -0.03554533, -0.055034168, -0.035994854, 0.13428806, 0.29214284, 0.03690569, -0.07522123, 0.057336383, 0.15632147, -0.035547152, -0.15005001, 0.13423866, -0.13884963) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.336135, 0.26841986, -0.004780673, -0.43475953, 0.18417862, -0.72992796, 0.28825918, 0.24239506, 0.07939326, -0.6339649, -0.3038709, 0.4557134, 0.27874947, -0.11491169, 0.10556778, -0.27527195) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.05776893, 0.2923439, 0.08934676, 0.08609043, 0.16980177, -0.28796574, -0.008803504, -0.1767748, 0.041599188, -0.26985857, -0.40052605, -0.1165593, 0.01669401, -0.23104383, -0.12154664, -0.05642281) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.029149313, 0.10849597, 0.016541697, 0.21921341, 0.040664684, -0.18083806, 0.039450243, -0.16937529, -0.011495261, 0.034282055, -6.5633314e-05, -0.0505498, 0.17604403, -0.8680221, -0.18499343, -0.0016286257) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.2477622, -0.4109126, -0.31471857, -0.37880057, -0.022466555, 0.026916455, 0.16600128, 0.005824989, -0.0840837, 0.14797331, 0.18036543, 0.32286513, 0.0015031716, -0.1420848, 0.27355954, -0.3231339) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.04972956, -0.1302112, 0.22781184, 0.120948955, -0.018184569, -0.09381311, 0.20343886, -0.06030506, 0.0063455054, 0.12456576, 0.18889038, 0.019352268, -0.024022304, -0.016434878, 0.10295406, 0.14849387) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
