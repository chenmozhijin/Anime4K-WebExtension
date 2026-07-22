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

@group(0) @binding(2) var tex_FEAT_TEX_1: texture_2d<f32>;

fn sample_FEAT_TEX_1(pos: vec2u, offset: vec2i) -> vec4f {
  let size = vec2i(textureDimensions(tex_FEAT_TEX_1));
  let coord = clamp(vec2i(pos) + offset, vec2i(0, 0), size - vec2i(1, 1));
  return textureLoad(tex_FEAT_TEX_1, coord, 0);
}
var<workgroup> tile_TMP1_TEX_0: array<array<vec4f, 10>, 10>;
var<workgroup> tile_TMP1_TEX_1: array<array<vec4f, 10>, 10>;
var<workgroup> tile_FEAT_TEX_1: array<array<vec4f, 10>, 10>;

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
      tile_FEAT_TEX_1[tileY][tileX] = sample_FEAT_TEX_1(
        groupOrigin,
        vec2i(i32(tileX) - 1, i32(tileY) - 1),
      );
    }
  }
  workgroupBarrier();

  if (pixel.x >= outputSize.x || pixel.y >= outputSize.y) {
    return;
  }

  var result: vec4f = vec4f(-0.27313584, 0.11394473, 0.10410854, 0.26507923);
      result += mat4x4<f32>(0.0010527812, -0.19523008, 0.06811512, 0.05999133, 0.030186776, 0.27629548, -0.21639068, -0.40043497, -0.12436956, -0.16333689, 0.055184398, 0.21568127, 0.24775593, -0.11143519, -0.15464722, 0.16788858) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.21856128, 0.051369734, -0.42223197, -0.2647367, -0.20602347, 0.44030365, -0.82211614, -0.1664449, 0.29699364, 0.15477867, -0.009152983, -0.26035798, -0.062258326, 0.12494542, -0.6771286, -0.1957766) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.05463641, -0.056247074, 0.020352466, -0.11019621, 0.22187757, -0.3986484, -0.14205204, -0.028454013, -0.10101933, -0.19910799, -0.08956818, -0.19867015, 0.23255615, -0.26074526, 0.18429632, -0.19993798) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.35449037, -0.11042673, 0.11224444, -0.3466446, -0.317455, -0.5335436, -0.0886868, -0.25032404, 0.17979962, -0.034576334, -0.03514483, 0.0044887783, -0.19075367, -0.22525279, -0.0956622, -0.3504559) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.35307974, -0.12550402, 0.22110407, 0.47703436, -0.17346516, -0.22131275, -0.29744807, -0.13083583, 0.36289197, 0.49744952, -0.13869733, -0.14582174, -0.100727506, -0.37364972, 0.01697181, -0.41102034) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.015789518, 0.08346174, -0.028564828, 0.39941564, -0.0952592, -0.0031855905, 0.026059221, 0.3741887, 0.48804602, 0.16191825, 0.22741225, 0.20013843, 0.2671461, -0.09756152, 0.011240521, -0.19588281) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.10718785, 0.13909501, 0.066901214, -0.08961821, 0.0122923, -0.2523763, 0.26009268, -0.11882061, -0.07402744, 0.13173567, -0.08998105, 0.07974265, 0.09751745, -0.1600019, -0.024779713, -0.13121024) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.20465279, 0.16503498, 0.051478546, 0.12611096, 0.15105377, 0.09176526, 0.015676033, 0.111356966, 0.011925805, -0.014709753, 0.066646025, 0.41862565, 0.14770435, -0.101325385, -0.051845305, 0.12403708) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.15092808, -0.015596879, -0.119511604, 0.23094465, 0.28652662, -0.14746481, -0.061294127, 0.17260568, 0.066487834, -0.12418404, 0.051781535, -0.08857563, 0.092697896, -0.11676074, -0.07366165, -0.19530547) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.021471852, 0.13116199, -0.15880577, 0.2235426, 0.24115807, 0.3841409, -0.22199772, -0.43515036, -0.50699246, -0.0019133548, 0.22662853, -0.043171305, -0.08962264, -0.08095994, -0.06564571, -0.26618305) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.51756513, -0.81504685, 0.7868719, 0.3484351, 0.12000578, 0.064392574, -0.09534743, -0.007708856, -0.44216323, -0.00991681, 0.15836066, -0.031212863, -0.2521928, -0.6422649, 0.44425875, -0.04484594) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.17865424, 0.03825185, -0.22434106, -0.16574785, -0.25984323, 0.14597553, -0.36898154, 0.112302914, 0.03988176, -0.022811335, -0.15008646, 0.5136579, 0.2034244, 0.09162336, 0.14863119, 0.031988464) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.06257627, -0.095320486, -0.16207008, 0.24364229, -0.13491449, 0.03609832, -0.17856967, -0.15692241, -0.33107287, 0.33394095, 0.18816003, -0.035312846, -0.3825707, -0.06393893, 0.006999577, -0.25480723) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.55682003, -0.64489526, 0.07341683, 0.11907537, 0.49148402, -0.4519812, 0.05738345, -0.08361218, -0.10743122, 0.2602482, 0.5957027, -0.7886137, -0.4878194, -0.44982696, 0.047232836, 0.11370503) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.53489864, 0.41123644, -0.20001207, 0.4843025, 0.3846029, -0.2539074, -0.051562063, 0.41847908, -0.14546977, 0.118075706, -0.34654278, 0.9150722, -0.2110106, -0.06156252, -0.09244922, -0.19947805) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.1984429, -0.07595623, -0.099211164, 0.05372269, -0.007995072, -0.097028136, -0.28612068, -0.06909309, -0.12389584, 0.1647356, 0.17887618, -0.4005159, 0.022365445, -0.09142189, 0.19799197, -0.36674517) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.03416738, -0.22484687, -0.026309451, 0.22783566, -0.034997404, -0.402847, 0.1905444, -0.061856005, -0.95078325, 0.16765212, 0.30076393, -0.25619933, 0.019149082, -0.12139187, 0.0964543, -0.18707827) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.15348816, -0.11625101, -0.09124702, -0.2248068, -0.35532424, -0.25591394, 0.048250653, -0.23172492, -0.06839773, 0.08996826, -0.24870977, 0.057415992, -0.089537665, 0.03522789, -0.04294508, -0.015300179) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_FEAT_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
