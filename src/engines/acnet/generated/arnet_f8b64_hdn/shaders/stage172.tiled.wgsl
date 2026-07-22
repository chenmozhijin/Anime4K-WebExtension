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

  var result: vec4f = vec4f(0.33650458, -0.043991093, 0.15630311, -0.12685937);
      result += mat4x4<f32>(-0.009405306, 0.64902765, 0.695849, 0.14577948, -0.071622215, 0.06718206, 0.08109148, -0.024273548, 0.2693825, 0.116513446, -0.34032094, 0.15261333, -0.12530631, 0.080561146, 0.056744125, 0.16711059) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.004394879, 0.42241013, 0.5004211, 0.22647369, -0.22999053, 0.13224527, 0.24444856, -0.12387801, -0.12447243, -0.23813625, -0.1722358, -0.19957195, -0.19323294, -0.19113228, -0.103710115, 0.15073615) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.05290816, 0.6603421, 0.6331006, -0.33241874, 0.060776547, 0.11547412, 0.19918327, 0.092867225, 0.08235356, 0.013591061, 0.0883995, 0.17733182, -0.16564773, 0.082124405, 0.08015719, 0.16696309) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.1041811, -0.09649745, -0.2645813, 0.19114293, 0.042402536, 0.2335126, 0.11170028, 0.045070402, -0.112403356, 0.059917774, 0.050591853, -0.18291827, -0.032194246, -0.103725985, 0.13643387, -0.09735762) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.0012435013, -0.07199896, -0.10190063, 0.4274564, -8.565174e-06, 0.15155588, -0.016828926, -0.17093956, 0.4664405, -0.16598402, 0.041183762, -0.15051259, -0.44204655, -0.04747926, 0.032430504, -0.39296165) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.08271167, 0.15766926, 0.09112904, -0.31297842, 0.10930444, 0.12420242, -0.0048359884, -0.17347485, -0.0738149, -0.08426723, 0.013150409, -0.043715876, 0.17525919, 0.12692592, -0.008990375, 0.051195648) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.04738133, -0.58951193, -0.4987436, 0.020938367, -0.07594008, 0.07540391, -0.026871117, -0.11201041, 0.29756433, 0.028409727, 0.23038252, -0.12341923, -0.16109446, 0.034377962, 0.025695765, 0.008184352) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.17916495, -0.5469084, -0.45434123, 0.19740918, 0.08088341, 0.19477785, 0.028762579, 0.14586918, 0.40513727, 0.027304418, 0.107554756, 0.17403924, 0.218228, -0.050244626, 0.23122309, -0.057585087) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.1075079, -0.61231774, -0.5987952, -0.4583369, -0.058076385, 0.030086562, -0.083027996, 0.035676077, 0.03833304, -0.05735744, 0.0055451, -0.07408843, 0.014709972, -0.01972452, 0.011502097, -0.076178335) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.34287083, -0.18994431, -0.11295224, -0.20660418, 0.03481643, 0.0838214, 0.049988817, 0.08092527, -0.23449743, 0.062536046, 0.029204775, -0.17229488, -0.10645224, 0.34168598, 0.3641532, -0.61677015) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.26465076, -0.09430003, -0.5658643, -0.20183684, -0.019282294, 0.045247942, 0.024079695, 0.08856732, -0.2586642, 0.07994099, 0.49810943, -0.47050497, -0.19649474, 0.15202218, -0.06403222, -0.7357546) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.051506713, -0.04862115, -0.16834486, 0.0771685, -0.0077565047, 0.07122208, 0.19026843, -0.105128646, -0.24815872, 0.040245134, 0.24854377, -0.07790021, -0.2326109, -0.013167561, -0.061980933, -0.8607328) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.012447818, 0.11456178, 0.22169493, -0.026011089, 0.0431054, 0.14283246, 0.040392887, 0.028478976, -0.09862116, 0.0007791947, -0.0839495, -0.14312668, -0.07422518, 0.1584291, 0.14263648, -0.09812754) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.83346796, 0.50115687, 0.47598183, 0.24186337, 0.23379882, 0.19176152, 0.021932717, -0.4268822, 0.25210372, 0.1715516, 0.17707811, 0.12928249, -0.06573198, -0.12828007, -0.13635002, -0.6205742) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.070180275, -0.09121787, -0.09880943, -0.16368164, -0.07760361, 0.11969172, 0.2201199, 0.10427114, -0.003944093, 0.14378536, 0.16934943, 0.015997669, 0.008039964, 0.09657286, 0.021656135, -0.21964037) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.25810486, 0.10533607, 0.20153435, -0.2902995, -0.01806557, 0.11939719, 0.080066904, -0.09769499, -0.043227986, 0.07900579, 0.013934973, -0.031141281, 0.27277943, 0.03947683, 0.19651769, 1.1031804) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.93638515, -0.09911873, 0.44729194, 0.15755524, -0.031576816, 0.12129398, 0.21674074, 0.052641287, 0.104133464, -0.08013897, -0.022562696, 0.13014156, 0.124997415, -0.21155699, -0.22603863, 0.937967) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.07924936, -0.07300054, -0.22642353, -0.0026848433, -0.08485483, 0.11745612, 0.11782903, 0.091798946, -0.05866734, -0.21231401, -0.07893668, 0.35039794, 0.24407879, -0.4930649, -0.29274324, 1.0158385) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
