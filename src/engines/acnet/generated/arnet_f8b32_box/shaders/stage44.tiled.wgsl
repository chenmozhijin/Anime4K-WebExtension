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

  var result: vec4f = vec4f(-0.15694095, 0.011736209, 0.10780208, -0.038672127);
      result += mat4x4<f32>(-0.042727154, 0.1783544, -0.04524087, -0.03483545, 0.06804692, -0.06815306, 0.021096887, -0.2231991, 0.12128219, 0.14031015, -0.09911477, -0.26069814, -0.025015501, 0.093055874, 0.084897295, 0.23636346) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.06840866, -0.0021601804, 0.15140404, -0.085427694, 0.004075965, -0.120769866, -0.22203226, -0.19832517, -0.058621783, -0.35501134, -0.18627758, -0.20650123, 0.09482457, 0.33476692, 0.071333945, 0.14032222) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.022076163, 0.08553964, -0.08909652, -0.052290287, 0.0011251565, 0.023402099, 0.092130125, -0.18334587, -0.021864034, 0.1447074, 0.062449742, 0.01092884, 0.07156952, -0.14751978, -0.026041908, -0.08342471) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.05810328, 0.048270997, 0.06905394, 0.16922252, -0.00040796562, 0.17164229, 0.12040819, 0.2783745, 0.01949928, 0.092436135, 0.2174281, 0.70498514, 0.25354952, -0.08178295, -0.272828, -0.8750195) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.08721346, 0.2570161, -0.027168514, -0.06469105, 0.11999717, 0.14652303, 0.12722543, 0.32161805, -0.18551423, -0.16964205, 0.38033956, -0.19906487, -0.21757427, 0.27899233, -0.19428678, -0.16763243) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.038235527, 0.051511053, 0.008784118, -0.12120808, 0.21991481, -0.020348769, 0.062400755, -0.112651035, 0.11018802, 0.06629218, -0.56687015, -0.08656251, 0.025104258, -0.06252488, 0.18953037, -0.09600425) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.09427142, -0.0057632243, -0.12660967, -0.02461761, 0.22199963, 0.10295135, -0.049620345, -0.18528503, 0.2732475, -0.16961032, -0.16153654, -0.11340307, -0.016704708, 0.023912102, 0.15821512, -0.08608249) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.15897353, -0.1798248, 0.34223554, -0.22351953, 0.10554293, 0.07679029, 0.2224649, -0.20945032, 0.1436452, 0.024986342, -0.4387968, 0.10144993, 0.121073045, 0.08361634, -0.06056274, 0.27504867) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.057406828, 0.08256117, 0.13730867, -0.09275994, 0.16782367, 0.13000582, 0.14458789, -0.38891473, 0.06088901, 0.12154295, 0.061765954, 0.029707558, -0.06868539, -0.006774075, 0.013583222, 0.086553134) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.07850368, 0.059206557, 0.10083287, -0.10913016, -0.06956804, -0.103254184, 0.107546836, 0.22140601, 0.049137317, -0.03693122, 0.032898787, -0.2976804, 0.031411987, 0.15775447, -0.06544816, -0.067268506) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.16056669, -0.037230823, 0.33303756, 0.034783516, 0.024996983, -0.18391368, -0.36876398, 0.27435493, 0.0057687117, 0.04429987, 0.2018549, -0.07388256, 0.11401268, -0.12738667, -0.09247478, -0.41600263) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.1388347, -0.050329335, 0.41558546, -0.031480737, -0.107907824, -0.25359094, 0.06328221, 0.21200904, 0.14776649, -0.16803434, 0.059876345, -0.056615498, 0.020184623, -0.03179903, 0.17286476, -0.13449189) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.16098654, -0.1302273, 0.23010226, 0.24882908, -0.14649726, -0.08286307, 0.05777496, 0.05047389, 0.042141255, -0.14642589, 0.028106995, -0.29307303, -0.07708036, 0.01984499, 0.14732297, 0.5624734) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.43491024, -1.6095308, 0.43616143, 0.30231798, 0.27354103, 0.26680142, 0.19833714, -0.4027519, 0.0045757033, -0.27708566, 0.12990552, -0.27712017, -0.22906587, -0.29183266, 0.73029584, 0.7715905) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.28564644, 0.27275273, 0.4129386, -0.0064259907, 0.0018918326, 0.15531443, 0.37854305, -0.40406138, 0.024686884, -0.36663908, -0.33616844, 0.24274807, -0.060616, -0.32157716, -0.6750395, 0.19542162) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.33285934, -0.16361392, 0.100408435, 0.2860613, 0.014537517, -0.17021063, 0.019986244, -0.16896193, 0.04192884, 0.19105741, -0.042193398, -0.23621276, 0.105715536, -0.06311363, -0.2325329, 0.17638469) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.2965275, -0.5312057, -0.10835754, 0.11407493, 0.23963463, 0.044232305, 0.18084562, -0.31063083, 0.00024850338, -0.043558408, -0.49722886, -0.40384558, -0.0014177196, -0.09794623, 0.046880066, 0.017455384) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.13084087, -0.22200526, 0.23205286, 0.1274764, 0.07108797, 0.30650553, -0.022734774, -0.22784114, -0.051035553, -0.12282168, -0.23325573, 0.051247608, -0.11684019, 0.078012735, -0.19195953, -0.026603317) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
