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

  var result: vec4f = vec4f(-0.04002502, -0.3766477, 0.16824861, -0.14589968);
      result += mat4x4<f32>(0.39831004, 0.14798997, 0.25651786, 0.011248724, -0.1534843, 0.12086027, 0.051410068, -0.2689611, 0.24859059, -0.20153363, -0.029678084, 0.2946415, -1.084579, 0.078795046, 0.049681224, -0.252307) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.21582639, -0.05327031, 0.17839527, 0.18722495, 0.2329, -0.004698108, 0.10299504, -0.1616362, -0.14802577, 0.0016785265, -0.04141425, 0.2594453, 0.44881126, -0.19326364, -0.15095536, 0.76593494) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.14936298, 0.093863174, -0.056042004, -0.07182413, -0.11106356, 0.061533105, -0.030182475, 0.02478264, -0.12856373, -0.086361386, -0.0029795673, 0.08739433, 0.17914285, 0.21802172, -0.1642013, 0.04060835) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.21857332, 0.22955325, -0.13516589, -0.1834612, 0.37104216, 0.11841766, -0.3940198, 0.16784017, -0.6179223, -0.16779694, -0.33721858, 0.25026882, 0.09044642, 0.7283507, 0.559056, 0.23710382) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.51013297, -0.6158013, -0.04384652, -0.1627125, 0.017023357, 0.13045888, 0.44303015, 0.08190548, 0.7468686, 0.35871783, 0.745408, -0.054833613, -0.12297463, -0.32029188, -0.5254893, 0.17513867) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.07635316, -0.030447192, 0.124413244, -0.058352616, -0.18886158, 0.31784037, 0.2596393, 0.17024612, 0.40706173, -0.3753796, -0.4098318, 0.58229506, -0.100879736, -0.05174166, -0.21919917, -0.113786936) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.021946196, -0.12894523, -0.03256681, -0.102903515, -0.14116201, 0.12729216, -0.08251011, -0.0074362583, 0.090464585, -0.14099342, 0.15528467, 0.13560612, -0.18583184, 0.04728931, -0.5184051, 0.16117471) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.28354305, -0.02047672, 0.18149236, -0.029402256, -0.4488587, -0.7418071, -0.53203577, 0.3014385, 0.5502517, 0.50831234, -0.6873741, 0.19484086, 0.0045682183, 0.32154796, -0.2594699, -0.059655305) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.08185127, 0.15162773, 0.009143063, -0.014102179, 0.05767456, -0.027580421, -0.10527202, -0.017160155, -0.6829263, -0.4805561, 0.23812343, 0.11724715, 0.103115246, 0.13977413, -0.09623351, -0.069872424) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.0044408184, 0.08633996, 0.1015187, -0.14029193, 0.24741733, 0.032350462, -0.07826465, -0.20405895, -0.039282598, -0.018341972, 0.07729972, 0.08620811, 0.013633918, 0.0715687, 0.04804545, -0.19444095) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.17339104, -0.08426581, -0.17656282, 0.073925525, 0.30941755, 0.117971934, -0.23998399, 0.052057106, 0.22263092, -0.13663925, 0.16089739, -0.23759036, -0.3900638, -0.06614469, -0.2639846, 0.11563339) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.040325496, -0.06461041, 0.07341003, -0.088253796, 0.3006956, 0.27032816, -0.062847696, -0.016874151, 0.052887473, 0.27805397, 0.061037824, -0.17971656, 0.012967977, 0.12306621, 0.13691732, -0.18255462) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.08802057, 0.11367977, 0.07108759, -0.043389495, 0.14414445, 0.042270172, -0.28864926, -0.019783922, -0.2208978, -0.20414564, 0.57476705, -0.26389772, 0.68716985, 0.26186168, 0.17841251, -0.014260348) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.93285614, 0.4550945, 0.9264794, -1.1024034, -0.10308398, 0.9736182, 0.8322475, -0.08294975, 0.543466, 0.8861263, -0.11278074, -0.3446859, -0.5154727, 0.011213553, 0.4999507, -0.14690639) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.03409657, 0.117615335, -0.07864055, 0.017638175, 0.2253878, 0.011912347, -0.25798726, -0.0077668293, 0.029153353, -0.100368805, 0.11943311, -0.23485987, 0.3910017, 0.13699122, -0.07242279, -0.083785616) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.16405816, 0.14629698, 0.1485462, -0.24096866, 0.025090989, 0.15114172, -0.11281815, -0.20268597, 0.19504656, 0.11103506, 0.020258432, -0.10762114, -0.14668138, 0.1890499, -0.10439714, 0.13326728) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.27270865, -0.06276319, -0.1286253, 0.0072745536, 0.4824291, 0.40826172, -0.36440596, 0.0875508, -0.0030722104, 0.18941505, 0.10587816, -0.28136307, -0.4921713, -0.12130627, 0.80940443, 0.05959864) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.00728383, -0.011508186, 0.020725744, -0.035515122, -0.16759819, 0.054707807, 0.005744415, -0.022576146, 0.20879379, 0.19783989, 0.040790346, -0.13064781, -0.27168342, 0.07060105, 0.10101388, 0.07022561) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
