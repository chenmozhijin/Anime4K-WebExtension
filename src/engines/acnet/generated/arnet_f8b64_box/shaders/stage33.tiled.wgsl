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

  var result: vec4f = vec4f(-0.062556736, -0.17690401, -0.008798008, 0.14841345);
      result += mat4x4<f32>(-0.038025305, 0.026184496, -0.0015749737, 0.00015646798, 0.079313725, -0.13188833, 0.17630805, 0.12605959, -0.008845295, 0.13282226, -0.02896456, -0.1153312, 0.040245615, 0.13891001, -0.1255603, -0.0031142423) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.09050716, -0.10425643, -0.46815452, -0.11740652, -0.09514708, -0.06561, 0.1794812, 0.25466964, -0.022258177, -0.23798673, 0.19294111, 0.22751692, 0.044899832, -0.28147402, -0.06775263, -0.08832403) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.13566968, 0.17333452, 0.032110333, 0.121101655, -0.0025951953, -0.06556174, -0.06345001, -0.068142995, -0.12395643, -0.20598501, 0.022612737, 0.08408699, 0.018913887, -0.21680517, -0.1507772, -0.23171212) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.2403662, 0.17888694, 0.31415206, -0.13312851, 0.039138958, -0.028555676, -0.17275578, 0.07655267, 0.05642823, 0.19545959, 0.12648378, -0.025774557, 0.1577274, 0.23955886, -0.18804996, 0.110145286) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.28379124, 0.2969389, -0.6495759, -0.34100547, -0.4068023, -0.031199122, -0.23758523, 0.1333243, 0.39191884, 0.033639643, -0.25931498, 0.6212524, -0.08776022, -0.2296624, -0.032307208, 1.1074061) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.05240995, 0.4103701, 0.2778959, 0.0682219, 0.026416337, 0.07056703, 0.015993573, -0.060352687, 0.25954592, -0.64365077, -0.15669765, 0.1878139, 0.3148014, 0.13281076, -0.20893137, -0.36524466) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.07128491, -0.18114951, -0.04427445, 0.031858284, 0.085972935, 0.030944422, 0.011750713, 0.20110081, 0.015602348, -0.06478386, -0.07328418, 0.05917646, -0.15880607, -0.025346478, -0.17162949, -0.2656154) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.19544531, -0.49745312, -0.25650495, 0.10689519, -0.03482091, 0.07530692, -0.07800771, 9.7747696e-05, 0.05224167, -0.08838296, -0.18921877, 0.4084232, 0.12756719, -0.5798904, 0.05246332, -0.45516604) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.040073995, 0.17834583, 0.02749403, 0.07514246, -0.115529746, -0.042385332, -0.03229995, 0.15652163, 0.36851802, 0.044611566, 0.11810376, 0.25146607, 0.075205326, -0.14272387, -0.01728227, -0.15351431) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.05486145, 0.14044221, 0.010230131, 0.12938763, -0.015078396, -0.037733242, -0.069669016, -0.057348046, -0.08462811, -0.10783358, -0.0018135202, 0.047549598, 0.13016336, 0.039042626, 0.15513447, 0.17094019) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.042734917, 0.026179696, 0.08235368, 0.07774522, 0.08122473, 0.07080498, 0.08394334, 0.100631334, -0.1760895, 0.054933134, -0.27527383, 0.21439467, 0.01935455, 0.08772649, 0.15512072, -0.028449787) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.058835533, 0.09530348, -0.29981682, -0.0058954917, -0.06866902, -0.061737176, -0.028521534, -0.04992538, -0.050823156, -0.08547299, 0.01948728, 0.06914147, -0.05654786, 0.14042702, -0.09231365, -0.043428585) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.18501404, -0.24615635, -0.32622743, 0.3255542, 0.13338311, 0.04755436, 0.038486864, 0.2744933, 0.13043098, 0.1433542, -0.104602635, -0.039255824, -0.18207425, -0.27346832, 0.124884404, 0.00038977352) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.27213728, -0.19600111, 0.07662787, 0.78800184, 0.41479406, 0.2903945, 0.08281438, 0.33155406, 0.1780355, 0.20944574, 0.8742232, 0.14677434, 0.04621396, -0.10359857, -0.9579682, -0.377447) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.1343699, 0.36075065, 0.08868457, -0.036971018, 0.11458611, 0.20341983, 0.31915513, 0.008797642, -0.16196045, 0.23118433, -0.030148529, 0.053457987, -0.054594114, -0.2385757, -0.16212027, 0.10372207) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.11473986, 0.0918907, 0.06637826, 0.21155126, 0.24167663, 0.04634225, 0.089498386, 0.0038434477, -0.16097069, -0.19583896, -0.16353269, 0.156586, 0.24476413, -0.09424216, -0.0038285814, 0.041070703) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.15839022, 0.34564993, 0.25152326, 0.37869105, -0.068690546, -0.03837529, 0.4328966, 0.11519292, 0.53742045, 0.261614, 0.35971463, -0.15166174, -0.12795034, 0.0038533257, -0.6474287, -0.33117607) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.1905951, 0.06691798, -0.05063112, -0.065902226, 0.25643352, 0.06254941, 0.5414337, 0.3464015, 0.051033035, 0.11291694, 0.042028822, 0.15527065, 0.1638527, 0.32140365, -0.07012424, -0.22063458) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
