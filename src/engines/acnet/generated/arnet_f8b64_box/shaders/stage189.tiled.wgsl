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

  var result: vec4f = vec4f(0.17693926, 0.110410415, -0.21931192, 0.2377239);
      result += mat4x4<f32>(0.4147912, 0.010463239, -0.14576162, 0.2510574, -0.0005197669, 0.10831025, -0.12262299, -0.010828231, 0.12768075, 0.072201096, 0.055240743, -0.068552874, -0.17183356, 0.027949516, -0.03778409, 0.040934894) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.5489155, -0.12094153, 0.16798262, 0.08897182, -0.11990572, -0.056944575, 0.06912305, -0.0047140177, 0.20099287, -0.13801166, 0.11611753, -0.0056516184, -0.21291646, -0.36222982, 0.06898045, 0.21738479) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.00689492, -0.15584947, -0.041804325, 0.14660814, 0.042506337, -0.05769834, 0.003656379, 0.11460557, 0.099864855, -0.25467157, 0.115239054, 0.007580574, -0.06558107, 0.023136973, -0.09683532, 0.111481726) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.5688028, 0.6683535, -0.23169291, 0.2412479, -0.13755083, -0.016881362, 0.15242605, -0.052848298, -0.24637856, 0.14869316, -0.14011814, -0.015189471, 0.07953603, -0.0098699415, 0.09201993, -0.08408583) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.27236426, -0.45256573, 0.74835, 0.20072642, -0.6650768, -0.5794857, 0.37242925, -0.035840172, 0.011675231, -0.3963904, -0.040292602, 0.30563438, 0.49439824, -0.81530166, 0.14602025, -0.25975248) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.12602222, 0.3730268, -0.33845434, -0.11673607, 0.018496035, -0.12064375, 0.15808482, -0.13256614, 0.021475006, 0.08090007, 0.010787969, -0.021076296, 0.13923575, 0.021222983, -0.027145362, -0.053474464) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.18140778, 0.49760774, -0.115550235, 0.36178, -0.1529049, -0.031344157, -0.049151607, -0.14131248, -0.44496387, 0.4011545, 0.2196242, -0.2021055, 8.377834e-05, -0.071854286, 0.07181511, -0.04114349) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.003231786, -0.16170762, 0.3541428, 0.5470599, -0.23405357, -0.32063743, -0.08710579, -0.10267832, -0.089195, 0.28080305, -0.08876763, -0.13658507, 0.13874382, 0.14442135, 0.37674665, -0.22239076) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.019695904, -0.03354687, -0.17345698, 0.35259154, 0.063300155, 0.035358828, 0.00547828, -0.056216672, 0.049808078, -0.13349123, 0.12928183, -0.06761545, 0.002918065, 0.009259446, 0.1480382, -0.123267725) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.05496123, -0.13727462, -0.05841029, 0.07929055, -0.045226093, 0.36279738, -0.040769715, -0.25959066, 0.16423543, 0.0011169945, 0.060550492, -0.003529931, 0.02962099, 0.08153052, -0.16371271, 0.05950715) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.018572217, -0.14851211, -0.031536028, -0.1310232, 0.026337378, -0.054041594, -0.04024933, -0.2859333, -0.029328082, -0.010369338, 0.027800508, -0.11827243, 0.19506736, 0.08705196, -0.16636452, -0.13107516) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.45270154, -0.032826044, -0.0043471353, 0.023857618, -0.13537143, 0.16867414, 0.20163484, -0.26519272, -0.056057476, 0.13616933, 0.12422424, -0.21365027, -0.06962404, -0.15799715, 0.0781748, -0.09184153) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.12443855, -0.025177442, -0.14982262, 0.13907446, 0.04400455, 0.15381442, 0.17934154, -0.2709891, -0.08251216, -0.11594033, 0.08519576, 0.16430849, 0.041322324, -0.18770024, 0.012116968, 0.003394493) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.29680112, 0.46160468, 0.17348632, -0.277008, 0.37491328, -0.5189982, 0.36142883, 1.0364133, 0.11919235, 0.33782318, -0.55585605, -0.22710884, -0.09011733, -0.30583134, 0.121884525, 0.083229735) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.036173344, 0.34579512, 0.041121088, 0.12955236, -0.0028910618, -0.090217695, 0.039232157, -0.06816003, -0.07882226, -0.019982886, 0.0059062457, 0.05572974, 0.09605336, -0.20748714, 0.4098325, -0.26861832) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.015497906, -0.15048124, 0.04599178, 0.08564225, 0.1253627, 0.024427067, 0.051834475, -0.13323033, 0.24027112, -0.025013344, 0.04982705, 0.11257636, 0.09696555, -0.011467921, -0.072915345, 0.06914112) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.17660375, 0.006465343, 0.10181041, 0.19681092, 0.1505273, 0.12886477, 0.03696075, -0.09886479, -0.07401589, 0.07198162, -0.06600081, 0.25138795, -0.11133767, 0.11054095, 0.06511263, 0.2704177) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.31638756, -0.09674468, 0.068541385, -0.07400686, 0.13718428, 0.08597239, 0.075725585, -0.2627053, -0.0040805894, 0.022841163, 0.1028089, -0.15634952, 0.12570933, -0.089755066, 0.28825897, -0.13005795) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
