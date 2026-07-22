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

  var result: vec4f = vec4f(0.09475857, -0.048105754, 0.031563774, 0.06378861);
      result += mat4x4<f32>(0.058105066, -0.005861354, -0.035078384, 0.039225645, 0.05229108, -0.096053086, -0.0074689584, -0.0043018865, 0.11919517, -0.3074959, 0.18424281, -0.00833708, -0.052007653, -0.056419395, -0.010677369, 0.014790631) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.017181087, -0.36066708, 0.08734385, 0.06606329, 0.053487644, -0.12227616, 0.074845485, -0.024006179, 0.20176464, -0.14931664, 0.024686642, -0.11611481, -0.011270556, 0.016196102, 0.022058995, -0.023489509) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.047784533, -0.20047978, -0.08415434, -0.10735702, -0.014745425, -0.022995835, 0.046056572, -0.052383218, 0.124724455, -0.10062497, 0.058702342, 0.03330373, 0.014173106, 0.037677217, -0.06598059, -0.073758386) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.10861891, -0.0007349646, -0.1426665, 0.058132775, -0.076874495, -0.010482472, -0.17575924, 0.17338815, -0.1011087, -0.13718283, -0.087828815, 0.15509114, -0.013306564, 0.029062238, 0.026756868, -0.041099563) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.06684407, 0.15362702, -0.5062112, 0.004506535, 0.4053017, -0.025822658, -0.44398275, 0.8529017, 0.30804807, -0.43007976, 0.01724085, 0.03765329, -0.3482449, 0.1114665, -0.16894248, 0.2792408) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.06774617, 0.081515275, -0.2588459, -0.5180713, -0.13294972, -0.032715023, -0.04633673, -0.02337332, -0.016067378, -0.13364647, -0.17463669, 0.073912755, 0.0055457884, -0.4011125, 0.15159492, 0.13929613) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.028780062, 0.061531536, 0.005159172, -0.06583237, -0.018602436, -0.23351495, -0.033516906, -0.020377517, -0.07236614, 0.25399303, -0.14497738, -0.10618908, 0.0076124463, -0.03452682, 0.05872973, 0.036710523) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.11669563, 0.20425124, 0.13979389, -0.19188978, -0.06652452, -0.289108, -0.31108308, 0.046112906, -0.08608418, 0.13286535, -0.137486, -0.11182319, -0.272701, -0.5449295, -0.17468962, 0.2433414) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.2755849, 0.10965199, -0.0077058086, 0.17052522, -0.040839225, -0.0628671, 0.072782315, 0.023721717, 0.051167857, 0.115160376, -0.058008365, -0.0192528, 0.013330478, 0.029891618, 0.12556891, -0.026035583) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.037075028, 0.011423691, 0.11111725, 0.062258206, 0.024892503, -0.02187565, 0.023057446, 0.07564158, 0.051326286, -0.19663642, 0.04443853, 0.013704573, -0.11448301, -0.15674433, 0.03038558, -0.09152774) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.09422055, 0.39685497, -0.15716265, -0.43857804, 0.06163642, -0.04214862, 0.10232121, -0.016976953, -0.22803481, -0.24260451, 0.05063297, -0.058845364, -0.010491744, 0.35234395, 0.31545362, -0.10232946) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.112393245, 0.2540088, -0.023463665, -0.20470686, -0.035515267, -0.0061039156, 0.066229455, 0.0021960312, 0.03277948, 0.280571, 0.11704281, -0.073822945, -0.12442063, 0.03687514, -0.029806143, -0.043088477) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.29696494, -0.29693946, -0.16161744, 0.2795435, -0.111524604, -0.057866182, -0.07208299, 0.075321525, 0.02119053, -0.09316481, -0.27264842, 0.06890954, 0.19359893, 0.035474323, 0.32340485, -0.13291846) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.15445805, 0.5315429, 0.033294555, -0.068505436, -0.4380035, 0.00223829, 0.11396265, -0.3579158, -0.5793114, -0.62504476, -0.1293496, 0.9568548, -0.02617667, 0.30952722, 0.46058455, -0.5153481) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.04197839, -0.108367905, 0.14428559, -0.21797283, -0.049812056, 0.004369548, 0.04544175, -0.020836066, 0.05001772, -0.09684512, -0.08984173, 0.2212853, -0.027238287, 0.021095721, 0.102371685, -0.15721023) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.040783536, -0.060569517, 0.15524031, -0.043392137, -0.07913941, 0.055901766, -0.090170346, 0.08433856, 0.07204567, 0.06532143, 0.030655557, 0.025614599, 0.051042266, 0.16655052, 0.035950292, -0.052621074) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.0634169, -0.44854364, -0.012083548, 0.2483474, 0.009186249, 0.31293702, -0.027556881, -0.3457716, 0.024513537, 0.08594775, -0.064970896, -0.21197812, -0.012763795, -0.03346492, 0.16538808, 0.16002397) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.034610778, -0.031563688, 0.032817714, -0.11397582, -0.02786258, 0.08290236, 0.05561304, 0.12698476, 0.17117582, 0.011943217, -0.08336704, -0.060901646, -0.05155196, 0.03985764, 0.04209814, -0.0019154404) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
