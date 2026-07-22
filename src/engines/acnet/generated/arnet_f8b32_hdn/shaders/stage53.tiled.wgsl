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

  var result: vec4f = vec4f(0.45423475, 0.30111188, 0.23526238, -0.051856026);
      result += mat4x4<f32>(-0.14379105, 0.25180906, 0.116796724, 0.051384978, -0.08102623, -0.07205514, 0.24740471, -0.096981004, -0.11721049, 0.21343753, -0.88318396, -0.36733034, -0.14197114, -0.107122354, 0.2135132, -0.15892884) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.0005066425, -0.23962983, -0.07543293, 0.07388651, -0.31782198, -0.23596783, -0.3742665, -0.319805, -0.20466553, -0.0042650206, 0.11521371, 0.3573136, 0.014165013, 0.06451372, -0.1043686, 0.069555) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.024520863, -0.20592068, 0.0592168, -0.14233315, -0.07286328, 0.030818645, 0.13394414, 0.1440844, 0.12857363, -0.020185344, -0.018909942, 0.28676525, -0.0400137, 0.045541015, -0.05922832, 0.06709772) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.08808201, 0.044464756, 0.14315575, -0.075301886, -0.51073015, -0.17868131, -0.10206612, -0.45173144, -0.8321947, -0.19251284, 0.038753547, -0.5198211, 0.0054276306, -0.22486165, -0.29910532, -0.4438404) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(1.680235, 0.18863995, 0.18102367, 0.5047205, -0.35404542, -0.4387089, -0.32289058, 0.5276771, 0.046378512, -0.15776639, 0.07335524, -0.4670481, 0.564425, 0.32834882, -0.0073738536, 0.5551651) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.36143973, -0.0938964, -0.19808662, 0.0044275643, 0.49487194, -0.387222, 0.048446532, -0.12214485, 0.0779838, -0.05674242, -0.01902925, -0.026417268, -0.21509793, 0.33063218, 0.13184431, -0.24727117) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.3134397, -0.012628657, 0.10271471, 0.015800517, -0.2264791, -0.12304801, 0.11879176, 0.069027394, 0.13820381, 0.2322072, 0.106526606, 0.019247636, -0.24128182, -0.115935534, 0.15259098, -0.1565509) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.17883909, -0.046377663, -0.12913527, 0.31465062, 0.41730562, -0.0015618758, -0.099965215, 0.39558655, 0.41023013, 0.19265004, 0.05935293, 0.1464771, 0.24332175, 0.2882001, 0.009421319, 0.10930601) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.008529514, -0.10905764, -0.071017414, -0.21760197, 0.04931576, -0.3914979, -0.07864717, -0.25879028, 0.074364275, -0.053265978, 0.042136915, -0.034452476, -0.052016355, -0.23094936, 0.02058588, -0.18109885) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.07896324, 0.022937488, 0.101722516, 0.16438803, 0.04497303, -0.10074038, -0.03426298, -0.097684816, 0.058160573, 0.00060729706, -0.06672743, -0.0001510554, -0.19622414, -0.213773, 0.23913358, 0.06385325) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.0706336, -0.029445855, -0.26789832, -0.07247693, -0.13232455, -0.54148495, 0.1610422, 0.15737465, 0.17397305, 0.0890663, 0.26457953, -0.10561299, 0.102328, 0.16624285, -0.24837567, -0.24820676) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.17962801, -0.08255543, 0.09632921, -0.10287847, -0.1558455, 0.0662849, 0.043489825, -0.002898202, 0.1386897, -0.062503554, -0.12858337, -0.09069207, -0.12569289, 0.007880614, 0.039433576, -0.23882696) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.24260668, 0.07432605, 0.03552728, 0.11486813, 0.18066728, 0.13200572, -0.025718212, -0.045521226, 0.31684807, -0.04320406, -0.016428493, 0.39484373, -0.024727877, -0.055415098, 0.19355933, 0.594179) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.8916133, 0.23833637, 0.0079316525, 0.16670074, -0.45896614, 0.15284266, -0.22544765, 0.3933168, -0.0018765749, -0.16931136, 0.17525727, -0.38185498, -0.40517655, -0.35572588, -0.732177, 0.105327986) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.039877016, 0.10032963, -0.042887647, 0.17795287, -0.5037524, 0.16532356, -0.022226976, 0.24282612, -0.20852019, 0.10412756, -0.21646073, -0.2096385, 0.014170212, -0.1687141, -0.06448707, -0.12682503) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.25571352, 0.021589559, 0.045637615, -0.042442903, -0.022696834, -0.035431776, 0.020259213, -0.33528218, 0.037108745, -0.28489164, -0.22457589, 0.09277122, 0.24613363, -0.13701615, -0.37573987, -0.04734483) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.11716072, 0.18156615, 0.08590733, 0.004124572, -0.26036197, 0.13434789, -0.012699008, 0.056784295, -0.58106333, -0.42934948, -0.0071361186, -0.23021314, -0.5791044, -0.33624536, 0.056205124, -0.034626205) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.20121135, 0.081526995, 0.02815853, -0.11310986, -0.13072725, -0.27564195, -0.12202666, -0.28543153, -0.18924163, 0.23219532, 0.078736044, -0.06559054, -0.11353933, 0.020235607, 0.073814094, -0.22048628) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
