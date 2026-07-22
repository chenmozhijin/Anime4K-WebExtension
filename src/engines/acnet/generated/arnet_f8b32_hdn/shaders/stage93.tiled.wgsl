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

  var result: vec4f = vec4f(0.24069627, -0.3912713, 0.12832068, 0.025721645);
      result += mat4x4<f32>(0.06635408, -0.015075374, 0.10016597, 0.09952045, 0.22541648, -0.3558569, -0.2508639, -0.22153045, -0.09059909, 0.21671452, 0.037337832, 0.029766379, -0.15286493, 0.24432676, -0.2621256, 0.10502843) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.028321996, 0.036918327, -0.0999363, 0.115503326, 0.24267651, -0.26852724, 0.004213795, 0.035330724, -0.20425323, 0.287817, -0.04039603, 0.04562532, 0.0953053, -0.2799018, 0.000510524, -0.08253155) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.0016006868, 0.010164768, 0.0904569, -0.027686927, -0.05238453, 0.15539075, 0.06862579, 0.04933062, -0.034119472, 0.18585351, -0.023215136, 0.034898788, 0.27712682, -0.5321844, 0.23350123, 0.06711609) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.037297897, -0.08170033, 0.09956323, 0.12943031, 0.069658495, -1.1002934, -0.5271077, -0.3744114, -0.0849536, 0.23429127, 0.029646777, -0.050623763, -0.3823362, 0.61351734, -0.26385418, -0.015304594) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(1.2977834, -0.9212445, 0.6483777, -0.5808626, 0.08215231, -0.35617572, -0.0062770415, 0.12721932, -0.14725468, 0.29774368, -0.092544936, 0.036250092, 0.043079592, 0.19822367, -0.53636324, -0.09099474) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.03787269, -0.13318467, 0.12672596, -0.06623857, 0.024558479, 0.02067068, 0.17306882, -0.095470436, -0.09859517, 0.16529684, 0.010395047, 0.048945658, 0.19661216, -0.5196344, 0.27706045, -0.03967259) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.042483974, -0.15568347, 0.108027644, 0.17489247, -0.0025117246, -0.09590955, -0.03569057, -0.22406207, -0.10113697, 0.22671673, -0.02168974, 0.08444451, -0.3533521, 0.7717088, -0.26125237, 0.074464574) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.80118275, 0.79164946, -0.4318907, -0.24233422, 0.10453852, -0.0648812, 0.108017504, -0.057374213, -0.19777143, 0.30650088, -0.111068495, 0.11501037, 0.12072478, -0.27568418, 0.16369525, -0.23888229) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.103677005, 0.24416809, 0.14661585, -0.025595011, 0.034316834, -0.10729335, 0.21862121, 0.030692572, -0.032200787, 0.18881324, -0.03552947, 0.07145682, 0.055541396, -0.07827211, 0.24441274, -0.00025956627) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.27696055, 0.61509687, -0.2041659, -0.016269365, 0.08225737, -0.20972152, 0.03117794, -0.0076373345, 0.06511283, 0.12813312, 0.09834715, -0.15856345, -0.15572274, 0.15070005, -0.049310245, 0.0976252) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.23837003, 0.43259484, -0.13999137, -0.09873987, -0.106158555, 0.057832666, -0.08141133, -0.34356344, 0.0024852518, -0.04699582, -0.14930627, -0.15329084, 0.19241701, 0.0146472715, 0.15505615, -0.10828244) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.093158595, 0.1923626, -0.18451612, -0.029385792, -0.11206699, 0.27752194, 0.018869592, -0.013207865, -0.044091336, 0.23098248, 0.122026324, -0.035914302, -0.012236551, -0.23597723, 0.13032247, 0.06333512) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.109314196, 0.21403743, 0.05924003, -0.31401446, -0.16557477, -0.36125344, -0.2658793, -0.32876465, 0.19035442, -0.46719918, -0.015755767, -0.52869457, 0.002251198, 0.11659377, -0.08134354, -0.2593202) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.61476785, -1.0655224, 0.16838004, 0.15847054, 0.29718417, 0.6116931, 0.4814035, -0.2917154, -0.16611773, 0.62013674, -0.3822673, -0.20661634, -0.6785691, 1.0191221, -0.6273873, -0.25589034) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.080565974, -0.17302278, 0.008351275, -0.00452182, 0.0026910238, -0.19372861, 0.025382675, 0.19836652, -0.16050735, 0.09856158, -0.0187005, 0.13770305, -0.060609106, -0.13368018, -0.11586342, 0.085088976) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.13609399, -0.30738217, -0.015222325, -0.3225753, -0.12661618, -0.4005406, 0.14280447, -0.15011308, 0.19379441, -0.5098791, -0.47808948, -0.77035964, -0.0063526076, -0.12971525, 0.16774951, -0.051248103) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.1296071, -0.22984824, 0.12785476, -0.15345752, -0.1285691, 0.011025149, -0.096206166, 0.3083817, 0.064544044, -0.32207647, -0.38636133, -0.27520576, -0.25427142, 0.06686753, 0.1822299, 0.3937568) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.11491218, -0.39613342, -0.0014991837, 0.10638762, 0.15990376, 0.1375947, -0.076391965, 0.30095524, -0.14180784, 0.39119655, -0.0018097189, 0.0634276, 0.039572954, 0.06068796, 0.08632346, -0.058661338) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
