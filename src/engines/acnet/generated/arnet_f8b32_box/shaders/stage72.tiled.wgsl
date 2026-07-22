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

  var result: vec4f = vec4f(0.031257067, 0.12102508, 0.257896, -0.2553763);
      result += mat4x4<f32>(-0.0533703, 0.024430674, 0.041307528, 0.28549424, 0.09933868, -0.106103696, 0.022117225, -0.13854945, -0.039342992, -0.07856929, -0.20535427, -0.15623012, -0.048641518, -0.032134973, 0.030609997, 0.12692256) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.016009117, -0.16762654, -0.15928133, 0.047444973, 0.074735664, 0.34174824, 0.094195955, -0.049309313, -0.46036044, -0.1375384, 0.16222678, 0.4820099, -0.1002107, -0.24899939, -0.08128795, 0.36925423) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.11860067, 0.06910882, 0.10251944, 0.13264248, -0.049591213, -0.046128772, -0.08503855, -0.058910802, -0.29594788, -0.17327432, 0.16701661, 0.17100105, 0.045750394, -0.12822382, 0.021366406, -0.042044207) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.10627288, 0.07847807, 0.03920845, -0.42912322, -0.30292055, -0.20044266, 0.2100179, 0.28555328, 0.18987426, 0.18255411, -0.13167292, -0.045960445, -0.051706843, -0.20472997, 0.03342355, -0.08831759) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.12375377, -0.10459589, 0.25271216, -0.2525872, -0.3563192, -0.121121556, 0.090066366, 0.4232451, 0.09735071, -0.09355805, -0.5467996, 0.23300095, -0.30460683, -0.36386734, 0.1793323, 0.48446083) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.11945349, -0.57498544, 0.22935553, 0.07036302, -0.06306587, 0.15661623, -0.039542045, 0.13507445, 0.10151492, 0.071596, 0.0015012124, -0.10844857, -0.1717092, -0.19780053, -0.10913726, 0.2865036) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.14980027, -0.19635706, 0.056812372, 0.011793761, 0.14327316, 0.33967274, -0.007618514, -0.04171864, -0.21577306, -0.05989902, 0.09648456, 0.33249924, 0.051758315, -0.2535947, -0.05109051, -0.20690039) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.17687489, -0.16754895, 0.13564558, 0.26372978, -0.0752599, -0.20962611, -0.28895754, 0.20623942, -0.2990851, -0.14311548, 0.10231129, 0.25773728, -0.2771297, -0.11546568, 0.43111956, 0.46029297) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.13822393, -0.15701637, -0.3029486, -0.04288149, -2.425473e-06, -0.028581329, 0.1774953, -0.13361128, 0.0017820467, -0.029058725, -0.043837555, -0.022557449, -0.05189017, -0.040187288, -0.13354173, -0.028041223) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.067218564, 0.08926432, -0.11636661, 0.036679238, -0.21760297, -0.22948685, 0.14244856, 0.08670647, 0.06500644, -0.05236299, 0.0076563004, -0.017467448, -0.073643915, 0.11077601, 0.10577509, 0.19099262) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.100429356, -0.32506576, -0.20750931, 0.07512348, -0.19855376, -0.24098578, -0.010790826, 0.2799388, 0.48557055, 0.34629184, -0.21364065, 0.0026844281, 0.44110218, 0.13451132, -0.15065072, 0.28211516) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.067390926, 0.11830601, -0.04552921, -0.060671303, 0.057905156, 0.018582346, -0.09178009, 0.053722408, 0.031637963, -0.14293684, -0.0613989, 0.031141376, 0.017894402, -0.021999385, -0.078511156, 0.23486508) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.11013414, -0.497776, -0.135358, 0.021258589, 0.063811444, 0.13590688, -0.03048522, 0.6109182, 0.014071025, -0.07404432, 0.019153444, 0.36508358, -0.04512105, -0.07649905, -0.054599654, 0.20328698) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.24845988, 0.2382, 0.09043282, 0.25279978, 0.35821322, -0.6011706, 0.4180166, -0.3812577, -0.22205554, 0.5315168, -0.105176784, 0.08551653, -0.19556855, -0.06924712, 0.39103296, -0.40328994) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.12789041, -0.09086077, -0.2457515, 0.09764806, -0.06457906, 0.35358933, 0.19827396, -0.19489682, -0.25756183, -0.045119528, 0.681946, 0.007298438, -0.16532493, 0.006407379, -0.012105822, -0.093082584) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.13639987, -0.22372513, 0.0046295864, 0.3951537, 0.12494618, -0.002561546, -0.13906951, -0.08204745, -0.005000957, -0.15754, -0.10051825, -0.16351035, 0.105344385, 0.029616449, 0.01028298, -0.062420197) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.03704294, 0.03601762, -0.11945622, -0.19507898, 0.025916735, -0.18692286, -0.048532683, -0.023339711, 0.057574935, -0.000918107, -0.22583044, 0.41584277, 0.29197142, 0.4615394, -0.0805838, -0.24469858) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.17995705, -0.13617507, 0.091712326, 0.07470706, -0.10108611, -0.034554604, -0.22464597, 0.12286089, -0.02552265, -0.3195052, 0.09907066, -0.09456949, -0.054013085, -0.043373886, -0.007741527, 0.12716377) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
