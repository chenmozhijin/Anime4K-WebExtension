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

  var result: vec4f = vec4f(0.4518844, -0.09745697, 0.2641471, -0.06677308);
      result += mat4x4<f32>(0.00038094656, -0.036657564, -0.045072827, -0.099620394, -0.11207395, -0.015789917, -0.018985966, -0.008554523, 0.08323172, 0.099091455, -0.06414078, -0.013454629, -0.035908733, -0.12859723, -0.11056416, -0.084230535) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.27316827, -0.16736165, -0.10390278, -0.047695108, -0.31394917, -0.0025407106, 0.042658538, -0.07570183, -0.8760398, -0.0074013304, -0.22442259, 0.05584241, 0.072743885, 0.0084410105, 0.17449537, -0.10844874) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(-0.23494324, -0.13153525, -0.17640951, -0.029575871, -0.08437636, 0.03381784, -0.023108104, 0.060811073, -0.014352683, 0.01423625, 0.019220874, 0.06426331, 0.20007293, 0.085390605, 0.02178631, 0.066794634) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.053830758, -0.10057089, 0.08243739, -0.09720039, -0.35226575, -0.19555259, 0.13225585, -0.27046323, -0.10589636, -0.4134997, 0.06493472, -0.3299105, 0.10026418, 0.08656912, 0.013142697, -0.02056753) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.53041995, -0.09391633, -0.17102246, -0.18627618, 0.20361935, -0.07389406, -0.3733104, -0.11400799, 0.32921475, 0.26222757, 0.16034967, -0.7203358, -0.044020392, -0.00040585722, -0.36824048, 1.1914407) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.6409939, -0.05842908, -0.2629644, -0.50025856, -0.35673192, -0.17695287, -0.014084366, -0.07309895, -0.53922254, -0.043980226, -0.15504557, 0.33730623, -0.009342718, -0.14059083, -0.04767528, -0.38635242) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.06509065, -0.10226998, -0.047508486, 0.3438988, 0.032155395, 0.041307487, 0.111170605, 0.16300905, -0.0660424, -0.07047828, 0.01846473, 0.09779396, -0.12132696, -0.011107568, 0.002540331, -0.010119996) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.32735825, -0.21666262, 0.08895704, 0.98310846, 0.7997325, 0.50375164, -0.63319516, -0.15543117, 0.3012769, -0.11862403, 0.2042245, 0.23086603, -0.18390116, 0.09299464, -0.17764853, -0.14793697) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.015840542, 0.052563302, -0.056399222, 0.02986603, -0.043771468, -0.2504581, 0.06690452, -0.30519235, -0.08346332, -0.022142306, -0.071049854, 0.24441239, 0.03704854, 0.10249431, -0.08303328, 0.0938506) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.2684249, -0.0207781, 0.36944625, -0.4155695, 0.07716054, 0.10334239, 0.042110648, -0.040703736, -0.1700267, -0.12793127, -0.13854137, -0.25521326, 0.060936388, 0.06621097, -0.014713579, 0.18331324) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.5869643, -0.4175446, -0.31991148, 0.26861224, 0.237965, 0.1838136, -0.14261027, 0.007574752, -0.21129535, -0.24670194, -0.1927201, -0.38282943, -0.04722895, 0.24129607, 0.42302796, -0.033022925) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.18702097, 0.106917, 0.069625914, -0.0638552, 0.031004325, 0.11137358, -0.06357701, -0.2866104, -0.3319595, 0.018157966, -0.108681604, -0.37355793, -0.0658809, 0.10142592, 0.0024663352, 0.24390537) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.36490998, -0.123697385, -0.015301797, -0.3942119, -0.051713746, 0.26029915, -0.05681368, 0.19025576, -0.24151438, -0.028614877, -0.18590164, -0.30360425, 0.1491654, 0.11805756, 0.23854652, 0.16957563) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.053811654, -0.010926785, 0.08441989, 0.10786421, 0.07090172, -0.145611, 0.5991506, 0.1753046, 0.054305412, 0.022514222, -0.29763913, -0.3372684, -0.09470713, 0.3980668, -0.32559845, -0.21427928) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(-0.010775433, 0.09127411, 0.12890306, 0.050652657, -0.23234975, -0.10930188, 0.10545794, -0.040796664, -0.39851072, -0.24657968, -0.11340188, -0.38996485, 0.043006543, -0.23090221, -0.03730651, -0.21980408) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(-0.17396154, 0.34747383, -0.22359495, -0.17263387, 0.10280031, 0.042453557, 0.11069076, -0.0045198505, -0.06956543, -0.028247697, -0.019435724, -0.27551377, 0.014659341, 0.033064798, -0.005161275, 0.13352779) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.057937805, 0.1669591, 0.16744511, -0.19045687, -0.02637286, 0.11368877, 0.09072826, -0.32914042, -0.23541246, 0.046054833, -0.13487889, -0.46209148, 0.27568725, -0.45986107, 0.12745655, 0.58066005) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.1204021, 0.046985142, 0.0037622426, 0.40505952, 0.15549593, 0.26891425, -0.05787192, 0.34285903, -0.08169166, -0.103171244, 0.0034088288, -0.25757563, 0.17554772, 0.004523647, -0.015518001, 0.10024214) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
