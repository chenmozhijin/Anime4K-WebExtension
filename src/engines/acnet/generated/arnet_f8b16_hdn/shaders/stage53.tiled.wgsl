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

  var result: vec4f = vec4f(0.39942718, -0.5926864, 0.17337091, 0.038586315);
      result += mat4x4<f32>(-0.16410062, -0.06428796, 0.08492489, 0.072698995, -0.23398396, 0.19368097, -0.046994552, -0.13711707, -0.20556295, 0.13653024, 0.10537474, -0.094269805, 0.020475235, -0.068242565, -0.017058518, -0.060596313) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.029151618, -0.07923619, -0.037246633, 0.23946013, 0.6412626, 0.35089576, -0.72111, -0.19295837, -0.024742534, -0.022876827, 0.22010899, -0.23605227, 0.033777107, 0.100058615, -0.016002985, -0.04941203) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.05715087, -0.018166313, -0.118150085, -0.06573163, -0.0025036049, 0.020509724, -0.00996073, -0.049229134, -0.08971776, -0.11075658, 0.19642629, -0.13381666, -0.011111165, 0.016415512, -0.055674415, 0.08438789) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.19555274, -0.32967785, -0.0559744, -0.1905311, -0.05945193, -0.14692217, 0.09650594, -0.06164857, 0.101062186, 0.3347861, 0.08615952, -0.019317934, -0.16189402, -0.13192306, -0.17988014, 0.0033006377) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.07670281, -0.10745869, -0.38781554, -0.30137777, 0.42450726, 0.15908347, -0.01900764, -0.32704717, -0.3406454, -0.18703836, 0.6067065, -0.6628795, 0.6278453, 0.30902976, -0.65409017, -0.355638) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.23727983, 0.08060895, 0.17349415, 0.43797287, 0.03204895, -0.25669572, 0.094519936, -0.12563011, 0.33079773, -0.17716748, 0.088789895, -0.1494429, -0.16634879, -0.07629116, -0.030050091, 0.14325464) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.06557632, 0.04599923, 0.06434042, -0.07491527, 0.015144613, -0.067024305, -0.004197349, 0.040964317, 0.06119214, 0.13149813, -0.039793897, 0.18937238, -0.11514496, -0.09568457, -0.0862296, 0.039275706) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.06354209, -0.060944613, 0.10711238, 0.107555166, 0.053736072, -0.043961503, -0.009560936, -0.08824686, 0.14110081, 0.19357072, -0.11401021, 0.20033176, -0.37888816, -0.11710079, -0.07230077, 0.049479835) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.04834089, 0.28603378, -0.17413542, -0.059996504, -0.00031341595, 0.042831242, 0.016366664, 0.08452723, -0.17307039, 0.14214675, -0.00084663904, 0.18648931, -0.06061834, -0.017418928, -0.09184091, -0.13947418) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.08045595, 0.044647567, -0.08435839, -0.17749403, 0.114112094, 0.053200983, 0.10170633, -0.015738014, 0.06664848, -0.023481274, -0.056471642, 0.01775384, -0.030032145, 0.16741376, 0.17124088, 0.021273531) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.08563905, 0.23666127, -0.5480994, -0.41947973, -0.07794066, -0.07000084, -0.0022531184, 0.11554219, 0.14028491, -0.0073428284, -0.23052335, -0.23709211, -0.03256736, -0.1725333, -0.22682427, -0.19938894) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.13394964, 0.15278581, -0.20539352, -0.33140633, -0.20806012, -0.07398572, 0.10912694, 0.18175347, 0.04390619, 0.03021088, 0.06356955, 0.058429163, -0.08467179, 0.03591464, -0.07604625, 0.18217516) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.0365354, -0.08236815, 0.13368781, -0.14252429, -0.14164732, -0.21918939, -0.026856605, -0.0044446583, 0.3165451, 0.06298704, 0.15734386, -0.09213304, 0.063761875, -0.48855707, -0.15435468, -0.002295892) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.47649264, 1.080941, -0.24870175, -0.32572535, 0.20168547, 0.41082937, 0.31584638, 0.52103186, -0.07727349, -0.23676723, 0.010359454, 0.38044, 0.13614623, -0.63912, 0.43796444, -0.06200653) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.07291894, -0.3257214, 0.1459135, -0.034515064, 0.09496942, 0.0553425, -0.13461651, -0.16403456, 0.04773741, 0.06619926, 0.026990477, -0.1318189, -0.08223127, 0.3949625, -0.19471018, -0.057431515) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.030532992, -0.043277126, 0.082438044, -0.08777893, -0.09207789, 0.040432304, -0.027140804, -0.02642668, -0.17686406, 0.4496331, 0.034008577, 0.025526594, 0.012494477, -0.029528495, 0.053534042, 0.012440251) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.17934927, 0.23279582, -0.048589423, 0.051026177, -0.08699021, -0.0069860006, -0.11096255, 0.030458452, -0.6994309, -0.15232223, 0.59259367, 0.17569797, 0.12153284, -0.07516892, 0.07327608, -0.12549642) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.055260476, 0.13103509, 0.09948193, 0.029571107, 0.035355248, -0.36558047, 0.0098158, 0.06623824, 0.06346387, 0.23789236, 0.06375102, 0.024736421, -0.042493083, 0.035289153, -0.0171043, 0.039050415) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
