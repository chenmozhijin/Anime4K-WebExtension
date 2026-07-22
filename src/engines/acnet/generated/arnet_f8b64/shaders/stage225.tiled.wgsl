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

  var result: vec4f = vec4f(0.113850944, -0.30592012, 0.30489877, 0.017921686);
      result += mat4x4<f32>(-0.1002097, 0.084219806, 0.009310149, -0.07629589, 0.007606458, 0.024132067, 0.0072995247, -0.0018932897, 0.060523327, 0.10278287, -0.06846486, 0.016911408, 0.0269998, 0.1412758, -0.021495568, -0.050529815) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.25999227, -0.045440115, 0.19301422, 0.100207366, 0.19534148, -0.2182643, 0.3199873, 0.29895622, 0.010728972, 0.12334665, -0.13311966, -0.2105041, 0.03645812, -0.006126199, 0.01577607, 0.02830596) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.1029855, 0.0059708254, -0.10554061, 0.024786878, -0.1306738, -0.09224318, 0.10296761, -0.061407287, 0.018532787, 0.04279849, 0.061779242, -0.0017676922, 0.050603505, -0.008425158, 0.0011939227, 0.04852883) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.21870272, 0.047084663, -0.22717777, 0.16186023, -0.120019145, -0.107000716, -0.022352729, -0.018610293, 0.23049876, 0.38976187, 0.23066959, -0.34398872, 0.009015109, 0.20660257, 0.20910454, -0.33605835) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.021252466, -0.31889653, -0.22232763, 0.036512095, 0.5793159, 0.058267362, 0.8396282, -0.36167097, -0.16665462, 0.5041044, -0.30428338, 0.24694042, 0.039063107, -0.046112604, 0.20094565, -0.06324703) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.05803038, 0.14665173, -0.012867872, -0.08674715, 0.007866058, -0.107864484, 0.16660371, -0.3790548, 0.008114157, 0.12436403, -0.048050337, -0.028779289, 0.047021665, -0.008645266, -0.021354245, 0.10027474) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.0008234492, 0.05603979, 0.07395615, 0.011904508, -0.073473364, 0.05267713, -0.026414752, 0.010186773, -0.08732264, -0.19719027, -0.12347031, 0.041732643, 0.3630703, 0.50276023, 0.47250736, -0.5411756) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.08549923, -0.029021174, 0.034815744, -0.016509434, -0.0874288, -0.18941014, -0.038778294, 0.069812775, 0.027021606, -0.34141394, 0.115854464, -0.10408389, -0.039659936, 0.064544715, -0.116361536, -0.08926718) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.011652778, -0.02175193, -0.0087326495, 0.019259743, 0.07083608, 0.03393268, 0.048018757, -0.05192086, 0.0038238943, 0.059560556, 0.042035144, -0.08867073, -0.051277537, 0.035456493, -0.08131674, 0.195588) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.027661223, 0.068583295, 0.0077685085, -0.014742631, 0.054272316, -0.07549453, 0.0999771, 0.073484756, -0.043750737, -0.039986253, 0.07649095, 0.07896466, -0.08228027, 0.07086486, -0.08146666, -0.08880221) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.026172822, -0.0036851978, 0.15461281, -0.19257863, 0.076407924, 0.07137511, 0.15708044, -0.0068287156, -0.03360384, 0.066304006, -0.22722992, -0.12828495, -0.10728423, 0.2232187, 0.01087031, -0.17285664) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.0866729, 0.072415635, 0.084359996, 0.036140256, -0.0010703601, 0.060539454, -0.016017081, -0.013245358, 0.024765793, -0.017607547, -0.24880724, -0.07235485, 0.034894668, -0.14540014, 0.12665726, 0.019329319) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.117812954, 0.2897465, 0.19972464, -0.22915769, -0.24785054, 0.031681776, -0.081373945, 0.20679732, -0.13434526, -0.08997623, 0.09557121, 0.040188596, -0.15448783, 0.101754405, -0.11701741, -0.07347198) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.019013349, -0.5234343, -0.062536396, 0.11329602, 0.2549518, -0.042199705, 0.0490864, 0.099826224, -0.2699057, 0.41774735, -0.21376698, -0.16755347, 0.20178476, -0.30971217, 0.7495516, -0.032049205) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.14837788, 0.25512597, -0.10176367, 0.18488945, 0.02899177, 0.040037174, 0.16695435, -0.17613482, -0.080141224, 0.16986598, 0.026700493, 0.5558575, -0.021198858, 0.03532121, -0.06541254, -0.15752582) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.07301065, -0.0073443297, 0.009637451, -0.07866224, -0.26095864, 0.122502275, -0.19295986, 0.21399292, -0.17651771, -0.030370988, -0.15019329, 0.02467892, -0.03820457, 0.104234844, -0.049711235, -0.07566535) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.14477548, 0.019025661, -0.07404889, 0.40521115, 0.027173718, 0.35522354, -0.047970183, 0.26296777, -0.118005045, 0.11325642, 0.1683119, 0.07147151, -0.055650353, 0.07362492, -0.019743139, 0.020387942) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.019174982, -0.0043697264, 0.074036196, -0.060014118, 0.13946782, -0.02911464, 0.1912371, -0.19074959, -0.080948904, 0.14464915, -0.06373106, 0.07451307, 0.0042345785, 0.03212637, -0.03691025, -0.080233745) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
