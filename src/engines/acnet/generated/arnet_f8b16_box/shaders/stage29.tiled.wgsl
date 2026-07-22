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

  var result: vec4f = vec4f(-0.07655367, 0.24818835, 0.24836949, 0.2689202);
      result += mat4x4<f32>(0.1858982, 0.004238446, 0.058208913, 0.039004654, -0.26455846, -0.062341135, 0.05333313, 0.13531417, 0.063118726, -0.087570876, 0.09620191, -0.008140421, 0.044947527, 0.023482053, -0.13432017, -0.07745561) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.19699544, 0.11248244, -0.0027615416, 0.020277396, -0.30447954, 0.21373954, 0.05134188, 0.092747636, 0.17896548, -0.19142045, -0.068140104, -0.12162673, -0.42951337, 0.08922024, 0.0640965, -0.11999041) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.11993113, -0.032452136, 0.009664992, 0.07665226, 0.25776678, -0.42494503, 0.01210394, 0.07239541, 0.14088598, -0.13516204, 0.01187864, 0.017584465, -0.19383378, 0.26049066, 0.10944146, -0.1653147) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.14500052, 0.108174995, 0.026064921, 0.081076324, 0.33249572, 0.04556795, 0.16567098, -0.12553178, -0.046356793, -0.08330965, 0.032123484, -0.14981276, 0.42387185, -0.12204183, 0.054008592, 0.057576012) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.03185034, -0.17974818, 0.18965796, 0.29625145, 0.14519425, 0.5523221, -0.08432032, -0.34511963, 0.30685097, -0.33145264, 0.27204698, 0.13833588, -0.31060058, -0.23040712, -0.4140041, -0.21420921) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.09780652, 0.054683983, -0.12520677, -0.22622037, 0.4217125, 0.12682658, 0.07441745, -0.123959, -0.04906319, -0.055444244, 0.1122897, 0.04492765, -0.056777585, -0.315954, -0.1371166, -0.06339183) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.07841735, -0.09242382, -0.0119223595, -0.11813168, 0.22351463, 0.16145024, -0.13282527, -0.07057964, 0.08607823, -0.15587892, 0.19797483, 0.08579371, -0.23923199, -0.14262547, 0.22680214, 0.19906741) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.056258652, 0.42514595, -0.12058848, -0.0982772, 0.07375761, 0.119394965, -0.02693946, -0.0646424, 0.3317029, -0.061488833, 0.09101959, 0.034812607, -0.32030207, -0.28557494, 0.22980252, 0.1417749) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.15506859, -0.16572964, -0.0112839965, -0.06709344, 0.47110784, 0.6286524, -0.3376076, -0.34694344, 0.03157494, -0.08774511, 0.09775441, 0.08927511, -0.28347543, -0.06140121, 0.08372034, 0.1214798) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.15421113, -0.19540742, 0.010461537, -0.036849387, -0.021629436, 0.028444245, 0.0122600775, 0.0456217, -0.2462107, 0.21637326, -0.06560363, 0.027267838, 0.048885893, -0.036552988, -0.006460903, 0.00097054377) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.05812516, -0.03227278, 0.13144237, -0.061977126, -0.1150599, 0.05171766, 0.19566175, 0.1391949, -0.13701297, 0.008001448, -0.0448936, 0.072109036, 0.004685699, -0.0838135, 0.0278569, 0.091058865) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.052422542, -0.093204916, 0.044943873, -0.05522582, -0.0073077637, -0.22853602, 0.095726356, 0.058051456, -0.2384171, 0.018784331, 0.014198263, 0.0704273, 0.20898919, -0.01293982, -0.05356718, -0.052088708) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.1086551, -0.1812577, 0.19521704, 0.5888711, -0.03180577, -0.09726338, 0.086303376, 0.10105222, -0.12630475, 0.24736449, -0.28893134, -0.13183637, 0.1454791, -0.047785692, 0.044196967, 0.05503673) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.2674409, 0.18153182, -0.009485266, -0.2930367, -0.15726961, -0.035511896, -0.048591346, 0.02296124, -0.1334737, 0.6889366, 0.060286902, 0.022531966, -0.0926636, -0.19455624, -0.45251828, -0.16794094) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.075180426, -0.3249079, 0.12735014, 0.20660181, 0.22857304, -0.54207426, 0.048578568, 0.124093786, 0.015996087, -0.024250384, -0.05661933, 0.062895, 0.044802763, -0.20863113, -0.35596144, -0.26079166) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.14617433, -0.15253277, -0.009700686, -0.16432986, -0.020196173, -0.07255954, 0.12212534, 0.044354323, -0.3097832, 0.25966513, -0.053666957, 0.019028207, 0.0046903044, 0.025978114, -0.023362206, 0.057970367) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.047393423, -0.0029122895, -0.0358408, -0.05144215, -0.3534166, -0.33913943, 0.13539566, 0.33729014, -0.28150657, 0.1480375, -0.1144967, -0.054317053, 0.18388526, 0.06540144, -0.035452582, -0.0059968634) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.06468993, -0.10570148, -0.08305533, -0.06330473, -0.10817045, -0.3447748, 0.20111583, 0.21215765, -0.22550409, 0.16393305, -0.12443224, 0.016183427, 0.2721974, 0.068698145, -0.026766164, -0.050191626) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
