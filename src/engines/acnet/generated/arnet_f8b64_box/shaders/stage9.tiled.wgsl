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

  var result: vec4f = vec4f(-0.23482917, 0.043676674, 0.2246873, -0.26859426);
      result += mat4x4<f32>(-0.0024296304, -0.022582596, -0.35277724, -0.110073715, 0.09720835, -0.12374608, 0.025707653, 0.04843814, -0.07607167, 0.06719836, 0.053401712, -0.14584239, 0.024285868, -0.023380736, -0.04356631, -0.0031668944) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.036787488, -0.13243757, -0.35732406, -0.14632644, -0.18299073, 0.0723397, -0.017067034, -0.2714158, 0.060715076, 0.08079747, 0.22925405, -0.37939206, 0.008706042, 0.070336305, -0.3254456, -0.07700389) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.017869912, 0.039632246, -0.17922084, -0.0008562989, -0.040927336, -0.18479711, -0.20094995, -0.12764321, 0.031572863, -0.032105293, -0.025145419, 0.065095454, -0.02012286, 0.025860906, -0.041879997, -0.088431984) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.14185369, 0.34040725, 0.2044172, -0.24770507, 0.13072553, -0.200416, 0.061646234, -0.0009480391, 0.15914881, -0.61684895, -0.19068062, 0.486708, 0.16011141, 0.06374203, -0.057754014, -0.014029655) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.42092276, 0.22575179, 0.20359199, -0.39564773, 0.2128977, 0.41193864, -0.019361975, 0.33964193, 0.52845776, -0.6510346, -0.17182766, 0.2625642, -0.029599596, 0.39689964, -1.6360651, -0.28205636) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.16375299, 0.21922436, 0.14413941, -0.14941503, 0.05442254, 0.15545166, 0.17904697, 0.18716876, 0.18310145, -0.40598255, -0.115236595, 0.18141945, -0.031424616, 0.10118403, -0.018189646, -0.070874885) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.0043870397, -0.21570742, -0.054669004, 0.15203658, 0.04862618, -0.060992245, -0.05680968, 0.018886767, -0.02499535, 0.14457959, 0.13883284, -0.21655068, -0.024519833, 0.042575847, 0.0012882764, -0.102011) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.11455646, -0.09686896, 0.06849382, -0.09397463, -0.072097346, 0.09266717, -0.24995719, 0.08555016, -0.02321273, 0.41735768, 0.09877494, -0.28188434, -0.2013038, -0.24134141, -0.36531758, -0.04327047) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.017756168, -0.055555783, 0.0001370416, 0.01672066, -0.1885969, 0.15027611, -0.078093566, -0.08208345, 0.010362195, -0.07393629, 0.07090374, -0.021608977, -0.010550278, -0.11715204, -0.05207786, -0.029873574) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.05046938, 0.11904727, 0.033353083, 0.1029425, 0.04547749, 0.098760694, -0.1194814, 0.057030175, -0.017923787, 0.022954833, -0.1549135, 0.29324022, -0.0953449, 0.105906084, -0.24768004, -0.2271371) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.268528, -0.35551283, 0.67015654, 0.21875419, -0.07644547, -0.1012705, 0.3212594, 0.023663677, 0.03265698, 0.08766121, 0.12426917, 0.23942289, -0.040695745, 0.3530628, -0.28037533, -0.18249106) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.07106608, -0.11907794, -0.33911544, -0.07873021, -0.11103519, -0.11189317, -0.40776214, -0.023386799, 0.025646443, -0.096903816, -0.21042725, -0.16373466, -0.00050480483, -0.12575668, -0.4512859, -0.10946345) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.07890584, -0.012603426, 0.058616813, 0.010491615, -0.0043874374, -0.047533367, -0.049067177, 0.035548788, 0.14073977, -0.24166808, -0.10685652, 0.00708813, -0.09740892, 0.1801765, -0.0651269, -0.23732711) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.024185903, -0.39164183, -0.47233924, 0.56197184, 0.05379699, -0.3881161, 0.23801276, 0.27774101, -0.27992612, -0.27828148, 0.17378686, 0.1496948, 0.19500394, 0.22793885, 0.15065998, 0.07659868) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.24125281, -0.7817951, -0.12829986, -0.1141269, 0.08101214, -0.1967581, -0.30480805, -0.11350105, 0.0139135495, 0.4550015, -0.015573653, 0.058855627, 0.20238842, -0.1864166, -0.039011247, 0.16584696) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.07044864, 0.08307975, 0.012908913, -0.0571314, -0.10871973, -0.4578153, -0.12795112, 0.14819369, -0.04006495, -0.035301697, 0.09378815, -0.10251731, 0.00181328, 0.35073555, 0.21442564, -0.17695835) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.04993047, -0.05168385, -0.2322244, 0.21882184, -0.050385408, 0.2979292, 0.33248445, -0.41620666, -0.054443125, -0.19896147, -0.3594414, 0.083005324, 0.20552352, 0.15301971, 0.04533466, -0.16571763) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.13423352, -0.098273665, 0.14907342, 0.12045996, -0.3496582, -0.23326372, -0.21399154, -0.30397108, -0.03870521, 0.035443693, 0.09952788, 0.2819833, 0.2989826, -0.219399, 0.085072465, 0.039994426) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
