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

  var result: vec4f = vec4f(0.27606386, -0.021749666, 0.3208711, -0.01201107);
      result += mat4x4<f32>(0.6605215, 0.056501523, -0.14363621, 0.35549158, 0.119824246, 0.018898524, 0.0007118557, 0.08744442, 0.2631348, -0.10975749, -0.102813385, 0.12782459, 0.11968649, -0.022653626, -0.1644806, 0.06381609) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.5153208, -0.03617894, 0.1054495, 0.12006262, 0.24168554, 0.112672836, -0.10706848, -0.001412701, 0.025312021, 0.0032331678, -0.19917844, 0.047662888, -0.19590732, 0.023971519, 0.091034815, -0.24051079) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.22858818, -0.09160741, 0.14049995, 0.052803498, -0.17404246, 0.068350375, 0.0015314469, 0.09774041, -0.013305578, -0.042723507, -0.05769201, 0.011063629, -0.11078501, 0.24848764, -0.12279948, -0.26401258) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.10066816, -0.05845817, -0.16685787, -0.081397444, -0.20889078, -0.17910405, 0.01171384, 0.06902527, 0.12094493, -0.16908565, -0.29288396, -0.085818395, 0.1594648, -0.053235143, -0.17301205, -0.011668782) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.57153803, 0.18880233, -0.003572618, 0.19984844, -0.089407034, -0.048762664, -0.34124175, -0.088724606, 0.20099178, -0.19121042, -0.102481805, -0.20205554, 0.14955592, -0.2129044, -0.03854044, -0.11768901) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.044414047, 0.16956526, 0.07442076, 0.1655371, -0.24419108, -0.051546857, 0.17768055, 0.46293035, -0.085258566, 0.052739732, -0.09454105, -0.0779952, -0.35740194, -0.10875406, -0.11056486, 0.17993434) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.04030109, -0.031822104, -0.061686367, 0.016977446, -0.09587726, -0.10702324, -0.1295401, 0.122424185, 0.23618774, -0.07388347, 0.080783986, -0.073691264, -0.15894708, 0.0032934356, -0.13171723, 0.016405813) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.22052872, 0.2513073, 0.14110956, 0.08557184, -0.14609222, -0.05441102, -0.1691706, -0.041717067, 0.2352737, -0.39980704, -0.26744887, 0.00049638277, 0.17201324, -0.052276433, -0.03690623, 0.015862258) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.26711118, 0.17740142, 0.18534833, 0.010905456, -0.045114614, -0.092101984, 0.041734386, -0.03069936, 0.05341671, -0.08991953, -0.19142365, -0.026450517, 0.24948986, -0.025210384, -0.0011511195, -0.10787711) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.13572755, -0.22061035, -0.077083685, -0.49393103, -0.08036003, 0.060558796, -0.024291528, -0.07501464, -0.15994619, -0.0789398, 0.037917834, -0.26160586, -0.11167869, -0.10920516, 0.22928724, 0.013728087) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.3768313, -0.055955987, -0.29235044, -0.47887787, 0.3985049, 0.016724003, -0.33648378, 0.23634472, -0.23400153, -0.22607332, -0.08275929, -0.06580356, -0.15889569, 0.09177679, 0.29281163, -0.16382197) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.1412925, 0.057222888, -0.06317629, -2.2431894e-05, 0.25609884, -0.04140785, -0.049511507, 0.16060744, -0.26945844, 0.08260286, -0.076863654, 0.15364698, -0.056481138, -0.09663275, -0.07833476, -0.22073224) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.33156404, -0.08028786, -0.034039527, -0.2727041, -0.044324473, -0.048553858, 0.102269955, 0.059470244, -0.18219599, 0.16692935, 0.1422305, -0.11362727, -0.48618975, 0.34718668, 0.31948328, 0.07507561) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.28808326, -0.6011137, -0.2475104, -0.1258526, 0.28370082, -0.12488356, -0.23837578, 0.049370237, -0.14437275, -0.29083273, -0.17171715, -0.06777817, -0.29571286, 0.17641151, -0.08376325, -0.16852501) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.42746794, -0.09848692, -0.18236862, -0.18580604, 0.45281664, -0.06766398, -0.058069013, -0.10648137, -0.22824761, 0.045453068, -0.061242096, -0.032446273, 0.030920375, -0.34534052, -0.15592816, 0.038070418) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.23060064, -0.20577483, -0.19902006, -0.053922184, 0.18874153, -0.013187806, -0.031320997, 0.08660632, -0.04512298, -0.04806811, -0.38880488, 0.26027405, -0.32350534, -0.08344546, 0.087155536, -0.07752071) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.22002086, 0.11746758, -0.031961087, 0.12310736, 0.42201856, -0.0022725768, -0.0012400673, -0.068685174, 0.03860517, 0.05504382, 0.2844647, -0.013082058, 0.06133952, -0.08071747, 0.01803709, 0.11123348) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.09058551, -0.2668366, -0.073865145, -0.36915353, 0.30474997, -0.11660699, -0.17265701, -0.12545337, 0.3184496, -0.04477604, -0.31820095, -0.11217287, -0.0038728835, -0.137979, 0.03122149, -0.017306203) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
