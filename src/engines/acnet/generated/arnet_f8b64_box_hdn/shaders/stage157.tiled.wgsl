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

  var result: vec4f = vec4f(0.1703825, 0.11214277, 0.34506753, 0.111579664);
      result += mat4x4<f32>(0.02122957, -0.29507998, 0.026994936, 0.13846579, -0.2309771, 0.25978705, -0.21756051, -0.011387221, 0.09537002, -0.12400242, 0.15613689, 0.00067862944, -0.20978235, 0.23472169, -0.20384133, -0.033698354) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.25101537, -0.46227404, 0.34375325, -0.2453838, -0.33459616, 0.40186554, -0.42142582, 0.009439362, 0.16210061, -0.11808485, 0.15180741, 0.020803927, -0.16887915, 0.34251747, -0.13676785, -0.06657305) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.0856572, -0.2766115, 0.37942746, -0.06838528, -0.19641513, 0.3383433, -0.2504695, -0.007015396, 0.12580337, -0.18514383, 0.16805291, -0.016958201, -0.2559681, 0.3326458, -0.24825463, -0.0058318735) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.070211075, -0.47892982, -0.14357668, 0.12310858, -0.27201876, 0.37220553, -0.24404688, -0.06705951, 0.12653665, -0.066447735, 0.08271093, 0.0157854, -0.19878554, 0.3813425, -0.15741889, -0.045924705) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.18477216, 0.5380818, 0.40508857, -0.5248068, -0.36169434, 0.49468198, -0.36948568, -0.021937903, 0.207677, -0.32621357, 0.21917227, 1.3418466e-05, -0.33631462, 0.5454842, -0.3073275, -0.115237266) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.0077154962, 0.043221373, 0.072841674, -0.053110406, -0.30745292, 0.35571006, -0.37271503, 0.048988286, 0.20628731, -0.2634015, 0.2182895, -0.02866566, -0.3504352, 0.45922482, -0.29858625, -0.012807054) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.0030562237, -0.062613755, -0.19832996, 0.03982133, -0.17754264, 0.26144883, -0.16975923, -0.027998935, 0.11299414, -0.07395214, 0.092939354, 0.008151519, -0.19701082, 0.26747644, -0.22198647, 0.03425133) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.09390265, -0.217616, 0.04462933, -0.1399512, -0.22889285, 0.3981113, -0.27906284, 0.0090769455, 0.1834524, -0.19390965, 0.22101073, -0.032161325, -0.29650018, 0.43632373, -0.365686, 0.049295705) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.04344256, -0.011484313, 0.12830313, -0.07692556, -0.21196386, 0.20406438, -0.28854373, 0.045048226, 0.18808667, -0.109718524, 0.16914587, -0.055807564, -0.2810234, 0.42063472, -0.3089524, -0.035763055) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.10234214, -0.5156157, 0.16097668, -0.06693242, -0.04407516, -0.062345333, 0.27712148, -0.29966396, 0.1477383, -0.19704963, 0.10570669, 0.047357395, -0.033479404, -0.5979502, 0.3403381, -0.32712576) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.0348717, 0.31625155, 0.131239, -0.012818945, 0.067079045, -0.2537342, -0.16814391, 0.15194045, 0.18905926, -0.2988173, 0.18028271, 0.043909248, -0.04856616, 0.14360934, -0.0681097, -0.0003615401) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.16288373, 0.28287634, -0.16010769, 0.2983378, -0.059921775, -0.07946701, -0.1581201, 0.07361443, 0.09815904, -0.21247716, 0.0797758, 0.025655484, -0.06720035, 0.43832457, 0.09712986, -0.09015857) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.20355892, 0.1774081, -0.3147277, 0.026691198, 0.1190361, -0.12169159, -0.053332213, 0.030474808, 0.14202552, -0.29501468, 0.098169334, 0.048885006, -0.31433037, 0.03728543, -0.44161227, -0.057174526) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.46143135, 0.49482477, 0.2539314, 0.26443538, 0.035599772, -0.9026027, 0.03299803, 0.046271946, 0.28823876, -0.42573488, 0.24512976, 0.08829198, 0.25319037, 0.13928032, 0.14215596, -0.16190124) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.08196608, 0.38319644, 0.17236942, -0.03307927, 0.084903315, -0.12553997, -0.117277, 0.06673409, 0.18948753, -0.29989788, 0.18190157, 0.04042186, 0.12628365, -0.0973022, 0.16432917, 0.114124104) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.16495617, -0.33450994, 0.16858156, -0.33642256, 0.030647347, -0.11376186, 0.076187804, 0.1108187, 0.16284347, -0.22922619, 0.13695018, 0.02108173, 0.09768884, 0.13704717, -0.43036103, 0.3388915) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.010427895, -0.17673784, -0.1590764, 0.13627115, 0.17333804, -0.062769815, 0.33025563, -0.15151669, 0.18872648, -0.37862, 0.18455702, -0.0012982739, 0.20262948, -0.4385746, 0.4521664, 0.24061234) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.11985924, -0.1883786, -0.049280733, -0.0792486, 0.09473995, -0.24962324, 0.07012811, 0.0751598, 0.17286243, -0.23255236, 0.18554083, -0.011446356, 0.016412934, 0.11285771, 0.0060397983, 0.073261544) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
