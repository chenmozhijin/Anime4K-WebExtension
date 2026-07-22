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

  var result: vec4f = vec4f(-0.089942105, 0.02397487, 0.27715352, -0.035918076);
      result += mat4x4<f32>(0.09057967, 0.065323524, -0.04674076, -0.114041924, 0.019299595, -0.10081347, -0.07013057, -0.13876541, -0.07628127, -0.09796541, -0.00967906, 0.022985559, 0.008896804, 0.47777826, 0.3733143, 0.31744316) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.47434545, 0.13460499, 0.034423456, -0.109599225, 0.004277815, -0.010056548, -0.19140634, -0.49431998, -0.11230786, -0.07249249, 0.1609361, 0.01830208, -0.00536829, -0.0688236, 0.13739893, 0.27781913) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.17969665, 0.08366545, -0.023846157, -0.15425892, -0.108802795, -0.09642741, -0.081644244, -0.102951996, -0.061567795, -0.12557301, 0.08008181, 0.05124032, 0.04730742, -0.44374418, -0.2149307, 0.22149055) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.15007287, 0.06399363, 0.011677972, -0.17901279, 0.08028708, -0.014659284, -0.16906846, -0.050200205, -0.15658431, -0.060417466, 0.030159907, -0.074490175, 0.09853797, 0.43088603, 0.23044758, -0.01489079) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.19762725, -0.082793675, 0.075236425, -0.33721066, -0.11118884, 0.0034086935, -0.51992863, -0.011784131, 0.26805332, -0.3669064, 0.9175437, -0.076540776, 0.046070404, 0.44261473, 0.23272698, -0.08722252) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.094836235, -0.14873113, -0.020090073, 0.15792334, 0.10980137, -0.18020909, -0.15816236, -0.12959167, -0.057674423, -0.10090293, 0.14020215, -0.0936588, -0.08311513, -0.44713464, -0.34526497, -0.1400617) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.118640974, -0.25035247, -0.1056087, 0.44321445, -0.033462428, -0.0011040886, 0.1012417, 0.18192871, -0.032888576, -0.096517235, -0.050910253, -0.11154679, -0.0045630746, 0.26580247, 0.124091305, -0.08047826) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.28648955, -0.20706758, -0.17572549, -0.12923491, -0.04719969, 0.093329936, -0.12357547, -0.32247075, -0.02656549, -0.03175947, 0.041206975, -0.014499891, -0.110256724, -0.066313595, -0.12885277, -0.30043885) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.2160459, 0.04635233, -0.052166544, -0.13690624, 0.17041717, 0.12922639, -0.05650154, -0.21423267, -0.031369556, -0.12770058, 0.027871573, -0.0058853235, 0.0639433, -0.53422886, -0.33427003, -0.24381533) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.040457457, -0.101409085, -0.06805351, 0.0400693, 0.034236584, -0.15830503, -0.049531206, -0.07377208, 0.008980621, 0.024703236, -0.03167186, 0.029058015, -0.0034466996, 0.34191832, 0.17063804, -0.17916569) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.1564765, 0.122437745, -0.020020673, 0.011127013, 0.15658501, -0.036513172, -0.3606591, 0.04418642, 0.10898103, 0.13097192, -0.18693969, -0.017179323, -0.030509608, 0.4440184, 0.27641544, 0.0024509765) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.124789804, 0.07219733, -0.08565322, -0.18548068, 0.12337197, -0.13535933, -0.13565154, -0.102516204, -0.0326266, 0.043836083, -0.090857044, -0.10693114, 0.015798643, 0.3800352, 0.25874388, 0.14478001) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.035872888, 0.08629096, -0.03249584, -0.030529106, 0.026544057, -0.15169723, 0.2520841, -0.044954073, 0.013505004, 0.1266727, -0.24739042, 0.23469701, -0.018866707, -0.1640583, -0.11872211, -0.0140160965) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.5093851, -0.43517798, -0.4472117, 0.24456885, -0.00110091, 0.4894714, -0.8214927, -0.04260965, -0.012547575, 0.38421974, -0.7905068, 0.30083567, -0.090147294, 0.105781436, 0.023976473, -0.06021102) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.04216629, 0.014422427, -0.19272049, -0.14166799, -0.06978037, -0.03837251, 0.04210714, -0.015512347, -0.028966684, 0.15711325, -0.17078745, 0.20006303, 0.050135512, 0.29945847, 0.3097945, 0.33904737) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.012668032, -0.01987555, -0.032371324, 0.04757898, 0.15046296, -0.03558993, 0.13151583, 0.15232977, -0.10813131, -0.028356437, -0.047935016, 0.026962345, -0.08052745, -0.35011488, -0.22379278, -0.14275171) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.19193918, -0.050005455, -0.18010657, 0.025710609, 0.020729514, -0.09800641, 0.26424864, -0.09345932, -0.00807059, 0.18564337, -0.23118763, -0.012466453, 0.082415625, -0.48006237, -0.37108168, -0.39370772) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.035045773, -0.15867597, -0.16178377, -0.21369648, 0.0062300037, -0.23921764, -0.06795333, -0.022997668, 0.07301369, 0.04968887, -0.03947247, 0.025346901, -0.015175212, -0.44059646, -0.28917387, 0.38010907) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
