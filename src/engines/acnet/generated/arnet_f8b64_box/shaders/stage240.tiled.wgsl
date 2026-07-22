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

  var result: vec4f = vec4f(-0.005026829, 0.0054330686, 0.16694784, -0.07434926);
      result += mat4x4<f32>(-0.009483268, 0.0801564, -0.12793167, -0.1313616, -0.023113644, 0.022135625, -0.15980563, -0.06783006, 0.1046226, -0.13859046, 0.06131334, 0.309117, -0.04143369, -0.03517356, 0.0076359166, 0.24144484) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.03439892, 0.07130121, -0.21576442, -0.033403955, 0.016350355, -0.08456823, -0.04905775, 0.14625199, -0.0879639, 0.14756574, -0.15448463, -0.28638166, -0.33037135, 0.08104481, 0.17845823, 0.23078677) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.052186422, 0.1616727, -0.20287944, -0.3346253, 0.028837238, 0.013775649, -0.030885972, -0.030121192, 0.0697564, 0.05560043, -0.02626637, 0.033141322, 0.10453853, 0.0022549017, 0.44870862, 0.15955374) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.062437452, 0.0596114, -0.12729397, -0.15619631, 0.11152493, -0.078094326, -0.11427931, 0.007318799, -0.019938776, 0.21742949, -0.022376742, -0.40073892, -0.057950836, 0.08890071, 0.0207362, -0.092146955) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.593411, -0.59643435, -0.53098696, 0.2551678, 0.00410782, -0.22119635, -0.4685729, -0.05399366, 0.38922438, -0.8443164, -0.44215956, 0.43998554, -0.18858449, 0.29308358, 0.0015480106, 0.33092004) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.044795446, 0.0857828, 0.07824434, 0.07237326, -0.0032354596, -0.024991816, -0.06808023, 0.034254238, 0.19099575, 0.18055245, -0.114526436, -0.26691228, -0.09015751, -0.3199513, -0.17483471, -0.06525) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.0029077206, -0.09686937, -0.015207943, -0.0078187315, -0.062311426, -0.02127472, 0.012010219, 0.11416763, -0.05714406, -0.03380781, 0.0326993, 0.047529273, 0.010793517, 0.021250723, 0.013342242, -0.026068289) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.116550826, -0.2734081, 0.06965299, 0.3012677, -0.062807634, 0.2856038, 0.15449332, -0.0055510825, 0.25357482, -0.007343986, 0.14170106, -0.29278234, -0.1273869, 0.047678288, 0.07195311, 0.13613862) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.10940236, 0.021623818, 0.028332867, -0.04440655, -0.0729557, 0.04202302, -0.13877861, -0.012395794, -0.10669564, -0.12760027, -0.04949645, 0.118698694, 0.09636104, -0.021482978, -0.089221515, -0.09303218) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.082054004, 0.10192086, 0.00975751, 0.041164912, 0.112477414, -0.11548508, 0.098681726, 0.020805798, -0.02190696, -0.00081596174, -0.011554767, -0.031493034, -0.10476724, 0.077667534, -0.054606795, -0.0200479) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.14467964, 0.10917104, 0.046546057, 0.1928508, 0.022838064, 0.014614407, 0.21496303, 0.12690547, -0.03061795, 0.123268984, -0.08420646, -0.033426613, 0.15102087, -0.1639624, -0.16829865, -0.18636972) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.038637817, -0.13999726, 0.12132546, 0.114634365, -0.006315533, 0.015120713, 0.07036441, 0.023807997, 0.06648925, -0.10374318, 0.072286904, -0.0054563787, -0.10162789, 0.06279615, -0.027233904, 0.06476426) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.054822672, 0.11961113, 0.0061510843, 0.029312732, 0.0067269746, 0.15270552, 0.017244937, -0.1801062, 0.2172581, -0.16144842, -0.2726844, -0.08022768, -0.15811421, -0.014401135, 0.040686917, 0.2193854) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.19221303, 0.4653483, 0.21697736, -0.44300658, 0.15678255, 0.25762048, 0.5876193, 0.18976176, -0.17162257, 0.23591109, -0.08292899, -0.086421005, 0.059047483, 0.18732592, -1.0030134, 0.5293679) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.03662447, 0.22333907, -0.1197344, -0.090489246, 0.0938688, -0.16550054, 0.13319813, 0.19118458, -0.1344111, 0.07307637, 0.23487534, 0.15050443, 0.015870463, -0.033818226, -0.22976954, -0.11795451) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.007968959, 0.023524463, 0.04805904, 0.0010297684, 0.023693694, -0.19086337, 0.092988186, 0.18946636, -0.04082712, 0.06516622, 0.0025978305, 0.0047946824, -0.049921192, 0.07326444, -0.008152204, -0.037114736) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.05109738, 0.131341, -0.019615013, -0.026525201, 0.050866596, 0.18171677, 0.018532299, -0.16442338, -0.04907685, 0.024145413, -0.06394052, 0.19071276, 0.12964602, -0.112302765, -0.043815006, 0.13015555) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.006776933, 0.021822883, -0.004321094, 0.0067026177, 0.025695961, -0.017886221, 0.04858753, 0.025714694, 0.05875656, -0.005526464, -0.07220864, -0.19596119, 0.02403137, 0.044255204, 0.009509701, -0.05974388) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
