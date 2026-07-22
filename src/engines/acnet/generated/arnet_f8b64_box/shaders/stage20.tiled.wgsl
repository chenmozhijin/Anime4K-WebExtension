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

  var result: vec4f = vec4f(0.24809583, -0.07912814, 0.118374914, -0.08180679);
      result += mat4x4<f32>(0.08656539, 0.061552186, -0.08091895, -0.07108318, 0.06511189, 0.059464496, -0.29667678, 0.15094544, 0.15221654, 0.106124625, -0.20864806, 0.06245698, 0.03035768, 0.14524046, -0.038428888, -0.19545984) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.072179146, 0.010772525, -0.047767833, 0.38282454, 0.17694621, 0.116787784, 0.017997446, 0.3954529, -0.01295928, -0.14903209, 0.09966273, 0.2849256, 0.26977375, 0.16376035, -0.14606069, 0.051995113) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.08157708, -0.11155767, -0.037317764, 0.13905232, -0.06805507, -0.030489877, 0.11838479, 0.011392746, -0.18440291, -0.07013132, -0.46784857, -0.0448542, 0.2422002, 0.13986114, 0.08647411, -0.060250103) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.17749071, 0.7099494, -0.3512589, -0.56577927, 0.3443767, -0.15410922, 0.0078431945, 0.12942493, 0.20152882, 0.44980276, -0.41551036, -0.19710492, 0.09003475, 0.051797062, -0.10822464, -0.2573255) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.90120834, 0.57451326, 0.7808529, 0.5183893, -0.01923555, 0.0024829234, -0.18572177, -0.51291454, -0.09263108, 0.059805088, 0.029573498, -0.6900949, 0.09088274, -0.4180894, 0.6534687, 0.47551653) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.109847255, 0.1365761, 0.06371892, 0.03809987, -0.31919882, 0.01119102, 0.3848834, 0.27582476, 0.018884635, -0.049371775, -0.6046778, 0.022830803, -0.0015661919, 0.06693204, -0.25973478, -0.23871896) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.21264242, 0.073173754, -0.15821369, -0.18325397, -0.055583842, 0.16796282, -0.20686579, -0.101046175, 0.22153974, -0.28817704, 0.10791045, -0.16448747, -0.10036064, 0.12900645, -0.07265365, -0.08374477) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.18944676, 0.072083674, -0.16098243, -0.083903395, -0.0777133, -0.056442525, 0.16563095, -0.09458117, -0.09824357, -0.18639323, -0.2101879, 0.07714052, 0.29266694, -0.10570184, -0.19708465, -0.08548975) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.119678326, -0.12183742, -0.14960618, 0.03250864, -0.008380875, 0.08334958, 0.18361129, 0.12455393, -0.247633, 0.12278039, 0.2358556, 0.020493709, 0.18596719, -0.064721346, -0.20061465, -0.08915542) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.16227415, 0.1097665, 0.10124591, -0.062200848, -0.086981185, -0.19267322, 0.038305845, 0.0514496, -0.17594142, -0.024194773, 0.0037077619, 0.06573735, -0.13725547, 0.02520313, 0.022084624, 0.16657399) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.23377496, -0.07036871, 0.09763691, 0.13389294, -0.04536632, -0.04373453, -0.023818364, -0.18653959, -0.19813061, -0.031615883, 0.026448064, 0.054472398, -0.2302814, 0.0818379, 0.1717997, 0.12579963) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.10298536, 0.30754498, 0.11859573, 0.19877285, -0.0051751654, 0.073636465, 0.08202686, -0.16822326, -0.22333108, -0.06527842, -0.09783711, 0.07580376, 0.02188362, -0.036575448, -0.16132186, 0.030460835) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.20018278, 0.14444268, 0.023956228, 0.067355976, 0.09388181, -0.69024897, 0.27851987, 0.43894526, -0.25142628, -0.27855447, -0.14500661, 0.32668275, -0.7148413, 0.1974537, 0.1314909, -0.1976916) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.16619651, 0.17998293, 0.5446469, -0.44106248, 0.5138208, -0.62972873, -0.60888606, -0.5156021, 0.46920952, 0.017096423, -0.61286855, -0.14176035, 0.10469619, -0.18932089, 0.04705436, -0.15739462) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.1527166, -0.16982375, -0.40458813, -0.16368887, 0.16487488, -0.13209347, -0.03553125, -0.11338126, 0.11784913, 0.009467219, 0.16535719, 0.2510489, 0.25525638, -0.14520927, -0.22917873, -0.010811136) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.07630696, -0.06722698, 0.050287873, 0.07000676, -0.0650943, -0.180752, 0.17363136, 0.24350138, 0.19209795, -0.043832432, -0.13422996, -0.011858885, -0.17885445, -0.13512093, 0.16850115, -0.06973142) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.06941096, 0.11058625, 0.0900646, 0.018518062, -0.19068791, -0.029140016, 0.17403834, 0.1015076, -0.024142945, -0.11826029, -0.1994509, 0.15043065, 0.030569812, -0.16692486, -0.19573633, 0.05596821) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.09116031, 0.07194371, 0.04248407, -0.174184, -0.12356163, 0.07393276, 0.12355328, 0.021675123, 0.053593714, -0.0005976397, 0.010849656, -0.03179004, -0.18543634, 0.0071600713, 0.0074569113, 0.04186227) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
