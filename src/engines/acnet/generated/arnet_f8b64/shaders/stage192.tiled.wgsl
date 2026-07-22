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

  var result: vec4f = vec4f(-0.16930266, 0.27587485, 0.37724867, 0.023694329);
      result += mat4x4<f32>(-0.046404544, 0.060726427, -0.03520628, 0.043517668, 0.031224439, -0.0023475247, -0.03594937, 0.042325083, -0.1227562, 0.09768506, 0.07771136, -0.11330136, -0.11300886, 0.11626647, -0.05835479, -0.07285115) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.08490228, 0.075956024, -0.07266314, -0.16569558, 0.11845646, -0.11580742, 0.036041234, 0.02449194, -0.3073419, -0.117957234, -0.25164327, -0.25724876, -0.3767029, 0.14921555, -0.026260884, -0.13664809) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.020867527, -0.050091617, -0.078375, -0.04572814, 0.03885023, -0.12161565, 0.13905527, 0.07817018, -0.10267418, 0.031681765, 0.23333997, 0.26479936, -0.066369236, 0.057819076, -0.037278447, 0.15771367) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.166769, 0.043890707, -0.03592475, -0.2843807, 0.034024734, -0.031753793, 0.25741455, 0.17827192, -0.41153675, -0.35118496, -0.12125148, 0.014431354, -0.30836973, 0.20029742, -0.06192939, -0.35367632) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.044463, -0.07719989, 0.0741368, -0.5473069, -0.18620236, 0.6922456, -0.896962, -0.025154937, 0.8485385, 0.37400776, 0.4501122, 0.66812575, 0.25180045, -0.071938, 0.413311, -0.24875546) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.2383449, -0.010727443, 0.10645558, 0.177925, -0.13099606, -0.08950382, 0.16889776, 0.18664464, -0.016230881, -0.013104313, -0.24252625, -0.071829, -0.09180207, 0.07866105, -0.18593745, -0.14514306) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.019123191, 0.1894005, 0.12328514, -0.2738959, 0.024655644, -0.027674843, -0.012932105, 0.08885536, 0.31149656, 0.114127934, -0.025020545, 0.10158984, -0.088234015, 0.03274044, -0.15433796, 0.011403798) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.15639827, 0.061756697, 0.08365033, -0.47079098, 0.14750543, 0.066806145, 0.46422806, -0.12450305, 0.16430461, -0.028231077, 0.18032262, -0.13244638, 0.2914358, 0.3190487, -0.0762687, 0.022211226) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.07490675, -0.032650594, -0.05005708, 0.08597624, 0.027195526, -0.0022458003, -0.039307494, 0.01105852, -0.069473155, 0.017074237, 0.022118662, 0.0027956623, -0.14962253, 0.15250336, 0.02623116, 0.011786232) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.06228133, -0.2892481, -0.32508856, 0.03732431, 0.021831512, -0.2745022, 0.060888287, 0.32082146, 0.029019466, -0.09708019, -0.004536612, 0.22644512, 0.067288905, 0.07777265, -0.06529714, -0.019546606) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.106330425, -0.32551798, -0.096702136, -0.19957632, 0.0047619366, 0.09561516, 0.35736215, 0.34528276, 0.1866122, -0.20549451, 0.14678155, 0.22078325, 0.16815783, -0.2664374, -0.24565984, 0.43230477) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.19320862, -0.27788827, 0.018612614, 0.24577998, 0.025292031, 0.2724346, 0.250193, 0.076435536, -0.21716295, 0.010379765, -0.23344734, -0.17938611, 0.26954812, -0.07661263, -0.092790805, 0.06353718) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.026582325, -0.07019425, -0.13158828, -0.2602065, -0.029273055, -0.29312813, -0.2100682, -0.3292374, -0.055963557, 0.08966608, -0.015882008, 0.038297564, 0.03558485, 0.047156993, -0.050778627, 0.12810315) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.12050618, -0.12136991, -0.50034344, -0.18889031, -0.040664773, 0.18855332, -0.251856, -0.3733701, -0.76446015, -0.08246502, 0.021876542, -0.30553633, -0.0045744963, -0.27069858, -0.05980393, 0.6417208) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.09768971, -0.0061792317, 0.44651887, 0.27444756, -0.0068360483, 0.29026854, 0.086452834, -0.121457346, 0.059527352, -0.034389064, 0.23821992, 0.011203823, 0.11050557, -0.059041534, -0.36022282, -0.016899759) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.0017716779, 0.22610794, 0.14602812, -0.19458011, 0.0020327223, -0.41553214, -0.26447216, 0.0331859, 0.052767985, -0.024993788, 0.06332123, -0.09146048, -0.057211727, -0.000519168, -0.01248779, 0.062360376) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.14370501, 0.29878637, 0.070811145, 0.14296596, 0.06495931, -0.13162827, -0.04034817, 0.12587924, 0.057655275, -0.19482902, -0.22752288, 0.3867789, 0.084986866, 0.049907114, -0.042999223, 0.22096935) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.00837273, 0.30419698, 0.1177424, 0.05645764, 0.15175006, 0.15102887, -0.13489987, -0.07298001, 0.14335752, -0.13322383, -0.046429634, 0.41388932, 0.14552362, 0.09131684, -0.0080024535, 0.037799843) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
