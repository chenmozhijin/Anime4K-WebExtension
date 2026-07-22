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

  var result: vec4f = vec4f(-0.09707444, 0.22185905, -0.05966558, 0.07947887);
      result += mat4x4<f32>(0.11824311, 0.37626326, -0.1463582, -0.10033341, -0.037415113, 0.06979254, 0.021941539, 0.10329858, -0.08463157, -0.18969885, -0.06621581, -0.027308954, 0.0454901, -0.09793122, -0.1529415, -0.13163544) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.10380802, -0.57443786, 0.472202, -0.54477596, 0.048882533, -0.10887712, 0.11360031, 0.11386974, 0.18324827, 0.033316575, -0.017478978, -0.045672126, 0.13344693, 0.033647593, 0.18184754, -0.37931156) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.18900833, 0.003023144, -0.027274668, 0.049908727, 0.0476244, 0.119380355, 0.09578797, 0.009613138, -0.14492325, -0.23752744, 0.17630972, -0.0015528061, -0.028111435, -0.05318939, -0.07382566, -0.022959024) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.057987235, -0.16612229, -0.37157977, -0.28829718, 0.056526124, -0.07960634, 0.113012224, 0.06571427, 0.002740366, -0.4792662, -0.31487098, -0.22346005, -0.065685615, 0.06103019, 0.20705225, 0.44852632) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.046059884, -0.26024744, -0.07037597, -0.6972757, 0.19488645, 0.03714306, 0.007623447, 0.11101808, 0.5699738, -0.11832352, 0.2501979, -0.22098486, 0.02715964, 0.029946074, -0.25178143, 1.2008165) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.1794016, 0.009049306, -0.07518191, 0.45864332, 0.0748107, 0.041311976, 0.122726776, 0.14184815, -0.41858712, -0.4672932, 0.28400356, -0.18184035, -0.015851408, -0.022567457, 0.025992539, -0.29780978) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.10998341, -0.21519601, -0.05084693, 0.08122794, 0.06204163, -0.062521696, 0.051237136, 0.017654572, -0.18783684, -0.4638034, 0.005963799, 0.13344315, -0.08397668, -0.23216684, -0.05187012, -0.01949512) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.03288156, 0.25085783, 0.054911695, 0.20987616, 0.16263953, 0.0074156905, 0.09235823, -0.04400376, 0.659067, 0.46537277, 0.23540509, -0.47357717, 0.009802695, -0.12677494, -0.08088422, 0.11227961) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.017167216, 0.22382627, 0.017318828, 0.27178925, 0.13797842, -0.022101961, 0.035727702, 0.10956046, -0.14604269, -0.36096284, -0.14650407, -0.2450892, 0.01017327, -0.07491772, 0.048495445, -0.04570538) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.087150194, -0.07830709, 0.050236, -0.020439979, -0.014207673, 0.06675316, 0.09091556, -0.006404267, -0.010202278, 0.063147746, 0.05772149, -0.0077659236, -0.025288522, -0.09782178, 0.116848946, 0.041033506) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.026223347, 0.14178596, 0.04823406, -0.064130135, 0.20906939, -0.07957259, 0.073188744, 0.06308295, 0.082211375, -0.011183821, -0.26035416, -0.19639894, 0.0050949897, 0.27205008, -0.081918985, -0.010885264) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.050471596, -0.101056345, -0.043855365, 0.10047095, 0.09202221, 0.036097884, 0.083943, 0.20632201, 0.06163747, 0.011797579, -0.021600768, 0.060763877, 0.06201609, 0.19002448, -0.053197734, 0.030608775) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.3383259, -0.5227015, -0.3086985, 0.22015423, 0.007215198, -0.04886936, 0.07278075, -0.006026458, 0.11495525, 0.14370266, -0.10554047, 0.33229178, -0.062454637, 0.11672695, 0.05630348, 0.14354691) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.1239408, -0.026031533, 0.09869061, -0.09484094, 0.35972667, 0.019959068, -0.08430614, -0.04188731, 0.32879922, 0.023260567, -0.1363875, -0.40234113, -0.023523543, -0.34879503, -0.016667679, -0.38088953) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.12007026, -0.011556124, 0.1548697, -0.059300557, 0.050013468, -0.034774642, -0.0723647, 0.37182963, 0.15860815, 0.12852609, -0.088057764, 0.045817025, 0.32110885, 0.4092564, -0.1267842, 0.20511901) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.02483877, -0.40167415, -0.13797902, 0.03399182, 0.12920886, 0.10581907, -0.015601533, -0.021194967, -0.016929837, 0.027448047, -0.2687288, 0.36611637, 0.037346028, 0.3499875, 0.016124848, 0.033049945) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.00035542945, -0.23250347, 0.25923598, -0.3744641, -0.32701465, -0.8198442, -0.42641506, -0.5740264, -0.10945282, -0.36187813, 0.069773234, 0.24309884, -0.026202284, 0.2561873, -0.017683793, 0.19787635) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.07635538, -0.212763, -0.02820299, 0.006890659, -0.27940133, 0.045209907, -0.22657046, 0.073176414, 0.06065231, 0.09411778, 0.0047788247, 0.0799436, 0.10870078, 0.228421, -0.021202313, 0.31116313) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
