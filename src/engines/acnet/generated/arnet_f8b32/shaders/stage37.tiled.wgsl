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

  var result: vec4f = vec4f(0.25538874, 0.035365272, 0.11809437, 0.027457828);
      result += mat4x4<f32>(-0.08287504, 0.5160589, -0.06402483, -0.18163896, 0.13252398, 0.014040692, -0.0435545, -0.037952013, -0.14829649, -0.39591902, 0.21832688, 0.041440632, 0.017832303, -0.36118838, -0.07117327, 0.12598789) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.13353212, 0.12283356, 0.27186564, 0.2845365, 0.38119218, 0.0797824, -0.13985609, 0.025682215, 0.21958746, 0.019536963, 0.37998316, -0.14889945, 0.12989582, -0.09473337, 0.4355818, -0.07982141) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.20414786, 0.08762325, -0.06726909, -0.09169462, -0.11063817, 0.053728987, -0.092290245, -0.05773671, -0.170555, 0.06485998, -0.22691083, 0.13582781, 0.08373905, 0.14842393, -0.19511032, 0.0047858567) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.2522335, 0.1295477, 0.0018139072, -0.6059937, -0.085010506, 0.045575008, -0.0021454946, -0.076278724, 0.62277734, 0.12534319, -0.30320814, 0.81787246, -0.044885397, -0.44467017, -0.28366137, 0.178417) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.28672013, 0.16250806, -0.28601876, 0.45439792, 0.6308572, 0.30170253, -0.062269676, -0.09528425, 0.20936608, -0.05546321, 0.025583796, -0.15907514, -0.5225662, -0.611134, -0.30855462, 0.051868267) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.038676366, 0.03393681, 0.006712689, -0.3125763, -0.06790128, 0.20686902, -0.074471936, 0.10403185, -0.112707876, 0.05923703, -0.09040137, 0.09965578, -0.29634845, -0.03468287, -0.31462342, -0.15002868) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.22405191, 0.13644187, -0.012725381, 0.12422132, 0.19281015, -0.023315797, -0.23032069, 0.21652287, 0.14497466, 0.19919394, 0.101297975, -0.07676898, -0.48206857, -0.14473884, 0.1333828, -0.28373262) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.26202348, -0.16978347, -0.105690286, -0.056369815, -0.4208336, 0.020615667, -0.030584529, -0.06699633, -0.4128097, 0.047078248, 0.28623968, -0.50548923, -0.263996, 0.020317627, 0.063296705, 0.078439675) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.16349624, -0.07163764, 0.013297492, -0.08183741, -0.111602455, 0.06616042, 0.0012882742, 0.15278979, -0.07978749, 0.2537785, 0.19018109, 0.08495307, -0.0372313, -0.028575381, -0.0455094, -0.25401586) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.0825982, -0.016856957, -0.024740282, 0.0610909, 0.03548241, 0.015494684, 0.21348825, 0.043210555, -0.0844382, 0.024300877, 0.08998359, 0.016664622, 0.011818979, -0.053882558, -0.20384188, 0.11455799) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.07619386, 0.10634637, -0.28428385, -0.20627724, -0.3501091, -0.23233406, -0.03979827, 0.03658048, 0.14551845, -0.22651072, 0.22900121, 0.04546698, 0.34121257, 0.20851503, 0.07955365, -0.073879026) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.09132272, 0.09605723, -0.21490459, -0.026277632, -0.14517376, -0.32921258, 0.061967727, -0.25927854, -0.0044517987, -0.06742333, 0.05595808, 0.1483471, -0.00022529109, 0.19129485, -0.071057476, -0.04862546) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.18509172, -0.039131764, -0.040067505, -0.27903068, 0.4593861, -0.31663743, 0.19439141, -0.08538101, -0.14900543, -0.09507343, 0.13481094, -0.42605388, 0.13366285, -0.12550512, -0.16808763, 0.22399235) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.105218686, -0.3788973, 0.46126345, -0.060159974, 0.46344328, 0.120103106, 0.1897466, -0.36723396, -0.3264977, 0.6673182, -0.34484497, -0.34125277, -0.39080033, 0.5199815, -0.32431355, -0.41413158) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.15921313, -0.02168907, 0.02967629, -0.4884967, 0.26028103, -0.09652377, 0.24870756, -0.2369842, -0.28790867, 0.19117434, -0.20996524, 0.43578523, -0.47614786, 0.14323191, -0.2423658, -0.040981997) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.19751376, 0.042981178, 0.005322566, 0.0141448025, 0.34424305, 0.07651014, 0.047155548, 0.09632658, -0.045636285, 0.115028605, -0.049374815, 0.40884107, 0.280006, 0.14869457, -0.34704342, 0.32345068) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.75027937, -0.69606894, -0.037888438, -0.11828474, 0.7726805, 0.11775933, 0.090082556, 0.06603423, 0.1284939, 0.14825855, -0.29295146, 0.47152093, -0.4555434, -0.11077164, 0.11091803, 0.26217183) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.40200981, -0.32728323, -0.011431959, -0.12417069, 0.24175885, 0.019449787, -0.049964596, 0.1717172, 0.033879966, -0.21473874, -0.262065, -0.050968256, -0.16172811, 0.32773116, 0.09238872, 0.2876882) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
