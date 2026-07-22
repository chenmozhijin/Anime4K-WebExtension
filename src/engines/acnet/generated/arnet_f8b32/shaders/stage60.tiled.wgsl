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

  var result: vec4f = vec4f(0.07420545, -0.2046079, 0.34281316, -0.17285453);
      result += mat4x4<f32>(0.080073714, -0.119399704, 0.09409387, 0.16036399, -0.18124618, -0.064183675, 0.019166404, 0.09157167, 0.121551126, 0.23118193, -0.010830257, 0.03642401, 0.1882444, 0.17252943, -0.00012903295, -0.23415725) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.03479611, 0.289872, 0.1127094, 0.2221811, -0.41098142, 0.057098955, -0.01959175, 0.30482173, 0.15933017, 0.27230603, -0.041908395, -0.08267798, 0.11447347, 0.2237369, -0.12879565, -0.23670787) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.073731124, 0.048403505, -0.0065221377, 0.079720154, -0.14812781, -0.050117575, 0.0015968307, 0.12023484, 0.083939806, 0.020471875, -0.11709551, -0.018918855, 0.027158314, -0.056018293, -0.08601691, -0.11998718) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.13586552, -0.17662664, -0.00080352445, -0.092944846, -0.2291877, -0.01837187, -0.094798, 0.26907682, 0.1757137, 0.23072885, -0.23833954, 0.015659783, 0.040667873, -0.09653629, 0.014477568, 0.07084969) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.4295279, -0.24158873, -0.13099429, 0.69361407, 0.03425106, 0.10047678, 0.0022810157, -0.12667634, -0.085547276, 0.876804, -0.20370005, 0.11028515, -0.15965997, 0.6761559, -0.058451846, -0.14204188) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.039506555, -0.12621255, -0.18440603, 0.20090754, -0.33431357, 0.0478542, -0.08560118, 0.24523078, 0.12619644, 0.2948754, -0.030800866, -0.035982788, 0.06922056, 0.3592043, 0.40449834, -0.36105698) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.03164442, 0.029180797, 0.027710041, -0.03156087, -0.10298171, 0.05598421, -0.06437843, 0.07134235, 0.18044256, 0.14240749, 0.07304372, -0.022611763, 0.029261945, 0.012083984, -0.07365667, -0.11009547) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.13429616, -0.06434401, 0.19205163, 0.1930297, 0.018739555, -0.0755789, -0.43839428, 0.19920617, 0.02262238, 0.20475906, -0.4393297, 0.06092017, 0.16214737, 0.14238535, -0.57073647, -0.068703674) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.08705824, -0.19070193, -0.08228986, 0.09962873, -0.09674864, 0.031835064, -0.03771237, 0.30702034, 0.0858319, 0.24743073, -0.024994625, -0.09724565, 0.08738651, 0.05749632, -0.07503679, -0.28863072) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.045007013, 0.013282323, 0.050848275, -0.034486312, 0.13676137, 0.33527052, 0.17472258, 0.08888813, -0.013876315, 0.10340246, -0.068645306, -0.36235675, 0.049912967, 0.070969306, -0.057750512, -0.16760153) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.07395219, -0.026032586, -0.13315202, -0.01791583, 0.09740462, -0.17085405, -0.016927535, -0.37823966, -0.038859885, 0.36291674, -0.048331354, -0.4056984, 0.13668096, 0.14724645, 0.10464033, -0.16096745) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.10382433, -0.08669261, -0.060199603, 0.02070234, 0.030988606, 0.1657321, 0.18469544, 0.006201865, 0.15895557, -0.1211692, -0.9606851, -0.24798623, -0.0296707, 0.025500104, -0.1004269, -0.027241163) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.098343715, -0.05430134, -0.21916851, -0.12744343, -0.029639319, -0.2934706, -0.046060707, 0.48566553, 0.09026532, -0.15434602, -0.26987737, 0.028698744, 0.09280206, 0.22733125, -0.34506422, -0.07242462) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.18812121, -0.04179165, -0.31038132, 0.11932304, 0.06546436, 0.273251, -0.25387788, 0.5497541, -0.14457059, -0.036813356, 0.11107875, 0.031490657, -0.14453913, 0.34187642, -0.0740937, 0.31890127) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.029422794, 0.16450092, 0.29538247, -0.45891353, -0.13846007, -0.21736394, 0.3611656, -0.04562982, 0.0048428983, 0.1286467, -0.16580287, 0.04082746, -0.12508616, 0.16551383, -0.008248585, 0.08633808) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.02078983, -0.105684996, -0.17578824, -0.07252387, -0.25039613, -0.63207954, -0.027383653, 0.07863462, 0.06284653, -0.03691213, -0.005685831, -0.08449872, 0.09693358, 0.19029462, -0.24070919, -0.14935888) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.09113962, 0.3617601, -0.34719083, -0.24921834, -0.11519975, -0.03578788, 0.27830294, 0.15029301, 0.26766858, -0.012831587, -0.3031201, -0.15394421, 0.30076492, 0.31518605, -0.76243955, -0.04772869) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.058196716, 0.21724816, 0.11032921, -0.1432897, -0.09758843, -0.054338753, 0.0041662506, -0.07723241, 0.14473286, 0.021437615, -0.10952576, -0.24603523, 0.10887014, -0.07220799, 0.022437818, -0.050819647) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
