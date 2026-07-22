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

  var result: vec4f = vec4f(-0.10674123, 0.015745379, 0.016833521, 0.28126565);
      result += mat4x4<f32>(-0.008672431, -0.01871943, -0.18517564, -0.021918429, 0.041308567, -0.032453306, -0.11624076, -0.119149566, -0.058021814, 0.1403666, 0.20791362, 0.026841596, 0.107191294, 0.05119577, 0.22167824, 0.039425574) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.058617447, -0.06899637, -0.32624283, 0.11187058, -0.18987189, -0.19305809, -0.43395394, -0.06563553, -0.061904892, -0.18639112, 0.016725933, -0.080099575, 0.18911354, 0.1367174, 0.32786262, -0.00071730826) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.058893654, -0.09566298, -0.26967958, 0.0024462012, -0.07411967, -0.0060529457, -0.16758797, -0.056821488, 0.010361273, -0.020569988, 0.049904108, -0.05981925, 0.088595755, 0.06758124, 0.2584096, -0.010182757) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.13992217, -0.092427365, -0.4550978, -0.12582484, -0.17813717, -0.11638157, -0.4229452, -0.05785811, 0.0040826323, 0.010522797, 0.33900267, 0.04173044, 0.14980891, 0.116593905, 0.40619683, 0.041923486) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.35296544, -0.14257601, -0.28581607, -0.08627914, -0.045383576, -0.26998264, -0.46429834, 0.044892162, -0.23013291, -0.2618314, -0.111049406, -0.27383566, 0.19328757, 0.11621239, 0.47589463, 0.007283589) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.1191707, -0.07869761, -0.040345863, -0.11069844, -0.07398151, -0.15657008, -0.3185306, -0.036150884, -0.1075061, 0.012139776, 0.50366753, -0.07464446, 0.18869972, 0.1322594, 0.466976, 0.0743698) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.065011345, -0.116421275, -0.33780292, -0.09185739, -0.09174193, -0.113919124, -0.11230223, -0.0413301, -0.14437605, -0.11104689, 0.23094307, 0.14636265, 0.15207496, 0.031142674, 0.2124639, 0.03708243) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.057942588, -0.07380482, -0.40840223, -0.061047707, -0.016449174, -0.13187832, -0.21566463, -0.08101588, 0.26599604, -0.026915193, 0.1645019, -0.19399402, 0.20149735, 0.12845026, 0.35765916, 0.07472287) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.088157184, -0.15601191, -0.3471426, 0.015910467, -0.06609629, -0.1038087, -0.2971727, -0.065894276, -0.06289705, -0.02701152, 0.15715903, 0.11541423, 0.10980824, 0.11896423, 0.2880077, 0.03807096) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.09603582, -0.029963411, 0.21291253, -0.3431398, 0.058042627, 0.05344012, 0.22916517, 0.25133827, -0.15838486, 0.40769574, 0.12947127, -0.19574812, -0.14582263, -0.12024043, -0.14642453, -0.12694748) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.117920496, -0.112392575, 0.22888936, -0.41710255, 0.19760554, 0.03651422, -0.018980026, 0.02500736, -0.01742833, -0.04488094, 0.044834953, 0.13601212, -0.08222631, -0.104150385, -0.08011679, -0.03642283) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.08668223, -0.041401584, -0.1029751, -0.07386228, 0.100691505, 0.08382726, 0.20549195, 0.005031072, 0.008134838, 0.02096997, 0.13646817, 0.23246431, -0.0072269086, -0.09318144, -0.099626094, 0.05094246) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.3293657, 0.14167637, 0.15429853, -0.3278094, 0.12650011, 0.14631261, 0.4540115, 0.17803612, 0.4024957, -0.4054724, -0.2708785, 0.71558374, -0.12342853, -0.22533335, -0.39718017, -0.02764614) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.3626201, -0.06995388, 0.48872846, 0.17278756, 0.31474322, 0.16505235, 0.3912122, 0.024161892, -0.20074876, -0.16630763, 0.29849616, -0.37036473, -0.18929836, -0.13970937, -0.25147617, 0.089218006) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.027099058, -0.022013258, 0.05298021, 0.002806282, 0.0948877, 0.10721752, 0.303011, 0.16218466, -0.1674054, 0.07892677, 0.67766875, -0.36731565, -0.10540453, -0.20974092, -0.27504548, 0.009164329) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.24174565, 0.07948329, -0.13134709, -0.195456, 0.17432608, 0.059474643, 0.25541115, 0.25870854, -0.21993424, -0.05462654, 0.112298675, 0.0055692354, -0.07345357, -0.063857116, -0.19892582, -0.11581388) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.21412127, -0.27875036, 0.049653884, -0.19069757, 0.21928227, 0.020121725, 0.33841273, 0.1531341, -0.13450359, -0.087335385, -0.3352357, 0.043136016, -0.1347708, -0.117133, -0.3726214, -0.155528) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.0029857499, -0.15511788, -0.27600434, -0.08721946, 0.14450832, 0.10721197, 0.2606169, 0.10899643, 0.113914, 0.12461788, -0.3304104, -0.22857833, -0.015783282, -0.13618807, -0.21621451, -0.11012805) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
