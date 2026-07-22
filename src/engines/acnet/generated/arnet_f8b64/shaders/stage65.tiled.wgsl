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

  var result: vec4f = vec4f(0.11601308, 0.06511497, 0.21898839, -0.067304246);
      result += mat4x4<f32>(-0.071007594, -0.27110693, 0.015187791, -0.010647503, -0.037223753, -0.32188225, -0.07024525, -0.0076191206, -0.026626738, -0.22306341, 0.0922164, 0.16288482, 0.15826315, 0.0025145186, -0.124534905, 0.070324175) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.0068770945, -0.3976059, 0.132555, 0.078780785, 0.20331644, -0.29125214, 0.15415384, -0.18154787, 0.1952727, -0.2166675, 0.28316903, -0.066823676, -0.15060677, 0.078687616, 0.20947365, 0.32631487) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.028335927, -0.12836568, -0.00073157455, 0.13759796, -0.13525282, -0.13661306, 0.11526089, -0.26936933, 0.0021597648, -0.40037492, -0.016230186, 0.0965337, -0.067341946, 0.07004522, -0.09396953, 0.002100435) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.21942158, -0.043797746, 0.16641141, 0.2789545, -0.1430739, 0.046040587, -0.122688055, 0.31489417, -0.18471968, -0.38041517, 0.034975626, -0.19034886, -0.015729632, 0.29694995, -0.14077286, 0.020038364) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.34727204, -0.41376215, -0.04221296, -0.04308893, -0.32767463, -0.069453895, -0.24089052, 0.3207539, 0.04785785, 0.28475726, -0.097508796, -0.50154704, -0.1713988, 0.68505436, 0.10826719, 0.57621056) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.113642775, -0.2155669, -0.022966983, 0.044067454, -0.23912096, -0.055181116, -0.25588605, 0.15132101, 0.09399217, -0.14685482, 0.018345883, 0.1738648, -0.02871256, 0.10522777, -0.09367411, -0.06913956) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.003815687, -0.21249405, -0.13905834, -0.09465904, -0.07119965, -0.098115474, 0.06789762, 0.4044646, 0.02178282, -0.25153586, -0.12880398, 0.14807943, 0.07574754, -0.012551075, 0.10200625, -0.3373204) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.13022472, -0.35038206, -0.09766843, -0.059510503, -0.03351018, 0.20923442, 0.06203067, 0.55644846, 0.004906565, -0.02746862, -0.008351062, -0.16505416, -0.06983748, -0.07011922, -0.32290974, -0.13487111) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.025958337, -0.10469701, -0.01566101, -0.004214377, -0.02876939, 0.05491141, 0.056603655, 0.3398333, 0.15567572, -0.102130465, -0.049019, -0.06732125, -0.1209951, 0.049700018, -0.06750881, -0.087708004) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.20187965, 0.090639725, -0.13314305, -0.19034515, -0.016506735, -0.16947298, 0.3719129, -0.03893744, 0.044601202, 0.17690615, -0.10948775, 0.043837465, -0.036750574, -0.20505911, 0.01904373, 0.010296599) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.046233002, 0.09022512, -0.39909768, -0.27099472, 0.029381197, 0.26164833, 0.1643423, 0.065792315, -0.17265843, -0.06916934, 0.07538997, 0.07000469, 0.055088773, -0.14990376, -0.18290626, 0.010490486) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.03988756, 0.0075869192, 0.088422336, -0.10352239, -0.01718082, -0.12621741, 0.052919526, -0.06984742, 0.032678403, -0.085510895, 0.20178227, 0.27214175, 0.020998714, -0.1528796, -0.19331191, -0.041461576) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.09111462, 0.29205975, 0.044164043, -0.24318792, 0.42767802, -0.21998732, -0.28454423, 0.1783908, 0.09500441, 0.16688626, 0.22473595, 0.27417946, -0.1600266, -0.40675735, -0.30352306, 0.1561751) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.018480437, 0.019550975, 0.13477874, -0.053868774, -0.024302604, -0.48792952, -0.052003343, 0.28319016, -0.05779992, 0.09038246, -0.5798544, -0.42803836, 0.02905367, -0.40896535, 0.24664114, 0.14037141) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.1874375, 0.06610243, 0.092878215, 0.2738215, 0.06144333, -0.35575813, 0.19740552, -0.13593455, 0.040623743, 0.022177884, -0.39301014, 0.22680119, 0.007842804, 0.15639232, 0.08611468, -0.14451788) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.0009007455, -0.109081365, -0.0076227826, 0.14461438, -0.1167121, -0.2622922, -0.17555754, 0.027314065, -0.12546721, -0.06320309, -2.193534e-05, 0.2687114, 0.02961013, 0.060752638, -0.3339909, 0.17699195) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.17064542, 0.11344323, -0.13257867, 0.28844172, 0.17406328, 0.23898338, 0.28726757, -0.345051, -0.38948315, -0.57314235, -0.02123404, 0.13675557, 0.13569452, 0.40074265, -0.25243044, -0.38525486) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.18312506, 0.10507393, -0.089799896, 0.1694733, -0.09506723, -0.1438194, 0.077256106, -0.050792713, 0.021290999, -0.08257889, 0.10803611, -0.13070087, 0.0039095455, 0.09712547, -0.07938689, 0.083800755) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
