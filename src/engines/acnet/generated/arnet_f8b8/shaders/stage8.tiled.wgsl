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

  var result: vec4f = vec4f(-0.11743038, -0.16231002, 0.09467287, 0.22727534);
      result += mat4x4<f32>(-0.51548827, 0.15808548, -0.13571733, -0.14273223, -0.15057826, 0.030074593, 0.068493836, -0.12844294, 0.18713784, -0.016000101, -0.09715594, 0.0055838507, -0.16399951, 0.16539454, -0.13824981, -0.10167678) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.13697715, 0.26219594, -0.21650817, -0.2165934, -0.015406543, 0.13315487, -0.0058171605, -0.12718087, 0.27039266, 0.1725975, -0.06647851, -0.08497834, 0.014193257, -0.25275543, -0.13867815, 0.11157574) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.17512031, -0.031932354, 0.09907872, 0.012270169, -0.08726568, -0.023330402, -0.06266416, 0.057744034, 0.06678231, -0.0047940016, -0.043570846, 0.07146166, -0.0736774, 0.037179712, 0.016628314, 0.0010944232) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.009598625, -0.5314439, 0.44985726, 0.0022008943, 0.06517828, -0.10094927, 0.32011816, 0.23916851, 0.14076614, 0.21300304, -0.010937648, -0.080391854, -0.16850063, 0.10303366, -0.045720827, -0.040261723) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.5002904, -0.21563224, 0.02404452, -0.20911911, -0.19017076, -0.1477176, -0.46054003, 0.46265918, 0.43199173, 0.5974608, -0.34539118, -0.3312841, -0.5938919, -0.15260786, -0.108566456, 0.20635751) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.11939628, -0.15311272, 0.09272302, 0.06710506, -0.228897, -0.00641993, -0.03652953, -0.042495403, 0.080015264, -0.09927188, -0.09529955, 0.10129391, -0.009078054, -0.020145357, -0.07288933, 0.0039098705) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.23070931, 0.018655553, -0.39131016, 0.030764543, 0.2004993, -0.12783334, -0.050624203, -0.041625377, 0.55393255, 0.4023199, -0.30161053, -0.12797196, -0.039660085, -0.098703876, -0.13656409, 0.112380184) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.07816313, 0.10847156, -0.007891233, -0.24849588, 0.08360888, 0.019200271, -0.36332434, -0.099814415, 0.43942454, 0.3943624, -0.21466185, -0.18517245, 0.09900762, -0.037406493, -0.18656285, 0.14789587) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.065378375, 0.07550733, -0.04080613, -0.079689436, -0.19499788, -0.24939217, 0.01950661, 0.11034688, 0.06214707, 0.031414058, -0.13365307, 0.032257605, 0.0112530645, 0.00730777, -0.08202546, 0.017572647) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.14070207, -0.01666193, 0.034629535, 0.047863863, -0.1215331, 0.1534163, 0.10311375, -0.11320891, 0.41778356, -0.08176557, 0.07304786, -0.053896323, 0.23764133, -0.0688709, -0.029590486, 0.076902606) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.068145, 0.42785034, -0.09306724, -0.275845, -0.18359652, 0.47085622, -0.11451097, -0.24949631, 0.17780478, 0.14360733, -0.0016823296, -0.08480175, -0.40213397, 0.10999707, 0.025154676, -0.1435435) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.24552824, 0.2330777, 0.009393284, -0.13848, -0.06737535, 0.027632507, -0.12971726, -0.06911854, 0.35154542, -0.13226014, 0.07761524, -0.054549973, 0.27885428, 0.08148365, -0.095757246, -0.021533212) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.09454266, 0.2140318, -0.016976485, -0.057624552, -0.09839205, 0.15363936, 0.043497685, -0.064059295, 0.2378484, 0.17965513, -0.49250692, 0.06263317, 0.18567434, 0.029376287, -0.047457956, 0.06774827) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.6005944, 0.7316118, -0.27836758, -0.19813935, 0.81357217, 0.27930802, -0.23901676, -0.24747422, -0.8693642, 0.37762254, 0.016820326, -0.04367687, -0.14583929, 0.94253695, 0.5433254, 0.5274216) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.34054813, 0.25838697, 0.118261084, -0.251229, 0.028324736, 0.19048929, -0.16192491, -0.12896627, -0.100976825, 0.22019616, 0.039321687, -0.21112084, 0.10459288, -0.11201688, 0.12801947, -0.24373414) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.1336266, 0.211002, 0.03210656, -0.09421905, -0.15140519, -0.07119925, 0.21009757, -0.08140687, -0.050216563, -0.012460943, 0.18304639, -0.07330297, -0.0098418, -0.1551483, 0.19184987, 0.026986087) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.022919213, 0.19337773, -0.45702758, 0.031346735, -0.15381978, 0.04094078, -0.1875338, -0.04040901, -0.05630891, 0.09842354, 0.15147696, 0.100789934, 0.06923394, 0.11349254, 0.106697135, -0.09372512) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.018661436, -0.10977688, -0.20715022, -0.0022962943, -0.054421525, -0.13888687, -0.0332814, 0.00016125318, 0.01978585, -0.090099916, 0.039801233, 0.010582678, 0.043903127, 0.14129712, 0.01645732, -0.06156448) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
