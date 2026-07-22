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

  var result: vec4f = vec4f(-0.06181073, 0.004526574, -0.025751652, 0.1732003);
      result += mat4x4<f32>(-0.011234779, -0.01971179, -0.031260867, 0.0056617446, -0.085117996, -0.06502848, -0.24532667, -0.05175892, 0.1581427, 0.060066763, 0.3951669, -0.027543597, 0.08814488, 0.06771086, 0.2547044, 0.018035563) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.025630852, -0.061807804, -0.102043994, 0.008294627, -0.14006183, -0.11672155, -0.41746894, -0.054994266, 0.099842, -0.08243896, 0.18865077, -0.1111633, 0.13623577, 0.12246809, 0.36495987, 0.0062033255) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.0143711725, -0.029757386, -0.07400581, -0.009712412, -0.09514475, -0.08466671, -0.2462786, -0.03979911, 0.026954684, -0.090258785, 0.008600269, -0.068771705, 0.09672266, 0.057056524, 0.2232395, 0.022756571) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.095406085, -0.10702526, -0.2738421, -0.034462478, -0.105275966, -0.08858976, -0.31446993, -0.120589785, 0.07976484, -0.08083389, 0.19115433, 0.035761196, 0.06931535, 0.08828367, 0.30156133, 0.020193659) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.11195967, -0.13023527, -0.38926268, -0.11014621, -0.12647848, -0.15864056, -0.39413437, -0.04717304, 0.021263903, -0.07529085, 0.17783195, -0.13275659, 0.15485865, 0.1545749, 0.50470996, 0.05321557) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.06581798, -0.097998224, -0.22301082, -0.04814116, -0.11248316, -0.11313096, -0.32989532, -0.073240824, -0.050649047, 0.06838034, 0.36221212, 0.0003636564, 0.11537512, 0.09406638, 0.3454364, 0.048069935) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.081168815, -0.05330362, -0.2602, -0.076908864, -0.019923229, -0.04055455, -0.09999271, -0.034559604, 0.15154412, 0.021034714, 0.31099105, 0.052746814, 0.0070510563, 0.087185614, 0.16508754, 0.003675705) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.09414345, -0.09208332, -0.33825713, -0.06113392, -0.041471113, -0.067931086, -0.22678019, -0.09455074, 0.091193974, -0.13835669, 0.04350714, 0.08701587, 0.0477537, 0.10549551, 0.29319453, 0.078476086) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.08711647, -0.06499255, -0.23947415, -0.07212573, -0.020522533, -0.049555447, -0.15826276, -0.075714506, 0.027642434, -0.04027988, 0.05020001, -0.061190598, 0.051152498, 0.065466896, 0.19531886, 0.025587726) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.10725874, -0.16151893, -0.2271309, -0.077325635, 0.08307258, 0.072593525, 0.25453502, 0.0042407736, -0.07280691, 0.28228903, 0.002447787, -0.32865795, -0.058501724, -0.048984896, -0.12566563, -0.0014292405) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.09250828, 0.11691229, 0.3686234, -0.3743681, 0.108540855, 0.06866433, 0.27709052, 0.0129619725, -0.261103, -0.05951175, -0.25771424, -0.101525076, -0.033847857, 0.004010237, -0.19877277, -0.060315453) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.13515599, 0.11824062, 0.55140626, -0.07945551, 0.014583129, 0.036802255, 0.11972487, 0.00057457184, -0.071980774, 0.10558181, -0.089308344, 0.3727335, -0.051281847, -0.043508, -0.16046883, -0.04987524) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.042000063, 0.21100843, -0.07060723, -0.27653795, 0.17843655, 0.14165486, 0.51937735, 0.08442122, 0.21968374, -0.32820612, -0.1347806, 0.35009938, -0.104204975, -0.15116651, -0.35378015, -0.08704607) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.060597252, -0.1546038, 0.40485254, 0.2981015, 0.21829337, 0.21756263, 0.68269193, 0.047961615, 0.04489207, -0.14150338, 0.20536946, -0.11361702, -0.10954678, -0.20761903, -0.35707414, 0.06774523) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.20787089, 0.013353815, 0.23534767, 0.052141245, 0.09776987, 0.09589176, 0.3568799, 0.03963131, 0.17793596, -0.08044849, 0.18170145, -0.12931009, -0.12839995, -0.13905089, -0.3982022, -0.0775526) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.24322653, -0.20586498, -0.6345539, -0.1818862, 0.10340245, 0.14056234, 0.41147774, 0.076988816, -0.24865314, -0.19346884, 0.3585596, 0.03235541, -0.06493744, -0.054265574, -0.20164905, -0.09379412) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.26167804, -0.10159929, 0.06923068, 0.12260205, 0.18965156, 0.19618116, 0.6168301, 0.12549037, -0.21705583, 0.04194002, -0.19819367, 0.029166054, -0.06541729, -0.13355245, -0.3521007, -0.09854498) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.099692576, -0.045902, -0.13458584, -0.17593142, 0.101796106, 0.09230031, 0.30338103, 0.031233646, 0.01854702, 0.20975082, 0.10071009, -0.06675395, -0.0593005, -0.09056702, -0.16623214, -0.035192665) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
