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

  var result: vec4f = vec4f(0.10089907, 0.30061117, 0.4947558, 0.13264692);
      result += mat4x4<f32>(0.16631408, 0.73068655, -0.21479698, 0.43130395, 0.15420792, 0.21980485, 0.15180811, -0.021563072, -0.12496679, 0.14082731, -0.34183648, 0.07734066, 0.04877858, -0.06998291, 0.2884127, -0.27243233) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.03361279, 0.56767493, -0.14874972, 0.035405383, 0.14742135, 0.17687781, 0.30679616, 0.094088495, -0.13349557, 0.048833285, -0.2601305, 0.028556159, 0.25616482, -0.08198168, 0.6432768, -0.23625304) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.3176136, 0.5182174, -0.44995382, -0.27952087, 0.19445683, -0.018601859, 0.5262485, -0.18477125, -0.11031262, 0.14646223, -0.25943714, 0.0574147, 0.023433663, 0.08946016, 0.29503307, -0.18946694) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.13855927, 0.17260554, 0.044251632, 0.15401517, 0.2721125, 0.10085814, 0.758755, -0.38211673, -0.1215455, 0.21173275, -0.4130245, 0.10478211, 0.09611526, -0.06276023, 0.21403019, -0.054669976) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.121316, -0.104457445, 0.3061708, -0.05598768, 0.069668025, -0.54685426, 0.7061922, 0.12890825, -0.16609834, 0.153722, -0.45227137, 0.11678311, 0.025842996, -0.060323462, 0.21919897, -0.18701665) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.18916844, -0.18847789, 0.118604526, -0.42816666, 0.32588652, 0.0020059668, 0.6506845, -0.32085836, -0.12537055, 0.096222125, -0.40384132, 0.093435325, 0.19966666, -0.014781618, 0.3281885, 0.026758583) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.16109133, -0.6892867, 0.2344831, 0.22734277, 0.09958675, 0.013822042, 0.20296544, -0.038688406, -0.10854945, 0.027733631, -0.4087329, 0.19323109, 0.061971013, -0.06559759, 0.31680772, -0.19248469) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.040243983, -0.15234147, -0.022626253, 0.14527959, 0.12599221, 0.3392883, 0.4096488, -0.14594924, -0.15124518, 0.029425468, -0.57010746, 0.25516677, 0.14033917, 0.07077247, 0.32279846, -0.22763026) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.026833165, -0.89256483, 0.18671668, -0.22560151, 0.06498673, -0.030243546, -0.09514163, -0.012744785, -0.12490948, 0.02787752, -0.38372484, 0.14156182, 0.08706146, 0.06310534, 0.044408027, 0.03778497) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.1687338, -0.11860802, 0.46197703, -0.44241232, 0.20965742, 0.1210568, 0.5475628, -0.08837527, 0.3374058, -0.3620035, 0.24981822, 0.3282318, 0.2623541, 0.18533309, -0.14600825, -0.09428397) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.016630717, -0.10551931, 0.40601367, -0.24683125, 0.04026615, -0.11060195, 0.16110256, 0.2638172, 0.104873836, 0.07017314, -0.11812542, 0.45183083, 0.013230717, -0.18656603, 0.30158904, -0.01293248) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.2030108, 0.092217505, 0.50433415, -0.076549694, 0.12694585, -0.19402269, 0.24844038, -0.0020927992, 0.3908378, 0.8040123, 0.06992604, 0.40530682, -0.004277154, -0.27603716, 0.78040546, 0.1024219) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.116297066, -0.1439894, -0.19237404, 0.35473862, -0.10317051, -0.06093448, -0.3192864, 0.2632981, -0.06979908, -0.53798807, 0.23643792, -0.1980757, -0.39080167, -0.46072993, -0.79356056, -0.7179423) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.23264682, -0.11925247, -0.3121829, -0.02087399, -0.09398243, -0.6709868, 0.28224567, 0.083830915, -0.15369008, 0.08134367, -0.07792643, -0.20112972, 0.0017092702, -0.070635125, 0.24635044, -0.28905106) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.6051246, -0.022722056, -0.4708735, -0.31229037, 0.049879633, 0.16620879, -0.23818555, 0.18467279, -0.25705513, 0.14430356, -0.2579309, -0.019604856, -0.26630884, -0.22181839, 0.31969187, 0.45998988) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.21557091, -0.113494985, 0.055579923, -0.30518636, 0.074802466, 0.11687356, 0.18600024, 0.11427215, -0.123318546, -0.7712518, 0.16759457, -0.34058473, 0.08303415, 0.16286996, -0.034436777, 0.11267473) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.0011040752, 0.095358565, -0.091663964, 0.040776275, 0.096878536, -0.11807149, 0.30478892, -0.10592926, -0.26293808, 0.052457117, -0.42600623, -0.13204482, -0.09695863, 0.28626052, -0.19343612, -0.07673817) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.25451434, 0.029906316, -0.29620984, 0.18068753, -0.007131162, 0.06817338, 0.37978202, 0.018025275, 0.0008774562, 0.47718927, 0.039863143, -0.23967533, 0.004275062, -0.113829054, -0.048357572, 0.14752951) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
