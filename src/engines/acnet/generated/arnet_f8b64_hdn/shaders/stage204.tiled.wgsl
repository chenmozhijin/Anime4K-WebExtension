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

  var result: vec4f = vec4f(0.017863354, -0.040095035, 0.37850437, -0.05533314);
      result += mat4x4<f32>(0.020566005, -0.053698875, -0.14070351, 0.17824867, 0.07004486, 0.09173016, 0.22100732, -0.026392188, -0.27002233, 0.19278629, 0.2144947, -0.07809485, 0.01939367, -0.061828293, 0.24872372, -0.42233962) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.06485703, 0.17624949, 0.022269288, 0.16469756, -0.013841403, 0.25947815, 0.26001278, -0.0849137, -0.19601636, -0.023328451, -0.11777723, -0.22828574, 0.51078874, 0.07981992, 0.048091523, -0.5656738) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.18299282, 0.0006046171, 0.05439521, 0.027715402, 0.18555714, 0.114369534, 0.0037189308, 0.04873661, -0.26178265, -0.23392329, -0.053311884, 0.07067153, 0.31350902, 0.38762215, 0.2977173, -0.08668956) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.017672027, 0.2877103, 0.16991651, -0.5046498, 0.009130045, -0.16884446, -0.14659807, 0.12324843, 0.0019633498, -0.027171806, 0.03333806, 0.12116202, -0.03914518, 0.058062706, -0.11195624, -0.4318046) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.6336411, 0.35999548, -0.19485006, -0.061193936, -0.8242008, -0.023771232, -0.008126353, -0.46092358, 0.95301604, -0.067806475, -0.4511075, -0.27114698, -0.17295617, -0.36980098, -0.37481368, -0.74233407) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.11293077, -0.07618879, -0.1150881, 0.0106265, -0.10870665, 0.1514217, -0.105909735, -0.15595022, -0.3412972, -0.7059357, -0.47811016, -0.33766204, 0.03282158, -0.07760475, -0.15058513, -0.25612196) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.09900109, 0.06333511, 0.16220433, -0.030981852, 0.06533643, -0.19480106, -0.29060233, 0.24644408, -0.13414411, -0.059679046, 0.057304412, -0.062206678, -0.12443133, 0.03946437, 0.1600624, -0.04603591) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.09045673, 0.1869112, 0.12870403, 0.13268216, 0.28311315, 0.2230587, 0.043997813, -0.1740869, -0.08131138, 0.120060384, 0.24220137, 0.24601392, -0.3250866, -0.36417988, -0.44071913, 0.3852936) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.05812513, -0.024099967, -0.023718677, 0.125632, -0.06625195, 0.10443651, 0.06685034, 0.12774266, -0.20494637, 0.09620988, 0.08851308, -0.011212892, -0.11509886, -0.009137409, -0.16321, 0.22807142) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.090341896, 0.019672038, -0.116922125, -0.13867013, 0.03769482, 0.03830342, 0.21799621, -0.121575266, 0.01959382, -0.11853985, 0.18496476, -0.22797087, 0.47240898, -0.0876815, -0.15078348, 0.51645106) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.10085527, -0.1731604, 0.018907975, 0.057150055, 0.22309497, 0.08516996, 0.056938138, 0.06524687, 0.14579815, -0.16927768, 0.03864655, -0.08072049, 0.3190325, 0.31474966, 0.18676162, 0.32486412) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.12530364, -0.1838894, -0.056814127, 0.025486361, 0.06844207, -0.06051995, -0.14506064, 0.14998505, 0.061161157, -0.07292428, 0.0717627, 0.07785519, -0.003366664, 0.17409547, 0.0678434, -0.0003821001) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.35732234, 0.20668393, -0.049958274, -0.5740214, -0.20300128, -0.034580152, 0.11568782, -0.36748368, -0.16084772, 0.074819006, -0.4383835, -0.052456684, -0.15735275, -0.29914293, -0.24070033, -0.123228036) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.4338119, -0.72966397, -0.9835787, 0.3301385, -0.761701, -0.69973683, -0.6750368, -0.82887524, -0.23350106, -0.2271215, -0.2976782, 0.026455259, 0.55667824, -0.365664, -0.72963536, 0.19812742) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.32242653, -0.1895666, 0.04457921, 0.28246662, 0.006437306, 0.28329545, -0.13047835, 0.06773429, -0.052765492, -0.16023757, -0.13709772, -0.05836946, 0.41665614, 0.094097674, 0.13233715, 0.133603) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.061189335, 0.062242612, -0.23565736, -0.3699259, 0.0294798, -0.016863257, 0.0084668, -0.20144057, -0.19889703, 0.0021454575, -0.8395196, 0.12689245, 0.013988339, -0.1744185, -0.23805235, 0.17670535) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.10546401, 0.20357391, 0.31761402, -0.14520825, -0.0298024, 0.2241241, 0.0063109193, -0.36591798, -0.05312383, 0.07619495, -0.22279397, 0.05167416, 0.0029386296, -0.09334351, -0.022880469, -0.05657012) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.044985913, 0.05430012, 0.19697626, -0.0069996035, -0.12805998, -0.09477821, 0.083874196, -0.03415595, 0.07720435, -0.041282825, 0.15624817, -0.16826159, 0.16873284, 0.039545745, 0.093964726, 0.019227033) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
