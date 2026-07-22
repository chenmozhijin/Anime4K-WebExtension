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

  var result: vec4f = vec4f(-0.06786445, -0.0402333, 0.24338377, -0.14754671);
      result += mat4x4<f32>(-0.08085903, 0.23515059, -0.031811297, -0.2152429, -0.09153414, 0.026367152, 0.06977273, 0.05365536, 0.051896244, 0.04358644, 0.04484133, -0.13804357, 0.07020777, -0.087230794, -0.083120525, -0.009375069) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.07508876, 0.17514476, -0.00059606956, -0.34148946, -0.044282835, 0.053184588, 0.13759959, 0.12683581, -0.06574252, -0.11371296, 0.008861926, -0.08511106, 0.20302917, -0.0925673, 0.24567185, -0.011937202) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.11511642, 0.31835267, 0.061837286, -0.24455903, -0.034672566, -0.0632757, 0.17789726, -0.0010733915, -0.011285298, 0.03538461, -0.07919424, -0.18696813, 0.03569054, -0.008521987, 0.049251016, -0.075650856) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.01422142, 0.18828188, -0.06311087, -0.21311294, -0.2013448, 0.084878005, 0.28862584, 0.04492973, -0.008625394, 0.04362831, -0.089962885, 0.055869337, 0.06403039, -0.15782581, -0.026493566, -0.030583926) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.13900688, 0.29338577, -0.25981575, -0.61425304, -0.16936937, -0.9265127, -0.20750631, 0.2627802, 0.5013793, 0.1580507, 0.6007832, 0.7347082, -0.4315181, 0.6406645, 0.633963, -0.28727958) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.06580751, 0.16998115, 0.026904607, -0.20051543, -0.011785776, -0.026255617, 0.11159282, 0.02240911, 0.11367502, -0.035088703, -0.100165255, -0.09712684, -0.49607474, 0.32354707, -0.1995188, 0.15389235) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.015040199, 0.08314719, -0.006561098, -0.052430667, 0.059237834, 0.077515155, 0.085898675, -0.26413444, 0.09503127, -0.09904206, -0.12161563, 0.021897653, -0.03678935, -0.029012915, -0.0036647827, 0.08201888) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.0778272, 0.15649442, 0.026382463, -0.08594275, -0.1531443, 0.14656809, 0.10422176, -0.077477105, -0.22827262, 0.18129942, -0.020598175, -0.044586446, -0.1387905, 0.05552749, 0.019600406, -0.058543913) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.015007542, 0.13317393, -0.024864733, -0.14333963, 0.06526101, 0.07031265, 0.15584798, 0.015520945, -0.010549996, 0.021626482, -0.020307114, -0.11610646, 0.19125266, -0.021376204, 0.13645288, 0.079137884) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.07322865, -0.009759591, -0.14302763, -0.05209435, -0.070494965, 0.025951076, -0.014786005, -0.08521446, 0.07486489, -0.001810171, -0.35315722, -0.13755624, 0.019580878, -0.16858903, -0.0071306215, 0.04136539) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.034941625, 0.19159302, -0.24733298, 0.055512022, -0.14486854, 0.016930323, 0.2585812, -0.12975879, -0.14707027, -0.31309554, -0.08689428, 0.19139306, -0.13414583, 0.116085835, -0.34869763, -0.16747612) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.022512328, 0.13076907, -0.14876801, -0.14424591, -0.036790125, 0.27531368, 0.38529274, 0.03150976, 0.119257025, 0.014943404, -0.3862758, 0.021812588, 0.050336372, -0.14899643, 0.31047076, 0.18543196) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.14780495, -0.09393895, -0.3776523, 0.010365127, -0.17336573, 0.28260157, -0.0068534147, -0.031716138, 0.19263673, -0.11731466, 0.028535046, -0.12210971, 0.1015064, 0.19287932, -0.08894102, -0.12163824) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.30495083, -0.6023426, 0.6814617, -0.52897906, -0.0016179059, 0.061288398, -0.012675711, 0.36922595, 0.40232697, 0.19115217, 0.20684677, 0.06625634, -0.2199585, 0.98339903, 0.094263844, -0.06383312) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.061425727, -0.07798835, 0.0014548325, 0.07572437, 0.053080563, 0.22957575, 0.027119791, -0.32647622, 0.07666456, -0.109516606, -0.44958523, -0.24149019, -0.2179267, 0.08635207, 0.34891072, 0.20110804) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.038236097, 0.023670856, -0.12267067, -0.21124674, -0.12935415, 0.15533006, -0.008669589, -0.2226594, -0.11405006, -0.34557152, -0.15072061, 0.2808485, -0.012078969, -0.034073196, -0.03824988, 0.12759908) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.12739402, -0.104944855, 0.2718413, 0.24225809, 0.7029352, 0.061036088, -0.26863822, -0.01833616, -0.23326285, 0.40556654, -0.12199924, 0.06077671, 0.15920465, -0.016409935, -0.04271899, -0.012296324) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.18072392, 0.10213747, -0.020766448, 0.04290458, -0.11876726, 0.18782584, -0.27812582, -0.46702567, -0.190324, -0.0072504105, 0.16330445, 0.054846693, 0.010558375, 0.0961649, -0.17727719, -0.23643671) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
