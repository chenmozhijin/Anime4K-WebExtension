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

  var result: vec4f = vec4f(0.03549737, 0.19857864, 0.13441104, -0.17885318);
      result += mat4x4<f32>(-0.13647777, 0.0018197612, 0.11817172, 0.26134226, -0.004167413, -0.09450887, -0.03557756, -0.08980999, 0.104273334, 0.050224654, -0.29215625, -0.3584898, -0.08931821, -0.041188963, 0.096437104, 0.0924188) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.02846646, -0.2511039, -0.26498258, 0.20786533, 0.08081578, 0.35362807, 0.059295796, -0.33403012, -0.41064075, -0.058559787, 0.11979231, 0.36822435, -0.053521957, -0.32350206, -0.058576554, 0.43386608) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.20548612, -0.019186115, 0.038410794, 0.21894664, -0.10172627, 0.18918517, 0.066296734, -0.13201843, -0.13445431, -0.055584926, -0.14257477, 0.16435094, -0.04327719, -0.0011986403, 0.015946308, -0.032672435) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.21675135, 0.16765028, -0.055793703, -0.5902567, -0.3760981, -0.31504595, 0.30899176, 0.22850275, 0.22790776, 0.21161024, -0.01929923, 0.08358708, -0.06288913, -0.20622772, -0.058724485, -0.028772015) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.11579087, -0.3523393, -0.008446392, -0.29516461, -0.17963436, 0.09061482, 0.35325265, 0.41089776, 0.081831686, 0.023798749, -0.63352704, 0.25061557, -0.20842262, -0.6827169, 0.4196183, -0.023374893) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.11923867, -0.3156384, 0.3663496, 0.0021021594, 0.04042486, 0.17580965, -0.3454001, 0.09794272, -0.061248668, 0.108399026, 0.16092467, -0.006200576, -0.120781004, -0.31039143, 0.25558257, 0.17885175) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.15634225, -0.2149599, 0.095225535, -0.019317608, 0.275109, 0.3033203, -0.22352742, -0.010985115, -0.23973443, -0.30860406, 0.100765534, 0.3275204, 0.023025429, -0.15646914, -0.10898798, -0.15636173) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.14725271, 0.021276949, 0.045286324, -0.007460037, -0.113451906, -0.281116, -0.345487, 0.2864298, -0.22989069, -0.2724144, 0.18667303, 0.09558499, -0.30221462, -0.17789346, 0.494515, 0.3993611) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.10604903, -0.30467382, -0.27933016, 0.028437994, -0.100007325, -0.050510075, -0.050253797, -0.03216771, -0.02907404, -0.100701064, -0.018374316, 0.07051104, 0.13991958, 0.030349137, -0.15613034, -0.23626351) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.076549, 0.012761046, -0.06849392, 0.16072284, -0.19475754, -0.1656388, 0.05913066, 0.0926137, 0.06657959, 0.08415249, 0.035051774, -0.16317704, -0.02355085, -0.04534902, 0.23661089, 0.2661465) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.0926015, -0.17145574, -0.21820568, 0.1666681, -0.2928684, -0.24929668, -0.049971044, 0.11489603, 0.38691843, 0.28026897, -0.4192709, 0.11826804, 0.41968593, 0.12775603, -0.23360457, 0.29932696) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.063070364, -0.09525821, -0.16091558, 0.098461576, 0.0013825053, -0.16354586, -0.25857896, 0.079395086, 0.0253561, -0.04026306, -0.18394421, 0.07128547, -0.0076486715, 0.020099727, -0.009672141, 0.14264569) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.012683607, -0.21874996, -0.16768618, 0.26688948, 0.17901847, 0.19305442, -0.105787516, 0.44358343, 0.02472081, -0.15968071, 0.076896206, 0.13937162, 0.05959437, -0.2553618, -0.25264853, 0.152684) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.28113616, -0.072644226, 0.0003023667, -0.14585899, 0.44660494, -0.34310928, 0.4371592, -0.4443659, -0.24628247, 0.72840714, -0.11332815, -0.055797208, 0.06997011, 0.056468297, 0.09150423, -0.41756126) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.020941665, -0.15140367, -0.3015244, 0.04638886, -0.04437846, 0.38363725, 0.11120358, -0.39276573, -0.18271329, 0.023941632, 0.8292805, -0.07346471, -0.016920237, 0.1416342, -0.26152852, -0.39982828) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.07077988, -0.35842037, -0.1622255, 0.17175558, 0.022517547, -0.123002626, -0.18595996, 0.17835641, -0.033612028, -0.20484504, -0.07349644, -0.13033098, 0.084721506, 0.16347767, 0.097410165, -0.12907858) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.019825453, 0.010724469, -0.025746576, 0.19648018, 0.17114754, -0.052040186, -0.25919774, -0.18579121, -0.0049468055, -0.21367982, -0.25247023, 0.22423567, 0.35553157, 0.5511327, -0.25756478, -0.35632515) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.074678265, -0.015216084, 0.15574811, -0.034952857, 0.02701922, 0.054352418, -0.30626512, 0.0856041, -0.010375714, -0.28999808, 0.068171486, -0.067675695, -0.10403873, 0.20852906, 0.21781448, 0.0123730935) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
