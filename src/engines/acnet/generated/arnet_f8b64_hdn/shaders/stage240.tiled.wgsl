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

  var result: vec4f = vec4f(0.11555647, 0.09231035, 0.04424821, -0.13171817);
      result += mat4x4<f32>(-0.08512938, 0.021130377, 0.047043167, -0.09313393, 0.030440262, 0.015662884, -0.2105039, -0.12960514, 0.07934429, -0.08606682, 0.04277221, 0.19988766, 0.0024239135, -0.11365346, -0.07429802, 0.3376203) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.0617752, 0.21712074, 0.03218489, 0.0055576963, -0.0019554705, -0.05519691, -0.079429284, -0.09074324, -0.184034, 0.037772484, 0.12900011, -0.18609442, -0.31307638, -0.043834023, 0.2050937, 0.33404848) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.014416581, -0.01620279, -0.04759116, -0.17749177, -0.039662696, 0.011447118, -0.068696424, -0.056218393, -0.09908323, 0.113087796, -0.00040525995, -0.07833591, 0.09256289, 0.14320235, 0.5406508, 0.15944375) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.07886926, 0.052522648, -0.054558203, -0.10415868, -0.017355237, 0.009581236, -0.14638457, 0.18409643, 0.09448154, -0.025261525, -0.042739797, -0.3521782, 0.011623344, 0.010405591, 0.0018567779, -0.0220249) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.7936888, 0.028927352, -0.82327724, 0.35450327, -0.07380989, -0.052901153, -0.68935096, -0.41814417, 0.20368336, -0.5453339, -0.66709816, 0.850898, -0.17059599, 0.14407566, -0.18453565, 0.31970552) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.07663315, 0.17287195, 0.1086215, -0.060687017, 0.059720602, -0.085516855, -0.17706846, -0.12336778, 0.27071232, 0.23690906, 0.04718188, -0.84872013, 0.030803427, -0.33439073, -0.19102535, -0.0367944) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.027662842, 0.070657305, 0.095630355, 0.009179289, -0.24075843, 0.11234306, -0.18465923, 0.08409539, 0.15506473, -0.11662809, 0.08248853, 0.085103154, -0.033001315, -0.053416006, 0.07402097, 0.09130546) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.18332885, 0.006769804, 0.08427806, 0.47765404, 0.010238453, 0.24532038, -0.018827084, -0.29257146, 0.36778605, 0.030652186, -0.072875835, -0.50591826, -0.02605647, 0.005448845, 0.056286052, 0.24191216) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.15002763, 0.029748656, 0.12606315, 0.010704281, -0.014428256, 0.021996645, -0.05574802, -0.0039391345, -0.050307963, 0.057002317, -0.10054947, -0.032295153, 0.14195634, -0.08687457, -0.049142692, -0.02406125) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.022752395, 0.011402976, 0.18109733, -0.12655082, 0.09341515, -0.08029159, 0.07521981, 0.03145663, -0.057868056, -0.004089552, 0.04290961, -0.08280267, 0.032102156, -0.092019334, 0.17469646, 0.014645003) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.051194064, -0.24004275, 0.20958765, -0.03107269, -0.12157582, -0.045712695, 0.2697897, -0.03740154, 0.061078764, 0.007661531, 0.14289518, 0.109285645, -0.11451432, -0.17455857, 0.090711385, -0.37505782) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.0128249815, -0.017176716, 0.062333237, -0.09119077, 0.04544301, 0.046505176, 0.2552359, 0.22069901, 0.03851264, -0.055283774, -0.062669046, 0.025817407, -0.010796355, -0.078793995, -0.017547397, -0.007341999) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.14970972, -0.14410684, 0.3315859, -0.36857736, 0.22877838, -0.08983239, 0.23375443, -0.20989138, 0.17806096, -0.078133166, -0.40836045, 0.09470607, -0.044461723, 0.037425183, -0.022204278, 0.021986717) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.026011735, -0.6418995, 0.47841805, -0.20101304, -0.1433913, 0.51545054, 0.8298395, 0.16744024, -0.33551863, 0.0085316235, -0.12155638, -0.38699475, 0.06723054, -0.02620912, -0.03872557, -0.08615757) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.14466648, -0.14297299, 0.16179873, -0.2835122, 0.050528295, -0.18477608, 0.17699637, 0.13317205, -0.14299852, 0.20208558, 0.23676382, 0.09771554, -0.040589195, 0.00863932, 0.0170174, -0.0105199525) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.023809968, 0.01762467, 0.06866174, -0.05879734, -0.03737351, -0.05156001, 0.23353983, 0.21605185, -0.044197444, 0.095899105, -0.09328347, -0.1905896, 0.02693547, -0.01941968, -0.044876322, -0.051495876) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.10007356, -0.013951757, 0.09710632, -0.12287638, 0.2324279, -0.102898784, 0.2015217, 0.09085565, 0.046169646, 0.0024815744, 0.058222897, 0.08077993, -0.014828953, -0.002190335, -0.016388422, 0.037481662) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.04181763, -0.0053068134, 0.1029743, -0.116693854, -0.0017063932, -0.033618815, -0.004202157, 0.027487205, 0.085236855, 0.0069525125, 0.010830935, -0.21428294, 0.015674504, -0.043664347, 0.023748478, 0.039302308) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
