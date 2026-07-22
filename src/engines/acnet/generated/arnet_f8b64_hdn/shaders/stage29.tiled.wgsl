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

  var result: vec4f = vec4f(-0.17317285, 0.09746341, 0.032463025, 0.012932621);
      result += mat4x4<f32>(-0.114276536, -0.25838444, -0.21797922, 0.05558345, -0.0697228, -0.1431514, -0.12533805, 0.009330914, -0.2691943, 0.027464587, -0.2063249, -0.31857592, 0.07707894, 0.08032085, -0.17636138, 0.25741193) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.13820192, -0.046651997, -0.54970175, -0.45255485, -0.3181062, -0.020155502, -0.089248866, -0.39310047, 0.4215715, 0.20139572, 0.36604488, 0.1511163, 0.3775047, -0.06622906, 0.215423, 0.05243206) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.14368577, -0.3688878, 0.026792811, -0.27555922, -0.21356143, 0.114740156, 0.27411783, -0.27526096, 0.06848134, -0.00418761, -0.33101627, -0.060526848, -0.07905884, -0.28466648, -0.2353082, 0.23100871) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.14068976, -0.17812711, 0.29239565, -0.28053948, 0.031684555, -0.106464185, -0.028139938, 0.08629515, 0.07679915, 0.20625779, -0.20806772, 0.24060018, -0.3319337, 0.24665406, 0.25390387, -0.51500213) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.39800173, -0.0007865716, 0.044199135, 0.12341781, 0.15499559, 0.55051243, 0.2418967, -0.22812068, -0.06446066, 1.085255, -0.40482923, 1.7823718, 0.015024333, 0.045188766, 0.5619414, 0.100489326) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.073474154, -0.30240077, -0.09783005, 0.11299324, -0.36455363, -0.018408276, -0.11565093, -0.09260427, 0.089853086, -0.071457066, 0.13637105, -0.19374245, -0.19066074, 0.19330621, -0.3545086, -0.17635426) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.11925805, -0.06328644, 0.032948717, 0.11723911, 0.04423092, -0.04129755, 0.07068206, -0.06757531, 0.13792345, 0.030067323, 0.13055508, -0.21558748, 0.03637509, -0.017513849, -0.10893307, 0.07010449) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.04599295, 0.44871277, 0.18351012, -0.029441556, 0.039326772, -0.035643127, 0.038947284, -0.20497522, -0.17399526, -0.24815598, -0.32314926, -0.37702167, 0.42728934, 0.29232413, 0.1746364, 0.19507904) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.0011644883, -0.04994577, 0.10784537, 0.21003114, 0.025439618, -0.12396833, -0.0737031, -0.100983515, -0.040465724, -0.08270826, 0.12927987, -0.054366797, -0.027906558, -0.15216215, -0.26607972, 0.067243986) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(0.02460503, 0.19774222, -0.21490546, 0.0067103184, -0.19544744, -0.07749728, -0.036728784, -0.0022889695, 0.06035858, 0.06628599, 0.22040205, 0.2545936, 0.1342005, -0.15198551, -0.04901696, 0.12512033) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.017216977, 0.293085, -0.069834165, -0.12722652, -0.11153214, 0.16858052, -0.4859864, -0.35007372, 0.03689287, 0.08856935, 0.072228216, -0.08640997, 0.3506899, 0.33924666, 0.8588532, -0.30367076) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.16293891, -0.076578096, -0.10679252, 0.09108181, 0.100053795, 0.11945076, 0.09267005, -0.038466685, -0.09676877, -0.27181393, 0.035720926, -0.16988921, 0.076843746, 0.15257542, -0.18245465, 0.13034315) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.18813731, -0.10413416, -0.11092474, -0.0061086444, 0.32804564, -0.38877958, 0.031888776, 0.2810244, 0.03035938, -0.2551, -0.15238576, 0.21968542, 0.35374, 0.28746122, 0.37174565, -0.14206663) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.47778293, 0.86900663, 0.19199179, 0.3562986, 0.50700366, -0.3265842, -0.79609334, -0.32204726, -0.18243279, 0.018067164, -0.014668454, 0.06805788, 0.46857905, 0.51785654, 0.084865935, -0.2846506) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.13363132, -0.10373524, -0.09128241, 0.60592455, 0.11222643, -0.6271555, 0.037266314, 0.5203608, -0.13000618, 0.61857665, -0.31791428, -0.5724705, 0.047171596, 0.14878406, 0.09955524, -0.31586558) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.011048765, 0.18713382, -0.043390956, 0.15434724, -0.095151804, 0.3024706, 0.14207348, -0.13070172, -0.048501506, 0.25353315, 0.16753975, 0.028074646, -0.05095976, 0.013050774, -0.054382086, -0.06914659) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.2377086, -0.19464816, -0.0912267, -0.024837235, -0.25206617, -0.72735673, -0.628505, -0.49536037, -0.09019105, -0.2704479, -0.284198, 0.21660434, -0.03943313, -0.1489715, -0.1169951, -0.025941527) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.2222766, -0.23766325, 0.11970372, 0.24567844, 0.11225518, -0.076847754, -0.012843554, 0.0028839707, 0.18815106, 0.18735048, -0.02402189, 0.178267, -0.083035395, -0.13931784, 0.05103228, 0.010430402) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_1[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
