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

  var result: vec4f = vec4f(0.117333405, 0.3057317, -1.1768742, -0.3160882);
      result += mat4x4<f32>(0.18880084, 0.017834062, -0.010796944, 0.087238565, -0.13323529, -0.025652701, -0.064165354, -0.020755759, 0.05549427, -0.011478293, 0.07086526, -0.038017448, 0.004357235, 0.028949318, -0.021478081, 0.0156497) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.20181914, -0.02530042, 0.26011252, 0.072437935, -0.018192481, -0.07411103, -0.10308579, 0.07473429, 0.26097035, -0.02581274, 0.14160079, 0.08357236, -0.047921564, 0.15166414, -0.05430682, 0.053337436) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.013438056, -0.016538428, -0.03190177, 0.033617537, -0.005671288, 0.009667655, 0.018967576, -0.07058319, 0.21668212, -0.0047480618, 0.06350407, -0.005230903, 0.046996087, 0.056434028, -0.008438332, 0.012010739) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.17538936, -0.1627874, -0.19812049, 0.3882546, 0.03234896, -0.099839576, 0.03838861, -0.110184, 0.12357079, -0.18045482, 0.19792682, -0.06609297, -0.085821025, 0.14359857, -0.07095498, 0.081353314) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.42542988, -0.6539012, 0.504431, 0.18556398, 0.33451763, -0.5239957, -0.12036373, -0.031472433, -0.009929042, -0.3880747, 0.8271549, -0.17097332, -0.05769249, -0.46929812, -0.34373543, -0.10383098) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.15190065, -0.10215758, -0.01001011, -0.24915938, -0.03513088, -0.01090679, 0.02004236, -0.0896301, 0.030034045, 0.14098148, 0.19904119, -0.25361532, -0.06869853, 0.1841214, -0.082292, 0.024077667) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.07725451, 0.022268271, -0.3909244, -0.29385483, 0.0023858338, 0.032234177, -0.09202378, 0.008166329, 0.027992377, -0.054689016, 0.11848077, 0.004938282, 0.026582962, 0.043463133, -0.035299636, 0.020799868) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.31489193, 0.13206215, -0.33675095, -0.30005378, 0.2574395, -0.2068153, -0.10015047, -0.13078156, 0.038618177, -0.09218912, 0.25704613, 0.015173436, -0.0049313684, 0.16719493, -0.08693049, 0.026961185) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.054305006, 0.029616997, -0.012790723, -0.26997855, -0.038217526, -0.017799428, 0.030294761, 0.01623937, 0.14460693, -0.0034427338, 0.0050310907, 0.05468457, -0.009035833, 0.057921324, -0.057674147, -0.003997133) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.013700635, -0.13963369, -0.019241303, -0.043125413, 0.009869813, -0.14806964, 0.13740389, -0.013068447, 0.013504269, 0.024806933, -0.0072526834, -0.034613345, -0.06279142, -0.027119948, 0.007256465, 0.056907687) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.18070355, 0.05976181, 0.022845337, -0.28441346, 0.045457724, -5.292009e-06, 0.021488577, 0.1161825, 0.12549508, 0.06719182, 0.051256064, 0.050784536, 0.06445388, -0.014649764, 0.10183226, 0.040649142) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.13647255, 0.12356541, 0.020898137, -0.12940262, -0.06627682, 0.024336373, -0.038835086, 0.04304128, 0.15344334, 0.06808111, 0.084904164, -0.045015156, 0.10882711, -0.15778986, 0.16509603, 0.104176894) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.262581, 0.015374705, -0.14470682, -0.20755538, -0.39283672, -0.061185703, 0.17112972, -0.013625063, 0.05354422, 0.17563382, 0.006220969, 0.011910853, 0.0058880253, 0.053956803, -0.09175954, 0.058151826) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.6977018, -0.29986385, 0.2587024, -0.4444126, 0.22626159, 0.0013723364, -0.44459468, 0.7948721, 0.0013010225, 0.05528914, 0.35574064, 0.2582932, -0.115239695, 0.11355024, 0.016602123, -0.0043711164) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.07698439, 0.051201627, -0.0059016063, -0.101297185, -0.0911019, 0.057911374, -0.029905539, 0.16209657, -0.37877774, 0.47260216, 0.27922344, -0.21728383, 0.07606992, -0.5143135, 0.35084817, -0.43356436) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.0071066576, 0.029924892, -0.08897387, -0.015649166, 0.13439573, -0.022363884, 0.04381794, -0.06997545, 0.025478687, 0.015214025, 0.016619202, 0.023201136, -0.11811325, -0.071825236, 0.041278273, 0.0028811733) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.1024077, 0.06493297, -0.016188933, -0.030746274, 0.25294042, -0.0043969355, 0.13298598, -0.012935455, -0.06863871, 0.12533033, 0.0113802785, -0.0041006664, -0.0842327, 0.04878365, -0.10245172, 0.03361183) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.047680765, 1.7147875e-05, 0.02421035, -0.045137923, 0.009389702, 0.034868523, 0.038486637, 0.03700783, -0.20156236, 0.21324916, 0.050826374, 0.06302122, 0.16118033, 0.00685669, 0.05496585, 0.040158432) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
