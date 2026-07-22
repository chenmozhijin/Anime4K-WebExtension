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

  var result: vec4f = vec4f(0.10466689, -0.3724589, -0.13289565, 0.09759411);
      result += mat4x4<f32>(-0.002562427, 0.050773386, 0.15123451, -0.0068648793, -0.09328695, -0.033005875, -0.044642944, 0.044421483, -0.019987611, 0.23981433, -0.061558235, -0.17120577, -0.008938416, 0.1685901, 0.06461511, 0.03759563) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.21206982, -0.16553125, -0.007035316, -0.34032172, -0.1932072, 0.18870308, -0.101380125, 0.3300221, -0.21519282, 0.0042353235, 0.49822518, -0.16969144, 0.1581237, -0.21353622, 0.0005103344, -0.22767626) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.078051224, 0.08948007, -0.38563907, 0.0045670965, -0.13175996, -0.052226778, 0.1964756, -0.05823438, 0.062152375, 0.16525307, 0.21219487, -0.09414398, -0.016611619, 0.11728401, 0.022144772, 0.021910444) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.04222957, 0.42243123, -0.22113082, -0.0015406744, -0.02578986, -0.06960389, 0.4596862, 0.20659602, 0.13879655, -0.10810521, -0.29713824, 0.2911566, -0.032900423, 0.034099776, 0.036650404, 0.0064380825) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.14972024, 0.23564263, 0.1693775, 0.30252844, -0.23393281, -0.35320315, 0.16986912, -0.35179746, 0.136966, 0.07397283, -0.0016438453, -0.7588768, 0.3558156, -0.07794065, 0.32146227, 0.28770065) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.03004691, -0.03632319, 0.12487854, 0.14021036, -0.09036974, 0.026282504, -0.10602385, 0.0797514, -0.18298438, 0.16718239, -0.0012917492, 0.2594176, 0.20035993, -0.3104403, 0.17357889, 0.14166272) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.1443591, -0.042903587, 0.16219425, 0.009694571, 0.11929616, -0.080768794, -0.3411811, 0.3593981, -0.029276403, 0.13009164, 0.18104321, 0.13689767, 0.122596145, 0.20096177, -0.03914054, 0.24443331) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.1535752, 0.10083576, 0.18017681, 0.06860083, 0.21120217, 0.032756533, 0.21496248, -0.35052907, -0.13684383, -0.046354897, 0.22429745, -0.035906877, -0.36060283, -0.29411358, 0.17715238, 0.10085532) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.2639655, 0.099960215, -0.10559419, -0.02737841, -0.11249358, 0.10038589, 0.0891355, 0.031678423, 0.05685372, 0.17038453, 0.010845342, -0.006822196, 0.07177671, 0.11297073, -0.15408362, 0.1486216) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.03970614, 0.065120004, 0.09840263, 0.054772533, -0.11348841, -0.06813952, 0.23037101, 0.37005532, -0.070705764, 0.07668128, -0.14638261, 0.29339552, -0.030305495, -0.030274646, -0.080551185, 0.17945334) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.10339814, -0.26912025, 0.15870579, 0.089587055, -0.0035321468, -0.17453511, 0.48130432, -0.22216323, -0.08511157, 0.25212565, -0.60419196, -0.63972026, -0.05345365, 0.16586785, -0.78374636, -0.5687383) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.056566387, 0.091242574, 0.09227305, -0.092345215, 0.102442935, 0.042302657, -0.013037007, 0.014917322, 0.1461881, 0.057322472, -0.012351711, -0.10888003, -0.21420081, -0.13288268, -0.113847405, -0.03502096) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.41994718, 0.17657095, 0.039167993, 0.5739919, 0.30931023, 0.15862715, -0.25106934, 0.4816951, 0.20524475, -0.06001892, -0.044672567, 0.37515262, -0.12754127, -0.39838105, -0.1500881, -0.56029725) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.6650548, -0.03515934, -0.22390345, 0.0713442, 0.2706202, -0.8165974, -0.46866298, -0.42831123, 0.03432299, 0.27206546, 0.5984607, -0.39808667, -0.5516981, -0.4986549, -0.17244917, -0.12493013) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.046807427, 0.1335813, 0.008581751, 0.11764944, -0.17755635, 0.08487266, 0.17535639, 0.019719698, -0.25059837, 0.45094904, 0.026579615, 0.8298599, -0.1136513, -0.1316188, 0.22895375, -0.19631204) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.053855766, -0.0015683963, 0.027458623, -0.16276483, 0.058705702, -0.114236996, -0.05922478, 0.03734819, -0.102701046, 0.24046661, -0.054114517, 0.08026473, -0.1291091, -0.21754484, -0.14191991, 0.021691065) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.00050016126, -0.14592107, -0.0070146546, -0.41480002, 0.017751718, 0.19561279, -0.24281815, 0.20747419, 0.13299564, -0.017315174, -0.0032852483, -0.2615022, 0.1417267, 0.19341198, -0.3006913, 0.082918845) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.09938891, -0.0569857, 0.07200405, 0.04283446, -0.03631778, -0.13799775, 0.00517839, -0.19610088, -0.098014124, -0.20625576, -0.08924047, 0.17591476, -0.22025956, -0.37299836, 0.16093071, 0.010860518) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
