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

  var result: vec4f = vec4f(0.07139637, 0.030497912, -0.01416857, -0.04523033);
      result += mat4x4<f32>(0.090622775, 0.06641472, -0.1885235, 0.32190698, 0.0008331026, -0.0179108, -0.19182841, 0.12971453, 0.11054846, 0.1144335, 0.040604107, 0.11379767, 0.032996513, -0.0395164, 0.10226553, -0.2792965) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.04966385, 0.06600392, -0.14026883, -0.16453077, 0.13747522, 0.031976856, 0.55852115, 0.41597626, -0.074457794, -0.10845321, 0.44881064, 0.16288023, -0.011387766, 0.18778528, 0.14760813, 0.18899107) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.1710858, 0.024880415, 0.46685928, -0.22543338, -0.122832015, -0.0749527, 0.08896424, 0.109870054, -0.07005137, -0.2009096, -0.0005889346, 0.40714556, -0.16626178, -0.29004064, 0.07593728, -0.115528785) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.05532805, 0.058856312, 0.018116526, -0.433772, -0.2104762, -0.12362674, -0.041121114, -0.13028717, 0.087588735, 0.09725291, -0.07585669, 0.21563351, -0.09110761, -0.13153748, -0.116221435, -0.10354331) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.2856159, 0.20203033, 0.27290884, -0.23611696, 0.25313687, -0.025054915, 0.47518545, 0.11105865, 0.15251529, 0.062056344, -0.4090004, -0.20766631, -0.12255785, 0.38236082, -0.76691794, -0.15368272) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.3164096, -0.39670393, 0.039801225, -0.2932734, -0.047419444, -0.19806696, 0.12274746, 0.029120957, -0.043922886, -0.23422047, -0.15802668, -0.52479553, 0.027368784, 0.40032715, -0.18184224, 0.10088696) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.13157094, 0.07846684, -0.010751136, -0.037671164, 0.009454087, 0.06380493, -0.06171004, 0.008786824, -0.04699846, 0.31258214, -0.06329686, 0.28007162, -0.19673559, -0.4321748, -0.035218578, 0.062953174) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.1242145, 0.1841877, 0.1880465, 0.095793426, 0.084506296, 0.24293357, -0.039061163, -0.009075974, -0.29508764, -0.5337627, -0.13977039, 0.041104525, -0.13371943, -0.42284977, 0.19976854, 0.10846832) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.046237145, 0.18999064, -0.039968435, 0.14276528, -0.0023785029, -0.11428506, 0.037496738, -0.10744537, -0.23164718, -0.446655, 0.031789847, -0.16476499, 0.09102402, 0.15940893, 0.12259443, 0.35487992) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.088874124, -0.53976524, 0.15010245, 0.046562504, -0.120209366, -0.22624506, 0.014881536, -0.2877479, 0.039097212, -0.15975665, 0.16745158, -0.07694959, 0.07808135, 0.06325453, 0.27321166, -0.011756147) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.075416245, -0.20876405, 0.45152533, 0.26747176, -0.17756248, -0.2875036, 0.0011890861, -0.19255239, -0.120440826, -0.14917302, 0.18121716, -0.11231805, 0.09991193, 0.081960835, -0.3322803, -0.021603463) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.12593174, -0.12792799, 0.074414544, 0.023280453, -0.09651511, -0.1689733, -0.051722642, 0.07674947, -0.07383268, 0.14101626, -0.0088592535, -0.0805579, 0.13830706, 0.046737973, -0.18429992, -0.045202225) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.043194953, -0.30621147, -0.18831468, -0.07503286, 0.009568635, -0.28374022, 0.38336143, 0.042970333, -0.10291134, -0.31495908, -0.20266666, -0.01858397, 0.34170365, 0.083093524, 0.12208568, 0.16865164) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.20804612, 0.04482423, -0.27740082, -0.107722744, -0.093664914, -0.3829129, -0.044909038, -0.29697636, 0.041182898, -0.07332933, -0.09359693, 0.43352258, 0.039244913, 0.25874162, -0.21356484, 0.073638804) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.08792758, 0.09719221, -0.05150679, -0.07235998, -0.023447206, -0.018901285, -0.08170514, -0.067552485, -0.07063383, 0.1433613, 0.06822758, 0.47944376, 0.20270701, 0.4321592, 0.0077063097, 0.21036877) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.10969793, -0.06840008, -0.07050849, 0.07499871, 0.2533279, 0.9305292, 0.020070137, 0.26724046, -0.08986969, -0.13423006, -0.030128712, 0.06284237, 0.08709072, 0.13300774, 0.17399065, -0.2252082) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.007164986, 0.023438267, -0.2397552, 0.119338125, 0.035384677, -0.019006696, -0.20165133, 0.012879201, -0.05806476, -0.050112043, -0.15557922, 0.07461384, 0.05262824, 0.039018475, 0.07963984, 0.17825927) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.0677727, 0.31907701, -0.07074281, 0.45226848, 0.016860541, 0.076936476, 0.014403374, -0.16159683, 0.025920846, 0.2375488, 0.014830583, 0.10383033, 0.041154947, 0.18847118, -0.043398988, 0.04785575) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
