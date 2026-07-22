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

  var result: vec4f = vec4f(-0.2120954, -0.08136685, -0.089316115, -0.118955374);
      result += mat4x4<f32>(0.032339104, 0.022886394, 0.12896468, -0.020823464, 0.15839803, -0.30365923, 0.038742762, 0.23739582, 0.098301664, -0.049446277, 0.121433, 0.25158158, 0.019266764, 0.051461812, 0.2036257, -0.24538098) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.08604473, -0.06305989, 0.14781614, -0.058903962, -0.008019736, -0.26078048, 0.4387267, 0.06791387, 0.04650796, 0.1737399, 0.52765715, 0.20326582, -0.05452519, 0.24149807, -0.22784828, -0.29935375) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.065475896, -0.10135159, 0.043978877, 0.0011387109, -0.10104227, 0.3117328, -0.007542332, -0.1695392, -0.16826822, 0.015874384, -0.0757294, 0.14771387, 0.20999628, 0.34255347, 0.30019584, -0.19380563) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.16961536, 0.056620985, 0.09671776, -0.521216, -0.06593415, 0.3024268, -0.3066912, 0.125173, 0.2433425, -0.5186772, -0.1421905, 0.12811181, 0.07427735, -0.24309458, -0.12351353, -0.13056275) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.25733516, 0.17110841, -1.2828614, -0.48631608, -0.0069186073, 0.3365523, 0.085853405, 1.3663157, 0.24854857, -0.06371769, -0.010115321, -0.33467144, 0.53410375, -0.45754173, -0.27404204, -0.18587685) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.08929885, -0.4177201, -0.058320813, -0.005966524, -0.0494208, 0.21460418, -0.19846018, -0.100671075, -0.2385082, 0.3375833, -0.009417152, -0.26529655, 0.21199396, -0.51533717, -0.12024777, -0.034058865) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.056055106, -0.102466, -0.18145353, -0.10158743, 0.033885263, -0.25043792, 0.09971587, -0.4324908, 0.040093638, -0.11376761, -0.20117311, -0.040262565, -0.03497708, 0.19392179, 0.023940304, 0.008850215) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.4961532, -0.43142408, -0.123125724, 0.2658715, -0.001546214, 0.05151415, 0.06248375, -0.0069119553, -0.084505714, 0.25289616, -0.11330468, -0.31024203, 0.19388233, 0.2852514, 0.2577506, -0.26262495) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.076964766, -0.029370641, -0.021062765, -0.18767776, -0.0067049814, 0.19893609, 0.0065291175, -0.14745867, -0.1827464, 0.09866949, -0.1333405, 0.03250816, -0.12002705, -0.12540928, -0.026438082, -0.070465095) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.15941569, -0.3387777, 0.27237964, 0.30966175, -0.025104806, -0.1464359, 0.626222, -0.80048424, -0.07337552, -0.03745024, -0.20909081, -0.026651861, -0.2057586, -0.484892, 0.2305179, -0.37958586) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.20044714, 0.049810346, 0.4182622, 0.23138817, 0.26177803, -0.3437514, -0.19014214, 0.23245236, 0.05304187, 0.07818123, 0.27375013, 0.10993718, -0.03296574, -0.34359998, -0.043038644, -0.019529326) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.099549055, 0.13913985, 0.3416879, -0.011879747, -0.3269324, 0.15038024, 0.19058807, 0.12594251, -0.07658373, 0.051060043, -0.05296781, 0.018271293, -0.1909457, -0.015543865, 0.07689065, -0.32541123) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.133308, -0.49765188, -0.2497304, 0.29239973, 0.26646903, 0.15001373, -0.114343174, -0.3750566, -0.06130397, -0.14230011, -0.039727986, 0.36950672, -0.023115436, -0.5561932, 0.016115157, 0.0046926667) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.9074651, 0.10913584, -0.32298404, -0.5320254, 0.041034486, 1.1314108, -0.7069194, 0.49522045, 0.21372174, -0.24399534, 1.1116374, 0.49775103, 0.16301297, 0.529474, 0.11024343, 0.8302128) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.21072982, 0.33649042, -0.10259073, -0.12333988, -0.3370299, 0.25506446, 0.11755315, 0.39762703, -0.06317005, 0.16753575, -0.11215753, 0.071273856, -0.103272706, -0.03900958, -0.086588174, -0.06680064) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.004013281, -0.3622743, -0.13344432, -0.04301613, -0.25790235, -0.046938203, 0.19607434, -0.21189791, 0.07868384, 0.18872635, -0.0010939274, 0.12126955, -0.2525306, -0.49782887, -0.35854173, 0.2887137) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.2662436, -0.23339602, -0.32221925, -0.040413946, 0.16432464, -0.46913493, -0.3585066, 0.061089583, 0.23586231, 0.3168168, 0.2140271, -0.14784825, -0.1747756, 0.14240947, 0.041445892, 0.26004744) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.32084966, 0.176729, -0.15113178, -0.10789218, 0.16208775, -0.10451868, -0.22319835, 0.39926946, 0.08239979, 0.21945266, 0.097399704, 0.14430204, -0.0013652712, 0.15622008, -0.04244913, 0.14673023) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
