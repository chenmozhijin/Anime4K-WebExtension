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

  var result: vec4f = vec4f(0.25937375, 0.06675413, 0.15103705, -0.20231037);
      result += mat4x4<f32>(0.021374963, 0.06603108, 0.10807315, -0.012186449, 0.19274305, -0.06875299, 0.045341827, -0.22423212, 0.062300213, 0.08072463, -0.13424197, 0.080380335, -0.05483916, 0.3118106, -0.066903435, 0.04152003) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.023312518, -0.04605879, 0.17031227, 0.16796802, -0.15573518, -0.3836407, -0.7258556, -0.21374276, 0.027281271, 0.15732765, 0.011125318, 0.1897472, 0.2095141, -0.042242866, -0.3511537, -0.13058317) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.117057376, 0.0006873599, 0.08490333, 0.07892231, -0.021777485, -0.33247054, 0.059879586, -0.1715085, -0.031270944, -0.010042458, -0.16949014, 0.007020436, 0.24261713, -0.0963918, 0.11784257, -0.061114457) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.28127563, 0.025477445, -0.033589035, -0.23967601, 0.08237488, -0.0017989057, 0.35553706, -0.30690715, 0.22424534, -0.08849063, -0.24540105, 0.24346074, -0.16104545, 0.18191662, 0.32296696, -0.18482459) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.4260012, 0.16580611, -0.042705115, 0.2716836, -0.36984053, -0.32832396, 0.22547661, -0.55669224, 0.31367168, 0.09158695, -0.2939332, 0.2945762, 0.22198042, -0.14251764, 0.16910994, 0.3322759) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.13477321, 0.0744292, 0.09833644, -0.04485916, 0.16502853, -0.05501139, 0.11157567, -0.045909002, 0.16963412, 0.13095032, -0.18259612, 0.15574524, -0.07046174, -0.23486973, -0.31372857, 0.107515246) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.09538022, 0.022329642, 0.07156676, -0.08923631, 0.2200805, -0.053347543, -0.15187496, 0.1614993, 0.1295006, 0.1838671, -0.02350851, 0.24010196, 0.031991776, -0.075114734, -0.08872769, -0.17532793) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.1325092, 0.08300537, -0.02974963, 0.12023312, -0.07154801, -0.2858118, -0.003668544, -0.3407929, 0.28090072, 0.31349844, 0.053565472, 0.15274417, -0.06611972, -0.24903202, -0.13121814, 0.31811854) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.026529178, -0.081967264, 0.053633258, -0.098633625, -0.16016537, -0.13786529, 0.012937571, -0.15545951, 0.07550262, 0.21847056, -0.05369645, 0.27128154, -0.09589673, 0.18869211, -0.053513207, 0.3178576) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.0969446, -0.09101593, 0.39870816, -0.15915889, 0.16713952, -0.063078895, 0.06007948, -0.096062005, 0.1363529, 0.1480031, -0.24914446, 0.16589135, -0.23795806, 0.088959716, 0.0738116, 0.024708675) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.34184965, -0.024516735, 0.14877632, 0.09180003, -0.1360097, -0.017207922, 0.13174735, -0.08027084, 0.2506786, -0.18357332, -0.31081057, 0.10133183, -0.3931915, 0.113440946, -0.1823078, 0.055950593) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.24783185, 0.08560269, 0.007409211, 0.12897296, -0.08526918, -0.08816771, 0.26211953, -0.2001878, 0.11368799, -0.116404146, -0.12133295, -0.040732265, -0.17333564, 0.11439281, 0.031059753, 0.07249616) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.347411, 0.2513565, -0.05272655, 0.027019408, 0.10757448, 0.006890063, 0.13682732, -0.17478572, -0.06938573, -0.34694615, -0.04827306, -0.039040666, -0.338448, 0.040643, 0.027045371, 0.01951167) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.21813957, 0.010778296, -0.33368626, 0.62152755, -0.45122215, 0.0013556228, 0.01918098, -0.32643893, 0.5390959, -0.21696061, -0.080576025, 0.19259362, -0.19544546, 0.03167327, 0.33504137, -0.4011128) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.35262465, 0.082449146, 0.09286297, 0.028222378, -0.672707, 0.040941972, -0.03809629, -0.1445996, 0.07905005, -0.027205832, -0.085227944, -0.3072125, -0.19430745, 0.17311159, 0.11518249, 0.1001402) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.18487404, 0.030702824, 0.23439583, -0.26918182, 0.21271653, 0.09152771, 0.01304478, 0.0081942845, 0.023078576, 0.14496706, 0.0019139636, 0.14906749, -0.4513466, -0.021367174, 0.07977495, -0.17349377) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.27440968, 0.27334994, -0.060164794, -0.09883563, -0.6247954, -0.47059017, 0.16836871, -0.62064344, -0.001227557, -0.01317321, -0.012624336, 0.19836622, -0.13465956, 0.40711418, 0.17887716, -0.09588391) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.022780279, -0.082261845, -0.047923677, -0.04801155, -0.40213364, 0.20594278, 0.12779813, 0.34336993, -0.03830145, -0.15587364, 0.017233491, -0.066558205, -0.36622295, 0.29510522, 0.06334573, 0.099856414) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
