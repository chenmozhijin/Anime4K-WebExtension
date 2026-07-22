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

  var result: vec4f = vec4f(0.0864731, 0.11334862, 0.32863137, 0.026678413);
      result += mat4x4<f32>(0.13789755, -0.037439466, -0.15183122, 0.19808768, 0.22105104, -0.19567491, -0.34586263, 0.36471745, -0.04822734, -0.14333431, -0.25153667, -0.012348516, -0.012990557, 0.0067964853, -0.097414985, 0.16132252) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.050762106, 0.08805636, -0.15609656, 0.31409332, 0.34251484, 0.09119279, 0.0382332, -0.087179855, 0.042876296, 0.013584208, -0.072206445, -0.030334534, -0.21848099, 0.20144989, -0.104617566, 0.26569563) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.021197826, 0.03368228, -0.054040868, 0.11121311, -0.720435, -0.0578961, 0.20250426, -0.24008921, -0.10147338, -0.104620054, -0.19728634, -0.009691091, -0.011026251, 0.110458426, -0.16225219, 0.16657852) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.026168743, 0.18809493, -0.3226603, 0.4753961, -0.6116588, 0.46658707, 0.08161713, 0.45025393, -0.0915164, -0.046225566, -0.1798026, 0.06987343, -0.35439712, 0.1626702, 0.009013519, 0.10471467) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.20840694, -0.18348765, 0.60594034, -0.67408556, -0.34874526, -0.19105457, -0.08248196, -0.6395685, 0.02522472, 0.19512494, -0.11477113, 0.33607182, -0.15623933, 0.012657666, -1.1100192, -0.6047356) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.026232665, 0.3294107, 0.039642837, 0.18141726, 0.605879, -0.24017233, -0.21324147, 0.18510723, -0.029526994, -0.114372455, 0.083734, -0.11363243, 0.12405868, 0.16827452, 0.048589036, 0.39194092) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.3039304, -0.091227464, 0.010865733, -0.11958173, 0.11672325, 0.040909022, -0.21057588, 0.30870926, -0.059919566, -0.0996895, -0.19118845, -0.039861586, 0.0809819, 0.021814676, -0.0010801071, 0.26379126) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.09239623, 0.21882649, -0.19571449, 0.03519447, 0.08066354, -0.11033974, -0.022288643, -0.11285497, -0.11947713, -0.07460519, -0.12840894, 0.046975326, -0.0652783, -0.017506562, -0.045669246, 0.43669853) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.12188512, 0.065780595, 0.10848057, -0.106096424, 0.18930393, 0.15433498, 0.05809385, -0.25055307, -0.08431053, -0.24142921, -0.21372116, -0.04621603, -0.20227592, -0.10694502, -0.11975183, -0.082517296) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.04436017, 0.045735143, -0.16380051, 0.13008678, 0.3418209, -0.12272684, -0.10413884, 0.5836299, 0.1634158, -0.011016438, 0.060076144, 0.008820069, 0.18720755, 0.024036879, 0.22036697, 0.53898376) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.12700883, 0.00032920687, -0.13680424, 0.24003235, -0.016410254, 0.00080246344, 0.084037244, 0.24828944, -0.16734856, 0.019171054, 0.028184384, 0.013953096, -0.15137273, 0.3439761, 0.22815727, -0.13897225) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.06415611, 0.119273566, 0.03547757, 0.06245406, 0.20729458, 0.28695908, 0.30918342, 0.55234414, -0.13875204, 0.01606298, 0.0076927524, -0.17941348, -0.1643997, -0.12892279, -0.34419698, -0.55375504) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.2089983, 0.2772268, 0.108422466, -0.38435075, -0.0952977, -0.15130661, 0.038937263, -0.12974752, -0.010758789, 0.1315139, -0.19147626, 0.3754804, 0.17689733, 0.18789276, 0.054187912, 0.43838772) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.2979728, -0.037806913, 0.31763583, -0.5013716, -0.21514243, 0.12036752, -0.11696704, -0.65810066, -0.05188921, -0.29835382, 0.21265502, -0.7838573, 0.008277712, 0.33787024, 0.34055844, -0.014466831) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.029395355, 0.05902321, 0.018486938, -0.2096367, -0.1016309, 0.09840844, -0.09797695, -0.19158137, 0.11110055, -0.024669014, -0.053245734, -0.26354697, -0.15025994, 0.07093411, -0.055123933, -0.30503407) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.015754616, 0.11631107, -0.028107818, 0.04993866, 0.018708287, -0.3667445, -0.38211045, -0.10000363, -0.084851995, -0.09950635, 0.087223515, -0.039351925, 0.24005525, -0.20343147, 0.12433905, 0.50963473) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.020869926, -0.047824126, 0.06278399, -0.104617946, -0.17775324, 0.09845154, -0.10892116, -0.48495927, 0.12705669, 0.027296945, -0.25584102, -0.018515922, 0.054424442, -0.121392205, -0.1852105, -0.019324295) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.059537157, 0.013593907, 0.08683451, -0.04479457, -0.21363685, 0.22072946, 0.098714605, -0.3292638, 0.14515716, -0.041026495, -0.13694985, 0.03999887, -0.12219585, -0.3012056, -0.23643693, -0.3926496) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
