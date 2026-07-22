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

  var result: vec4f = vec4f(0.14382169, 0.0124765895, -0.17477491, -0.22128156);
      result += mat4x4<f32>(0.08974067, 0.06819468, 0.20492293, -0.16003315, -0.007301914, 0.04691034, -0.17082871, 0.08788456, 0.1708311, -0.031161439, -0.2165928, 0.14773877, -0.08403607, -0.059552725, -0.17086072, -0.31492114) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.1387206, -0.22228114, 0.07434672, -0.5055586, -0.110285446, -0.12789431, -0.15351719, 0.19894286, 0.19878595, -0.024298813, -0.05598544, 0.09781959, -0.4881422, -0.12771437, -0.34615588, -0.2562045) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.0065230997, -0.048792705, 0.017006414, -0.17278051, 0.4640985, 0.01359766, -0.007538973, -0.11860656, 0.048449617, -0.013225663, -0.049032822, 0.023965802, 0.09342821, 0.14916815, -0.08027083, 0.10138883) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.012991391, 0.12175272, 0.19829392, -0.07415491, 0.083817, -0.023749769, 0.028014608, 0.09777015, 0.18002228, -0.3774088, -0.35939616, 0.15986544, 0.1454163, -0.040520098, 0.30041876, -0.13956414) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.25837025, -0.1417786, 0.14462405, 0.19305457, 0.166236, -0.03739613, -0.13939795, -0.50702435, -0.19689853, -0.28643742, -0.1306156, -0.07707234, 0.6896099, 0.01672377, 0.11920219, 0.11195794) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.26466036, 0.14729124, 0.1815891, 0.10448532, 0.0323876, -0.019913407, 0.30874065, 0.30162472, -0.056616746, 0.022362277, -0.36606443, 0.07170714, -0.48343578, 0.08512637, 0.55601645, 0.10765444) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.054383263, -0.15892898, -0.08685518, 0.72173893, -0.1447775, 0.09961781, 0.18749453, -0.09687145, 0.0185521, -0.2762651, -0.26158196, 0.17277421, 0.10165107, -0.027951432, -0.015176253, -0.0052076345) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.4595481, 0.28780264, 0.54669535, 0.85588175, -0.44600195, 0.04860887, 0.17765822, 0.14201841, -0.19568552, -0.40094513, -0.7569682, 0.35532326, 0.1318865, -0.033178236, 0.12956367, -0.22265133) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.07965836, 0.0831447, 0.036898527, 0.009438429, -0.12555392, -0.045754537, -0.49521026, -0.016510546, -0.08088175, 0.0029802865, -0.22475429, 0.2123316, 0.12978145, 0.03448904, -0.08598345, -0.23664476) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.42310953, 0.009759581, 0.053960484, 0.33378366, -0.010357811, 0.031293318, 0.011306624, -0.11814793, 0.110569164, -0.045979355, -0.021472529, 0.11193484, 0.08547941, -0.08381981, -0.07134243, -0.05437296) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.4481675, 0.30775997, 0.49617878, -0.14841162, -0.023746878, 0.115327865, -0.19075783, -0.036194015, -0.04298427, 0.02953725, 0.12027175, 0.14240469, -0.046785604, 0.020259272, 0.14059347, 0.32450774) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.044970144, 0.10762502, -0.056895364, 0.10464049, -0.053007614, -0.16232745, 0.1731496, -0.13663125, -0.16192318, 0.1720247, 0.052480124, 0.19451687, 0.24913354, 0.17603448, 0.15934338, 0.6038004) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.27659297, -0.10402966, -0.24457309, 0.26562572, -0.06383403, -0.17526717, -0.16759619, 0.18570906, -0.08412308, 0.2077897, -0.12090444, -0.011444157, 0.067175284, 0.09280512, -0.33398592, 0.029940462) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.0105437795, -0.209711, -0.34271136, -0.18448327, -0.021844096, -0.18631075, 0.32414076, 0.0013256173, -0.27248582, 0.128103, 0.14524077, 0.18834347, -0.40524223, 0.20693941, -0.0054114307, -0.59612507) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.30506927, 0.07623101, 0.3050448, 0.15472879, 0.13675813, 0.07355373, -0.04499242, -0.060158227, 0.096306875, 0.1711523, -0.16471103, 0.15394315, -0.2927597, -0.121063694, 0.031042103, -0.059506577) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.08168052, -0.07826535, 0.05480163, 0.042541932, -0.04194836, 0.0075176926, -0.23257768, -0.04843618, 0.05653899, 0.16671602, 0.07422872, 0.027160093, -0.12800269, 0.015398112, -0.02078073, 0.22013947) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.034401115, -0.20520847, 0.28229105, 0.31166384, -0.69063324, 0.11964377, 0.98825943, 0.22218294, -0.30533966, 0.19639367, 0.03200651, 0.17341092, -0.14054422, 0.1104671, -0.053512648, -0.24110037) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.01475935, 0.2267233, 0.34288785, -0.05367597, 0.11295031, -0.22002469, -0.46044898, -0.08028184, -0.041977026, 0.08121215, -0.05388389, -0.104003854, 0.04565917, 0.047571097, -0.18263096, -0.09219702) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
