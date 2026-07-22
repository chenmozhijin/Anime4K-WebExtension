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

  var result: vec4f = vec4f(0.20947182, 0.3104697, 0.15996589, -0.040328737);
      result += mat4x4<f32>(0.08825309, 0.20135407, -0.065791965, 0.02287029, 0.0013457175, 0.1264891, 0.02637196, 0.030447572, 0.26004323, -0.60267454, 0.12359172, 0.14518154, -0.179921, 0.48423654, -0.2739682, -0.03299366) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.09122877, 0.16421817, 0.10944584, -0.1185866, 0.16278741, -0.4251602, -0.121826366, 0.29693714, -0.14361185, -0.31262553, 0.46471512, -0.03836366, -0.026793092, -0.19624303, 0.1648589, 0.077635095) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.05827032, 0.08051396, -0.01888666, 0.07325147, 0.03630061, -0.11616269, -0.11877477, 0.20733172, -0.117053226, 0.05992223, -0.049153116, -0.035367146, 0.030469881, -0.032444686, 0.0993, 0.10025395) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.06890026, -0.054563127, -0.17293748, 0.2958991, -0.11131273, -0.21745904, -0.1049892, -0.39642888, -0.12000435, 0.017394045, 0.11353423, 0.44866022, -0.688114, -0.006284517, -0.16971737, -0.20888616) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.332005, 0.062083356, -0.026688963, -0.15098605, 0.81376404, -0.022875793, -0.02502571, -0.12595901, -0.25449175, 0.2176504, 0.034783006, -0.021370057, 0.053584844, 0.20113048, 0.17416468, -0.26850253) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.12761359, 0.08103229, 0.0277405, 0.104705766, 0.43844417, 0.19182658, 0.12813847, -0.18581526, 0.18176526, 0.06139009, 0.14304361, -0.2637528, -0.2696338, 0.16055097, -0.21379331, 0.4783778) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.33526054, 0.16881873, 0.025787808, 0.06118781, -0.2859979, -0.38658535, -0.039730046, -0.049759023, 0.060689427, -0.14868926, -0.08768606, 2.5852329e-05, -0.16291739, -0.03009402, 0.12237461, 0.054234706) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.04105645, 0.009596064, 0.2053829, -0.010460983, -0.07098707, -0.14201604, -0.07321202, 0.16471797, 0.04356856, 0.24688841, -0.12908171, 0.09050429, -0.31492, 0.06806657, -0.12224087, 0.019666148) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.023604233, 0.087507255, 0.0846571, 0.056066457, 0.033390943, -0.104978524, -0.16684663, -0.15287852, 0.15258648, -0.23050319, -0.12608504, -0.100883305, 0.107070625, 0.18886776, -0.043333646, 0.04460994) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.03708866, 0.13197504, 0.059254292, 0.013088745, 0.0058212075, 0.113081515, -0.15466726, 0.19128232, -0.23956567, 0.03519554, -0.11468553, 0.0792421, -0.04840432, 0.005276582, -0.03520124, -0.0766907) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.21732774, -0.030727085, 0.08552051, -0.22316702, -0.0030446958, -0.03683978, -0.08959119, 0.299243, 0.07163822, -0.04962082, -0.1404943, 0.116653815, -0.15613627, -0.0004449985, -0.13627651, 0.030405097) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.062191863, -0.240939, -0.011156102, -0.21821423, 0.02878478, -0.043421667, -0.08816376, 0.21624595, 0.10419184, -0.0019908233, 0.086125284, -0.10991, 0.16092733, -0.09881134, -0.17184405, -0.08373916) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.104351565, -0.10838054, 0.21489614, -0.074157156, 0.04774926, -0.2164153, -0.07776439, 0.003571762, -0.020767493, 0.17277366, -0.16706778, -0.08826433, -0.2244224, -0.3363645, -0.14518529, -0.22320926) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.33589867, 0.35248256, -0.52380544, -0.612812, -0.0035429897, 0.16106834, -0.31117097, -0.28926805, 0.5793654, -0.59061193, 0.39518872, 0.4290384, -0.5481419, -0.458753, -0.19222416, 0.2422796) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.19101307, -0.06992668, -0.0059942035, -0.24257107, 0.30390415, -0.004709191, -0.10046474, -0.348798, 0.020127427, 0.019017544, -0.38731897, 0.3412126, 0.0821974, -0.3514374, -0.124985114, -0.223645) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.124703914, 0.10779312, -0.009484613, 0.027160319, -0.17313966, -0.046049662, -0.10183791, 0.020765152, -0.14152667, 0.0504648, -0.14422739, 0.106902525, -0.1662999, 0.09139851, -0.14494734, 0.038280282) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.12567946, 0.098461024, -0.09995612, 0.17227733, 0.50547075, 0.14376621, -0.040209528, 0.69592303, -0.30547872, -0.4111357, -0.16629303, 0.20914067, -0.4081948, 0.089150295, 0.06427005, 0.16882409) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.10193803, -0.20734285, -0.022154499, -0.34783185, 0.3465465, 0.048237488, -0.13514845, -0.2948514, 0.18972729, 0.02322683, -0.08304559, 0.13036102, -0.0906787, -0.058067832, -0.061536305, 0.06733453) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
