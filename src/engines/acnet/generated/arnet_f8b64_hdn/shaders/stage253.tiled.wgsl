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

  var result: vec4f = vec4f(-0.013474065, -0.3433595, -0.108070575, 0.035446923);
      result += mat4x4<f32>(0.040803038, 0.055527326, 0.03307684, -0.014953871, -0.009208972, -0.09958393, 0.0038064856, 0.03138393, -0.02087128, 0.31292665, 0.10773957, -0.035784148, -0.030360753, -0.26542452, -0.055186223, -0.022999108) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.07445652, 0.044532206, -0.15555571, -0.02408597, -0.08790069, -0.04138251, 0.11147602, 0.059375346, -0.064578965, 0.1498529, 0.063570306, -0.21169022, -0.27352554, -0.042273782, 0.027124703, 0.06104216) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.11071781, -0.13410857, -0.0046240664, -0.012354938, -0.023169985, -0.04335409, 0.04925805, 0.035795588, -0.061578974, 0.08861705, 0.017708099, -0.011199438, 0.012601675, -0.042129356, -0.043103497, 0.02335255) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.0023773683, 0.16289735, 0.05121208, -0.16542462, 0.020031726, 0.14990377, -0.074747905, -0.10375372, -0.3093955, 0.026804619, -0.41978425, -0.34372756, 0.032115836, 0.07861678, -0.10544096, -0.020442247) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.16784948, 0.24415937, 0.049362794, 0.008681331, 0.40199828, 0.21345907, -0.34240568, -0.096323125, -0.37685364, 0.048966624, -0.47627506, 0.23049985, 0.029369771, -0.36387262, 0.26928735, -0.5859115) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.046904847, 0.4378671, -0.23851128, 0.10878745, 0.17014566, 0.06729595, -0.27923244, -0.06798786, -0.081254005, -0.06538968, -0.047730017, -0.07904191, 0.01995538, 0.008034949, -0.07578053, 0.19123785) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.06822561, -0.15095226, -0.013903824, 0.0051569687, 0.020080524, 0.02712624, 0.042655297, -0.092841975, 0.11813523, 0.10970582, -0.045757737, 0.059712593, 0.06661593, -0.08376875, -0.0005055296, 0.012742656) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.18329899, 0.09585337, 0.21188569, -0.0029300565, -0.23357435, -0.37592924, -0.057385933, 0.017065484, 0.06541097, -0.026919993, 0.094071686, 0.025346166, -0.065595075, -0.15599337, 0.043034937, 0.17509079) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.14210734, -0.15779208, -0.017626671, -0.1446361, -0.12011478, -0.12145364, 0.15009686, -0.061867498, -0.03449492, -0.12554577, 0.026549948, 0.017868638, -0.09000127, -0.059794225, 0.1274881, 0.16541131) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.17635088, -0.114189886, 0.1628311, 0.16080165, -0.008312474, 0.16224678, -0.1170831, -0.05204352, 0.026528062, 0.10728137, 0.037624426, -0.035446078, 0.1791274, 0.17248319, -0.08255744, -0.03834622) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.2704259, -0.16488506, -0.008916877, -0.024007842, 0.23487918, 0.0061040553, -0.08229614, 0.015868008, 0.15368316, 0.15691091, 0.09615331, 0.12452667, -0.009607239, 0.062613055, 0.00039003877, 0.03822874) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.13729005, -0.009275398, 0.02572398, 0.2932158, 0.072568156, -0.0028676616, 0.023349866, 0.036017187, -0.06501704, 0.14503182, 0.02276486, -0.11897075, -0.037744366, -0.089315556, 0.09709097, 0.076214805) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.17113449, 0.002957337, 0.105532266, 0.14918853, -0.031149201, 0.04845586, -0.09830032, -0.19548377, 0.03966683, -0.10837555, 0.14593627, -0.12569772, -0.022585347, 0.14612584, -0.07817239, 0.022012142) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.39703304, -0.77962303, -0.18796925, -0.025082288, -0.48060098, 0.09643785, 0.39328513, 0.3286718, -0.6085426, -0.381927, -0.06425216, -0.23438074, 0.29072604, 0.3155998, 0.104193084, -0.18394807) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.16468874, 0.07950287, 0.09146194, 0.08515683, -0.056890897, 0.11544368, -0.023603357, 0.002719174, -0.105756745, 0.046820726, -0.30030477, -0.1141021, 0.13434473, 0.20982791, -0.18809825, -0.038084023) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.13770546, -0.0030989882, 0.1536949, 0.029416366, -0.44066757, -0.33904302, -0.10755057, -0.020568982, 0.08837187, 0.092584416, 0.116271146, -0.19227198, 0.40113056, 0.15891725, 0.12664066, 0.12379679) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.05911486, -0.15684792, 0.25015566, 0.4138072, -0.17869322, -0.16092479, -0.06232783, -0.03558126, -0.48712987, 0.15865235, 0.30033258, 0.3003056, -0.0012663588, -0.020090606, 0.0057835383, 0.08544819) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.19201729, 0.08606127, 0.14169621, 0.33534208, -0.09276904, -0.013124061, -0.10831108, -0.1899714, -0.026320562, -0.19842575, -0.2018475, 0.14214514, 0.15660396, 0.044855423, -0.02699015, 0.11123221) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
