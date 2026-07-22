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

  var result: vec4f = vec4f(-0.012966952, -0.2812022, 0.23141256, 0.10585057);
      result += mat4x4<f32>(-0.10016986, -0.0747009, -0.110440366, 0.025335206, -0.030533692, -0.20080803, -0.10698702, -0.11722918, -0.06839003, -0.020595811, 0.0027254443, -0.107846, -0.028160065, 0.18041535, -0.3632138, -0.3363022) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.26182184, 0.084144354, -0.34674674, -0.6882299, 0.17184423, -0.10493509, 0.15122873, -0.017420754, 0.017435221, -0.010605902, -0.14698815, 0.30236635, 0.07307758, -0.2729145, -0.029240541, 0.17156363) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.002426614, 0.039830558, -0.011980256, -0.23855944, 0.005562875, 0.055505656, 0.023172615, -0.11470207, -0.023999635, 0.0029700235, 0.021077098, -0.029145323, 0.0034750265, -0.19181852, 0.35736445, 0.19642784) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.042604223, -0.32130504, 0.11157516, -0.20004211, -0.11877459, 0.085939266, -0.03323797, 0.14818507, 0.088883065, -0.046261262, 0.11507648, -0.28878433, -0.035030443, -0.10897205, 0.1070272, 0.15439102) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.34390613, 0.5596287, 0.08795819, 0.61750114, 0.51711994, 0.9960925, -0.38307008, 0.3066895, -0.26782686, 0.5839331, -0.18817288, 0.66106004, 0.0944933, -0.19389202, 0.097521156, -0.08100302) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.01762402, -0.36026508, -0.3004441, 0.3970244, 0.173318, -0.24005775, 0.23011734, -0.15282394, 0.15957119, -0.27773637, -0.12568481, 0.08524088, -0.04188344, -0.20765215, 0.29552194, 0.21410376) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.1242148, -0.090261854, -0.11078913, -0.037304077, -0.026161248, -0.21944125, 0.10688028, 0.1854156, -0.0062057357, -0.034063075, -0.094262324, -0.09848658, -0.05227533, 0.4486331, -0.4100744, -0.17269985) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.22339186, -0.16278909, -0.030540414, -0.101902254, -0.1591225, -0.21598199, 0.14803253, 0.23133644, -0.038270257, 0.09097449, -0.1100273, -0.016678004, -0.25766844, 0.4652684, -0.290853, -0.19579177) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.1284574, 0.07691889, -0.1332814, -0.10255227, -0.059283502, -0.13240215, 0.018948391, 0.06568773, -0.05727233, 0.09166984, -0.015751421, -0.046634987, -0.25086987, 0.16570945, 0.031926963, 0.25178897) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.08095055, 0.3316384, -0.09403075, -0.28317133, 0.016307766, -0.25532013, 0.016925156, 0.045378778, 0.013048884, -0.11527272, 0.07287025, 0.1266179, -0.23345709, -0.09978959, -0.23718682, -0.09845146) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.10185776, 0.19648351, -0.48260656, -0.17962502, 0.21380775, -0.051869933, 0.050130866, -0.11662904, -0.07285461, 0.029838538, -0.0626001, -0.05162216, 0.29357415, -0.11794529, 0.08257676, -0.35719055) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.102155335, 0.024378084, -0.11892095, -0.26909772, 0.06842266, -0.3483237, -0.056703456, 0.07772773, -0.030822601, 0.09412819, 0.04082969, 0.03678932, -0.117734015, 0.16057424, -0.070004314, 0.08190203) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.07640916, 0.34507447, -0.10933213, -0.055936966, -0.059837323, 0.1327866, -0.0065229954, 0.12813021, -0.067488484, -0.16236651, 0.13200775, 0.01886437, -0.018134313, 0.24488576, -0.3408756, 0.04017177) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.16657259, 0.17337482, -0.18388331, -0.046252124, 0.8746814, -0.09407755, -0.10939466, -0.20301454, 0.44664758, 0.5806951, 0.036669195, -0.41594648, 0.19566673, 0.3918073, -0.2847915, -0.36264595) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.20209953, -0.37749696, 0.41434523, 0.08992895, -0.028794326, 0.17563567, 0.26832524, -0.03322573, 0.24431403, -0.3812524, 0.077452846, -0.13152146, -0.30028936, -0.14871472, 0.023844237, 0.13418768) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.009951943, 0.072072506, 0.02718141, 0.059108946, -0.027868757, -0.094707824, 0.06878908, 0.12942047, 0.022512982, -0.11270443, 0.049988955, 0.07214629, -0.040887497, 0.09082855, 0.18906505, -0.023001269) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.17876722, 0.034372017, 0.29694274, 0.41737607, 0.0070805512, 0.054035295, -0.096573524, -0.014457362, 0.14262076, 0.035337422, -0.07647425, -0.18064024, -0.24058183, 0.23644489, -0.21709086, -0.17151643) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.07237599, -0.44212142, 0.35767776, 0.4012498, -0.054322038, 0.027571995, -0.002745445, -0.045933854, -0.29097944, 0.09038233, -0.16171502, -0.16415988, -0.04231091, -0.023536347, -0.08687797, 0.015160048) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
