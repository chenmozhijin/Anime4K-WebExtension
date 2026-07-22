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

  var result: vec4f = vec4f(0.2004651, 0.04275744, 0.19896422, -0.19120993);
      result += mat4x4<f32>(0.015995014, -0.041713398, 0.024078095, -0.05385172, 0.10732304, 0.33092934, -0.06669024, 0.034349695, -0.010552195, -0.090041675, 0.043480612, 0.08584, -0.22188, 0.3724884, -0.05448707, -0.108243965) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.09324261, 0.09321442, 0.14498405, 0.046203617, 0.22247976, -0.31191653, -0.71827507, -0.2055411, 0.0139432745, 0.055229366, 0.15237744, 0.17130157, 0.36106303, -0.22516225, -0.15407412, -0.10516667) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.025415089, 0.007577077, 0.10319616, 0.023904823, 0.12041151, -0.39364788, -0.022455301, -0.18477985, -0.060959153, 0.029499503, -0.04303573, 0.20277159, 0.19472621, -0.12567468, -0.11003561, -0.095542125) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.23479727, 0.023151597, -0.101553224, -0.009428112, 0.23586108, 0.19631547, 0.3642846, -0.3383122, 0.24946705, -0.14913489, -0.23247382, 0.40806335, -0.21103683, 0.3804291, 0.19280268, -0.0070953094) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.5457342, 0.11020681, -0.08597077, 0.12587401, -0.015589174, 0.11834327, 0.08916859, -0.3515645, 0.44652444, 0.12301228, 0.16354604, 0.5428893, 0.072000936, -0.1314634, 0.12391107, 0.6020831) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.15823057, -0.0067796535, 0.013045289, -0.06679538, 0.23587646, -0.12505421, 0.027686821, -0.20621493, 0.22312307, 0.37393942, -0.069043465, 0.24162392, 0.1842547, -0.012266875, -0.070398025, 0.06902965) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.051633548, 0.073230796, 0.010155856, 0.083599076, 0.39411858, 0.097717606, -0.30689874, 0.41606933, 0.0075850245, 0.005605687, -0.093678154, 0.045291517, 0.34900004, 0.21185777, -0.061896786, 0.021075733) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.10488002, 0.022145532, -0.12749192, 0.18864752, 0.02773891, -0.26956832, -0.24403664, -0.15171997, 0.4253873, 0.35638025, 0.10564767, 0.2008672, 0.01887747, 0.08390051, -0.18696015, 0.18448761) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.15366912, -0.03556457, -0.009543515, 0.024979968, 0.09719078, -0.16874492, -0.05448284, -0.01513401, 0.1294085, 0.1058093, -0.07697455, 0.15340704, 0.031282593, 0.000688297, 0.00263326, -0.014191317) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.03665302, 0.0337255, 0.21512945, -0.15471585, 0.08650551, 0.070792414, 0.022670005, -0.1565759, 0.30988407, 0.103883535, -0.17433004, 0.07598319, -0.22527863, -0.06937884, -0.0047765253, -0.03739773) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.40072697, -0.060576025, 0.299803, 0.006305655, -0.09106875, -0.102066495, -0.036730807, -0.16283278, 0.33283582, 0.09553439, -0.3101032, 0.076792695, -0.23677559, 0.12912813, -0.030993901, -0.099739656) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.16509245, 0.2839278, -0.074588984, 0.1809287, -0.123497434, -0.1467039, 0.07880784, -0.14165479, 0.07576357, -0.056324385, -0.04139429, -0.008071125, -0.31701204, 0.045777462, -0.13833511, 0.09244013) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.3703822, 0.24306466, -0.15466282, 0.14389761, 0.08424217, -0.16927555, -0.04835833, 0.02094513, 0.0064724428, -0.18240765, -0.049819984, -0.02277361, -0.34970558, -0.08556427, 0.020839095, -0.10499898) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.11203266, 0.028491266, -0.10233322, 0.46440336, -0.315516, -0.39031768, -0.30262536, -0.23591927, 0.76546204, -0.1762083, -0.19572248, 0.277641, -0.54706603, -0.06071932, 0.57642126, -0.37064087) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.2904455, 0.07379278, 0.11272756, 0.08743859, -0.69303787, -0.2985168, 0.010890711, -0.17612047, -0.02417817, 0.071374334, -0.22381933, -0.25823674, -0.46609837, 0.21724072, -0.015207507, 0.14817576) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.1958271, -0.22872713, 0.19881853, -0.27533123, 0.21874237, -0.013266039, -0.035035353, 0.07442974, 0.11611408, 0.19171637, -0.009613787, 0.17698611, -0.55473655, -0.18450743, 0.07803957, -0.23767918) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.3761611, 0.2117831, -0.1684622, 0.116763614, -0.62936336, -0.729843, -0.06168784, -0.5294732, 0.01782676, 0.07171553, -0.08711263, 0.18576494, -0.15840714, 0.15123528, 0.2635241, -0.008526751) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.20370531, 0.025995288, -0.036253065, -0.08170792, -0.37205967, 0.008456414, 0.013051871, 0.26958016, -0.07812908, -0.03882244, -0.092938714, 0.18793659, -0.30471787, 0.14581352, 0.037365142, 0.13902679) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
