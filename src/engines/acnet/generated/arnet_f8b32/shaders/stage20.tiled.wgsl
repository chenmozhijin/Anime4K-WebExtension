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

  var result: vec4f = vec4f(-0.18089603, -0.020843169, 0.2855005, -0.12507035);
      result += mat4x4<f32>(0.006715561, -0.06079357, 0.09472825, 0.2950811, 0.11791012, -0.023729188, 0.064684525, -0.15241826, -0.20224233, 0.2616426, -0.033551257, 0.04508503, 0.09502488, -0.00469143, -0.07645092, -0.11282313) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.27784988, -0.24199848, 0.0037169517, -0.16992517, 0.13391095, 0.4129975, 0.33674678, 0.2454191, -0.452742, 0.24522096, 0.023753421, 0.51474243, -0.1931919, -0.03677156, 0.02331882, -0.024811316) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.014995176, -0.039419316, -0.039554186, -0.122716226, 0.17596798, 0.17021993, 0.25427312, -0.10338447, 0.11956023, 0.35391343, 0.81573653, 0.08521472, -0.054616854, 0.22693683, 0.2670758, -0.0029847813) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.037068106, -0.23778628, -0.46821457, -0.04903665, 0.050148778, 0.113648176, -0.101130076, -0.13208328, -0.24292952, 0.26689515, -0.05541445, 0.32554013, 0.04020873, 0.39181542, 0.1757623, 0.4171426) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.06567154, 0.14361289, -0.5471668, 0.496025, 0.25100762, -0.24393691, -0.017381826, -0.2223845, -0.8381968, -0.62720805, 0.769165, 0.4629639, -0.50835264, -0.13306277, 0.14060977, -0.27674097) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.13664599, 0.01498007, 0.2318079, 0.12577736, 0.19068527, -0.4876068, -0.1333217, -0.17041358, -0.5530063, -0.18487325, -0.97241515, 0.17376843, -0.0464072, 0.061711263, -0.3168794, 0.038566157) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.07456722, 0.17493063, -0.098236784, 0.04321474, 0.10310844, 0.07397839, 0.057380844, -0.03103586, 0.00013891437, -0.26551628, -0.13437077, -0.13948579, -0.06622686, 0.16902427, -0.072284415, 0.04075341) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.0072980784, -0.08103252, -0.20706223, 0.31566858, 0.07325414, 0.28618518, 0.10017837, -0.06628908, -0.007896616, 0.31958586, -0.54703027, -0.24551861, 0.06847539, -0.111492425, 0.019592855, 0.04289004) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.099439554, 0.011519088, -0.09313347, -0.01109375, 0.044825744, 0.3192126, 0.5602149, -0.3784022, -0.002321939, 0.48528767, -0.08587192, -0.2235423, -0.119362995, -0.1635777, 0.066194385, -0.15746047) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.0559195, -0.36222568, 0.027535047, 0.48150975, -0.008062478, 0.00048621983, -0.041770007, 0.14346717, 0.056499362, 0.11971803, 0.027965989, 0.042248093, 0.07265392, -0.011760573, -0.12556104, -0.070005305) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.40580863, -0.010049403, 0.14224188, 0.08822584, 0.13974504, 0.072120875, 0.236871, -0.093832545, 0.16997777, 0.1436269, -0.07256641, -0.22704352, 0.23931785, 0.14935741, -0.37176374, 0.016533023) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.09249484, 0.4534649, 0.15627947, 0.16897908, 0.14946185, -0.38597772, 0.15510184, 0.055914197, 0.13375688, -0.04099545, 0.047778487, -0.081359416, 0.03059027, 0.009600544, -0.03357217, 0.21008222) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.021833885, -0.48812258, -0.29639143, -0.11295706, 0.06372449, 0.0354697, -0.093379214, 0.014371923, 0.054093033, 0.1600361, -0.019938033, 0.21711345, 0.14580803, 0.22670776, 0.039953537, 0.2864784) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.069013804, 0.02146015, 0.032632995, -0.10444661, 0.21846208, 0.44278622, -0.13710895, -0.016775459, -0.06820245, 0.1739011, -0.5225272, -0.31572196, 0.5358528, 0.12064051, -0.24909453, -0.20058307) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.28710818, 0.25166953, 0.5405219, -0.05494952, -0.1107388, 0.38777924, 0.60720146, -0.09989635, 0.1672349, -0.026098054, 0.17543559, 0.119017266, 0.013206505, -0.0075010955, -0.0029742727, 0.112222455) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.27307373, -0.23143108, -0.17380434, 0.054207023, -0.0031078875, 0.08123557, 0.028903127, -0.00069789856, 0.10896636, 0.012277787, -0.02452701, -0.21241653, -0.09158341, -0.2711933, 0.077401325, 0.042143192) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.49992517, -0.10252911, 0.025221571, 0.10446183, 0.06981583, 0.034467913, -0.23652387, 0.039106924, 0.064504296, 0.17111842, 0.16055806, 0.19948138, 0.0708971, -0.18340217, -0.31800336, 0.24672458) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.4003055, 0.18456164, -0.040073603, 0.015615795, 0.17139995, -0.017176038, -0.0029003415, 0.018992065, 0.062170487, 0.16111629, 0.146264, 0.09696629, -0.023791328, -0.071994, 0.060047723, -0.076556146) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
