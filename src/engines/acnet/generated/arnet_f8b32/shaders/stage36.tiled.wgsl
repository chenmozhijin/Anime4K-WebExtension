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

  var result: vec4f = vec4f(-0.11155968, -0.13488655, 0.12953185, 0.079031296);
      result += mat4x4<f32>(0.00019148168, -0.13853589, -0.22228357, -0.09352276, -0.0025519321, 0.06664177, 0.0932431, 0.14538357, -0.17427273, 0.29066488, -0.09540639, 0.12025225, 0.055734344, 0.28131536, -0.012263668, 0.29907286) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(-0.18526737, -0.033830684, 0.12431983, -0.07642657, 0.23128477, -0.04682322, 0.21960242, -0.1276742, -0.18636477, -0.12314886, -0.100496724, -0.14997667, -0.1982918, 0.12563679, -0.2554474, -0.0027314841) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.057480797, -0.054773767, 0.07044831, 0.08020934, -0.047300536, -0.025885884, 0.049745213, 0.16700241, 0.032775987, -0.32118353, 0.10433718, 0.10468985, 0.10169633, -0.21693686, -0.08153182, 0.055862036) * tile_TMP1_TEX_0[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(-0.022774355, 0.18284158, -0.01844036, -0.18820608, 0.06812571, 0.25853854, -0.11118152, 0.09854671, 0.2655929, 0.012021202, -0.0902652, 0.42326325, 0.28782082, 0.22799139, 0.013447378, 0.09141347) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(0.050123416, -0.4999732, -0.52975184, -0.21085432, 0.15708463, -0.09481452, 0.26935273, -0.008013112, 0.173169, 0.2052743, -0.4946253, -0.09493161, 0.34008422, 0.3262815, -0.16099042, -0.28657672) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.027047157, 0.17372975, -0.2234037, 0.10327523, -0.06934294, -0.22947425, 0.08493876, 0.17078885, 0.079993606, 0.031869892, 0.065034054, -0.24853934, 0.0849872, 0.15735573, 0.013791632, 0.2766709) * tile_TMP1_TEX_0[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.0830976, -0.030648956, 0.1265091, -0.06821688, 0.2204386, 0.08355277, -0.19341573, 0.0015616849, -0.0054066833, 0.15830745, -0.17325795, 0.028416704, -0.23500718, -0.036749043, -0.18107577, 0.19574487) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(0.09760377, 0.037132435, 0.07774799, -0.40329573, -0.12329497, 0.2165144, 0.58964974, -0.0076855086, -0.37960812, -0.13218455, -0.092960835, 0.24697557, -0.14946145, -0.106646836, -0.09425089, 0.097029) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(0.0136287995, 0.3135459, 0.19816509, -0.15628009, -0.069240086, -0.07839481, 0.09555729, -0.01970597, -0.047122233, 0.13734785, -0.024107497, -0.41182545, 0.023631135, -0.06639302, -0.08338446, 0.13447675) * tile_TMP1_TEX_0[localId.y + 2u][localId.x + 2u];
      result += mat4x4<f32>(-0.03233889, 0.046247017, 0.18855277, 0.19985574, -0.07886344, 0.07579929, 0.21375878, -0.16772342, -0.09802992, 0.054120537, -0.07042581, -0.07645901, 0.0996813, -0.13400608, -0.035864014, -0.054551903) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 0u];
      result += mat4x4<f32>(0.13630573, -0.24304126, 0.14401895, 0.06709831, 0.11356667, 0.114129476, -0.035564348, -0.6269908, -0.088048875, 0.2582913, -0.14984407, -0.1874336, 0.03570617, 0.17747146, -0.081472635, -0.30212286) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 1u];
      result += mat4x4<f32>(0.13896018, -0.05429672, -0.08634158, 0.01170092, -0.0033923192, 0.10144766, 0.043673873, -0.0540518, -0.010571548, 0.18985353, 0.1285778, -0.15756962, -0.039669614, -0.13919306, 0.02444231, 0.14844222) * tile_TMP1_TEX_1[localId.y + 0u][localId.x + 2u];
      result += mat4x4<f32>(0.09419969, 0.44722033, 0.2358614, -0.11506055, 0.07464613, 0.19682044, 0.32772934, 0.027013388, -0.028339988, -0.049872335, -0.3987437, -0.3396223, -0.05340147, -0.11381853, 0.040827975, 0.2801219) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 0u];
      result += mat4x4<f32>(-0.1286369, 0.48193592, 0.21452634, -0.5901869, -0.02358084, -0.23279347, 0.39486295, -0.043680493, 0.069451615, 0.3449204, -0.12279974, 0.40438718, 0.26432493, 0.36099482, -0.45047325, -0.33866563) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 1u];
      result += mat4x4<f32>(0.08351731, -0.15968427, 0.14746688, -0.057199076, -0.02362202, -0.020836046, -0.013271893, -0.2791492, 0.048524607, 0.40754932, 0.07629561, -0.06089274, -0.12832606, -0.10230112, 0.14048763, -0.09343424) * tile_TMP1_TEX_1[localId.y + 1u][localId.x + 2u];
      result += mat4x4<f32>(0.015874978, -0.06282833, -0.3710354, -0.26477283, 0.12821315, 0.15961815, 0.14596897, 0.08787633, -0.0150385285, 0.1972343, -0.0061456384, 0.09394714, 0.3213717, -0.10252681, -0.14139473, -0.30630484) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 0u];
      result += mat4x4<f32>(-0.10007603, 0.06943968, -0.39449313, -0.00021004888, 0.045591768, -0.21531686, 0.030972682, 0.1958402, 0.2311506, 0.35614246, -0.5743578, 0.09705736, -0.14787625, 0.15129188, 0.5260422, -0.74287593) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 1u];
      result += mat4x4<f32>(-0.076466806, 0.22623856, -0.07493154, 0.057337727, 0.13372652, -0.13074942, -0.07983351, -0.30723915, 0.025262732, -0.49953964, -0.3467508, 0.4206674, -0.2124546, -0.082053736, 0.18843971, -0.3116276) * tile_TMP1_TEX_1[localId.y + 2u][localId.x + 2u];
      result = result * 0.2 + tile_TMP2_TEX_0[localId.y + 1u][localId.x + 1u];
  textureStore(out_tex, pixel.xy, result);
}
