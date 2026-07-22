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

  var result: vec4f = vec4f(-0.13213933, 0.4305893, 0.048797566, -0.23532392);
      result += mat4x4<f32>(-0.117032275, -0.03585393, -0.0014396292, 0.11005106, -0.06268686, -0.010096035, -0.13907704, 0.12362775, 0.6449157, -0.08914181, 0.06329628, -0.8514485, -0.23409936, 0.05447807, 0.13867459, 0.4953766) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.007516311, 0.066472575, 0.11313452, -0.0943577, 0.3726035, 0.37491742, 0.31342536, -0.007345452, -0.035638914, 0.13681911, 0.318623, -0.44462696, -0.21980646, 0.14807203, -0.15185526, -0.10290455) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.17082708, 0.13354063, -0.15393218, -0.4811754, -0.04142153, 0.09120922, 0.058421228, 0.22599205, 0.030423671, 0.16120774, -0.024306873, -0.30877194, -0.11087372, -0.036265705, -0.26799595, 0.12730485) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.03536519, 0.15823728, -0.008987898, -0.03456092, -0.15323135, 0.04726671, -0.1910016, -0.5022519, 0.0642508, -0.06128918, -0.1231219, -0.4320531, 0.23365764, -0.06969019, 0.006111074, -0.10256921) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.033689618, -0.8894373, 0.20582424, 0.8769819, 0.13548452, -0.6966772, 0.02807232, 0.13027684, -0.12728655, -0.2986252, -0.6793598, 0.40725186, 0.24330829, -0.28984022, 0.099634774, -0.20224202) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.09363082, -0.054449175, 0.23343152, 0.18192978, 0.057195395, -0.6264627, 0.071335, 0.39146435, 0.101176895, 0.1240921, -0.049789723, -0.038058195, -0.2632494, -0.12085602, -0.37504667, -0.13370351) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.09558878, -0.008404093, -0.12139067, 0.03111006, -0.09486553, 0.08086614, 0.13469368, 0.24586529, -0.05974047, 0.08058586, -0.05419332, -0.26600766, -0.21671832, -0.23814882, 0.1812633, 0.32673526) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.059339296, -0.02741738, 0.02493207, 0.035363313, 0.22569963, 0.0758689, -0.27538434, 0.10347787, 0.14083633, 0.3514863, -0.006615217, -0.2118492, 0.24786355, 0.083744146, -0.30470723, -0.02568987) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.047353674, -0.05714545, 0.053179994, 0.07159458, -0.043602757, 0.03470215, 0.029648462, 0.07030892, 0.07919583, 0.040251367, -0.05539616, 0.06753819, -0.02270488, 0.061913468, -0.110027954, 0.045507107) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.0009970653, -0.031043474, -0.037301704, -0.031502403, 0.07979696, 0.11346492, -0.028592942, -0.1486074, -0.022353135, 0.19970573, -0.05382726, -0.10934451, -0.06371642, 0.03826464, 0.041105714, -0.19134581) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.039986465, -0.27854538, -0.036095597, 0.29805395, 0.14570084, 0.15197614, 0.05014634, -0.22142504, -0.07018786, -0.28367773, -0.088332, -0.14940843, 0.072792195, -0.17977759, 0.04692183, 0.015560005) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.018514642, -0.11839932, -0.037956845, 0.16295615, -0.038308926, -0.13983417, 0.1108321, 0.21455355, 0.1197678, -0.1342792, 0.10494161, -0.041573226, 0.018845778, 0.117024705, 0.21419126, -0.051537972) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.010637911, -0.12592737, -0.030785296, 0.056541916, -0.013085806, -0.47894505, 0.16606076, -0.16918096, -0.0059178644, -0.17473252, 0.2628834, 0.231155, -0.25959882, 0.1885113, 0.26634103, 0.9382009) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.1550925, -0.42561466, 0.31825477, 0.10229362, 0.3970509, 0.15467227, -0.17859267, -0.35619643, -0.14874505, 0.08674959, -0.14671151, 0.83912766, 0.3196396, 0.5589964, 0.5104266, -0.3764706) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.0009290166, -0.053201523, -0.3055103, 0.007388264, -0.16145901, -0.1367571, 0.44900236, 0.0669208, 0.0073763463, -0.06725844, 0.09324186, 0.37519655, 0.004962391, -0.16092381, 0.22358902, 0.032747537) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.0324545, 0.06679693, 0.00033370577, -0.012263403, 0.073649265, 0.29373485, -0.1326477, 0.027917136, 0.08918453, -0.22306468, 0.015271599, -0.015181428, 0.17764722, -0.12916066, -0.17573264, -0.24891658) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.022262631, -0.02456994, -0.084879935, -0.09171812, 0.0016111264, 0.08872065, 0.10965439, 0.020277036, -0.22929665, -0.16527563, 0.7143963, -0.007986546, -0.23759723, -0.09055695, 0.3678089, -0.23331809) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.073173374, -0.07839953, -0.04564252, 0.063139096, 0.021643119, 0.014737708, -0.06310898, 0.031771038, -0.17186402, -0.11414287, 0.18996882, 0.17362335, -0.05615046, -0.24032693, 0.0020495101, 0.12952223) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
