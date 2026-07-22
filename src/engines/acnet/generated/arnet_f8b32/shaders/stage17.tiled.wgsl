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

  var result: vec4f = vec4f(0.03322287, 0.0658719, 0.10178062, 0.17468877);
      result += mat4x4<f32>(0.08587674, -0.06865755, 0.036057197, 0.28382775, 0.0624726, -0.08017584, 0.17202134, -0.018631622, -0.045905177, 0.030219773, -0.15948652, -0.0012596905, -0.19915774, 0.10700138, 0.17097709, -0.111100174) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.20586069, -0.08536646, 0.24650824, 0.09607582, 0.03780306, 0.09128354, 0.10428496, -0.15489309, -0.020222198, -0.10453939, 0.03381643, -0.07018587, 0.34858933, -0.18030402, -0.34826893, -0.36743423) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.013862511, -0.00058245333, -0.02942172, 0.20461772, 0.10463807, -0.03419654, 0.0056581125, 0.08394689, -0.020731997, -0.03821135, -0.050342336, 0.07045085, 0.33236283, -0.18437007, 0.035850246, -0.2228827) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.20611164, -0.083508216, -0.14195774, 0.21119478, 0.06869657, 0.30852726, -0.1459586, -0.22278509, 0.21116665, -0.03299185, -0.20601796, 0.3042797, -0.13179518, -0.020664798, 0.043783896, -0.13308097) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.2750543, 0.5939041, -0.51195765, -0.3599928, 0.09893809, 0.37854716, -0.29378888, 0.21994181, 0.40514603, 0.08256021, 0.10325558, -0.29889816, -0.41490933, -0.097182296, 0.03268561, -0.02818483) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.0055069528, -0.082701646, 0.042196292, -0.10449117, 0.27678904, -0.19262221, 0.18400607, -0.044598177, -0.21623929, 0.057000596, 0.1446144, -0.15991183, -0.282226, 0.18953279, -0.09189362, 0.059037402) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.0579598, 0.006842582, -0.013244084, 0.03513146, -0.4854052, -0.29064807, -0.016915368, -0.4165118, 0.4084395, 0.10224116, 0.01624178, 0.123750895, -0.078531034, 0.3643557, -0.13732477, 0.2359141) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.17420802, 0.37684473, -0.20893525, 0.4121416, 0.051816616, -0.39730823, 0.43637136, -0.21179311, 0.31079736, -0.05988654, -0.18119776, -0.17368573, -0.65960425, -0.00038925547, 0.061988037, -0.25161338) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.3733051, -0.13454024, 0.14701505, -0.38716632, -0.014780644, -0.119064756, -0.2257056, -0.35212886, 0.100981995, -0.16044582, -0.23273376, -0.20572929, -0.021669129, 0.02022409, -0.08386203, -0.06954608) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.074556544, 0.11511224, -0.05847305, 0.010067957, -0.052823905, -0.003059771, -0.0041430024, -0.041069567, 0.006955214, 0.09615892, -0.1043461, -0.036920585, 0.18428868, -0.033600982, -0.15700541, -0.08260131) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.07044139, 0.34858543, -0.6584236, -0.58301324, 0.06065432, 0.02073611, -0.026852677, 0.15928818, 0.0018544965, -0.05422891, 0.02654406, 0.21365315, 0.04175696, 0.17587504, -0.2932217, -0.13298753) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.06767566, 0.0081404075, -0.22502358, -0.14577764, 0.13524562, -0.1160551, 0.19319858, -0.17624512, 0.07711731, 0.018048836, 0.23508064, 0.020183451, -0.18760356, -0.08328712, -0.10387789, 0.048471928) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.006747994, 0.12385463, -0.0046400507, -0.13222496, -0.02355952, -0.15943381, -0.043625705, -0.29300132, -0.043197755, 0.5231149, 0.059326712, -0.2508485, -0.09564603, -0.16644889, 0.09323634, 0.07312234) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.037019882, 0.57869345, -0.13338627, -0.05652672, 0.029240014, -0.38500568, -0.16603643, -0.60664123, -0.03954308, 0.048340067, -0.49045998, -0.059855163, -0.35511172, 0.42864898, -0.5962728, -0.11578175) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.18284342, -0.10084704, -0.014616076, -0.19150877, 0.3461427, -0.102976836, 0.17300065, -0.1177671, 0.0029343734, 0.093074426, -0.013124552, -0.14595734, 0.035165876, -0.11947254, 0.1208167, 0.24430317) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.07997587, -0.022649374, -0.018506039, -0.043047883, -0.1311622, -0.07932232, 0.031792928, -0.072507806, 0.39721778, 0.36192882, 0.13132435, 0.17241621, 0.30275598, 0.15098593, -0.05305933, 0.30737418) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.009221631, 0.17373717, 0.056652233, -0.034600332, 0.052684262, 0.20494603, 0.0050045145, 0.3116413, 0.25959697, 0.43419594, 0.1647508, -0.20902112, -0.5945385, -0.39316216, 0.40976194, -0.0189413) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.021884002, 0.06027393, 0.009482378, 0.059412424, 0.17726521, 0.023570077, 0.09319015, -0.14728147, -0.097884044, 0.05754129, 0.04321069, 0.12164752, 0.17963493, 0.01370699, -0.2092757, 0.092541) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
