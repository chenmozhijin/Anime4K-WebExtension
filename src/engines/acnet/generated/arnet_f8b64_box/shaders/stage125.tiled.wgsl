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

  var result: vec4f = vec4f(0.16948599, 0.09117829, 0.2692416, 0.24125932);
      result += mat4x4<f32>(-0.0940713, -0.17780195, -0.07177423, 0.15611365, -0.12228822, 0.045050334, 0.03252701, -0.22528243, -0.06896876, -0.0751135, 0.05260644, -0.09464284, 0.002052548, -0.12813376, 0.016211154, 0.056050792) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.009639187, -0.3119544, 0.3485618, 0.24273373, 0.0586872, 0.3194168, -0.4554086, 0.16104762, 0.009805524, -0.19474487, -0.024706345, -0.027612336, -0.06558289, 0.031138813, 0.40468132, -0.37893057) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.26251474, -0.27720168, -0.07256643, 0.07546838, 0.018800046, -0.024772085, -0.031159682, 0.0027809327, -0.0076968223, -0.049075287, 0.08725165, -0.060586467, 0.00026299764, -0.18217255, -0.08342108, 0.013047645) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.14463808, -0.36490214, 0.03658434, -0.0036357772, 0.120520264, 0.32379648, 0.12627856, -0.099552214, -0.09701198, -0.3119161, -0.020155888, -0.096015066, 0.26147372, -0.15298004, -0.2310122, 0.2055966) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.21092123, -0.35752952, -0.6028477, -0.31256044, -0.16814919, 0.20859908, -0.31612012, 0.0061997566, 0.07156314, -0.057878498, -0.037114892, 0.10839667, -0.12464972, -0.10637792, -0.090416685, 0.21873666) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.014529088, -0.26613104, 0.07200673, -0.111446746, -0.010546874, 0.084644064, 0.12118023, -0.22770615, -0.09278225, -0.14411756, 0.0999943, -0.07538108, 0.06560752, -0.032802954, 0.11588265, -0.21814646) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.0071467087, -0.26247582, 0.053604312, -0.05947721, 0.03485489, 0.02998349, 0.011853481, -0.009173849, -0.14354175, -0.43256825, 0.10310466, -0.26193988, 0.100796305, -0.085519604, 0.17690228, 0.0121454345) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.24395311, 0.048815925, -0.174928, -0.028505268, -0.18164729, -0.20850863, -0.17633283, 0.059432305, -0.083103396, -0.19592752, -0.089789726, -0.11933558, -0.08691697, -0.37867394, -0.2653037, 0.32932302) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.049725756, -0.16893795, 0.078600846, 0.023303475, 0.0672145, -0.0766302, 0.024689881, -0.05444908, -0.24906091, 0.1493321, -0.15234023, -0.36343306, 0.066634566, -0.45435038, 0.20244998, -0.058493886) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.0545813, -0.12224601, 0.14708334, -0.09560817, -0.15366505, -0.35661379, -0.38600865, 0.68980104, -0.09631791, 0.08638811, -0.11425684, 0.1311308, -0.024788145, 0.22515792, -0.16726166, 0.11359463) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.060881518, 0.0810337, 0.010728636, -0.39906663, 0.20197305, -0.27519554, -0.26691464, -0.8533095, 0.018586723, 0.035319485, 0.32189846, -0.15731825, -0.023520768, -0.01020015, -0.22979671, 0.19557549) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.045239866, 0.090463646, -0.010467122, -0.09271873, -0.20166096, -0.14829867, 0.15255116, -0.032532074, -0.07698041, 0.14909337, 0.013791998, 0.0064620576, -0.14213532, -0.14943592, 0.1705224, -0.2161823) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.20795617, -0.37616968, -0.0058449437, -0.2977855, -0.28510123, -0.28053263, -0.06849313, -0.089634545, -0.050100148, 0.034351937, -0.04879926, 0.17270672, -0.124956824, -0.20860271, 0.22735508, -0.18634278) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.14588585, -0.24368863, 0.17452703, -0.5823723, -0.16450262, -0.10595522, 0.08484071, 0.013063399, 0.12177453, -0.12647767, -0.054363832, -0.5580896, 0.1900955, 0.030450251, -0.37642056, 0.27974787) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.033393774, -0.10698449, 0.07419373, -0.078448094, -0.17204909, -0.21813002, -0.027860068, -0.11679245, -0.045193255, 0.067772776, -0.28231826, -0.020322662, -0.0532632, -0.023910591, -0.31163603, 0.1607117) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.11428094, -0.06924056, -0.04833857, -0.071582556, -0.08763068, -0.1754733, -0.07249823, 0.02959055, 0.010540947, 0.12878606, 0.05018226, 0.02942179, -0.18630412, -0.5068385, -0.23100011, -0.07090648) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.00090207445, -0.2320806, 0.08368333, -0.21819545, -0.19621931, -0.034890886, -0.09413255, -0.086383514, 0.17731181, 0.3761177, 0.19393857, -0.18566737, -0.10396179, -0.21591654, -0.14469291, 0.00455802) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.006398683, -0.17055067, 0.1221278, -0.16672735, -0.024527103, 0.020014394, -0.042401727, -0.0012994516, -0.088467784, 0.15065739, -0.056989357, -0.027592888, 0.12240503, 0.5719011, 0.26982853, -0.3514773) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
