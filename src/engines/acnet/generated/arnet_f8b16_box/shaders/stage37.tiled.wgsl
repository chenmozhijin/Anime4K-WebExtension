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

  var result: vec4f = vec4f(0.06551138, -0.20907208, 0.12220768, 0.5170686);
      result += mat4x4<f32>(-0.11125311, 0.19727989, 0.13049264, 0.19842662, -0.07572091, 0.06902824, 0.072792396, 0.041715827, 0.13920833, -0.18037382, -0.07688474, -0.061256595, -0.071124926, 0.0752886, 0.10813083, 0.03482419) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.13313663, 0.07286861, -0.005337711, 0.010594484, -0.13370973, 0.029771047, 0.10833481, -0.095504895, 0.14191012, -0.03162578, -0.0330118, -0.07440279, -0.12381848, 0.28960705, 0.11491533, 0.1494668) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.10191681, 0.04456104, -0.0706922, 0.023283502, -0.14220409, 0.16244051, -0.04751866, 0.0226441, -0.10578314, 0.10525202, 0.005213542, 0.074007444, 0.08300937, -0.14907856, 0.10822398, 0.17536736) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.5437605, 0.15429688, -0.25897902, 0.09129583, 0.3297663, 0.084801674, 0.0674634, -0.12562394, 0.109612726, 0.20750076, 0.32399267, -0.036557656, 0.3472749, -0.3481662, -0.042074826, -0.21290307) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.24268423, 0.047494315, 0.0052505117, 0.16937992, 0.4123918, -0.26201805, -0.24770716, 0.041077483, 0.024054505, 0.21325842, 0.38290223, 0.2720844, 0.28326103, 0.18248552, -0.023946453, 0.3976579) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.2353993, 0.5282163, 0.12943862, 0.30627555, -0.08345897, 0.17659806, -0.17761937, 0.09854889, 0.18207797, -0.6319616, -0.25091878, -0.25509602, 0.09935885, -0.5824756, -0.06090341, -0.0010950681) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.44900882, 0.13501734, 0.016338583, 0.21357545, 0.36055917, -0.06578524, -0.11359003, -0.30464417, 0.58822805, -0.11306909, -0.009385075, -0.23237713, -0.13002981, 0.024768012, 0.18277454, 0.29693916) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.121067435, -0.035324566, -0.046390757, -0.01831625, -0.56500775, 0.7141285, 0.13407679, 0.06825368, -0.103964694, 0.011024298, 0.070389695, 0.013475683, -0.23158348, 0.1148412, 0.025580946, 0.103782244) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.12629625, -0.14100067, -0.024616644, 0.09269886, -0.1847057, -0.064144865, -0.07462322, 0.049544048, -0.43591884, 0.18570365, 0.037441682, -0.030889504, 0.011157807, 0.14718062, -0.032504838, 0.026591923) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.020042136, -0.08474427, -0.010809592, -0.052200984, -0.038845573, -0.09650919, 0.04662748, -0.050874986, -0.011824826, 0.22710782, -0.08196665, 0.012562335, -0.098069765, 0.07001195, -0.07589229, -0.021948688) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.027538002, -0.2933738, 0.14223292, -0.037102465, 0.14303073, -0.096874766, -0.12947945, 0.0097227385, -0.40933567, 0.3480734, 0.18652086, 0.20764574, -0.078336805, 0.38637102, 0.08861243, -0.13749714) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.1121175, -0.026168462, -0.034482803, -0.004998792, 0.16786695, -0.3626282, 0.061495524, -0.097235784, 0.08059723, 0.0560794, -0.004000121, -0.09697664, 0.09361276, -0.047281776, -0.059163403, -0.08301084) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.041641396, -0.111153856, -0.021640737, -0.012760837, -0.27543098, 0.37359798, -0.23056349, 0.19108719, -0.0666341, 0.24504367, -0.023584552, 0.10506868, 0.30475843, 0.020503692, 0.10926962, -0.17628427) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.25330013, 0.16774812, 0.20272304, -0.03793928, 0.24562776, 0.55775625, -0.19922253, -0.4457574, 0.17659098, 0.28963152, 0.08163871, 0.053891953, 0.84781045, 0.03455889, 0.06529471, -0.2069612) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.33110794, 0.39250803, 0.1588709, -0.031656783, 0.11094607, -0.14593056, 0.18491325, 0.14694084, 0.12925194, -0.124392405, -0.07779133, 0.053903956, 0.038978145, 0.116142176, -0.12048786, -0.031295456) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.032896113, 0.09328446, 0.1755555, 0.0380287, -0.16904724, -0.11407033, 0.09486441, 0.12760597, 0.05092561, 0.16255392, -0.031057948, -0.05690918, -0.0034726767, 0.20986919, 0.043266814, 0.08340036) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.34506, -0.4001617, 0.17405361, 0.19733633, -0.24595405, -0.013345465, 0.053828534, -0.034677234, -0.14573132, 0.04901542, -0.05054183, 0.052793857, 0.30729797, 0.1479019, -0.13750175, -0.059418116) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.46890244, -0.05428116, -0.1467048, -0.20671107, 0.037274692, 0.01469304, 0.03678004, -0.044425588, -0.19005789, 0.102861315, 0.003948402, 0.11826353, -0.30389452, 0.0070341923, 0.070285104, 0.22692248) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
