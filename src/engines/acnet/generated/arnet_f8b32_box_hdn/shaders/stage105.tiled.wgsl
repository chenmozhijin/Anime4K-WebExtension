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

  var result: vec4f = vec4f(-0.10901505, 0.014372182, 0.1930426, -0.4288463);
      result += mat4x4<f32>(0.046812095, -0.09519272, 0.064369306, 0.022000343, -0.056160092, -0.08164788, 0.030438492, 0.17718129, 0.045061365, 0.091751136, -0.13470034, -0.2732119, 0.06420444, -0.37600374, 0.2721783, 0.20710719) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.019309727, -0.06712075, 0.47642496, 0.42729792, -0.13724902, -0.20364308, -0.04375593, 0.021682257, -0.10369882, 0.08847669, 0.09534789, 0.03042454, 0.1676357, -0.061899953, 0.026340127, -0.040096264) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.035816986, 0.18776518, 0.38856184, -0.27061507, 0.0015504047, -0.056402355, -0.027549593, 0.1078535, 0.16983323, -0.10046227, -0.0090043945, -0.0006875011, -0.00060804683, 0.04707316, 0.13508587, -0.118222) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.021188881, 0.4112722, -0.35572422, -0.20683442, 0.12178449, 0.17252237, -0.067544386, -0.09849521, -0.07017761, 0.16010334, 0.1868378, 0.33346608, 0.10952623, -0.4514606, 0.27942926, 0.310689) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.2839997, -0.009489573, 0.05300459, -0.09292357, 0.5270231, 0.035420347, -0.007953589, 0.15865698, -0.10920526, -0.037305906, -0.63902533, 0.29365507, -0.2924609, 0.6988003, -0.5640874, -0.41200945) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.23901302, 0.07364749, 0.105634004, -0.32801056, 0.016076913, -0.03904592, -0.02746505, 0.044221364, 0.08479616, -0.02794831, 0.074076146, -0.18764526, 0.043785337, 0.263903, -0.20122427, -0.17758232) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.030457988, 0.20003241, -0.17966674, -0.12013816, 0.103141904, 0.1659244, -0.11691367, 0.063830346, 0.05596856, 0.20678508, -0.5547144, 0.2669982, 0.17406248, -0.22281122, 0.20440342, 0.077931836) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.09526698, 0.4168698, -0.3048508, -0.3515934, 0.41714188, 0.290814, -0.4054642, -0.14436148, -0.14757182, 0.24560182, -0.26773572, 0.26789626, -0.25602496, 0.1311197, 0.28359315, 0.12989433) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.07419606, 0.09361117, -0.032374695, -0.10413061, -0.0567194, -0.045425277, -0.050030883, 0.0139816115, -0.08340713, 0.12908094, -0.11697934, 0.03814793, -0.25062922, 0.43088692, -0.31780913, 0.04950355) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.025449017, 0.23793907, -0.094315045, -0.1635, -0.11667638, 0.07834588, -0.09014109, -0.055977117, -0.05722794, 0.1252524, -0.033795767, 0.08955697, -0.0035200908, -0.118020855, 0.13472708, 0.08780906) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.1454154, -0.17077929, 0.29071137, 0.37346312, 0.17807515, -0.1837764, 0.34755993, 0.30225307, 0.055629496, 0.25506523, -0.030499965, 0.06867987, 0.07085887, -0.075912505, 0.10267108, 0.14950745) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.17579831, -0.08285433, 0.0062400135, -0.05756188, 0.19274183, -0.2741932, 0.23190248, -0.04176587, -0.16209318, 0.47413874, 0.23241077, -0.16115212, 0.029431704, -0.14389975, 0.080073155, 0.10108821) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.13670601, 0.07738524, 0.17507632, 0.23550868, -0.08001698, 0.22077477, -0.07142122, 0.051535428, -0.12180503, 0.10250699, -0.1297585, -0.008705521, 0.025542755, -0.15607822, 0.107235916, 0.09220525) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.3875295, 0.06350913, -0.43937632, -0.33716512, 0.27850375, 0.049965035, -0.19093114, 0.20978074, -0.063419595, -0.24788274, 0.6161454, -0.07571391, -0.13793683, -0.54700655, -0.32608193, -0.27636388) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.13741931, -0.009783625, 0.14931199, 0.04765471, 0.3090567, -0.06039361, 0.06050371, -0.20441623, -0.109511524, -0.010858706, -0.050766315, 0.27042213, 0.1571246, 0.0013577976, 0.15558031, 0.3130774) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.14444399, -0.0031644262, -0.077964135, -0.048538294, 0.00074786315, 0.0012302838, 0.023375848, 0.05725237, 0.029712971, 0.0015215152, -0.006833135, -0.033525873, 0.009313115, -0.22389755, 0.2933182, 0.22279553) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.24205211, 0.08652958, 0.050524563, -0.10980311, -0.073714145, -0.1515519, 0.20520894, 0.1369807, -0.016327836, 0.36995643, -0.4187852, 0.017581616, 0.1376121, -0.2313438, 0.3652522, 0.37415314) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.040364746, 0.07446927, 0.09698267, -0.07097228, -0.104078755, -0.12575386, 0.032436114, 0.08348575, 0.10904358, -0.11131648, -0.042815678, -0.053615443, 0.036568332, -0.1409462, 0.027154962, 0.059446413) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
