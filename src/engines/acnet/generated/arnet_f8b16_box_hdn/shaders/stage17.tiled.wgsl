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

  var result: vec4f = vec4f(-0.026570782, 0.066260904, 0.059630834, 0.4505026);
      result += mat4x4<f32>(-0.018077193, 0.2775665, -0.023818022, 0.013856589, 0.25062, -0.15613064, -0.17204234, -0.019648068, -0.29581583, -0.0304661, 0.1706575, -0.037172694, -0.052070282, 0.055092882, 0.13883354, 0.16919273) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.101393685, 0.0075698774, 0.010308572, 0.015371297, 0.25805444, -0.48612475, -0.17768833, 0.026536144, -0.3325294, 0.33372065, 0.040042095, -0.18893461, 0.4031298, 0.07057028, 0.16634172, 0.0046465346) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.05790135, 0.17760961, 0.00013786473, 0.047126874, 0.0432113, 0.04393331, -0.0061432356, -0.05645786, 0.051793445, -0.05106493, -0.04915924, 0.02544303, 0.110594, 0.08045632, 0.15044698, 0.21072058) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.074832834, 0.14106409, -0.080180615, -0.07443604, -0.22049235, 0.0766546, -0.04639726, 0.18763976, -0.02334823, -0.45575494, -0.052641623, -0.30550063, -0.0025188343, -0.028992925, 0.18870886, 0.15002783) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.60492164, 0.20804848, 0.09359268, 0.05116659, -0.1874204, -1.163569, -0.57132846, -0.20600595, -0.5729796, 0.78674376, -0.14136451, -0.4784391, 0.43486217, 0.55475396, 0.2451897, -0.034564614) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.22671682, -0.02821003, 0.058461837, 0.067499824, -0.15759502, -0.20482446, -0.10185642, -0.123645864, 0.13874184, 0.055917453, -0.083052844, -0.13427259, 0.042866483, 0.19477001, 0.24197276, 0.19553927) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.027140407, 0.12441361, 0.08965579, -0.040419407, -0.18561141, -0.26984778, -0.31556267, -0.49505973, 0.17554808, 0.069713145, 0.18294203, 0.39200118, 0.14284095, 0.07459433, 0.02086693, -0.015550861) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.2621383, 0.5241477, 0.13343154, -0.06637864, -0.3712883, -0.08487417, -0.5314911, -0.44929564, -0.03884442, -0.18436931, 0.22463901, -0.045771863, -0.08972976, -0.089931235, 0.15810856, 0.11614194) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.2804014, 0.21166359, -0.004850386, 0.064417005, -0.20228294, -0.4687969, -0.02146625, -0.06803178, 0.12863772, 0.21364939, -0.019287065, 0.083939426, 0.024358597, 0.021347106, 0.10267338, 0.19994394) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.02496924, -0.25904718, 0.11950497, 0.07980592, -0.11995975, 0.07326997, -0.008018978, 0.039950557, 0.35829276, -0.22800763, -0.12108209, -0.20287779, 0.37186736, -0.14719047, 0.08762613, -0.12572552) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.27812114, -0.105465636, -0.069613844, -0.011424139, -0.2933687, 0.08291421, -0.041424766, -0.041520245, 0.16316226, -0.1257701, -0.07583737, -0.19211976, 0.4154823, -0.15163548, 0.072126515, 0.024661439) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.041155625, -0.16433235, 0.070270784, 0.037973236, -0.2323319, 0.012839485, -0.09601007, 0.102970935, 0.07768174, 0.0005904664, 0.11480156, 0.10340768, 0.2999487, 0.119660355, 0.307661, 0.22158693) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.35931152, -0.46916923, 0.00030937276, 0.16505243, -0.006473788, 0.33397117, -0.017041512, -0.044030212, 0.6548699, -0.030153332, 0.32540828, -0.050621033, 0.05115678, -0.1072656, -0.07038763, -0.13082886) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.58915555, -0.30060685, -0.18032606, 0.10700301, 0.11246585, 0.2973643, 0.031136125, -0.114995144, 0.20833102, 0.46981928, 0.35384467, -0.0626442, 0.19962545, 0.05141286, -0.24087054, -0.21391392) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.22717285, -0.4858238, 0.17130613, 0.18171313, -0.25828516, 0.2216215, 0.17033796, 0.28647664, 0.05851393, -0.041149627, 0.103821404, 0.07532138, 0.6154967, -0.16433801, 0.18544158, -0.06590381) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.26158348, -0.21906675, 0.03410287, 0.119257316, -0.08880162, 0.3540777, 0.09805736, 0.10001837, 0.0077967215, -0.10358567, 0.2215669, 0.13672364, 0.16578269, 0.048090246, -0.052189864, -0.14157458) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.718097, -0.77793425, -0.00779591, 0.010386006, 0.05691258, 0.29388666, 0.13126269, 0.11697216, 0.044854518, 0.080197506, 0.20352684, 0.07220045, 0.23249072, -2.8203622e-05, -0.25805083, -0.28443208) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.15140289, -0.4198977, -0.03569256, 0.031434678, -0.25877184, 0.13256957, 0.21214023, 0.22715507, -0.02184803, -0.10856097, 0.038633425, 0.030394325, 0.4373357, -0.10672779, 0.08238464, -0.0054148273) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
