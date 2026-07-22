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

  var result: vec4f = vec4f(0.46606302, -0.1654503, -0.09791532, -0.057014205);
      result += mat4x4<f32>(-0.15036948, -0.32976726, 0.00218249, 0.17047796, -0.00065327773, -0.0021974053, -0.26872212, 0.018500255, 0.09016202, -0.030014683, 0.09083501, 0.0672447, -0.2059622, -0.17626786, -0.026486991, -0.24286757) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.1508982, -0.25108135, 0.32258108, -0.0004252876, 0.022657758, -0.24082866, -0.74498826, -0.06346436, 0.10948069, -0.163827, 0.12176884, 0.042129382, 0.24395065, -0.30030164, -0.14923048, 0.16338237) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.2419603, -0.3098657, 0.21356317, 0.3455798, -0.13937116, -0.3527393, -0.065791026, -0.23844431, -0.06717097, 0.16710702, -0.06980718, -0.027448557, 0.019085972, 0.1358192, -0.0744095, -0.13435116) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.2564871, -0.23044322, 0.10258772, 0.26388842, -0.1896719, -0.0437985, -0.40930176, 0.01374537, 0.098715484, 0.22845487, 0.8864479, -0.08737793, 0.21481901, -0.46248505, 0.7353641, -0.20522636) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.30991596, -0.45724365, 0.32423875, 0.94306713, 0.46394897, -0.7221998, 0.4900241, -0.16105843, 0.37585723, -0.105693415, -0.2772179, 0.20974253, 0.12216086, 0.5863403, -0.06252949, 0.30965364) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.07810221, -0.17177927, 0.18192434, 0.38224548, -0.37985545, -0.33036223, 0.048196483, -0.25505105, 0.11761235, -0.13674913, -0.016642869, -0.121395305, -0.03285402, -0.23570131, -0.0404731, -5.3701402e-05) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.008375321, -0.13192406, 0.08201584, 0.12673987, 0.14523813, 0.13760827, 0.004377411, -0.017084643, -0.3378466, -0.017286116, 0.019425288, 0.04348007, -0.34232408, 0.16475092, -0.3622882, 0.17468135) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.04264065, 0.024957024, 0.2543097, 0.29465237, 0.002113154, -0.15097058, 0.19634712, 0.14072049, -0.19660439, -0.15658224, 0.44369662, -0.094335414, 0.1053092, -0.26900283, -0.043718494, -0.069146685) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.009630376, 0.04475395, 0.14353319, 0.017892893, -0.14145324, -0.11332399, 0.0889516, 0.015182838, -0.01505248, 0.07565932, -0.010755754, -0.15686782, -0.13640366, -0.020086734, -0.16527283, -0.12219593) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.21688505, -0.0065954668, -0.12166752, 0.26994318, 0.12666905, 0.047817875, 0.060072742, -0.0069949855, 0.28493735, 0.04899463, 0.27877194, -0.110173695, 0.048512656, -0.31301755, -0.06937446, 0.12875777) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.12665002, 0.29918513, 0.21640858, 0.0044954005, 0.11657123, -0.19650882, -0.14072041, 0.102655135, 0.09155823, -0.35832903, -0.13101326, 0.20275894, 0.40706193, -0.29102919, 0.051665932, 0.12989339) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.07878869, 0.020100925, 0.026943695, 0.18873118, 0.08531577, 0.06361482, -0.04514466, -0.13452578, -0.0639468, -0.21608882, -0.037329625, 0.012932245, -0.103159964, -0.26939866, 0.117825106, -0.07945274) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.44838744, -0.018128488, -0.30607575, -0.030446518, 0.10931958, 0.036187526, 0.07377407, -0.07059668, -0.053813048, 0.00021497995, 0.18986712, -0.04136639, -0.2931106, -0.11164049, 0.46412656, -0.2837876) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.52820104, -0.18925957, -0.4266277, -0.23011012, -0.12241246, 1.1433452, -0.29663235, -0.17605497, -0.15733701, -0.17656636, -0.29506883, -0.46435663, -0.23275991, -0.7945346, 0.09945116, 0.102665626) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.08438431, -0.20823441, 0.09783445, -0.056676432, 0.45701718, -0.22457112, 0.030590491, -0.30819243, 0.015680173, -0.25916973, 0.037490554, 0.29515034, -0.2714978, -0.19438252, -0.13465317, 0.30888492) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.2481146, -0.5767022, -0.20722046, -0.12112232, -0.063443385, 0.039254837, -0.1553876, -0.0071140337, 0.14120016, -0.07677041, 0.028286232, -0.033921324, 0.26575583, -0.28422305, -0.06257761, 0.1021366) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.16813889, -0.29045787, -0.04375926, -0.06165595, 0.7566627, -0.15694906, 0.08561675, -0.17545703, -0.31193614, 0.06694986, -0.17639786, -0.100790285, 0.5147927, 0.015670884, 0.24794677, 0.36890915) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.02290892, -0.15649752, 0.23306169, -0.01784012, 0.27542567, 0.13644771, -0.05265861, -0.23783904, 0.11995983, 0.04398772, -0.10677551, 0.17355533, 0.49657384, 0.063566506, 0.05758088, 0.064888686) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
