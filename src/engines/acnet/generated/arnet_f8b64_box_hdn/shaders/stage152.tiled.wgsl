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

  var result: vec4f = vec4f(-0.13252002, 0.18684874, -0.05048467, -0.3943101);
      result += mat4x4<f32>(-0.29752904, -0.069719836, -0.8274196, 0.083962135, -0.030095275, -0.046357352, 0.20152557, -0.012697744, -0.27187657, 0.046774596, -0.038582653, -0.1267666, 0.19869033, 0.0052134153, 0.47308525, 0.0001303099) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.100912094, -0.19846226, -0.17459886, -0.13176903, -0.15029491, -0.064531706, -0.39778072, -0.055287, -0.36306387, 0.13217498, 0.22572012, -0.23275812, 0.2492779, -0.12997869, 0.25962064, 0.11678544) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.027431088, 0.035209414, -0.2170455, 0.08077606, -0.07886947, 0.050173532, 0.11231939, -0.21810326, -0.2108169, 0.23180917, 0.028388847, -0.016052315, 0.2174957, -0.0075107687, 0.45339426, 0.01137103) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.22348832, -0.0103303995, -0.41306013, -0.16084859, 0.172958, -0.03490442, 0.16144978, 0.0030796803, 0.07017294, -0.037780847, -0.0054000104, 0.24580808, 0.39898476, -0.29118177, 0.4802625, 0.21093753) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.13333626, 0.056455165, 0.112471566, -0.06070824, 0.10589471, -0.16330619, -0.29259902, 0.40290135, -0.25130552, 0.12994295, 0.31781888, 0.104449816, 0.42517307, 0.045522183, 0.70459753, 0.002165593) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.27984607, -0.12643267, 0.12279451, 0.067854606, 0.052651975, -0.042039108, -0.3029642, -0.029763574, 0.01999075, 0.12840387, -0.026080951, -0.15484285, -0.0013400536, -0.00090409914, 0.011397114, 0.07021576) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.081375, 0.064077124, 0.13454965, -0.026709251, 0.16106541, -0.111368805, -0.076582916, 0.23070677, -0.23001382, 0.22872105, 0.059856053, -0.1895831, 0.28442302, -0.0030698313, 0.32709312, 0.08269203) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.048325546, 0.14113063, 0.38758698, 0.122914724, -0.04227655, -0.16501817, -0.029690865, 0.12727456, -0.5230007, 0.11577115, 0.41803208, 0.0881384, -0.033528816, 0.054049455, 0.24412756, -0.03617077) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.5334828, 0.17206378, 1.0742176, 0.12766299, -0.0066691944, -0.012121943, -0.0006420667, -0.015019436, -0.29612744, 0.19746448, -0.07532906, -0.01518995, 0.42078513, -0.1462624, 0.6795853, 0.09212655) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.07132684, -0.19203287, 0.049142607, -0.031506017, 0.09051947, 0.07272814, -0.10807456, 0.39223725, 0.13280158, -0.0394372, -0.16764912, 0.19563518, -0.4850151, 0.43334365, -0.4007212, 0.008889271) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.14006649, 0.0952396, -0.39361385, -0.014748221, 0.59584504, 0.29181084, -0.07720219, 0.61855835, 0.23356432, 0.075348236, -0.01867682, 0.11719625, -0.49876976, -0.07016424, -0.18008055, -0.063917845) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.05789426, -0.10818865, -0.18799028, 0.018335652, 0.06316452, -0.06663408, -0.35228047, 0.39350748, -0.04017205, -0.05546561, 0.10541142, -0.071764745, 0.030394807, 0.111939125, 0.070205405, 0.031379297) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.20484239, 0.46005517, 0.4871057, -0.39926168, 0.38411516, 0.12585919, -0.08854832, 0.52474225, -0.3370774, 0.306558, 0.18888527, -0.3891418, 0.21807238, -0.14062922, 0.1472848, 0.2506172) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.13118589, -0.10364685, -0.34514144, 0.46904472, -0.10278694, -0.2007351, 0.016985947, -0.12350138, -0.20625488, 0.26577875, 0.5402324, -0.04712839, -0.03525746, 0.12934737, -0.2919, 0.13109444) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.098758355, 0.20224163, -0.14849877, 0.22011414, -0.21546295, 0.04481067, 0.71802133, 0.03484203, -0.12611465, 0.14970759, 0.15372801, 0.1488935, -0.08414997, 0.044311635, -0.18391623, 0.015638284) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.07802382, -0.10513845, 0.21824807, -0.031033255, -0.211175, 0.16848703, -0.077247225, 0.103583105, 0.13666709, -0.2384417, -0.03294818, 0.24943194, 0.04159275, -0.1275503, -0.117050454, 0.25658053) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.10789079, -0.17375255, -0.24066399, -0.07505364, -0.20102625, 0.004744872, 0.14961258, 0.227973, 0.46132302, -0.063829914, -0.27306965, 0.08758939, 0.0127626695, 0.09193552, 0.13114427, -0.20480652) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.13968737, -0.0046113394, 0.15475547, 0.017603071, -0.03727086, 0.19679157, 0.027027056, 0.28657407, -0.17281438, -0.03803809, -0.29647085, 0.158584, -0.006956959, 0.052712962, 0.40469682, -0.11740476) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
