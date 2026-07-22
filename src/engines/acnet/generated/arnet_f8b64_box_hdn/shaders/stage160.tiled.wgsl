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

  var result: vec4f = vec4f(-0.22086796, 0.18323034, 0.12455303, -0.086787954);
      result += mat4x4<f32>(-0.4022798, -0.15988438, -0.9198576, -0.017556898, -0.0010962771, 0.054792624, 0.045847557, -0.1598795, 0.007678842, -0.23597375, -0.1024034, 0.07472776, 0.2191356, 0.055547196, 0.35656095, 0.14967836) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.14635694, -0.46793142, -0.6072999, -0.0874474, 0.10709245, 0.12923422, 0.109145716, -0.039298404, 0.002021953, -0.20130892, -0.14215697, 0.044275984, 0.08863641, 0.1334525, 0.27176222, 0.14589794) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.3181221, -0.2629133, 0.35649016, 0.12498291, 0.099328086, 0.01316441, -0.26155272, -0.105374396, 0.021681096, -0.23188679, -0.1597308, 0.042341936, 0.21630177, 0.083035156, 0.4255811, 0.16328882) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.26337057, 0.17573072, -0.48445573, 0.033172734, -0.12227628, 0.13615346, -0.15456587, -0.20841312, 0.016895466, -0.13534594, -0.0028969331, 0.056861613, 0.1913301, 0.10319505, 0.38092735, 0.15489717) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.05340962, 0.07293659, -0.09440175, -0.08186792, -0.15936197, -0.4033476, -0.4994292, 0.07315321, 0.09644236, -0.11083458, 0.06533971, 0.010072712, 0.20344508, -0.04319798, 0.35457745, 0.23021822) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.12075672, 0.014116556, 0.2975061, 0.028064921, 0.065372735, 0.033259187, -0.16170959, 0.2801384, 0.0053127473, -0.123970464, -0.019722564, 0.029540516, 0.2124043, 0.014182125, 0.3214217, 0.124755874) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.10701475, 0.5190775, 0.21219362, -0.12995358, -0.06636479, 0.044121444, -0.13155225, -0.11092517, -0.061365224, -0.19471002, -0.23420107, 0.054622468, 0.1368988, 0.017235553, 0.23657022, 0.14386868) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.11598176, -0.048543204, 0.29746115, 0.0021906267, -0.14019533, 0.10259366, -0.017764736, -0.19768995, -0.08460193, -0.13733652, -0.14696231, 0.054950647, 0.1349131, 0.08216055, 0.33851433, 0.14088605) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.39135253, 0.20380217, 0.9383061, 0.08432353, 0.0437171, 0.010145396, -0.1609685, -0.15526861, 0.02158725, -0.20406549, -0.12667812, -0.00543419, 0.12829348, 0.04350227, 0.35987374, 0.11008131) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.15852614, -0.28646913, 0.079125814, 0.0537857, -0.39491472, 0.31756663, 0.1438887, -0.40354598, -0.20816451, 0.30809483, -0.17493555, -0.12145733, -0.23451002, 0.032519784, 0.19389921, -0.71434253) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.45102412, 0.069929026, -0.0049064057, 0.11306299, 0.030168395, 0.14060788, 0.037014242, 0.21214096, -0.3402823, 0.036308996, -0.6330479, 0.12916295, -0.084462635, -0.011439266, -0.1207928, 0.13135216) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.064223886, 0.04773577, -0.29788187, -0.02526028, 0.21090552, 0.020882247, -0.1391259, 0.09344308, -0.588927, -0.05405109, -0.9984993, -0.17118001, 0.43050483, 0.30794784, -0.31364805, 0.3057869) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.5315562, 0.29915202, -0.4303417, -0.10596467, -0.20511495, -0.089450605, 0.0760797, 0.3879213, 0.2033094, 0.2422091, 0.56207085, 0.007233931, 0.8703102, 0.014189798, -0.47882944, -0.099860415) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.54902935, -0.017014844, 0.0045917034, -0.120224744, -0.034639753, -0.21810715, -0.09711634, 0.1818115, 0.1065027, -0.14198487, 0.07740375, -0.034790408, -0.27230108, -0.15787815, -0.14751999, 0.19341713) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.029262226, -0.3630271, 0.3939338, -0.0958815, -0.12182203, -0.22640324, 0.26831156, -0.076755166, 0.17844011, -0.34485337, -0.10155332, 0.054292083, -0.3616424, -0.040166587, 0.3289977, 0.21008517) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.34383237, -0.3482052, 0.13535991, 0.1950822, -0.30312905, 0.060595054, 0.16566584, 0.08124043, 0.25095314, 0.27137887, 0.74511576, -0.00509302, -0.20383278, 0.2865771, 0.31698182, -0.06978715) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.1239494, -0.061198954, -0.22556329, 0.038829517, 0.17971076, -0.02712398, 0.015451441, -0.08465024, 0.2891132, -0.10702174, 0.52389616, 0.1524618, -0.09832079, -0.0034264827, 0.11843309, -0.0012922304) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.14445285, 0.16576155, -0.40326688, 0.003060804, -0.087708056, 0.1562456, 0.003822643, -0.1363012, 0.136955, -0.28594843, -0.010699772, 0.06039634, 0.20501608, 0.05869681, -1.5595226e-06, 0.015310642) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
