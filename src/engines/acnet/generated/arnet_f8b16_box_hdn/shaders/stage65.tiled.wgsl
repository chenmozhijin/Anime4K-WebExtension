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

  var result: vec4f = vec4f(0.08280424, 0.013070222, 0.14486323, -0.21523802);
      result += mat4x4<f32>(-0.059089687, 0.00435549, -0.003351328, -0.0058474657, -0.28314188, -0.10906849, -0.15321898, -0.13132663, 0.26726776, -0.0014018351, 0.0116579225, 0.1548923, -0.067761675, -0.029985111, -0.06696863, -0.13167161) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.042927183, 0.08905388, -0.045695692, -0.10060655, -0.1695666, 0.06515686, -0.062998444, -0.3393483, 0.07259705, -0.054935787, -0.0035622243, 0.20698592, 0.19782096, 0.016891921, -0.0089218775, 0.07848612) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.03123747, 0.023539092, 0.04095371, 0.096358165, 0.0451491, 0.09155823, -0.0048125223, -0.20088887, -0.3200809, -0.07200875, -0.06131607, -0.13056132, -0.009034802, 0.0069935843, -0.0072975173, 0.035351533) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.018035572, -0.21905906, -0.27155507, 0.21705937, 0.16252378, -0.074790925, -0.2919403, 0.14787751, 0.042147655, 0.12254175, 0.08960107, -0.32551292, 0.06673337, 0.09039629, 0.14798748, -0.4757047) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.0657312, -0.4470467, -0.17170137, 0.6527149, 0.32885137, -0.70182407, -0.2733244, 0.34119174, -0.27609435, 0.28667974, 0.17706014, -0.71225345, 0.34312016, -0.6552537, -0.051141195, 0.5644817) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.084076956, 0.00950006, -0.10151498, 0.17207958, -0.08695729, -0.49767444, 0.21776241, -0.0031647133, -0.14518574, 0.15755, -0.009556384, -0.04421182, 0.06016019, -0.06914094, 0.025939498, -0.1498026) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.23214194, 0.11317207, -0.05343115, -0.058681346, 0.07120621, -0.011584773, 0.116622694, -0.016501462, 0.19949706, -0.06446944, 0.07732391, -0.0046824426, 0.41778743, -0.01019286, -0.18593977, 0.39806917) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.10684715, 0.14834176, -0.073103175, -0.32257292, -0.08015869, 0.014069027, -0.012760983, -0.0151475305, -0.17018473, -0.003726887, -0.059606757, -0.08630104, 0.06228374, -0.39869136, 0.09120441, 0.42161953) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.08851116, 0.058803678, -0.06758395, -0.10005924, -0.17712475, -0.11655646, -0.10563752, -0.14323045, -0.05961793, 0.118074864, 0.0032910828, 0.07403913, 0.14474334, 0.033505622, 0.02316218, -0.2552093) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.04244934, -0.041319173, 0.017564181, 0.011490899, -0.0397205, 0.027274996, -0.032039326, -0.042932216, -0.103129484, 0.05491007, -0.067321874, -0.04763157, -0.084214084, -0.053356625, -0.03223248, -0.11399936) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.26559246, 0.134132, 0.14039621, -0.26561016, 0.23976229, -0.05748746, 0.047118414, -0.19398753, -0.2709896, 0.08227294, -0.03124876, -0.070904054, 0.12329989, 0.022056216, -0.0044178725, -0.021272115) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.024782334, 0.0064331307, -0.068306826, 0.055782083, -0.2794529, -0.41657746, 0.11335459, 0.45577377, 0.10021564, -0.0388172, 0.012543004, 0.022190548, -0.25971842, 0.037794102, -0.16246414, -0.07972598) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.098814495, 0.009711538, 0.019096578, 0.09373847, -0.12011197, -0.064717315, 0.03174653, -0.13727453, 0.031909406, -0.030114286, -0.08323812, -0.033823483, -0.16951905, 0.015210174, 0.1527192, -0.14858857) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.021984031, -0.29940617, -0.26423788, 0.22850248, -0.30910343, 0.36160037, 0.15020022, -0.27669016, 0.1371065, 0.4582159, -0.23521245, 0.29353353, -0.25105336, 0.5196561, 0.123805135, -0.35560915) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.0766006, 0.29423398, -0.09835909, -0.88128644, 0.33834264, -0.43862042, -0.09988921, 0.61533415, -0.044513226, -0.15432854, 0.11670028, 0.16010712, -0.2299998, 0.35314828, -0.0056255925, -0.35764366) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.057328206, -0.02857311, -0.06561448, -0.049825005, -0.027398244, 0.03228581, -0.0072687087, 0.026178025, 0.51016474, -0.12766555, -0.058747586, 0.31338152, 0.012940784, 0.046995923, -0.06903187, 0.016355652) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.114122696, -0.09065588, -0.12758781, 0.1045119, -0.12611522, 0.0948453, 0.13671927, 0.017201586, 0.17961551, -0.55286056, -0.022021703, 0.8215869, 0.13142247, -0.03285374, 0.07550503, 0.17283486) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.030590177, 0.13521832, 0.10382302, -0.061970852, 0.13031195, -0.13283409, -0.06695371, -0.0009902009, 0.07229706, 0.044863593, -0.06923799, 0.014596096, 0.10813392, 0.038302224, -0.03660924, 0.07599382) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
