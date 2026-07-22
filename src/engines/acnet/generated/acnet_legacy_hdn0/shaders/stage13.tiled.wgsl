const WG_X: u32 = 8u;
const WG_Y: u32 = 8u;
const BT709_LUMA: vec3f = vec3f(0.2126, 0.7152, 0.0722);

fn luma709(color: vec3f) -> f32 {
  return dot(color, BT709_LUMA);
}

@group(0) @binding(0) var tex_TMP2_TEX_0: texture_2d<f32>;

fn sample_TMP2_TEX_0(pos: vec2u, offset: vec2i) -> vec4f {
  let size = vec2i(textureDimensions(tex_TMP2_TEX_0));
  let coord = clamp(vec2i(pos) + offset, vec2i(0, 0), size - vec2i(1, 1));
  return textureLoad(tex_TMP2_TEX_0, coord, 0);
}

@group(0) @binding(1) var tex_TMP2_TEX_1: texture_2d<f32>;

fn sample_TMP2_TEX_1(pos: vec2u, offset: vec2i) -> vec4f {
  let size = vec2i(textureDimensions(tex_TMP2_TEX_1));
  let coord = clamp(vec2i(pos) + offset, vec2i(0, 0), size - vec2i(1, 1));
  return textureLoad(tex_TMP2_TEX_1, coord, 0);
}
var<workgroup> tile_TMP2_TEX_0: array<array<vec4f, 10>, 10>;
var<workgroup> tile_TMP2_TEX_1: array<array<vec4f, 10>, 10>;

