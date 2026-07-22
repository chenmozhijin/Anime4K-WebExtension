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

  var result: vec4f = vec4f(0.07219224, 0.07000691, 0.122560725, 0.12680224);
      result += mat4x4<f32>(-0.23544799, -0.23016375, -0.7627327, 0.02578996, -0.044201974, 0.06767973, -0.025026768, -0.010730794, -0.03611276, -0.16073908, -0.015640114, 0.17974961, -0.1181506, 0.0757746, 0.18595709, -0.2668256) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.05677091, -0.31064257, -0.43767637, -0.063791476, -0.23196927, -0.10467309, -0.02820259, 0.028630521, 0.07913807, -0.1948441, 0.04156555, -0.005809266, 0.029392423, 0.24380834, 0.0654695, -0.168921) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.21143003, -0.26406714, 0.16678128, 0.22391766, 0.2677529, 0.3163616, 0.10473354, -0.24730232, 0.026684387, -0.075071886, -0.04529534, -0.0064045973, 0.14320707, -0.07058355, -0.0137996, -0.053075813) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.16641794, 0.16326196, -0.13340995, -0.0140067, -0.10503835, 0.19865568, 0.29087725, -0.10091595, -0.04256197, -0.011674524, 0.12865484, 0.21955095, -0.19921714, 0.15484384, 0.06051676, -0.32114607) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.096204, 0.06573707, -0.02933807, -0.1804422, -0.23617922, -0.2380373, 0.5362287, 1.0987004, -0.006760333, -0.13918191, 0.05100129, 0.12115221, -0.008053955, -0.009291283, -0.013569463, -0.062542416) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.2790796, 0.07262431, 0.65856576, -0.21418422, 0.11004507, -0.0014649706, -0.5439531, 0.00088720693, -0.09881344, -0.17674273, -0.045687295, -0.09073856, -0.13898939, 0.13858324, 0.15300845, 0.14020991) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.116021425, 0.19033651, -0.04968191, -0.08793377, -0.109537765, 0.09193013, -0.0058605894, -0.21393433, 0.008280919, -0.13818072, -0.04812499, 0.27353033, 0.028724032, 0.008405966, 0.22392415, -0.2558382) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.05411516, 0.075512506, -0.059774056, -0.040337034, -0.024060683, 0.07245726, 0.17135878, 0.043669686, -0.0040965397, -0.08831083, -0.023911282, 0.32075092, -0.06633259, 0.29045063, 0.17177522, -0.35155705) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.26499763, 0.2043122, 0.6562429, 0.009518481, -0.0006969621, 0.29260254, 0.42774832, -0.008583731, -0.006445632, -0.08830077, -0.23145103, -0.07110451, -0.12605204, -0.020356141, -0.03886973, 0.14908572) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.043243032, -0.08903352, 0.14742754, -0.1879335, -0.18469797, 0.051425222, 0.09270533, -0.78224796, -0.13798395, 0.23384455, -0.17296942, -0.09011414, -0.45351797, 0.33178186, -0.03701663, -0.248777) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.28087962, -0.009105308, -0.1396082, 0.019514514, 0.06592261, 0.17218713, 0.077573605, -0.06547107, -0.2653722, -0.06552625, -0.49926987, 0.23852772, -0.016138198, 0.09369304, 0.04607297, 0.19460909) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.012640573, -0.017229842, -0.25216007, -0.35469118, 0.13017188, 0.05887036, -0.119282335, -0.13490672, -0.34324598, -0.1230517, -0.8458554, -0.2406617, 0.49835488, -0.07411287, -0.25123173, 0.6035696) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.29494578, 0.19834352, -0.16875379, 0.31265217, 0.05395126, -0.09896971, -0.1582765, -0.42446372, 0.10884454, 0.16841088, 0.524242, -0.041338988, 0.8240206, -0.15379053, -0.24656104, 0.63513666) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.30967307, -0.1422123, 0.07821909, 0.00025567185, 0.08480208, -0.21845073, -0.35628387, -0.17966348, 0.15634997, -0.018187732, 0.123442575, -0.10886718, -0.49799153, 0.016945936, 0.030606404, 0.016945401) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.04243978, -0.57844114, -0.22643363, -0.121338956, -0.15035078, 0.18473567, 0.25684282, -0.20068759, 0.032186847, -0.31811896, -0.1736567, 0.17774583, -0.46055713, -0.21442376, 0.24891461, 0.23718823) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.22305003, -0.078797154, 0.06663579, 0.04696673, -0.03400595, 0.11356285, 0.23094328, -0.21816131, 0.19260177, 0.17160718, 0.52898455, -0.019130973, -0.26229432, 0.14542902, 0.14186183, 0.030952344) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.033176024, -0.10762359, -0.11353692, -0.06948069, 0.16682723, 0.0653645, -0.002553803, -0.25247425, 0.21735783, -0.09696307, 0.30445433, 0.05638386, -0.04576876, -0.16780251, -0.008091319, -0.13268253) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.10759039, 0.12024929, -0.40662736, -0.12298045, -0.016506616, 0.018139571, -0.012463743, -0.25187764, 0.09553033, -0.0452044, 0.20974922, 0.07290161, 0.034387954, -0.08048274, -0.18759638, -0.27008727) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
