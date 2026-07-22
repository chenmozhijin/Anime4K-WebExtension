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

  var result: vec4f = vec4f(-0.121285066, 0.08219092, -0.16567829, 0.016514044);
      result += mat4x4<f32>(-6.596831e-05, -0.06698233, -0.0012153862, -0.059671544, -0.070504785, -0.07422075, -0.32085007, -0.07575312, 0.23201115, -0.073683776, 0.027917724, 0.21919122, 0.089000024, 0.067975566, 0.35386902, 0.05358934) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.004616965, -0.030287866, -0.07282493, -0.13363884, -0.1005592, -0.122608714, -0.42658424, -0.046232127, 0.18940859, -0.11138873, 0.112731956, -0.025622958, 0.11548495, 0.16374956, 0.48214963, 0.06148299) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.02902072, -0.076082304, -0.16463031, -0.047379516, -0.08542322, -0.064284444, -0.30216953, -0.065018885, 0.058763266, -0.14187819, 0.12243611, -0.13815495, 0.07910469, 0.062624216, 0.287184, 0.057030078) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.05788206, -0.08055027, -0.20504647, -0.12443752, -0.10970396, -0.13896348, -0.41876784, -0.10678062, 0.21325718, 0.002128946, 0.38815805, 0.06106189, 0.06354302, 0.13677976, 0.441203, 0.072327144) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.14995608, -0.13931778, -0.40461788, -0.24174997, -0.13267666, -0.19899309, -0.54397815, -0.08054205, 0.0637953, -0.07023905, 0.10964752, -0.234883, 0.16784249, 0.14948837, 0.5892349, 0.14129986) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.06164965, -0.09880364, -0.2732546, -0.052993737, -0.16999982, -0.13226551, -0.42883816, -0.069432065, 0.029941434, 0.023677235, 0.22917646, -0.20921859, 0.14661343, 0.14030664, 0.4691151, 0.07395034) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.06267574, -0.06550145, -0.25391307, -0.05824898, -0.051774006, -0.049818218, -0.16541173, -0.050163053, 0.15601198, -0.12965691, 0.23708783, 0.11959019, 0.053915538, 0.052556757, 0.21612304, 0.048873015) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.07550249, -0.08426589, -0.2851914, -0.08017225, -0.057424944, -0.066928305, -0.23249143, -0.09864132, 0.05087385, -0.06380346, 0.12850223, 0.008566237, 0.10476926, 0.11964828, 0.35849127, 0.095141165) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.066817425, -0.07498734, -0.16427836, -0.067672156, -0.04989813, -0.015278202, -0.18012793, -0.1286603, -0.061564688, 0.00019389037, 0.067618795, -0.09546956, 0.08354726, 0.05956934, 0.27311388, 0.03329472) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.090955175, -0.19621632, -0.2982114, -0.051750313, 0.09983305, 0.12555829, 0.37544, 0.01078571, -0.07031384, 0.36915496, 0.19340229, -0.80454695, -0.02039366, -0.057979833, -0.17816858, -0.052940324) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.008457072, 0.1782834, 0.23238784, -0.2589795, 0.109491356, 0.16675034, 0.46942645, 0.031751122, -0.18947487, -0.10533714, -0.09359068, -0.075661495, -0.033301905, -0.06379367, -0.30389068, -0.057014108) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.2071565, -0.000661748, 0.7006153, 0.009635348, 0.054279566, 0.04850365, 0.27939907, 0.0064139185, 0.06406496, 0.016781053, -0.46094504, 0.5533476, -0.05548184, -0.044371065, -0.22573261, -0.05962913) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.04325344, 0.32699952, -0.03156925, -0.38232014, 0.20789598, 0.16776295, 0.7082389, 0.1338213, 0.29415867, -0.21431829, -0.18214768, 0.6821913, -0.10616231, -0.1474174, -0.42276695, -0.046695307) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.1949744, -0.25392097, 0.4640052, 0.16762725, 0.23013765, 0.25066018, 0.84871787, 0.13130236, 0.12950113, -0.13066106, 0.3103199, -0.009422354, -0.147152, -0.22002728, -0.46264648, -0.03635757) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.33732778, -0.04359596, 0.3282637, 0.069107436, 0.16612366, 0.106526166, 0.5380108, 0.054621458, -0.12136892, -0.20838737, 0.35215858, -0.3712154, -0.12155668, -0.14927462, -0.44182926, -0.07959677) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.1487317, -0.10061315, -0.5656755, -0.11077817, 0.17444912, 0.101971045, 0.54083544, 0.08003434, -0.34855145, -0.044785894, 0.4948893, 0.123702735, -0.050349396, -0.06882795, -0.25127906, -0.06528217) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.17673326, -0.117107585, -0.0219185, 0.092172876, 0.19204979, 0.20918731, 0.6324296, 0.082864955, -0.13621344, -0.17522772, -0.019474644, 0.16271055, -0.08905007, -0.13929716, -0.4063679, -0.07806241) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.014502014, -0.09972645, 0.032470003, -0.06662736, 0.14728284, 0.073232375, 0.36628512, 0.046587892, 0.065889046, 0.32122684, -0.09313674, -0.19661377, -0.049735848, -0.06688429, -0.2260412, -0.04078645) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
