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

  var result: vec4f = vec4f(-0.16436245, 0.12728673, 0.2675976, -0.73722035);
      result += mat4x4<f32>(0.41961008, -0.08558346, 0.0878298, 0.1272586, 0.0014648554, -0.101473644, 0.044888955, -0.05523057, 0.03275211, -0.16378778, -0.049946256, -0.08846726, -0.010729401, -0.005747328, 0.106538504, -0.08006672) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.06679673, -0.60713017, -0.24017178, 0.16220927, 0.17361036, 0.13658549, 0.16105346, 0.12192565, -0.9615602, 0.35259312, -0.32647055, 0.08337616, 0.020101972, -0.2884095, -0.18580194, -0.017479131) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.047882456, -0.3054521, -0.09119904, -0.16958357, -0.16668281, 0.13326861, 0.023132507, 0.1733228, -0.02708351, -0.024084019, -0.12041528, -0.09269874, 0.021800596, -0.032063935, 0.05538769, -0.077836156) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.14937608, -0.072983004, 0.023914687, -0.015467291, -0.3146021, 0.122854, -0.0094604045, 0.22133239, -0.19505857, -0.15995678, -0.08599568, 0.07127624, -0.22242007, 0.15344451, 0.0019193313, 0.031518627) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.032527518, 0.3948207, 0.68663645, 0.1698129, -0.15199499, 0.35684434, 0.37637722, -0.33662713, -0.19305517, -0.44060305, 0.43155837, 0.06319844, 0.508138, 0.9951461, -0.38726753, 0.5416165) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.1808389, 0.099824294, -0.034236, 0.03308647, 0.11970191, -0.0456106, 0.020842096, 0.021469973, -0.4591218, -0.77641153, -0.5987549, 0.46182576, -0.009718964, 0.19888292, -0.0003748525, 0.19102843) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.045157783, -0.033344932, 0.0373549, 0.09638466, -0.03734704, -0.0059406995, 0.09365457, -0.013243321, -0.07443705, 0.007924209, -0.021252634, 0.10052174, 0.014385339, -0.15486939, 0.058573272, -0.026921783) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.23523928, 0.1917545, 0.12796491, 0.013745201, 0.010657339, 0.07122798, -0.15913142, -0.008231735, -0.058847647, 0.09537728, -0.037712406, 0.14760701, 0.109157644, 0.4902219, 0.08935423, -0.008691659) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.07575984, 0.13577232, -0.06788055, 0.038102634, -0.10904801, -0.25231346, 0.1369177, -0.020479495, 0.15219754, 0.2403208, 0.13749996, -0.06059607, 0.09705169, 0.108905055, -0.031540863, 0.017725931) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.0614194, -0.025052259, -0.042415287, 0.032743763, -0.12760183, -0.089292675, 0.03985468, -0.037316218, 0.11107055, 0.281347, -0.053146653, 0.18612635, -0.13020967, -0.1010758, 0.020581624, -0.030490948) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.43453544, 0.07739043, 0.06113552, 0.23768057, 0.019683702, -0.19393808, -0.08160342, -0.11555321, 0.30056947, 0.39513323, 0.12036578, 0.27493584, -0.06299419, 0.0836177, 0.15418749, -0.04143048) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.05669477, 0.13441882, 0.26645967, 0.035127684, -0.022248413, -0.0062981048, -0.015693977, -0.045128472, 0.010710852, -0.02304027, 0.16792709, -0.090707146, 0.3127633, 0.11640163, 0.12257344, -0.14670141) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.40299952, -0.033275463, -0.042316247, -0.06610945, -0.10356764, 0.040968858, -0.093895815, 0.07442831, 0.3546118, -0.06752149, -0.019307436, -0.2668148, 0.20306313, -0.0852293, -0.039369196, -0.009603688) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.5317335, 0.72369564, 0.11358869, -0.60275984, 0.052790835, 0.56764823, -0.0066267936, 0.27114972, -0.41358078, -0.10379461, -0.07069593, -1.0836922, 0.2947043, 0.3776471, 0.26602814, 0.18807736) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.04589237, -0.18507116, -0.3758885, 0.11873474, -0.26154843, 0.09166056, 0.081917085, 0.09896273, -0.1602203, -0.18308319, -0.13634808, -0.18153612, -0.16516197, -0.31175637, -0.2234988, -0.050697967) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.040796995, -0.05295826, -0.16419373, 0.06362829, -0.06674112, 0.13634712, -0.007426557, 0.05019671, 0.1490814, 0.058457203, -0.06291573, -0.034907322, -0.15847985, -0.17210656, 0.052456465, -0.03944019) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.092466764, 0.055438258, 0.19178274, -0.038321257, -0.15557078, -0.5544728, 0.33528206, 0.68072724, -0.070438966, 0.15553896, -0.29138514, 0.10579757, 0.020892082, -0.057043817, -0.27960277, -0.063486636) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.0008635522, -0.115967266, -0.13427933, -0.06256065, 0.21038404, 0.06958969, 0.078154474, 0.25147185, 0.056870297, 0.21883273, 0.03282711, 0.06704872, -0.06980941, -0.34664926, -0.08509487, 0.04285445) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
