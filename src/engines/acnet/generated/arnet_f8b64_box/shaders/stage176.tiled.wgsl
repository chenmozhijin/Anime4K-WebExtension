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

  var result: vec4f = vec4f(0.088733666, 0.12400125, 0.1973549, 0.025663955);
      result += mat4x4<f32>(0.34145123, 0.013786474, -0.21055773, 0.020467784, 0.12315803, -0.23356424, -0.17642488, 0.15321039, -0.10944315, -0.06879912, -0.1882399, 0.02838192, -0.13515033, -0.033321142, -0.24767002, 0.23344839) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.07861542, -0.124560095, -0.26985076, 0.09302325, 0.14913443, 0.098037414, 0.16603068, -0.16195671, -0.29058385, 0.01582574, -0.03078981, -0.02648045, -0.0038701068, 0.11254977, -0.09733158, 0.1683739) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.065687664, -0.030081412, -0.010861583, 0.18477814, -0.45096198, 0.017726593, 0.028639358, -0.1291089, -0.08574527, -0.021165088, -0.17692824, -0.028927231, -0.15016, 0.1212952, -0.0075282725, 0.2773572) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.14061974, 0.08674973, -0.17458686, 0.1832415, -0.38269147, 0.31399003, -0.04896313, 0.04615076, -0.1775659, -0.05209031, -0.25007623, 0.1367469, -0.44060794, 0.26691115, 0.10891196, 0.11878694) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.23068087, -0.08124771, 0.3735366, 0.23782422, -0.36324683, -0.17680655, -0.30091855, -0.3254089, 0.034168612, 0.03639217, -0.21107756, 0.34617028, -0.20890789, 0.03444219, -0.6871791, -0.6464119) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.02819427, 0.07216485, 0.18925343, 0.19280957, 0.44303772, -0.28869772, 0.37036023, 0.44595602, -0.06153725, -0.08388046, -0.101301104, 0.0770021, 0.17703685, 0.19097182, -0.08536369, 0.36674556) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.21102603, 0.07592563, -0.052126456, 0.1047892, 0.400368, -0.1697267, -0.10820092, 0.21120176, 0.007110695, 0.116165236, -0.21426517, -0.10203837, -0.0514906, 0.039750524, 0.035589855, 0.18294403) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.16724662, 0.12961169, 0.18368384, -0.04651106, -0.12371019, -0.080269895, 0.0735063, 0.03339083, -0.10817478, -0.052995365, -0.39118516, 0.1787146, 0.21530737, -0.062265906, -0.15363562, 0.3059413) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.11306562, 0.028690882, 0.09962041, -0.1553077, 0.017360376, 0.08715173, -0.1320432, -0.087209076, 0.03724628, -0.13539243, -0.31128657, -0.033677444, -0.09807096, -0.13648447, -0.025651721, -0.07257807) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.020148212, 0.10645894, -0.017855745, 0.31453064, 0.24797963, -0.327816, -0.23998387, 0.47381458, 0.058750294, 0.025969164, 0.0587094, 0.043375567, 0.067250036, 0.06898732, 0.16031556, 0.21989195) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.20678881, 0.047680125, -0.05562798, 0.4034249, 0.042887032, -0.088874444, 0.040674534, -0.04032273, 0.06999031, 0.06205508, -0.0021281138, 0.09834508, -0.16089092, 0.3518962, 0.071170114, -0.026007304) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.046428338, 0.09194666, 0.1261052, 0.1285948, 0.037817545, 0.3286718, 0.39974168, 0.25099656, -0.012363201, -0.08369806, -0.0013065704, -0.14499429, -0.029722158, -0.14703879, -0.040429257, -0.25895476) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.30904198, 0.24066916, -0.097846344, 0.043822784, 0.028369138, -0.16405177, -0.0026093852, -0.10062903, -0.14369206, -0.0032628328, -0.061753843, 0.3780647, 0.06705554, 0.15666598, 0.14818722, 0.22946742) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.024887834, 0.16478686, 0.1942898, -0.3521975, -0.22822765, 0.17539892, -0.15357138, -0.21465446, 0.523059, 0.057898708, 0.0026733587, -0.7502614, -0.06640764, 0.43387917, 0.4148242, -0.13448574) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.12639332, 0.12174082, -0.11616291, -0.06380972, -0.08039417, 0.2439722, 0.19861473, -0.29338026, -0.038845193, 0.08481226, 0.018880166, -0.12179942, -0.093721226, 0.22477664, 0.03455385, -0.27392548) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.13808165, 0.121224076, 0.06314311, 0.06956125, 0.08990936, -0.40349898, -0.38943127, 0.16384207, -0.11745655, 0.006854986, -0.02658748, 0.16960517, -0.04622725, -0.3486811, -0.18389992, 0.4665473) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.23912188, -0.244218, -0.18795724, -0.13930249, -0.036512084, 0.11899672, -0.07848145, -0.28480884, 0.14773326, 0.111933224, -0.018089227, -0.09279434, 0.2370411, -0.12947932, -0.06756673, -0.03782025) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.036454387, -0.028410967, 0.029739434, 0.23723614, -0.07528989, 0.27098832, 0.26518285, -0.3356832, 0.07448225, 0.031632476, -0.04894664, 0.072312534, -0.1103681, -0.3400793, -0.3714647, -7.675726e-05) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