@group(0) @binding(2) var out_tex: texture_storage_2d<rgba16float, write>;

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
      tile_TMP2_TEX_0[tileY][tileX] = sample_TMP2_TEX_0(
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

  var result: vec4f = vec4f(0.023380728, -1.21361e-40, -5.604e-39, 0.03709979);
      result += mat4x4<f32>(0.025151992, 5.23014e-40, -5.40272e-40, -0.03515651, -0.031823598, 1.32823e-40, 4.44985e-40, 0.064042695, -0.014459976, 4.26133e-40, 1.60886e-40, 0.07159416, -0.05833409, 1.63363e-40, 5.8681e-40, 0.055296235) * tile_TMP2_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.032877993, -2.9923e-40, 4.4355e-41, 0.06833694, -0.055094764, 4.58492e-40, -4.48711e-40, -0.010253264, -0.08783427, 3.26074e-40, 4.16236e-40, 0.039860073, 0.18886134, -2.03914e-40, -5.7259e-40, 0.055199184) * tile_TMP2_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.021626445, 3.8688e-41, -3.21435e-40, 0.016149249, 0.031338103, 3.53084e-40, -2.4561e-40, -0.0006281291, -0.032342855, -2.07885e-40, 4.51144e-40, 0.08108844, 0.06154676, -5.9017e-41, -1.53706e-40, -0.021253174) * tile_TMP2_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.19879234, 3.15753e-40, -4.8838e-41, -0.0058649774, -0.032198917, -2.6657e-41, 4.16865e-40, 0.04682788, 0.24023436, -3.90538e-40, 1.64384e-40, 0.17750321, -0.26151818, -7.9899e-41, 5.2654e-40, 0.17214134) * tile_TMP2_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.029080117, 1.15037e-40, -3.85954e-40, 0.60604906, -0.4381959, 5.98286e-40, 5.22389e-40, -0.39618507, 0.71916467, -2.56079e-40, -3.6331e-40, -0.12381018, 0.6672177, -2.98697e-40, 4.74118e-40, 0.20542084) * tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.003033072, 5.56548e-40, 2.50645e-40, 0.031738453, 0.041391086, 3.27907e-40, -5.7603e-41, -0.009263273, -0.18559264, -2.76375e-40, 6.4961e-41, 0.14476427, -0.12486084, 5.639e-40, -2.02647e-40, -0.0037858838) * tile_TMP2_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.23380142, -3.44993e-40, 4.03648e-40, 0.09330563, -0.04120748, -2.8348e-40, -1.52105e-40, -0.081751615, -0.0067635034, 4.5027e-40, 5.08992e-40, 0.02341638, -0.048128262, -2.556e-41, -4.8621e-41, 0.12831248) * tile_TMP2_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.02357773, 2.30498e-40, -1.01947e-40, 0.21498536, 0.3747549, 2.58101e-40, -3.57681e-40, 0.09908257, -0.094409496, 2.70647e-40, 6.10365e-40, 0.12818941, 0.10510026, -1.9786e-40, 4.94968e-40, 0.032086983) * tile_TMP2_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.118705876, -6.3766e-41, 4.83556e-40, 0.13609004, -0.18548319, 5.57907e-40, 3.63851e-40, 0.004429593, -0.017890459, -4.55933e-40, 2.48279e-40, 0.010815686, -0.04261931, 9.47e-41, 3.01758e-40, -0.051851425) * tile_TMP2_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.003010139, -7.4049e-41, 4.22351e-40, -0.023685569, -0.11399693, 2.75392e-40, -2.07349e-40, -0.08802973, 0.032181736, 5.27206e-40, 3.49691e-40, 0.023828804, -0.04282858, -1.76814e-40, 3.4962e-40, -0.0039768144) * tile_TMP2_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.096379526, -2.39024e-40, 4.53808e-40, 0.122715, -0.19220804, 4.02139e-40, 1.3423e-41, -0.025852691, -0.056346387, 1.9304e-40, -5.34587e-40, -0.00500781, 0.10777531, -6.9657e-41, -6.2313e-41, 0.02057962) * tile_TMP2_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.06613984, -2.84965e-40, 4.65007e-40, -0.016009307, -0.03415843, 2.07318e-40, -4.41094e-40, -0.01708667, 0.032655276, -3.84892e-40, 3.9245e-41, 0.053854253, -0.068129495, -4.07456e-40, -2.729e-40, -0.04193076) * tile_TMP2_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.10201253, -1.89119e-40, -1.61239e-40, -0.20176086, 0.022871224, 7.012e-41, -5.42179e-40, -0.20532818, -0.01691224, -3.9759e-40, 2.40283e-40, -0.009693363, 0.005815604, 8.0894e-41, -5.2709e-40, 0.06957713) * tile_TMP2_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.23239583, -1.5589e-40, -1.94489e-40, 0.74756616, -0.6868364, -4.41996e-40, -1.15368e-40, 0.1521441, 0.08426427, 2.61844e-40, 5.77743e-40, 0.037047278, -0.23997793, 1.69501e-40, -3.22254e-40, -0.10415726) * tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.18355577, 5.54627e-40, 5.14972e-40, -0.034525897, -0.010856264, 7.3787e-41, -1.16638e-40, -0.0018639421, -0.0795205, 1.25936e-40, -6.29728e-40, 0.47324622, 0.19051774, -1.0574e-40, 2.42446e-40, -0.0025036654) * tile_TMP2_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.040018767, -2.17825e-40, -1.28908e-40, -0.047055073, 0.026311385, 2.64519e-40, 5.60063e-40, -0.11236091, 0.001278824, 1.58313e-40, 1.88023e-40, 0.0056975167, -0.041854657, -1.05899e-40, -3.63005e-40, -0.019197807) * tile_TMP2_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.22985104, -1.95321e-40, -1.65488e-40, -0.37098673, 0.025421828, 1.197e-40, 3.41093e-40, -0.24611884, -0.071109615, 3.71787e-40, -4.6258e-41, -0.086107545, 0.101403035, 2.8466e-41, -2.07943e-40, 0.06202685) * tile_TMP2_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.12979656, -2.3785e-40, 4.83482e-40, -0.19215767, -0.0151898675, 2.82981e-40, -3.14335e-40, 0.063094124, 0.08658505, -3.49149e-40, -5.07162e-40, 0.0655686, -0.017139038, -2.7558e-40, 4.05411e-40, -0.01083265) * tile_TMP2_TEX_1[localId.y + 2u][localId.x + 2u];
      result = max(result, vec4f(0.0));
  textureStore(out_tex, pixel.xy, result);
}
