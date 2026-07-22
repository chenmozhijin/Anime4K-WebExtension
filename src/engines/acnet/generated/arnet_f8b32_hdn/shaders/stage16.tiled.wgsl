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

  var result: vec4f = vec4f(-0.17924792, -0.015966775, 0.28653333, -0.034246113);
      result += mat4x4<f32>(-0.0033248144, -0.12964818, -0.18577723, -0.08897603, -0.079746306, 0.07405061, -0.16318926, -0.072944336, 0.016075887, 0.27034277, 0.10488491, -0.04147577, -0.045962743, 0.37966847, 0.33422223, 0.33708328) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.24163935, 0.103913486, -0.10060114, 0.1329458, 0.05606386, -0.03006456, 0.08137972, -0.24293548, -0.18292494, 0.32109684, 0.20341362, -0.008240997, 0.48391584, 0.18265828, 0.016202299, 0.22490618) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.012804799, 0.026117433, -0.0710909, -0.08378861, 0.013008133, -0.26328665, -0.1741825, -0.09505169, 0.13000861, 0.2053742, -0.37940863, -0.3005064, 0.03527599, -0.2243792, -0.053958215, -0.19634676) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.04063787, -0.09653029, -0.019987494, 0.3729758, 0.13191646, -0.5080919, 0.01615955, -0.15402146, 0.09798329, -0.01924253, -0.19139275, -0.4457893, 0.10553763, 0.27640796, -0.014260235, -0.47228834) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.03292241, -0.19072936, 0.30110058, 0.24504481, 0.29937217, -0.08235322, -0.04025691, 0.05055823, -0.10873523, -0.16637382, -0.65647393, -0.6770584, 0.31024015, 0.16575104, -0.32048237, 0.30150422) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.013397945, -0.12876178, 0.0011745419, 0.073801115, 0.05030413, -0.19460623, -0.43157533, -0.40251908, -0.11843433, 0.44285384, -0.97759676, -0.07971648, 0.17580995, 0.054264095, -0.1587772, 0.059839617) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.04977996, 0.18998207, 0.06137221, 0.11294115, -0.11108635, -0.3893536, 0.16579543, -0.4382462, -0.0506655, 0.076146856, 0.05473397, -0.17797682, 0.040559113, 0.045744922, -0.23905057, 0.030762522) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.1936657, 0.03538808, -0.0737534, 0.17863418, -0.04479014, -0.0719071, -0.107688636, -0.14577928, 0.12796001, 0.25766706, -0.012574744, -0.15942845, -0.26343772, 0.17019632, 0.08768588, -0.29132047) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.03158266, -0.28809842, -0.11399185, 0.20305891, -0.0037754567, -0.1814054, -0.65321255, 0.25146425, -0.011918292, -0.05238904, -0.42774647, 0.09971531, 0.028945064, -0.055571016, -0.061283473, 0.120805964) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.032392915, -0.12845916, -0.05083408, -0.15550186, 0.037663575, -0.06287388, -0.11056915, 0.07979731, -0.077469215, -0.012430609, 0.042027894, -0.07831897, 0.029807467, -0.04746495, 0.076696195, 0.19098544) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.44587964, 0.33554345, -0.028713979, -0.10389053, -0.09978359, -0.00606339, -0.14646174, -0.25175217, -0.1080469, 0.008422546, -0.01954857, 0.068693504, 0.14733635, 0.09699127, -0.10178613, 0.18274851) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.10281733, 0.11301334, 0.0032390272, 0.15962794, -0.124599695, 0.019045575, -0.11162681, 0.10738177, -0.17004628, 0.13104792, 0.1330188, 0.011734588, 0.08141644, 0.19685885, 0.092202105, -0.14228807) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.027357789, -0.017182233, 0.03415907, 0.18161002, -0.047328092, -0.6471931, 0.20894083, -0.2614387, 0.03072693, -0.24002376, 0.0012861335, 0.09373337, -0.09656784, 0.16875109, 0.040378626, -0.10094397) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.14288162, 0.17873386, -0.18630794, -0.030744163, -0.057610344, -0.7290276, -0.014124918, -0.24018656, -0.12549712, 0.25396913, 0.8009515, 0.06632588, 0.23785429, -0.52307236, -0.637675, -0.4740934) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.0716038, -0.19454879, 0.1467432, -0.117680624, 0.018853245, -0.40684426, -0.019725725, 0.16684243, -0.100150965, 0.24999233, 0.1028533, 0.008924303, -0.052757442, -0.1128579, 0.1153826, -0.2504435) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.06738109, 0.083824456, -0.13486257, 0.06591159, -0.10546018, -0.3898912, 0.0025265533, -0.13486291, 0.087081574, 0.008464246, -0.12455028, 0.19259566, 0.08444364, 0.3628493, -0.12639375, 0.15053082) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.10800516, 0.13655137, -0.10401474, -0.037799694, -0.12579583, 0.2988488, 0.124584496, -0.14928441, -0.014159139, 0.1949017, 0.19031796, -0.17259897, -0.6938426, -0.25300872, 0.18071277, -0.8735445) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.10365295, -0.036422, -0.036214273, -0.03174087, 0.019904802, -0.1311617, -0.17560276, 0.06243107, -0.0034660986, -0.0406976, -0.10562644, -0.1258201, 0.17109162, -0.07062792, -0.22927663, 0.27952036) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
