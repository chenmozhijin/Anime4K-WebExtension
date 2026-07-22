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

  var result: vec4f = vec4f(0.2647975, 0.11946588, 0.082586594, 0.09560753);
      result += mat4x4<f32>(-0.103990145, -0.2912499, 0.20644996, -0.21759292, -0.09013022, -0.19463594, -0.014218035, -0.09590446, -0.03887459, -0.13096912, 0.049687028, -0.053471588, 0.081969574, 0.06326869, 0.30613515, -0.2766865) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.0037383495, -0.16357246, -0.5109065, 0.18143785, -0.25109813, -0.29718292, 0.16118488, -0.37071577, -0.21512283, -0.2554744, 0.08050482, -0.2658356, 0.07719562, -0.12207707, 0.33322525, -0.10373202) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.05693457, -0.03570793, -0.15952909, 0.18891981, -0.00974352, -0.11351224, 0.2897016, -0.21159017, -0.17598976, -0.28888676, 0.11544215, -0.24256824, 0.12946509, -0.10803507, -0.10254238, -0.03831612) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.20715787, -0.111388534, -0.458144, -0.095117904, -0.3001878, -0.4075359, -0.20761822, -0.20161918, -0.22725575, -0.35256436, 0.1403538, -0.37007093, 0.33291164, -0.75921357, 0.35028416, -0.012362297) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.056097936, -0.29133084, 0.07550773, 0.09615201, -0.16760679, -0.39628217, 0.17678344, -0.4234313, -0.33316082, -0.27829328, 0.022741156, -0.3519936, 0.11281907, -0.26230884, 0.32634565, -0.15637372) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.14126824, -0.1863565, -0.09490554, 0.14352866, -0.20879962, -0.19794394, 0.27423668, -0.39054936, -0.19255586, -0.34351942, -0.1033187, -0.23478693, -0.027784424, 0.4794571, 0.34131992, -0.45368153) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.06106141, -0.048188068, -0.09516493, 0.06743465, -0.16867645, -0.24471909, -0.2503265, -0.08792856, -0.17422144, -0.17195225, 0.022032984, -0.36997864, 0.052625272, 0.10190418, 0.06977191, -0.23538494) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.12054094, -0.021536265, -0.16685823, -0.15214163, -0.20916201, -0.16412733, -0.1417233, -0.18947408, -0.22449718, -0.47985226, 0.100209795, -0.22748691, -0.10233058, 0.18972625, 0.15852304, -0.09945269) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.07820137, 0.06323014, -0.12867558, 0.009519823, -0.1298287, 0.00016926353, -0.07318443, -0.12328886, 0.011416958, -0.2697772, 0.018176278, 0.09708908, 0.24607772, 0.18285312, -0.06640583, 0.13078646) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.04663294, 0.029277965, -0.06662186, 0.100156546, -0.050722424, 0.22616816, 0.003558622, 0.044956926, 0.108683676, 0.11723226, -0.057866257, 0.17951244, -0.09640184, -0.35492682, 0.44191253, -0.22697939) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.052137394, -0.2793082, -0.05656972, -0.14654043, 0.11732495, 0.08657675, 0.6652372, -0.11579419, 0.15554681, 0.287312, -0.23672126, 0.2884233, -0.034795918, -0.17721792, 0.091223314, 0.02423703) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.04867277, -0.1358661, 0.057439175, -0.08071984, -0.07248106, -0.19258554, 0.19578809, -0.06218582, 0.16671419, 0.22895977, -0.018229855, 0.21764551, -0.14572605, 0.06565107, -0.08949262, 0.06730944) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.06479072, -0.101508096, 0.12664273, -0.043908875, -0.08286663, -0.52870715, -0.058682345, 0.0202918, 0.18461075, 0.18991747, -0.1570192, 0.33525968, 0.0676584, -0.1627919, 0.35258874, 0.019030523) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.15680443, -0.092360556, 0.638556, -0.4880536, -0.14136098, -0.16425866, -0.15831739, -0.4286126, 0.15208103, 0.20494154, -0.24102642, 0.34661907, -0.053764485, -0.43676358, 0.07177699, 0.035735335) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.08556331, 0.13827036, -0.0146783115, 0.08164855, -0.058640815, -0.0792627, 0.15965709, 0.034492854, 0.21766429, 0.33176363, -0.17132434, 0.3568181, 0.057508618, -0.099431455, 0.39411348, -0.14495444) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.0030251339, 0.37494498, 0.35013708, -0.17716472, -0.072362065, 0.27618513, -0.10445879, -0.10997884, 0.101020604, 0.09129368, -0.11609979, 0.23299499, 0.08648302, 0.025187464, 0.1681129, 0.08831109) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.21342142, -0.028027074, 0.13805014, 0.26299393, -0.28241378, 0.1789176, -0.431177, 0.08527708, 0.08904201, 0.14820728, -0.2563641, 0.25688106, 0.20216562, 0.004511361, 0.24925801, -0.036442097) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.051856596, 0.15040195, 0.06862716, -0.0011497469, -0.004351706, 0.020864658, 0.089384064, 0.016919378, 0.07169233, 0.1044976, -0.19180906, 0.23293188, 0.021461986, 0.0051236483, 0.12422031, -0.05740767) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
