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

  var result: vec4f = vec4f(-0.071187384, 0.24146746, 0.30159608, 0.38878188);
      result += mat4x4<f32>(0.024577707, 0.12607884, -0.014124842, 0.0178797, 0.012096808, -0.22368538, 0.18865469, -0.31783536, -0.0074151307, -0.02083495, 0.13564226, -0.13204533, 0.15836614, 0.2116492, -0.0057378467, 0.211602) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.056809254, -0.26897106, 0.24644029, 0.14964943, -0.07775244, -0.078531556, 0.05916366, -0.026731208, 0.025721826, 0.1328023, -0.03702543, -0.097493514, 0.07998686, 0.22910555, -0.09844121, -0.07251134) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.1951175, 0.028252704, -0.114519306, -0.033340562, -0.099653706, 0.15972386, 0.12350023, -0.44208133, -0.04647326, 0.053853627, -0.031472437, 0.06417584, -0.054295994, 0.112464026, -0.17341422, -0.024730517) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.01465659, 0.0010692773, 0.15543406, -0.37599775, -0.03648065, -0.081792645, -0.053879615, -0.007347264, -0.027849328, 0.020916527, -0.007694227, -0.27490446, -0.098525584, -0.14489244, -0.2786303, 0.51574033) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.3807945, -0.26611906, -0.14729258, 0.22733194, -0.2161516, -0.008287012, -0.0926887, 0.021047965, -0.029771205, 0.13989754, -0.3063599, -0.053729706, -0.11300094, -0.22203483, -0.07458341, 0.8315993) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.044922322, 0.3552098, -0.1271835, 0.39768565, 0.14321642, 0.37584135, -0.02135527, -0.04023784, -0.09375888, 0.42166096, 0.08642821, -0.3265904, -0.00013363075, -0.12803058, 0.1949475, -0.013425319) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.42953858, 0.71065485, 0.37048447, 0.16793256, 0.19240114, 0.24829336, 0.18606322, 0.14423718, -0.061551526, 0.003515224, -0.17762527, -0.13701168, 0.09062898, 0.31893012, 0.01895473, 0.14870448) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.1383193, -0.03907445, 0.11833929, 0.13231131, 0.00038429972, -0.16615705, 0.077435106, 0.14915787, -0.008351837, -0.38687634, -0.19678688, -0.11084492, 0.100635566, 0.25514156, -0.056107197, 0.2552506) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.13714267, -0.13519105, -0.21745238, -0.027145114, 0.1381731, 0.06205397, -0.0021565678, 0.1583166, 0.14405112, 0.3419931, 0.10397834, -0.15485743, -0.13162826, -0.053766865, -0.030377971, -0.091992915) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.0034586512, -0.08737764, -0.027942458, -0.019350663, 0.083869845, -0.3422344, 0.18636988, -0.08533533, 0.0030404846, -0.111138366, -0.09641436, -0.41175002, -0.030493772, 0.12914664, -0.023167148, -0.12747537) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.024944402, -0.024808038, 0.22058606, -0.075597346, -0.15855256, 0.18040428, -0.6598059, 0.28809655, -0.1828608, 0.46259156, -0.85966176, -0.49287152, -0.13207969, -0.12770097, 0.037086025, -0.0656775) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.079507515, -0.05855456, -0.10710452, -0.011173148, 0.02985135, 0.24936138, -0.10343267, -0.14585885, 0.02707679, -0.004306229, -0.07529558, -0.37153667, 0.0844744, 0.12158149, 0.011182824, 0.050020497) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.0204659, -0.044473104, -0.15368578, -0.3459552, -0.027920747, -0.23164596, -0.09520321, 0.08162281, -0.052031387, -0.122754976, 0.10321429, 0.2658314, -0.07922957, 0.30085018, -0.17387266, -0.20096923) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.060382705, -0.48794222, 0.5410212, 0.2789419, -0.40099812, -0.46695018, -0.4108203, 0.26291284, -0.22546273, 0.081879444, -0.2806955, 0.31856802, -0.16937283, -0.051005453, -0.07725244, -0.7726876) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.09812824, -0.08899647, 0.07712826, -0.15614809, 0.16116531, -0.106015116, 0.04204247, -0.12721302, -0.09082147, -0.20174147, 0.33052975, -0.28813392, 0.068200245, 0.20979348, -0.0885723, -0.038986128) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.04732164, 0.073465295, -0.020425692, -0.0021471262, 0.16908921, 0.34091446, 0.10290637, 0.0414784, -0.15066361, -0.013832662, -0.02173321, -0.30197895, -0.039386977, 0.12582439, -0.039209384, -0.039114237) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.3231895, 0.4214001, 0.17202699, -0.016202059, 0.07666484, 0.16510831, -0.13314769, 0.17599724, 0.13921264, 0.13739523, 0.1226181, -0.10100176, -0.020686246, 0.09532932, 0.08187813, -0.036149126) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.048805706, -0.008618898, -0.15888171, 0.0011236476, 0.24170092, -0.030454893, 0.04047107, 0.046033487, -0.06238286, 0.061863646, -0.36107555, -0.14671457, 0.035651278, 0.11682898, 0.03291568, 0.15778936) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
