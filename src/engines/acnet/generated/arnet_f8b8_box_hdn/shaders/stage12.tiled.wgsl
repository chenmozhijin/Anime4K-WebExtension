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

  var result: vec4f = vec4f(0.01813022, -0.4367987, 0.2436155, 0.3379497);
      result += mat4x4<f32>(-0.22186886, 0.04007365, 0.24386998, -0.045404654, -0.011970791, -0.025561016, 0.047568567, 0.079985805, -0.07326405, 0.06912239, -0.05855379, -0.01707404, 0.012507307, -0.15000002, 0.06313115, 0.09083115) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.07802534, 0.2029877, 0.11627993, -0.11450324, -0.14677162, 0.0935874, -0.041575003, -0.053375214, -0.43522328, 0.47007346, 0.0725248, -0.35737947, -0.17111947, -0.24964769, 0.16242856, 0.09726544) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.028571924, 0.03222125, -0.076341584, -0.046597753, 0.035953034, -0.14048761, 0.002908441, 0.074327126, -0.04033756, -0.0037882566, -0.018784389, -0.026932565, -0.1265651, -0.12472393, 0.18896914, 0.13786641) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.11433215, -0.13927813, -0.041755807, 0.014247947, -0.12217213, -0.121502265, 0.23590197, -0.041722372, 0.2424223, 0.074632786, -0.13423167, -0.05714524, -0.12868516, 0.001644092, 0.33194903, 0.00970414) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.0073883645, -0.23996358, 0.030301208, 0.1104237, 0.45682308, 1.1586581, -0.9176464, -1.0140095, 0.040009625, 1.0768999, -0.8867283, -0.660058, -0.42560986, -0.11370158, 0.6867046, 0.04435352) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.08846, 0.15749756, 0.42959353, -0.30372843, 0.020020554, 0.09545414, 0.07776567, -0.04511186, -0.24847521, 0.23625596, 0.26868, -0.1798453, -0.32117948, -0.234022, 0.07481524, 0.2846148) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.161035, 0.2284703, 0.011978039, -0.15747526, -0.0061923186, -0.12760392, -0.02448438, 0.074157216, -0.13344064, -0.09732827, 0.110373564, -0.08487482, -0.067645304, -0.25373653, 0.26293123, 0.20706907) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.20050956, 0.24766731, -0.24006782, -0.044732537, -0.36694592, -0.22585669, 0.12563145, 0.0701344, 0.43519497, -0.0660724, -0.28459558, 0.041255068, -0.42674124, -0.36228815, 0.7315847, 0.19250941) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.123015106, 0.034444764, 0.5844055, -0.1552003, -0.12850864, -0.1219189, -0.058611587, 0.1351137, 0.09600883, 0.04427762, -0.051534455, -0.0547471, -0.36807477, 0.07117477, -0.15003796, 0.0013920306) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.15412591, 0.011937432, 0.029510532, -0.022649191, 0.18659633, 0.16300036, -0.41103435, -0.11051529, 0.2573064, 0.039005812, -0.062665276, -0.05400448, 0.024933614, -0.075117774, -0.16448335, 0.032843955) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.032692455, -0.18425715, -0.13073383, 0.03175978, -0.5971128, 0.28598022, 0.37938157, -0.27040896, -0.18028198, 0.44799125, -0.25306848, -0.33550256, 0.20378897, 0.117731765, -0.106895804, -0.16798681) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.11472307, 0.05750437, 0.13955446, -0.1301395, -0.07243371, -0.14867243, 0.15072927, 0.15642735, 0.55528855, 0.17804517, -0.15006235, -0.3560095, -0.014288665, 0.14024313, -0.06942535, 0.034121998) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.18612315, -0.069708034, -0.16925696, -0.05477824, 0.08464303, -0.144659, 0.036319748, -0.051304866, -0.12262354, -0.13402307, -0.2731802, 0.23583987, -0.17189197, -0.11542629, 0.27548146, 0.17149512) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.6915603, -0.3076957, -0.216375, 0.40931374, 0.684214, 0.97303957, -0.5272417, -0.67299324, 0.6126613, 0.3535003, -1.1666554, 0.07955002, -0.04296615, 0.2697075, 0.5249323, 0.47405398) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.22449897, -0.2780684, 0.19646153, 0.07714733, -0.41859996, 0.17410368, -0.13732877, 0.11246338, 0.4818043, 0.10055382, 0.30412883, -0.35728738, 0.41007006, 0.15048763, 0.00088815484, -0.097429685) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.08732315, 0.0348526, 0.08414293, -0.14094722, -0.1662112, -0.013579872, 0.2274062, 0.027952291, -0.13209198, 0.08026769, 0.15272628, -0.092179306, -0.2475575, -0.117064975, 0.215914, 0.052768458) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.14211033, -0.38068846, 0.07262795, 0.17383826, -0.15928678, -0.22565739, 0.13675894, 0.06834791, -0.11385312, -0.19735368, -0.07797241, 0.17496306, -0.032622673, 0.4752936, 0.027989807, -0.29745585) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.20256461, -0.096168645, 0.10255186, -0.04097162, 0.14195937, 0.0104069635, -0.19409555, -0.010446134, -0.1471423, -0.1208388, 0.009876788, -0.010620067, 0.29238883, 0.1199775, -0.20970355, -0.06788528) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
