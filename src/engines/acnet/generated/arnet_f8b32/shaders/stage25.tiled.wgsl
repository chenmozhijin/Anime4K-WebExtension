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

  var result: vec4f = vec4f(0.24561149, 0.044802707, 0.036160752, -0.07186913);
      result += mat4x4<f32>(-0.24065812, -0.19618455, -0.16811697, 0.20808466, 0.09498403, 0.16337618, 0.19568828, 0.033832725, 0.19962144, -0.2432308, 0.00834537, 0.17912617, -0.035996303, -0.16962686, -0.18374309, 0.24383101) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.15371996, -0.15461403, 0.17808545, 0.35101163, 0.2249174, 0.13166846, -0.10200848, -0.07187165, 0.4496174, -0.1804596, 0.3077247, 0.18722008, 0.02051597, -0.2596064, -0.4518294, 0.18963128) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.1978334, 0.006209413, 0.20137899, 0.20406935, -0.08766054, -0.162889, -0.1979265, 0.030652503, 0.14864059, -0.14087728, -0.10989566, 0.15229206, -0.16736239, -0.14631073, -0.0031013822, 0.12866376) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.03467102, -0.05586991, -0.17315173, 0.34734756, 0.29748416, -0.08924025, 0.111484304, -0.32402462, 0.0282819, 0.35318774, -0.23631497, 0.40178508, -0.291519, -0.27256253, -0.17037632, -0.56096804) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.355334, 0.5048655, -0.036018606, 0.15697785, 0.04116968, 0.20498796, -0.11892183, -0.45718387, 0.6698379, 0.1033108, 0.14521477, 0.47577995, 1.4278148, 0.3652938, 0.12465202, 0.6582078) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.78713614, -0.091058165, 0.55892366, -0.25952172, 0.23007336, -0.10861565, 0.07294497, -0.20537944, 0.09101573, -0.29506925, -0.19125834, 0.11219675, -0.3768485, 0.13447897, -0.12613791, 0.055855446) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.49658823, 0.09566018, 0.0066116545, -0.19837594, 0.09559138, -0.06090648, -0.0655349, 0.05161756, -0.5294834, 0.08448288, 0.028702453, -0.065224916, 0.37390822, 0.09532905, -0.030715574, -0.048865445) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.3675183, 0.4815762, 0.43314683, -0.20500055, 0.17993608, 0.16230759, -0.04682331, 0.0385486, -0.29673967, -0.084259026, -0.12810493, 0.028726568, -0.36792973, 0.09043468, 0.11089052, 0.1262995) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.030146483, -0.03725701, 0.20332237, -0.19408606, 0.3549858, -0.02674725, 0.08773419, -0.1297561, 0.19728865, -0.08345765, -0.033351935, -0.056153238, -0.03664753, 0.2195757, -0.027591076, -0.09861405) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.0859773, -0.106515266, -0.063061975, -0.0072288266, 0.09414391, 0.0046081343, -0.11072054, 0.3740708, -0.054923635, 0.04621951, -0.11852718, 0.09413113, -0.27405548, -0.10408563, -0.08353497, -0.19860986) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.01754506, 0.15984583, 0.36252743, -0.20639454, -0.062257707, -0.31007138, 0.30336404, -0.12269522, -0.0110021, 0.13307372, -0.33299783, -0.14467166, -0.11604476, -0.16389789, -0.09239999, -0.305793) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.25431728, 0.32369766, -0.21687838, 0.030096697, -0.17165953, -0.16138688, -0.13868776, 0.034517705, -0.15285845, -0.06803852, -0.051899478, -0.11601268, -0.04795967, -0.12377309, 0.0373505, -0.14644808) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.08524572, 0.04132954, 0.07460978, 0.21837975, -0.09316471, -0.15109444, 0.017480787, 0.23741907, 0.17760998, 0.040987324, -0.016976058, 0.49857095, 0.41573727, 0.027852593, 0.22875518, 0.35262653) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.65598786, 0.31186965, 0.049869966, 0.30347303, -0.35748017, 0.19890863, -0.41535428, -0.21084, -0.51953936, 0.15874302, -0.14528473, -0.22824846, 0.61718696, 0.31806108, 0.85204554, -0.08168977) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.4315981, 0.35592863, -0.13015552, 0.6498668, 0.016374102, -0.29700902, -0.11770273, 0.033528842, -0.57118374, -0.014377261, -0.21871261, 0.5414393, -0.1692235, 0.14729728, 0.101516396, 0.10942512) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.047677465, 0.06438456, 0.07586991, -0.142813, 0.07679987, 0.045070373, 0.020778527, -0.10289016, 0.17749602, -0.06819566, -0.028324917, 0.03083768, 0.12328396, 0.120790996, 0.24812315, -0.0017013544) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.104784094, -0.09051239, -0.037676267, -0.3180215, 0.26495257, 0.08408481, -0.110371724, 0.25325456, 0.27263784, 0.007921614, -0.3183343, 0.0931824, -0.36794025, -0.24506533, 0.1346976, -0.5165295) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.25102314, 0.075997904, 0.03370451, 0.21363755, 0.10478525, -0.19637434, -0.09822339, -0.079592966, 0.06637103, 0.035673853, -0.24514055, 0.2607199, -0.084211975, 0.23257862, -0.0019760316, 0.10505335) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
