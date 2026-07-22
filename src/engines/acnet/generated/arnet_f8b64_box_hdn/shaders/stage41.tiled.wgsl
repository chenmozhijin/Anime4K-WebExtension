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

  var result: vec4f = vec4f(0.049269766, -0.1307467, 0.14690611, 0.055130318);
      result += mat4x4<f32>(-0.01321027, 0.096064284, 0.17259845, -0.34230638, -0.022716993, -0.15692994, 0.16158722, -0.024050493, 0.12150505, 0.19795476, -0.010606789, 0.21590714, 0.21603295, -0.025009051, -0.18909054, -0.075510345) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.1613594, -0.14499336, -0.8161018, -0.39561427, 0.12841497, -0.16440567, 0.024234127, 0.056189574, 0.064665794, -0.048352007, 0.680788, 0.3724404, 0.04406633, 0.055056915, 0.54986507, -0.2405059) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.095185935, -0.33540702, 0.10403662, -0.03820264, 0.043482095, 0.060923576, -0.0184644, -0.092373714, -0.09889968, -0.09286103, -0.34890538, 0.19975765, -0.03926524, 0.19304606, 0.24166153, -0.46473902) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.1378613, 0.20141277, -0.24407506, 0.28298634, 0.032485723, -0.068355314, 0.07740293, 0.14401305, -0.020314967, 0.17521837, 0.025533522, 0.18886006, -0.11344381, -0.15536422, -0.10028568, -0.07170654) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.052897327, 0.5417265, 0.64034534, -0.039308343, -0.90442014, -0.4311172, 0.21632092, 0.37718457, 0.3068331, -0.13636461, -0.81635165, 0.5827399, 0.37011462, 0.09042396, 0.41221088, -0.21619742) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.0150747495, -0.34617808, 0.22948743, 0.11625921, -0.19780101, 0.06812361, 0.08033977, -0.37471324, 0.24885306, -0.5849176, -0.44317162, 0.43808737, 0.19894506, 0.22556975, 0.37437144, -0.03333348) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.10289704, 0.27801108, 0.15229286, -0.21131854, -0.06240801, -0.016293837, -0.095749386, 0.065971315, 0.048226558, -0.013079433, 0.004819889, -0.021218179, -0.017603118, 0.44402015, 0.16770361, -0.34259522) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.0039065033, -0.095718555, -0.29106608, 0.2563814, -0.055475537, 0.22579037, -0.18410595, 0.16379584, -0.4362927, -0.5469438, -0.29730922, 0.04996143, 0.28635958, 0.5362124, 0.006027679, -0.068651594) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.0837268, 0.25998846, -0.11138646, -0.39567572, -0.07576596, -0.29356286, -0.044487305, 0.25625497, 0.16813394, 0.44539928, 0.14856276, 0.35616204, 0.06559798, 0.13527519, 0.07128224, -0.08139855) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.07964493, -0.21981685, -0.017508054, 0.08583101, -0.002726884, 0.23105142, 0.108658254, -0.22568859, 0.021843748, -0.119395725, -0.043760866, 0.0019961258, -0.048771568, -0.20520855, -0.027880332, -0.1094048) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.21811338, 0.14622955, -0.33222708, 0.10716743, 0.12130646, 0.009507709, 0.64534324, 0.38318178, -0.08220079, -0.24108084, -0.13627663, -0.36772606, -0.02649896, 0.009882617, -0.1629869, -0.12913513) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.020571884, -0.07006044, -0.25255588, -0.024790024, -0.036011748, 0.17776571, 0.036300484, 0.29821017, 0.0581481, 0.037757203, -0.051587567, -0.11783436, -0.117553726, -0.12634179, -0.11217998, 0.12575659) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.08463798, -0.5865999, -0.39905608, 0.01531189, 0.03367515, -0.6045921, -0.12433468, 0.040307708, -0.03416438, 0.031233506, 0.24499743, -0.44497094, 0.1546743, 0.012180456, 0.17088233, -0.08744332) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.2841284, -0.016588483, -0.16029954, 0.32085875, 0.07904507, 0.029716136, -0.24322036, 0.26397052, 0.21107085, -0.20539674, 0.00697118, 0.11315524, -0.37485614, 0.28490907, 0.629168, -1.1731771) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.01682312, 0.23348033, -0.1443929, -0.04853454, -0.0843014, 0.60051733, -0.124994785, -0.25583997, 0.015703179, 0.077378646, -0.15804183, 0.011976817, -0.27413914, 0.8758708, 0.044445254, -0.527817) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.1255897, -0.032338753, 0.05180865, -0.08777271, -0.0033744944, 0.14388262, 0.01700207, -0.002823896, 0.039509572, 0.043833222, 0.038098946, -0.2078349, 0.049607657, 0.052495502, 0.026945442, -0.12970328) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.010026197, 0.0031075713, -0.09274464, 0.09432438, -0.018511508, -0.069067635, 0.1277771, -0.5529104, 0.33605018, 0.10847864, 0.13269293, -0.15575987, 0.12222945, -0.1057745, 0.04904177, -0.5025484) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.15444984, -0.13619602, -0.12060271, 0.0020035994, 0.008109845, -0.046436794, 0.04332723, 0.24402653, 0.040591273, -0.001475227, -0.15838675, 0.058205727, -0.35123158, -0.31069764, -0.1776887, 0.3021216) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
