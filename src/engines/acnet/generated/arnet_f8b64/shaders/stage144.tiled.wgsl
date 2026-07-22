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

  var result: vec4f = vec4f(-0.05514695, -0.03166926, 0.1512198, -0.08528394);
      result += mat4x4<f32>(-0.04331197, -0.029486507, -0.2186686, 0.023262557, 0.049712278, 0.05940994, -0.044871252, -0.058838896, -0.05058901, 0.06980713, 0.01210471, 0.16764699, -0.25026911, -0.07570005, -0.16384943, -0.3639463) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.015188599, -0.047604777, 0.17083287, -0.11044954, 0.06003974, -0.14967369, -0.18420166, 0.115805835, -0.15660235, 0.099106364, -0.44818753, 0.24740523, -0.3980154, -0.0041739396, -0.10037365, -0.13453029) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.3118562, -0.30884942, 0.07711908, -0.45045725, 0.09234176, -0.11978951, -0.12723126, -0.068774916, 0.17030667, -0.0818767, 0.0653689, 0.30549175, 0.133955, -0.124681525, -0.0071007186, -0.012789401) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.30916458, 0.18263727, 0.37828827, 0.22725624, 0.14655927, -0.061961796, 0.04923469, 0.21257357, 0.11724531, 0.036421023, 0.10948858, 0.19786246, -0.018457294, 0.1256968, 0.32224795, -0.109137215) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.6322286, 0.055278968, -0.17165698, 0.12179286, 0.16110237, -0.01620307, -0.2671963, -0.14969863, -0.36534926, 0.06935359, -0.20612457, 0.41695654, -0.10248743, -0.12702394, -0.3003674, -0.14619923) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.36181015, -0.150839, -0.3931934, 0.03375862, -0.2445883, -0.13124803, -0.37512702, 0.06635699, 0.09891888, -0.0024013757, -0.17076303, -0.037611637, 0.23612224, -0.27046204, 0.13868378, -0.006585207) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.042479232, -0.038482144, -0.12699535, 0.0031145744, -0.10051728, -0.032159507, -0.17498045, 0.10573972, 0.44109955, -0.13303578, -0.5649892, 0.12533255, 0.12108212, -0.16419786, 0.10115199, -0.13124125) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.043769427, -0.13594358, 0.00436943, -0.008839669, 0.13703962, 0.12073629, -0.025101172, -0.039441682, 0.16668692, -0.1624396, -0.20183824, 0.36752403, 0.1423316, 0.03707778, 0.36154678, -0.02688388) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.009756408, -0.35787997, -0.121129975, 0.19154444, 0.0062052486, 0.0028635475, -0.06463489, 0.098519266, 0.088748924, 0.14764999, 0.3549009, 0.16694687, 0.19943558, -0.032789934, 0.3401806, -0.07452441) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.06340615, -0.21389692, -0.20903738, -0.15732983, -0.108421944, 0.010791002, 0.09094448, -0.021185325, -0.40635666, -0.051641792, -0.31712508, -0.3008819, -0.10693078, -0.11207601, -0.44509697, -0.09826856) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.1745687, -0.14817877, -0.026594434, 0.07927336, -0.49126112, 0.07166134, -0.09742034, -0.09906804, -0.044857748, -0.29270017, 0.05035729, 0.08296611, -0.12731539, 0.035636544, -0.33724707, -0.11437891) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.11515666, 0.17793556, 0.036301974, -0.053794283, 0.06575296, -0.016525984, 0.33649725, 0.15590613, 0.050393265, 0.013668732, 0.0855506, -0.044504236, -0.022378573, 0.031728745, -0.13169718, -0.12790424) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.051782094, 0.005306907, -0.32386112, 0.047393512, -0.16241875, 0.046881102, 0.18003033, -0.10027588, 0.052443776, -0.1149928, 0.38191786, 0.23843296, -0.2567407, 0.09851339, -0.39913306, -0.15116805) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.12728311, -0.14959067, 0.3626577, -0.47984183, -0.5353888, 0.33847305, 0.3786395, 0.07985842, 0.40996522, -0.22516112, 0.15194315, 0.2065018, -0.12652494, -0.056854684, -0.108964086, 0.12611163) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.17979904, -0.054948393, -0.064291, -0.5171421, 0.24034055, 0.099097885, 0.18895572, -0.08811738, -0.1563978, -0.14947474, -0.44045836, 0.1124351, 0.010114581, 0.11126358, -0.05543969, 0.055413336) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.0007160909, -0.0733566, -0.3502813, 0.11969486, 0.17311896, -0.041255873, 0.13320625, 0.12666497, -0.03923993, 0.19687158, 0.32615444, 0.050505556, -0.16632035, 0.10871024, -0.0413173, 0.017279146) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.22445576, -0.12256085, 0.12022823, 0.038932703, -0.1400647, 0.18944447, 0.2304515, -0.02442422, -0.012083626, 0.06329107, 0.11473329, -0.06629918, -0.02793279, 0.08686747, 0.0005801167, 0.045238) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.12632732, -0.13803795, -0.108558476, 0.022318246, -0.1965167, 0.017544864, -0.088423416, 0.09317562, 0.028938444, -0.122998185, -0.2135445, -0.09112584, -0.01760706, -0.15487643, 0.014667137, 0.2944644) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
