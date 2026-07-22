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

  var result: vec4f = vec4f(-0.021194959, 0.19013275, -0.058241934, 0.29260835);
      result += mat4x4<f32>(0.08088756, 0.02927631, -0.4290688, -0.23998262, -0.1466399, -0.03255171, 0.036049668, 0.03949894, -0.08818875, 0.08340249, -0.16082695, -0.11324605, -0.16030689, -0.2279667, 0.026062852, -0.1891411) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.36404765, -0.17099614, -0.08738498, -0.32097363, -0.0007835549, 0.21083404, 0.01578097, 0.03357404, 0.26437885, 0.06609431, -0.054897092, -0.1639786, -0.92075914, -0.41429245, -0.42324364, -0.59781605) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.17394266, 0.32727355, 0.07147261, 0.015648892, -0.06484829, 0.08723565, -0.05943784, 0.08141039, 0.13529937, 0.015953718, -0.07774026, -0.17064373, -0.11468109, 0.169212, -0.19094627, -0.22258277) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.36634293, -0.104631536, -0.056817126, 0.053605534, 0.062315848, 0.14555435, -0.005222271, 0.00950458, 0.061616097, 0.12202853, -0.12987922, 0.046460636, -0.15406252, 0.102534615, -0.005227185, -0.014656451) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.028843269, -0.6475224, 0.16434623, 0.15999709, 0.38476807, 0.31580663, 0.01765108, 0.37331378, 0.59765196, 0.2189417, -0.15037508, 0.018127745, -0.56622833, -0.47885814, -0.080172844, 0.09983897) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.24368973, 0.10455874, 0.028192999, -0.028631665, -0.053279072, 0.2567313, 0.18356179, 0.03861506, -0.117964014, -0.07670795, -0.09585327, -0.02403877, -0.11328499, -0.29829964, 0.24432023, 0.2135086) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.14123823, 0.27213696, -0.075656824, -0.1151329, -0.03992152, 0.0038496612, 0.02745677, 0.097683206, 0.02962905, 0.03060696, -0.014642392, -0.2534832, 0.053293273, 0.17960519, -0.119856834, 0.009245779) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.1254782, 0.18688715, -0.093607426, -0.12898901, 0.36085945, 0.3854728, 0.09673269, -0.04022842, -0.033842295, -0.07011655, 0.21814415, 0.15651697, -0.114047594, -0.016551157, -0.05425939, 0.009528303) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.046511397, 0.023579542, -0.16207299, -0.21302338, 0.29588887, 0.5791373, 0.22119746, -0.043538373, 0.39590734, 0.029737808, -0.3109754, -0.25513965, 0.07342935, 0.066090725, -0.063241355, -0.1346104) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.2096307, 0.1250626, -0.04462492, -0.06399936, -0.021343224, -0.10468451, 0.1675747, 0.14489831, -0.12172087, -0.2525042, 0.02656693, -0.005416998, -0.029055888, 0.05136901, 0.009118234, -0.008773431) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.2810899, -0.21389988, -0.013314522, -0.2496166, 0.2837281, -0.7388652, 0.5220897, 0.41728052, 0.3167905, 0.0439979, 0.32666123, 0.19320302, -0.120576985, 0.25385198, 0.051180873, 0.2617257) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.14089571, 0.03569191, 0.06715681, -0.027552562, -0.0022496441, -0.25049517, -0.19667417, -0.30735758, 0.081652686, -0.23482643, 0.09331591, 0.17933096, -0.026442144, -0.034507163, -0.04273736, 0.26272854) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.14712471, 0.07639291, 0.12478417, 0.2835685, -0.2214985, -0.12355251, -0.0034605635, -0.12822685, 0.26641464, 0.047046535, 0.117350504, -0.056512337, 0.32035413, 0.12636252, -0.13312577, -0.2622102) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.13792576, 0.121074885, 0.3057227, 0.61875236, -0.12570983, 0.091170475, -0.4415709, -0.43123344, 0.29588038, 0.5418846, 0.20814572, 0.13780499, 0.35989052, -0.06479559, 0.21688592, -0.1286936) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.075463004, -0.18388967, -0.16224019, -0.35383713, -0.15126877, -0.0059034666, -0.17230378, -0.25175318, -0.031458493, -0.007996979, 0.11957807, 0.16944213, 0.13022089, 0.70214826, 0.24821867, 0.26126927) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.00081915193, 0.23859113, 0.08122675, 0.013345037, 0.068579696, -0.10107015, 0.0701722, 0.074410364, -0.068404295, -0.456098, -0.013904747, 0.09096872, 0.18255447, -0.13998775, 0.21016605, 0.13728213) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.46064094, 0.29111618, 0.30516443, 0.008119883, 0.16341697, -0.29839835, 0.18479842, 0.18245444, -0.437109, -0.40668014, -0.07937834, -0.040866915, -0.088443816, -0.1836151, -0.12517427, 0.071704775) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.20420064, 0.050690953, 0.05430722, 0.10799085, -0.11695517, 0.06599607, -0.07962624, -0.002859273, -0.015120136, -0.006688596, 0.085235454, 0.014505971, 0.18769579, 0.05428678, -0.13191864, -0.14335634) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
