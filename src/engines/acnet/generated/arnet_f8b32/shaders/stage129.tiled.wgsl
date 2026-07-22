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

  var result: vec4f = vec4f(0.35480174, 0.24863812, -0.15410617, 0.030351711);
      result += mat4x4<f32>(0.042737804, -0.0022649416, -0.0058755944, 0.023616979, -0.06771415, -0.0029961478, 0.0020955708, 0.047239725, -0.12599888, -0.000948783, -0.15155107, 0.18216456, 0.048506804, 0.027062118, 0.011719461, -0.02388688) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.14433078, -0.07093334, 0.022590714, -0.05095499, 0.17270637, -0.06013948, 0.028693339, -0.09608785, -0.5664407, 0.021026073, -0.22432351, 0.31592634, -0.279816, -0.08084573, -0.08430836, -0.060511135) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.55589634, 0.032894697, 0.21357265, -0.11884641, 0.16265583, 0.001284232, 0.05797257, -0.009868059, -0.19255045, -0.030580975, -0.0050303577, 0.0024218305, 0.025399202, 0.0034334196, -0.005792101, 0.090896815) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.22110306, -0.041371286, -0.048254296, -0.052973364, 0.05447465, 0.123622775, 0.05671093, -0.015826548, 0.14569789, 0.11793122, -0.14402822, 0.09599682, -0.24201421, 0.020114753, -0.06846877, 0.07390796) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.10316825, -0.22703367, 0.26979, -0.1705234, 0.43425098, -0.28592166, 0.15509175, 0.17529559, -0.7099945, 0.3661411, 0.41023105, 0.44238517, 0.12281288, 0.03981849, -0.22889109, -0.410855) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(1.0288527, -0.103280105, 0.023284681, -0.5333109, 0.16692486, 0.068546325, 0.10405405, -0.13682775, -0.19009866, -0.10428582, -0.1529298, -0.08160943, 0.10172334, 0.30646533, 0.3312208, -0.67130286) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.057975266, -0.013761704, 0.030431684, -0.03502401, -0.06278004, 0.09017897, -0.023220431, 0.017791579, 0.10885336, 0.054865535, -0.045072887, 0.06771136, 0.08580962, 0.026870094, 0.04514191, -0.021549435) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.16511253, 0.05056065, -0.05235771, 0.062846474, -0.29562223, -0.32516643, 0.5238358, 0.16581607, -0.32926914, 0.023314254, -0.12212736, 0.017277313, -0.1624003, -0.22488427, 0.05904699, -0.06993089) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.024232812, 0.074459694, 0.0053069894, -0.0019776707, 0.109169446, 0.2036875, 0.20729744, 0.05152566, 0.09519232, 0.031024404, 0.0025034864, -0.016226524, 0.055581007, -0.040808644, 0.09651176, -0.058502227) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.25185713, 0.12776189, 0.038576998, 0.011759203, -0.020836, 0.04058207, -0.018521683, 0.08516012, 0.065182954, -0.08061842, 0.06637078, -0.026714718, 0.2742073, 0.088572375, 0.11502994, -0.020270355) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.1138755, -0.018416177, 0.008807017, -0.077752374, -0.38018396, -0.074868485, -0.042029824, 0.12533967, 0.19979374, 0.050661515, 0.08986849, -0.08935499, -0.20603111, 0.09868054, -0.00937459, 0.15272978) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.15445152, 0.22403106, -0.08899134, 0.12320974, -0.010382349, -0.006021623, -0.00041844, 0.014262577, -0.069752924, 0.0616541, -0.0579481, 0.09614844, 0.038727988, -0.16734205, 0.17882858, 0.09470377) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.05418434, 0.043153863, 0.16751507, -0.14210257, 0.27140275, -0.024498614, 0.034007005, 0.16376127, -0.54943454, 0.06829174, 0.17229787, -0.5055034, 0.19841897, 0.17923643, 0.1011855, 0.08103615) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.22888964, -0.090039864, -0.22898284, 0.32585678, -0.035401955, -0.040793058, 0.3278472, 0.58601993, -0.26836625, 0.40596542, 0.5647496, -0.3545989, 0.63405, 0.31201738, 0.32627395, -0.07850953) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.3729768, -0.066628166, -0.103795044, 0.619999, -0.050480302, -0.09728079, 0.020784963, 0.04789298, 0.007941117, 0.03326712, -0.04219688, 0.17522629, 0.33693737, -0.0054103136, 0.023707487, 0.11217363) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.16422877, 0.11400127, 0.08514319, 0.07253528, -0.03395236, -0.0075202365, 0.014549952, 0.06374667, 0.23862632, -0.02743329, 0.15311028, -0.016370164, 0.3708478, 0.12769113, 0.041705478, 0.021857653) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.09914662, -0.08414899, 0.13758889, 0.08309529, -0.1844987, -0.044451337, 0.06302812, 0.029911416, 0.08897075, -0.14229183, 0.06390647, 0.049966298, -0.06338939, 0.007851566, 0.06677392, 0.06943698) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.051650066, 0.14268145, -0.089934886, 0.0071977377, 0.119038776, -0.05790728, 0.04631091, -0.0070085702, 0.28860828, 0.100415416, 0.07391182, 0.05360136, 0.056256603, 0.08256469, -0.02986925, 0.020382062) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
