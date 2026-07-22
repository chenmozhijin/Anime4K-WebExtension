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

  var result: vec4f = vec4f(0.1312946, -0.08105721, 0.23548967, -0.27237594);
      result += mat4x4<f32>(-0.17610706, -0.6868505, 0.15916774, 0.06398832, -0.078224905, -0.12283302, 0.012171153, 0.16294025, -0.06054743, -0.050929278, -0.102269456, 0.12370904, -0.10248193, 0.17509067, -0.004885054, 0.15651655) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.20935267, 0.288125, 0.25106624, 0.3296989, 0.15299249, 0.020408468, -0.12770484, 0.040968914, -0.15642262, -0.005319537, 0.099401794, 0.10696638, 0.07300718, -0.25856978, -0.03550631, -0.20456696) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.04571225, -0.12681901, 0.15991217, 0.12247891, 0.060592785, -0.08418336, -0.15820596, -0.21425107, -0.004400649, 0.06399708, -0.036424782, -0.011527546, -0.043104414, -0.32295552, 0.029800426, -0.15921445) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.02595467, -0.29971087, 0.2430929, 0.08888707, 0.0070970543, -0.08329694, -0.10209324, 0.20934898, -0.22937605, -0.069631085, 0.19435504, -0.14550988, -0.08035438, 0.21885142, -0.114446774, 0.21987662) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.17206104, 0.22232682, 0.24919482, 0.15255538, 0.22049624, 0.15253389, 0.31840122, -0.18699586, 0.48210147, 0.23920287, -0.059691492, 0.12987658, 0.2077401, -1.16243, 0.23764624, -1.4072359) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.0350094, -0.23823366, 0.012742818, 0.26972717, 0.005245554, -0.37365332, -0.029025448, 0.3292038, -0.102804184, -0.21647951, -0.22410549, 0.121225156, 0.048366744, -0.39055008, 0.14881337, -0.50768393) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.070176505, -0.22285484, 0.23100072, 0.0251048, -0.03160607, 0.036733016, -0.13760796, 0.10052417, 0.27759245, -0.33424428, -0.48986664, 0.07736229, -0.07884583, 0.107110925, -0.057967477, 0.13953021) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.10066122, 0.043498, 0.25243747, -0.013105708, 0.013434367, 0.065891854, 0.22532053, 0.17048451, -0.06809515, 0.39408574, 0.601446, 0.06554314, -0.057461906, -0.31257173, -0.03832166, -0.21851307) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.028982542, -0.21700162, 0.04909994, 0.15363452, -0.10588109, -0.20353396, -0.009783008, 0.090196215, -0.087266505, 0.10533188, -0.34060812, -0.055089623, -0.006806112, -0.3243697, 0.05204261, -0.32460696) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.016659256, 0.15140396, 0.07847333, -0.05513273, -0.02852024, 0.42287886, -0.39792082, 0.35339656, -0.019268425, 0.10921606, -0.10459926, 0.18839316, 0.18056664, 0.031856924, -0.06574062, -0.1337275) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.3191952, 0.041687988, 0.13910122, 0.07894478, 0.107818305, 0.1287907, 0.006003912, 0.038326573, -0.31980515, 0.028268658, 0.107783325, -0.26298913, 0.055520967, 0.29542166, -0.02407858, -0.07820027) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.20967424, -0.38428923, 0.040299274, 0.3429941, -0.17923751, 0.32335177, -0.28525063, 0.4497412, -0.32312402, -0.011638995, 0.2575963, -0.19873585, 0.14097758, 0.004948388, -0.061387863, -0.10595454) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.093830355, -0.12254803, 0.122266844, 0.20651287, 0.14800055, 0.29353678, 0.05107246, -0.13248317, 0.04839407, -0.16680379, 0.034488745, 0.07909506, 0.021883491, 0.089806095, -0.04696382, -0.15215066) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.12016859, 0.2920735, 0.41530758, 0.64634734, 0.14450598, 0.17440462, 0.19765158, -0.19523822, -0.33599177, 0.16220622, -0.07248439, -0.34469336, 0.4616093, 0.38289493, 0.2709154, 0.32517815) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.3557658, -0.26221162, 0.104492, 0.49238613, -0.07660234, 0.27993062, -0.06861268, -0.065970786, -0.08089384, -0.14444086, 0.05025901, -0.11149432, 0.21139269, 0.39652297, -0.18239464, -0.17109436) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.08708088, 0.07602315, -0.018232327, 0.3324953, -0.08835428, 0.4134777, -0.21194635, 0.2521364, 0.004810818, 0.009409683, -0.011625883, 0.07952101, 0.20469958, -0.08037796, -0.01743007, -0.22751468) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.11777608, -0.72779834, -0.10706561, -0.07911078, -0.07995749, 0.16673958, -0.10858907, 0.25270215, 0.15350153, -0.011439167, 0.06251658, -0.03816484, 0.2765452, 0.3452107, -0.9199605, -0.32143262) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.024930593, -0.046960212, -0.076794155, 0.063865304, -0.07893296, 0.14858869, -0.119578876, 0.06863147, 0.07912617, 0.15751208, -0.21711478, 0.05549452, 0.17529112, 0.14509195, -0.04332231, -0.04202269) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
