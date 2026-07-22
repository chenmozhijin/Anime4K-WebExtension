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

  var result: vec4f = vec4f(0.44002578, -0.2567937, 0.385074, -0.05560447);
      result += mat4x4<f32>(-0.13505489, 0.3719974, -0.16920072, -0.025772003, 0.020030571, 0.111721516, -0.26242387, -0.26238692, -0.16934648, 0.37206718, 0.3077587, -0.07879403, -0.031861532, -0.06138229, 0.08524384, -0.1455939) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.3330023, 0.25852874, 0.2697541, 0.07146553, 0.05593183, 0.06982248, -0.10681429, 0.035367545, -0.30170873, 0.31603977, 0.294721, 0.18307926, 0.27946225, 0.2289244, 0.029750863, -0.37932986) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.32274342, 0.37612236, 0.19187224, 0.13614659, -0.013625822, 0.10630194, -0.13120642, -0.033326887, 0.38703117, -0.69977134, -0.08687484, -0.03769972, 0.0377138, 0.17686817, -0.0671784, -0.16957335) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.0013813927, 0.04445714, -0.28258118, -0.15266581, 0.11840871, 0.10346217, 0.054557946, -0.06631615, -0.26597515, 0.18980911, 0.06862705, 0.24249709, -0.3070167, -0.03813211, 0.59548616, 0.5627331) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.13211606, 0.2747161, 0.16950144, 0.023164868, -0.11280506, -0.2665712, -0.2800945, -0.306157, -0.22042744, 0.2288847, -0.2039102, -0.10647393, 0.07450303, -0.061878067, 0.15341061, -0.20237839) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.07511899, 0.029939925, -0.029788472, 0.06145733, -0.17163932, 0.28267926, 0.0071701403, 0.0015580668, 0.35219747, -0.27730542, -0.040308554, -0.104311734, -0.13751635, -0.08000066, 0.17107823, 0.034128126) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.24696817, -0.16793191, -0.26060602, -0.0017968426, -0.06747516, 0.12539986, -0.15974244, -0.13969016, -0.024270305, 0.17525795, -0.05261819, -0.07450947, -0.039129104, 0.124220856, 0.023594327, 0.16178918) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.17679983, -0.6400682, 0.204671, -0.07750363, -0.13692507, 0.40658128, 0.085212775, 0.11361767, 0.124556385, 0.15386763, -0.24427243, -0.11435526, -0.058160763, -0.18325643, 0.15407422, -0.06859248) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.15542138, -0.44366658, 0.040081814, 0.11856154, -0.10835145, 0.15620343, -0.02833875, 0.09033714, 0.14137611, -0.35292882, -0.11503144, -0.07486483, 0.052682094, 0.04560188, -0.03368146, 0.018064905) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.16867939, 0.111001894, 0.2278436, 0.19385129, -0.06187614, 0.07671636, 0.038849182, -0.05295365, 0.066000074, -0.0003568928, -0.00025491143, -0.13172165, -0.0057892036, -0.31882414, -0.026574638, -0.019018892) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.015520413, -0.03411085, -0.031483807, 0.24648675, 0.0022901203, -0.1923538, 0.03483152, -0.23870386, -0.0926256, 0.18638004, -0.008201605, 0.029801164, 0.24772812, 0.33132485, -0.25758076, 1.2850401) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.05214025, 0.09206697, 0.10755136, -0.01793656, -0.042047646, 0.20017698, -0.024632977, 0.020691996, -0.11668674, -0.04356624, -0.022732463, 0.15423323, 0.6769663, 0.16023077, 0.25351372, -0.7395223) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.06866557, 0.03209552, -0.08906007, 0.23992833, 0.062978625, -0.007984145, 0.065117314, 0.037936315, 0.2274147, 0.009953121, -0.034786552, 0.36531335, 0.013461863, 0.082466215, -0.029855069, 0.25464717) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.066161074, 0.47095478, -0.043259174, -0.0018907578, -0.33168846, 0.8644075, 0.27669564, -0.36319295, -0.7760986, -0.8989259, -0.34869862, 0.5520179, -0.26981977, -0.5185247, 0.37045392, 0.28919548) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.33200315, -0.30131105, 0.12968375, -0.24990517, -0.078043625, -0.3743542, -0.22164729, 0.16174836, -0.11127821, 0.6446442, -0.14134236, -0.0011524991, -0.067812264, -0.5611248, -0.048557177, -0.05132206) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.33206207, -0.14814794, -0.14052436, -0.2008689, -0.04742739, -0.0018463058, -0.019028801, 0.039750032, 0.026350066, -0.114235766, 0.13042721, -0.0070748525, 0.015133268, 0.07087278, 0.038126193, 0.105567776) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.37687087, 0.15820834, -0.26295683, -0.1267953, -0.33695033, -0.4331578, 0.016435893, -0.33258715, 0.092402525, 0.08341196, -0.098304436, -0.052754804, -0.10638263, -0.0071301563, -0.07477877, -0.03238115) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.15622829, -0.094055586, -0.11878618, -0.11939595, 0.23596126, -0.09292685, 0.06101298, -0.026520971, -0.08274877, -0.030045822, -0.00674056, -0.05051811, 0.12779109, -0.15023623, -0.10581997, -0.013646183) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
