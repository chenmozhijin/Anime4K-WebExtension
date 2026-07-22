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

  var result: vec4f = vec4f(0.58111846, -0.054613017, -0.022473354, -0.36598924);
      result += mat4x4<f32>(-0.051490657, -0.29223377, -0.24017215, 0.12602082, -0.059927285, 0.04032181, 0.08033375, 0.15473762, 0.07762556, -0.32363185, -0.03755202, -0.17434722, -0.10930959, 0.34673348, -0.08422287, 0.31837147) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.42782462, 0.094231166, 0.28346747, 0.7329557, 0.011250307, -0.013817308, -0.029809201, 0.09930293, -0.0937428, -0.03721851, 0.11027517, -0.1308335, 0.027117187, 0.06608049, -0.12941459, 0.21269508) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.3482158, -0.3783603, -0.23366599, 0.5577681, 0.011074206, 0.14255622, 0.04850753, 0.067754745, 0.046109464, -0.04815615, -0.07343721, -0.010659834, -0.10687894, -0.056808867, -0.096730545, 0.22741814) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.18122084, -0.43694192, -0.092548035, -0.12863438, 0.031239327, -0.048068322, 0.17851116, -0.03235889, -0.12103604, 0.1413197, 0.35017338, 0.4682718, -0.113163754, 0.40807167, -0.120238185, 0.43773538) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.13196275, -0.20234607, 0.17758533, 0.060809344, 0.14766847, 0.006797578, -0.19032073, -0.20092912, 0.24511622, 0.3450068, 0.06570361, 0.2913355, 0.24609789, -0.46702096, 0.088066064, -0.53088665) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.06987944, -0.037616093, -0.36608908, 0.7506241, -0.0025636642, -0.02742286, 0.07561107, 0.15185314, -0.122256555, -0.3937192, -0.23558503, 0.14741585, 0.14944288, -0.17101887, -0.009742238, -0.43336254) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.094108805, -0.17978488, -0.02503557, -0.061382566, 0.072375245, 0.17701462, 0.14978555, 0.21939382, 0.3464594, -0.319037, -0.11389606, 0.5485759, -0.049309835, 0.281736, -0.3022551, 0.25685525) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.17146309, -0.2553681, -0.24148579, 0.11380643, 0.39931002, -0.21439947, 0.049144574, -0.45821488, -0.04489107, 0.056026194, 0.3528711, -0.2159161, -0.32181516, -0.33166695, 0.5784495, -0.14380993) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.013660306, 0.101322845, -0.03510384, 0.28027102, -0.021002417, -0.036192607, 0.12591088, 0.23629549, -0.03214721, -0.15247025, 0.098894864, 0.08551322, 0.040877648, -0.5655873, 0.37917262, -0.5094245) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.0074359295, -0.17109324, -0.047734078, -0.0199941, -0.00046374995, 0.013574313, -0.045209736, 0.24637647, -0.014176037, 0.03160018, 0.09639396, -0.039921086, -0.047450088, 0.16273488, -0.0146463495, -0.1261451) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.15755886, 0.056013517, 0.132307, -0.34210348, -0.20621575, -0.22445379, -0.057238195, -0.0479396, 0.089541584, 0.11696542, 0.32790235, -0.24453263, 0.012624973, 0.44615898, -0.11831733, -0.0075615076) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.005123483, -0.12607305, -0.077402525, 0.18530239, -0.09365004, -0.29984853, -0.25900072, 0.07382018, -0.1845672, -0.23718639, 0.6782911, 0.19189294, -0.020041514, 0.261019, -0.059019763, 0.26395667) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.16905811, 0.07279687, 0.04448863, -0.10952326, -0.015337846, 0.08134602, -0.0423717, 0.13203876, 0.00062809803, -0.018479675, 0.026253384, 0.12891562, -0.05464853, 0.10770388, 0.040149804, -0.019531997) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.18109755, 0.89852756, 0.4453406, 0.25375268, 0.09159234, 0.1871936, 0.09974576, 0.15345451, -0.34729493, 0.3829784, 0.04322437, -0.17705232, 0.2707681, 0.037899625, 0.6936609, 0.08684532) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.1302189, 0.2185042, 0.013366274, 0.14508271, 0.017979637, -0.12260388, -0.30255425, 0.16086924, -0.15886103, -0.37251452, 0.15860802, -0.036677476, -0.033154693, 0.35039422, -0.29147995, -0.034060262) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.005289717, -0.14696139, 0.006205505, 0.03125206, -0.0363399, 0.036472883, -0.024992565, 0.10076624, 0.0077096066, 0.09071332, -0.060641762, 0.05473956, -0.15094556, 0.26346287, -0.1910682, 0.098369546) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.04299051, -0.48828036, -0.7978101, -0.56497234, -0.09038427, 0.11815413, -0.21358322, -0.14513652, 0.1963451, -0.16833209, 0.20208046, 0.025901139, -0.1990945, 0.3204872, -0.20336612, 0.21047737) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.021977471, 0.15493698, 0.0017016269, 0.19731832, -0.02750971, -0.025540411, -0.106832504, -0.14032525, 0.13972169, 0.30564934, -0.3505851, 0.019097103, -0.0063142464, -0.02218142, -0.063511685, 0.0015935893) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
