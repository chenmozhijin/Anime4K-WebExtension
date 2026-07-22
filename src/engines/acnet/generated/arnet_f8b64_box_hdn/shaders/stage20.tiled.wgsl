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

  var result: vec4f = vec4f(0.32909188, -0.054405157, 0.22642803, -0.054854557);
      result += mat4x4<f32>(0.18619287, 0.14059204, -0.09508425, -0.16071677, -0.11446094, -0.027200062, -0.16020317, 0.23444869, 0.25256377, 0.1830477, -0.07819449, 0.19969189, 0.003564617, -0.005433593, -0.105899595, -0.080525525) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.14553815, 0.007923125, -0.14444807, 0.35413593, 0.21831936, 0.08872285, -0.12778819, 0.53979236, 0.10451522, -0.09853681, 0.34066346, 0.6992495, 0.2311941, 0.055920463, -0.3236455, 0.13507363) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.18964233, -0.074102946, 0.1033657, 0.08640905, -0.1338659, -0.07672798, 0.10212025, -0.02458322, -0.0560731, -0.010007693, -0.24449633, 0.099006735, 0.2664953, 0.20559105, 0.09924422, -0.17058092) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.098613344, 0.8040682, -0.054869123, -0.49551016, 0.19141862, -0.33459544, 0.15369055, 0.16610603, -0.08153229, 0.3010264, -0.5015485, -0.0849571, 0.15764505, 0.050682634, -0.0102429995, -0.1434629) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-1.2414201, 0.7140429, 0.6906332, 0.44293383, 0.14994466, 0.02053055, -0.2691118, -0.51818675, -0.41804263, -0.0052524935, 0.3303596, -0.7033078, 0.3639611, -0.5207028, 0.55697536, 0.23082669) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.041334286, 0.22309406, 0.19965574, 0.15230425, -0.20338589, 0.18343464, 0.4798429, 0.14845419, 0.08900931, -0.0045521404, -0.6993371, -0.0038142947, 0.32969618, 0.14598411, -0.1748, -0.18874626) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.15338635, -0.018814247, -0.24711944, -0.28504714, -0.11484107, 0.06414513, -0.036617253, 0.0140574975, 0.07866041, -0.429799, 0.057077598, -0.069635235, -0.09191534, 0.035612054, -0.21837336, -0.017675316) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.12885165, -0.011997693, -0.07174466, -0.24146608, -0.0893526, 0.04808915, 0.020132668, -0.45878342, -0.43617085, -0.15154901, -0.26104036, -0.00059550634, 0.29161587, -0.07952276, -0.18185171, -0.22061898) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.1919345, -0.11454954, -0.102307215, 0.105230436, 0.2504209, -0.010115726, 0.08379462, 0.14213046, -0.094074816, 0.043993045, 0.15575123, 0.010099572, 0.21883944, -0.037893303, -0.19909614, -0.2132545) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.08554165, -0.013820192, 0.004610889, 0.08016455, -0.1613997, -0.21484315, 0.11292769, 0.11638155, -0.0992368, 0.03145596, -0.010424083, 0.08394724, -0.03634672, 0.15033728, 0.21817279, -0.07343553) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.035032164, 0.03561904, 0.27755857, -0.09530291, 0.110531256, 0.019891495, 0.13718708, -0.25972936, -0.27026618, -0.01846888, 0.021108894, 0.16047545, -0.21975212, -0.07538283, 0.10324682, 0.17680265) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.285747, 0.33413345, 0.09240066, 0.3294172, -0.0411106, 0.019575456, 0.027308524, -0.053943384, -0.15014674, -0.06857353, -0.14429262, 0.0241051, -0.012533144, -0.13001584, -0.3144946, -0.19072577) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.3142429, 0.11210067, 0.21899864, 0.06410136, 0.123977035, -0.73838794, 0.042903677, 0.28634182, -0.22772886, -0.42066154, -0.21909173, 0.48510343, -0.56371295, 0.017163517, 0.059652954, -0.8357659) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.007924504, 0.22704703, 0.29756007, -0.35886908, 0.83201563, -0.6421125, -0.4424648, -0.5457417, 0.22153915, -0.095402434, -0.6042548, 0.002005167, 0.06425418, -0.07020723, 0.42078942, -0.14835694) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.34441307, -0.04603349, -0.5282232, -0.10448057, -0.0023593486, -0.30470756, -0.12916045, -0.22774625, 0.008790187, 0.1306188, 0.15797527, 0.28736937, 0.10901758, -0.08402256, -0.012570167, -0.17016959) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.061052863, -0.06764232, 0.07806924, 0.080716014, 0.014104949, -0.20732892, 0.16860431, 0.3102077, 0.076265685, 0.12685877, 0.118350044, 0.06927522, 0.1173611, -0.043566857, 0.12229175, -0.18218821) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.004471847, 0.10896151, 0.21456866, -0.07506968, -0.08594937, 0.01657679, 0.09096271, 0.25013843, -0.20945743, 0.02953384, -0.045631364, 0.28040427, 0.42637753, -0.2846519, -0.19427854, -0.63104826) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.15143614, 0.043927852, 0.034681424, -0.017810306, -0.1754664, 0.03628467, 0.12645903, 0.022930639, 0.012100213, 0.015107802, -0.09111104, 0.0012951167, 0.029997453, 0.03342392, -0.009296088, -0.09524216) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
