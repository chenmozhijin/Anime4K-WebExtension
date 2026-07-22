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

  var result: vec4f = vec4f(0.06853767, -0.30175513, 0.36922926, -0.017524973);
      result += mat4x4<f32>(-0.13271676, -0.000263377, 0.039888814, 0.05144864, -0.01376628, 0.18863283, -0.29211307, 0.21466714, 0.10891703, 0.09626502, 0.3156821, 0.08924226, 0.04540079, -0.07211346, 0.07723804, -0.056006942) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.4064646, 0.13604519, -0.2683626, 0.041383613, 0.6199522, 0.30468142, -0.5162158, 0.7683911, 0.21527793, 0.25960928, 0.7377399, 0.027651422, -0.33972695, 0.03149767, 0.13069856, -0.069358684) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.0010210312, -0.10447619, -0.26673865, -0.100075066, 0.13200022, -0.100587755, 0.096911974, 0.23155823, 0.05385957, 0.1751491, 0.444903, -0.045237307, -0.06126451, -0.019405892, -0.03563098, -0.1477263) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.3040715, -0.21156625, -0.18503846, -0.14888948, -0.35497278, -0.20294401, -0.37303305, -0.19339666, 0.21932676, 0.49967742, 0.44358838, 0.13616155, -0.028866144, -0.21066126, -0.08743321, 0.16470867) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.2740626, 0.890209, -0.8894774, -0.20605488, -0.14179985, 0.068749025, -0.31377944, -0.17046347, 0.020768208, 0.18066213, 0.86020595, -0.58859885, 0.69519764, -0.718516, -0.53261155, 0.87460804) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.042256255, -0.05336397, -0.43322822, 0.2347681, -0.022816654, 0.042484295, -0.12022551, 0.026749503, 0.0013556493, -0.1260713, 0.34995976, -0.25787613, 0.011267946, 0.05089727, -0.047276687, -0.009633363) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.050208032, -0.043490067, 0.08634242, 0.06869766, -0.10295693, 0.032736447, -0.09610036, -0.12960742, 0.17830078, 0.26203576, 0.3089978, 0.14063744, -0.06779335, 0.15530895, -0.11528588, 0.20170641) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.12597908, 0.037622586, -0.0106392335, 0.16983575, -0.038990892, 0.14645773, -0.05886189, -0.01874409, 0.005477999, -0.12208635, 0.31314158, 0.14594288, 0.30594778, -0.38226464, -0.14572762, 0.03781752) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.0045919116, -0.012894619, 0.026773348, -0.09759914, -0.055424083, 0.0398252, -0.043726668, -0.0753758, 0.118403144, -0.011136027, 0.41347015, 0.17272572, 0.0897168, 0.0049345717, 0.108219005, -0.12619318) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.17054272, 0.01237525, 0.149519, 0.21332416, -0.029021392, 0.0047716307, 0.11531668, -0.085490674, -0.028693184, 0.014669185, 0.10430666, -0.1529959, -0.012660971, 0.13617738, 0.17527585, 0.23638466) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.95934117, -0.67252254, -0.10285128, 0.5659165, -0.0066793035, 0.23113953, -0.14444868, 0.013956616, 0.13119696, -0.03252704, 0.08584267, -0.16469324, 0.5816072, -0.04165956, 0.01136132, 0.08570458) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.08828437, 0.13093166, 0.077011034, 0.28457868, -0.26985002, -0.2560689, -0.24791731, -0.053471524, -0.022486808, -0.09111445, 0.027914273, -0.1257072, -0.17821944, -0.09174932, 0.11120905, -0.07561817) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.02076644, -0.089009136, 0.10787323, -0.12236464, -0.28003865, -0.19304466, -0.16602597, -0.09026777, -0.055312343, 0.0931435, 0.2797168, -0.043486416, -0.1303198, -0.05049738, 0.6159957, -0.113789216) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.1824834, 0.24832648, -0.4590539, 0.42031845, -0.3978981, 0.37334704, -0.56498134, 0.26744792, -0.65447366, 0.71156925, 0.29560548, 0.247261, 0.33247778, 0.5808309, 0.15620221, -1.1370089) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.17724723, 0.20704664, -0.054025035, -0.03340204, 0.096324764, -0.046263784, -0.14910232, 0.06663996, 0.2130246, 0.12404989, 0.075870074, 0.27529922, 0.11777931, -0.13237607, -0.027634464, 0.13299844) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.0013201386, -0.018381221, 0.13581626, -0.14527352, -0.019575985, 0.002877577, 0.09156025, 0.12426591, -0.07469663, 0.016035262, -0.08386952, 0.05546082, 0.1901489, 0.1709699, 0.11728164, 0.37391806) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.030826425, 0.06397511, 0.06633265, 0.066612355, -0.05641037, 0.13661665, 0.13973495, 0.5741697, -0.16660666, -0.32243994, -0.083923675, -0.6531366, 0.13428122, 0.0011002935, 0.23511347, 0.03490403) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.028392209, 0.029621381, 0.041655544, -0.08622604, -0.00051693217, 0.12255611, 0.05100926, -0.14193809, 0.010589838, 0.009550104, -0.0011826792, 0.1893367, -0.0375758, -0.17579195, 0.05179474, -0.07242611) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
