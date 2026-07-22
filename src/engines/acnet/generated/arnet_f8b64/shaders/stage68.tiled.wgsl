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

  var result: vec4f = vec4f(0.20682706, 0.014871105, 0.12976496, 0.124405034);
      result += mat4x4<f32>(-0.42345402, 0.033787306, 0.21129863, -0.21959582, 0.015451765, -0.06340141, -0.040407054, 0.116195805, 0.15236892, -0.1608388, 0.04868686, -0.12266765, -0.12499348, -0.10437949, 0.17137459, 0.16462764) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.17921433, 0.07294538, 0.25873947, 0.028906193, -0.16351856, -0.0698724, -0.39713886, 0.12061765, 0.15545563, -0.0730045, 0.2024047, -0.010585739, 0.23532474, 0.22695333, 0.15605605, -0.16658847) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.005361483, -0.102196604, -0.020300966, 0.07524967, 0.03727841, -0.040455587, -0.21791355, 0.2578977, -0.2283072, -0.048310522, 0.18215394, 0.23372614, -0.076087125, 0.118552506, 0.27337408, -0.009631926) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.17571494, -0.005288401, 0.0759676, -0.09447277, -0.021852959, -0.05341472, -0.19494076, 0.24109067, -0.07405355, -0.06317731, -0.12151313, -0.11699, 0.3277959, 0.090041675, -0.02028845, -0.012825035) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.32199612, 0.0073472625, 0.023319352, -0.0063388753, -0.23652248, -0.22040668, -0.35732606, 0.21770725, 0.032946803, -0.21430045, -0.06547474, -0.38350186, 0.61614966, -0.49969524, -0.17871891, -0.83614296) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.5580819, 0.15700251, 0.3600417, 0.07233574, 0.20087875, -0.123557396, -0.4635964, -0.0035616125, -0.14815941, -0.08293501, 0.1921471, -0.04676072, 0.14192651, 0.084344, 0.018415159, -0.068681896) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.16694991, 0.08384243, 0.023547208, -0.05040633, 0.0014210214, -0.034869395, -0.09312217, 0.11975109, -0.23040935, -0.15450126, 0.06339518, 0.04906247, 0.080702916, -0.26806638, -0.25230345, 0.11087498) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.117076665, 0.19204226, 0.10448171, -0.20742556, -0.023855276, -0.016715998, -0.21150535, 0.20779943, -0.445469, -0.091681175, -0.30610168, 0.45779517, 0.292121, -0.11335738, 0.09135829, 0.106811196) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.02353706, 0.1210462, 0.28424954, -0.22270142, 0.180074, -0.12083004, -0.35587075, 0.086202376, -0.54582053, 0.16281782, 0.28180417, 0.13585632, -0.008585281, 0.11130483, -0.02073805, 0.22482543) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.11839164, 0.15404241, 0.019395651, -0.13324949, -0.014622263, -0.030011604, 0.037893064, -0.16255909, 0.04263241, -0.13627814, 0.00503486, 0.2149981, -0.0326507, 0.12342275, 0.20514941, -0.22175062) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.09559162, 0.07353023, 0.09571666, -0.15232868, 0.41741183, 0.008799019, -0.07854218, -0.04892614, 0.21396196, 0.051303428, 0.12071808, 0.1930542, 0.15113762, 0.3815396, 0.31946212, -0.014752956) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.040394165, 0.1005905, 0.030445293, -0.1334118, 0.34129286, -0.05524326, 0.14593601, -0.17740756, -0.040416908, 0.05580848, 0.056924287, 0.040013976, 0.089070305, 0.06825859, 0.25860605, -0.085927986) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.31129304, -0.1645976, 0.23727871, 0.31539485, -0.37366462, 0.022152359, 0.03828457, -0.20237911, -0.04451864, -0.18382645, -0.32911906, 0.22173086, 0.1332736, -0.2184991, -0.08833084, -0.05105207) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.6079017, -0.37905085, 0.028494643, 0.0024205402, -0.5827488, 0.16111386, -0.35098895, 0.22616722, 0.02922943, -0.019604357, -0.19423586, 0.029216621, -0.32455245, -0.34744072, 0.6582255, 0.21456085) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.345388, -0.0056312303, 0.008115621, 0.1842474, -0.21749151, -0.023398722, 0.110005416, -0.05621247, 0.057154056, 0.16876635, 0.012556155, 0.22643249, -0.14100419, -0.3040066, -0.22374442, -0.19404925) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.19646314, 0.0814287, -0.35716042, 0.13804334, 0.034105033, -0.1618199, -0.25913233, 0.1748951, -0.41767725, 0.13433604, 0.0781479, -0.31386873, -0.053659357, -0.022160513, -0.16539632, -0.047408417) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.17396739, -0.05728785, 0.091915086, 0.03900757, 0.5444565, -0.15509817, -0.35254407, 0.21639395, 0.030789115, -0.21908437, 0.25731063, -0.04172915, -0.21184587, 0.124494426, 0.010793289, -0.10923527) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.09570445, -0.018319981, 0.09022025, -0.00021251202, 0.5522144, -0.2074476, -0.24676701, -0.11148624, -0.068085104, 0.1250801, 0.22042014, 0.103953965, 0.39583933, -0.12981112, -0.3072877, -0.018926771) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
