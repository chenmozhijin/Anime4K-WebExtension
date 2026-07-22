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

  var result: vec4f = vec4f(-0.08780638, -0.0026264444, -0.1489084, -0.00045034222);
      result += mat4x4<f32>(0.12060945, -0.35567012, -0.039913163, 0.21964498, -0.026596753, 0.17402264, 0.032232948, 0.04449282, -0.19691902, 0.058701858, -0.1042954, 0.15264888, -0.060489696, 0.08220441, -0.07444946, -0.067340516) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.4083899, 0.012270584, 0.6972017, -0.21868612, -0.15728866, 0.05460586, -0.21943223, 0.01593365, -0.4219532, 0.16586243, -0.012755006, -0.0033017637, 0.2033255, 0.21944621, 0.49372822, 0.15048003) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.032557636, -0.08081172, 0.12124389, 0.017456278, -0.124721915, -0.20500171, -0.13203594, -0.018060964, -0.005971939, 0.1456973, 0.05730402, 0.0296491, 0.2000792, 0.036040872, 0.058494516, -0.060733445) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.38664672, 0.65604496, 0.18598644, 0.14503635, -0.23583396, -0.27736652, -0.36616266, -0.0831772, -0.15371743, 0.09586438, 0.07321429, 0.0057185898, 0.18553473, -0.28712094, -0.04355906, -0.09785386) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.2883262, 0.47121343, 0.29438847, -0.021438688, 0.37809, -0.2021953, -0.2945878, -0.06052956, 0.40342426, -0.036160123, 0.15266038, 0.3548752, 0.43363118, -0.05214093, -0.068870045, -0.40662798) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.025850756, -0.035119023, -0.06809523, 0.06460376, -0.17116447, -0.3131677, 0.1367986, -0.022242172, 0.049228206, 0.33877912, 0.7029359, 0.075453036, 0.12623428, -0.07251642, 0.017095331, -0.2703004) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.021192035, -0.23377016, -0.13777152, 0.12950295, -0.063129075, 0.025783364, 0.05344648, 0.058742575, 0.014535327, 0.17478573, 0.3245193, 0.06650424, 0.16070955, 0.08659722, 0.049609818, -0.030395567) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.09339469, 0.027645582, -0.2686735, 0.09141205, 0.16014837, -0.5227381, -0.1837699, 0.003120559, -0.236524, 0.61739767, 0.39259893, 0.17576429, 0.005275578, -0.02513598, -0.11162692, -0.020717444) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.024689263, 0.006471771, -0.16124362, 0.05820545, -0.3293162, -0.2628006, -0.34621987, 0.13821004, 0.101816975, 0.36561915, -0.21210022, 0.26928127, 0.057439633, -0.0074292887, -0.09409351, 0.010080398) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.14186603, 0.115745485, -0.02796187, 0.006291005, -0.101602875, -0.41515157, 0.07443958, -0.08530805, 0.0064470754, 0.12030096, -0.13063747, 0.0026487221, -0.0035815209, 0.041592903, 0.0036926146, -0.04368823) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.25887072, 0.3266604, 0.3216383, -0.025676364, 0.16042475, -0.4013472, 0.36000022, -0.34761488, 0.2614648, -0.13532785, -0.2391433, -0.0195871, -0.27026725, -0.11705254, -0.1259222, -0.29325986) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.060710385, -0.12606703, 0.01717103, 0.0011194177, -0.018767476, -0.23849514, 0.24192274, -0.12176721, 0.0032917776, 0.14164121, 0.034007665, 0.049779516, -0.14268382, 0.23493703, -0.7282011, 0.12508628) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.0632104, -0.02748025, -0.20603015, -0.0007595041, 0.17632265, 0.07161745, 0.18019675, -0.22920978, -0.022440376, 0.10032073, -0.03315398, 0.06376548, 0.058798272, -0.0032447046, -0.263953, 0.00929479) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.6524886, -0.6560228, -0.39595124, -0.14449206, 0.40033263, -0.5296145, -0.25617263, 0.09493545, 0.21996987, -0.43804976, 0.15931812, -0.16664538, 0.40382987, 0.021164218, 0.01649315, -0.0046977135) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.30384204, 0.72534794, 0.1009786, 0.12602901, -0.09598958, -0.0021037122, -0.399014, 0.28244913, 0.056785453, 0.25485075, -0.07958482, 0.023070617, -0.34320012, -0.013270577, -0.119224116, 0.039470058) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.0094931265, -0.14093678, 0.04247802, -0.079576306, -0.09185556, 0.009484426, 0.08324226, 0.07160097, -0.14697918, -0.0115054855, -0.008678445, -0.030803947, 0.028857788, -0.0223057, -0.083254024, -0.06542768) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.05489556, -0.30766463, -0.28614014, -0.20414972, -0.09384059, -0.050691683, -0.12619424, -0.16387406, 0.31127277, 0.079490185, 0.3077161, -0.20104945, 0.07292798, 0.056458473, -0.13499764, 0.015716966) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.16697058, 0.17179273, 0.18191937, -0.06237034, 0.07280594, 0.06924079, 0.07786287, -0.009358013, -0.062385455, 0.060576998, 0.0047217812, 0.060849734, 0.030252883, -0.03812895, 0.033300616, 0.014416936) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
