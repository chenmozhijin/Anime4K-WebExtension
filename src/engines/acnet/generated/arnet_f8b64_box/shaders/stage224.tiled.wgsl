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

  var result: vec4f = vec4f(0.019418094, -0.042282335, 0.18919355, -0.19921538);
      result += mat4x4<f32>(0.012926354, -0.059983704, -0.08173298, 0.0025740617, 0.08632089, -0.053029776, 0.05301042, -0.08206503, -0.13121021, 0.19674091, 0.00669201, -0.11352556, 0.04174085, 0.12462283, 0.04825587, -0.092556186) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.21579336, -0.60615885, 0.08309947, 0.31456622, -0.06861392, 0.19835962, -0.16059884, -0.050613515, -0.09069342, -0.1502064, -0.32279187, -0.10385451, -0.03526595, 0.029419947, 0.030659411, -0.06886456) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.047997225, -0.03925501, 0.04572924, 0.11234817, -0.06356529, -0.1234023, 0.10250587, 0.08801227, -0.021079632, -0.021089744, -0.06646801, -0.08875556, 0.033620585, 0.030496761, 0.05388181, 0.052250724) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.059849847, 0.08438791, -0.122045435, -0.121372886, -0.040084723, -0.07734852, -0.0010898899, 0.26727805, 0.26953694, -0.19843176, -0.10143306, -0.09418993, 0.3619057, -0.26417154, -0.57455873, 0.42295212) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.12042526, 0.5213237, 0.3379277, 0.06354499, -0.5241531, 0.021466633, -0.10165138, 0.28113806, -0.28924856, -0.21950585, -0.2934694, 0.06134831, -0.07344544, -0.36206847, -0.36110303, 0.09672555) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.016140189, 0.046058133, -0.012520087, -0.02515498, 0.26905566, 0.27878827, -0.04477139, -0.056364145, 0.019106323, -0.113228664, -0.019709058, 0.040488493, -0.039690617, 0.015035904, -0.010026416, -0.013672181) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.028525667, 0.021232601, -0.051754694, -0.052231185, 0.049212936, -0.11542954, -0.006269852, 0.100848086, 0.062612474, 0.09205629, 0.041689783, 0.050661296, -0.17835706, 0.04187343, 0.100285195, 0.07498406) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.057470046, 0.014224318, -0.12203164, -0.121801585, -0.03215814, 0.080454186, -0.07077193, 0.027230782, 0.15351899, 0.066567615, 0.17340325, 0.15663354, 0.08245579, -0.027845254, 0.08538507, 0.016304217) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.02659961, -0.033972304, 0.030932318, 0.04227845, 0.04589577, -0.10530501, 0.051465813, 0.15883814, -0.0017942869, -0.0069990037, -0.010589069, 0.066655464, -0.035214357, -0.060711406, 0.059214056, 0.113676295) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.1791059, -0.07751846, 0.03674228, 0.51135194, -0.013612672, -0.061375156, 0.100067385, 0.002416716, 0.007512946, -0.011213683, -0.09008232, 0.024318146, -0.03236866, 0.01920869, 0.06536855, 0.1433609) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.10338285, 0.019974098, -0.38320664, 0.0059722187, 0.054593988, -0.10259671, 0.06892896, 0.054044448, -0.12300578, 0.13917616, -0.21424602, -0.20739184, 0.053305145, 0.08863546, -0.0014883169, 0.11321918) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.09687019, -0.11557177, 0.09386991, -0.057224605, -0.014078902, 0.08030892, -0.024013162, -0.09321895, -0.0633381, -0.036284015, -0.11435666, -0.057769537, -0.055082545, -0.05509104, -0.07605941, 0.021524517) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.2096742, -0.14292888, -0.41430232, -0.09346315, -0.33347768, -0.028158821, 0.36405116, 0.09761974, -0.030695533, -0.032439467, -0.2392613, -0.11625694, 0.0753734, -0.111123145, 0.046565767, 0.02252759) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.13168561, 0.37828276, 0.52485746, 0.06684739, 0.14765047, 0.3235789, -0.11680828, 0.23355044, -0.18248451, -0.04148487, 1.0740323, -0.6320545, 0.66703796, 0.29739386, 0.16611467, -0.27696115) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.12022804, -0.022717094, 0.09602466, 0.18984206, 0.06944451, 0.075646825, -0.0027140381, -0.07715483, -0.1837095, -0.24835412, 0.075795315, 0.15249152, -0.12904952, 0.075154744, -0.15874429, 0.07033026) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.060299627, -0.019952316, -0.114284806, -0.10894713, -0.017021898, -0.14401498, 0.13309267, 0.22684468, 0.03174853, 0.0050428202, -0.14338908, -0.07929122, -0.005143409, -0.029354746, -0.012017698, 0.058474634) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.13804868, -0.031318106, -0.07680091, 0.13035136, -0.24862696, -0.11289212, 0.07162894, 0.076319665, 0.02467514, -0.124753945, -0.0942688, -0.13480145, 0.026013583, -0.08577711, -0.061445456, 0.1708588) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.01090548, -0.08424263, -0.02136631, 0.09345583, 0.07697234, 0.065542735, -0.015231702, -0.116239674, -0.20022634, -0.13387106, -0.12355118, -0.04097751, -0.017594462, -0.058816545, -0.041485623, 0.11820624) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
