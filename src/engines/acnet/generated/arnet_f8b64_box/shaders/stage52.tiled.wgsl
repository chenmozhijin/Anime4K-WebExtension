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

  var result: vec4f = vec4f(0.23673777, 0.07737454, 0.25048953, 0.1908444);
      result += mat4x4<f32>(0.47286516, 0.0032548953, -0.2283636, 0.010827597, -0.040461153, -0.01951332, 0.04315595, -0.029333167, 0.22095186, 0.24443774, 0.14048856, -0.14692087, 0.03814582, -0.05730024, 0.18997434, 0.030612502) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.42161408, -0.1464856, 0.014548255, -0.05407607, 0.23619962, 0.03671906, 0.014512874, -0.04758062, 0.0859726, 0.0391079, 0.20070411, -0.12209534, -0.034080345, -0.09943324, 0.19301388, -0.035390496) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.024770422, -0.068164326, 0.106668144, -0.2104405, 0.07040051, 0.048819356, 0.106038265, -0.005578329, -0.13344608, -0.24324547, -0.1257475, -0.025211064, -0.023031568, -0.03971626, 0.2131021, 0.105944015) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.14960937, 0.14547858, 0.3777424, -0.3441826, -0.17791417, 0.14300694, 0.08147579, -0.32093516, 0.3576791, 0.073341265, 0.027520584, -0.3118413, -0.23678282, -0.013064109, 0.224878, -0.34027267) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.119470164, -0.11229011, -0.5536233, 0.45548737, 0.039847918, 0.035092387, 0.09269993, -0.06257703, 0.4579137, 0.22776167, 0.47407424, 0.32032838, -0.10465782, -0.019199904, -0.088727385, 0.2756362) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.13279316, -0.046753403, 0.22246961, 0.30298907, -0.21313104, 0.049360894, 0.15881404, 0.17912938, 0.18678668, -0.0018000785, 0.40993223, 0.06604832, -0.18125096, -0.20378421, 0.02711054, -0.22697072) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.134228, 0.027324505, 0.31305465, -0.04085546, 0.1551283, 0.08216245, -0.04233691, -0.051410086, 0.049636055, 0.0033376114, 0.16112393, -0.27173713, -0.07802474, 0.04968508, -0.16667174, -0.14462961) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.22659062, -0.30958223, 0.08433531, 0.07050117, 0.31995657, 0.030449059, 0.09375364, -0.15874751, 0.22692652, 0.10153825, 0.306734, -0.15629686, -0.28429383, 0.27960438, -0.25194594, 0.027761815) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.23232691, -0.050889835, 0.047983572, 0.1341342, 0.20303382, -0.044920467, 0.03080528, -0.11615221, 0.003894411, 0.033895623, 0.12843117, 0.013765611, 0.24763139, -0.027259003, -0.18672392, -0.18573451) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.30168772, 0.056231186, -0.1443928, 0.01924215, -0.25414386, 0.35447988, 0.12598382, -0.44107565, -0.18564428, -0.08503308, 0.142665, -0.14906208, -0.024113446, -0.040023107, -0.0025051748, 0.1080096) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.026646364, 0.25585935, -0.5549116, 0.03641604, 0.12782006, -0.14124116, -0.013570983, -0.026989633, 0.18532178, -0.052568935, -0.06348011, 0.1056298, 0.00034443632, -0.026938526, -0.18391329, 0.05858018) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.0810035, 0.12954728, -0.05217485, -0.022055045, -0.2219802, -0.3451724, -0.19012734, -0.3837621, 0.35553655, 0.10376075, -0.14304136, 0.061525404, -0.25562036, 0.14437927, -0.020768108, 0.11674831) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.17579812, 0.26780447, 0.049585752, 0.08102792, 0.3118338, -0.11104441, -0.13478805, 0.118586004, -0.14195012, -0.10241282, 0.2652955, -0.18402648, -0.2605771, 0.091010146, -0.079743214, 0.22389942) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.42294818, 0.2613874, -0.32652953, 0.05175747, -0.18322444, -0.15348244, -0.15920734, -0.13404948, -0.120092906, 0.17498405, -0.2737324, 0.12600678, 0.43715742, -0.26786944, 0.04445257, 0.27335846) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.0011873223, 0.022935268, -0.026296869, -0.11829205, 0.12224429, 0.11531558, 0.16716366, 0.18724634, -0.4910311, 0.013554927, -0.07162657, 0.33077404, -0.03657003, 0.0095526045, -0.066275865, -0.21616329) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.16417679, 0.0060621807, 0.06334778, 0.07135665, 0.01151355, -0.021088572, -0.16309607, 0.15505272, -0.13799046, -0.14438283, 0.12312909, 0.022793084, -0.20688257, -0.077434234, -0.25991565, -0.1700439) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.19428621, 0.15044948, -0.025532251, 0.046501752, 0.04394023, -0.08553908, -0.09046752, -0.10770704, -0.11993218, 0.0055402475, -0.31895804, -0.048737507, -0.20380326, 0.08595524, 0.45591936, -0.4366359) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.015492621, -0.0065661496, 0.014465424, 0.016204957, 0.089175336, -0.04076581, -0.105277956, 0.08295827, 0.26246557, 0.19787872, -0.1349787, -0.026627896, 0.11567608, 0.063527815, 0.20837766, -0.13965088) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
