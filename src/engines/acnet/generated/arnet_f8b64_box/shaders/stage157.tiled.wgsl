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

  var result: vec4f = vec4f(0.06136629, 0.06572567, 0.13528766, 0.09348239);
      result += mat4x4<f32>(0.095176175, -0.18875813, -0.1057625, 0.23066738, -0.1227125, 0.29477766, -0.1195329, -0.0077027897, 0.13953583, -0.22188292, 0.11032672, 0.07920538, -0.056232672, 0.22080128, 0.0021983895, 0.008749184) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.3153359, -0.32603228, 0.1313366, 0.10364051, -0.26291972, 0.3595962, -0.301125, -0.064225726, 0.19356976, -0.28887826, 0.14885712, 0.040043544, -0.07978779, 0.4152178, 0.04761367, -0.05821831) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.18738863, -0.019243395, 0.32484373, -0.08156474, -0.16385187, 0.24914612, -0.12255803, -0.00090299227, 0.097931, -0.31902122, 0.08220578, 0.008746566, -0.13812664, 0.36499152, -0.19441657, 0.044796556) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.1797041, -0.12032677, -0.124020256, 0.37393516, -0.1597506, 0.34675926, -0.1029525, -0.00946274, 0.043782175, -0.11473645, -0.049101025, -0.002342923, -0.118685365, 0.25135165, -0.1022421, -0.009794261) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.3339866, 0.45015147, 0.5718672, -0.17137314, -0.25662822, 0.37875852, -0.28914997, 0.039872058, 0.14859432, -0.4389927, 0.08685377, 0.05779066, -0.15343492, 0.6154425, -0.17756918, -0.15950783) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.17207478, 0.23518212, 0.10021492, 0.015999297, -0.22528376, 0.28576213, -0.24945451, 0.040413823, 0.17747284, -0.2523893, 0.20497465, 0.0555139, -0.25220034, 0.26912177, -0.22541226, 0.07953638) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.048661284, -0.07808951, -0.038064428, 0.049288128, -0.1526083, 0.2268917, -0.11403913, -0.01216438, 0.06884504, -0.1038413, 0.06355211, 0.038960196, -0.05655005, 0.3061728, -0.11921039, 0.07623195) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.008882926, -0.18832126, 0.029515946, 0.044136677, -0.17964604, 0.2442987, -0.22677445, 0.02577401, 0.18167691, -0.27576724, 0.15824746, 0.028780455, -0.2031673, 0.3347752, -0.23780268, 0.100511044) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.11064446, 0.040028606, 0.09633429, 0.110729896, -0.09318928, 0.11815243, -0.14877832, 0.032618873, 0.0976706, -0.08979771, 0.06290266, 0.025138298, -0.2373111, 0.34202218, -0.27332774, -0.012248266) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.019146156, -0.30417565, 0.1688017, -0.089950055, 0.032990742, -0.029780515, 0.2042599, -0.1791963, 0.1085121, -0.17593452, 0.083772905, 0.0029323394, 0.106191956, -0.28352466, 0.39103517, -0.13394786) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.002168817, 0.3006, -0.071260534, 0.09230492, 0.060660705, -0.16943999, -0.10779795, 0.07013677, 0.08623451, -0.23468783, 0.07907254, 0.043666247, -0.017303487, -0.033279363, 0.10643829, -0.18197457) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.20164482, 0.34342086, -0.15006681, 0.38295737, -0.105212204, -0.0898142, -0.066901036, -0.07438986, 0.050115984, -0.19252746, 0.0553576, -0.01277585, -0.13564692, 0.21428533, 0.066701286, -0.1650194) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.11877769, 0.12554634, -0.32775944, -0.026833422, 0.14863075, -0.1697221, 0.049100604, -0.047102254, 0.07728261, -0.33375835, 0.13891995, -0.012870759, -0.35630974, -0.11857819, -0.32253247, -0.123956196) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.33061978, 0.4273644, 0.36352512, 0.13419652, 0.0674983, -0.6081844, -0.17073767, -0.003899164, 0.2406423, -0.38410726, 0.17361014, 0.08051408, 0.08971059, -0.11184011, 0.5746986, -0.24506922) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.0044130185, 0.35754183, 0.10386049, -0.07011025, 0.12656483, -0.14517187, -0.12681037, 0.11589874, 0.13106884, -0.28082654, 0.1518252, 0.014842532, 0.04669764, -0.15164971, 0.3482466, 0.12892263) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.3142931, -0.39471045, 0.051493037, -0.40026495, 0.05555485, -0.10521705, -0.021628905, 0.061118197, 0.07783856, -0.1835497, 0.063920416, -0.023581594, 0.041131124, 0.052023128, -0.24968892, 0.15484893) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.08559974, -0.33313936, -0.07204963, 0.053064656, 0.24214034, -0.10899683, 0.30830786, -0.17497386, 0.10644235, -0.3192847, 0.069647275, -0.0025638295, 0.27726868, -0.17252222, 0.3332809, 0.23302837) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.0084894365, -0.20850606, -0.047029868, 0.08391578, 0.005430037, -0.1004913, 0.09173168, -0.058926668, 0.09358693, -0.17604017, 0.09318835, 0.0057172077, -0.121733285, 0.11229376, -0.26925465, 0.19748849) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
