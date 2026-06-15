const WG_X: u32 = 12u;
const WG_Y: u32 = 16u;
const ISIZE_X: u32 = WG_X + 2u;
const ISIZE_Y: u32 = WG_Y + 2u;
const PACK_X: u32 = 2u;
const PACK_Y: u32 = 2u;
const BT709_LUMA: vec3f = vec3f(0.2126, 0.7152, 0.0722);

@group(0) @binding(0) var input_tex: texture_2d<f32>;
@group(0) @binding(1) var out_tex: texture_storage_2d<rgba16float, write>;

var<workgroup> inp: array<array<array<f32, ISIZE_X>, ISIZE_Y>, 1>;

fn luma709(color: vec4f) -> f32 {
  return dot(color.rgb, BT709_LUMA);
}

@compute
@workgroup_size(WG_X, WG_Y)
fn computeMain(
  @builtin(global_invocation_id) global_id: vec3u,
  @builtin(local_invocation_id) local_id: vec3u,
  @builtin(workgroup_id) workgroup_id: vec3u,
) {
  let local_xy = local_id.xy;
  let base = vec2i(workgroup_id.xy) * vec2i(i32(WG_X), i32(WG_Y));
  for (var y: u32 = local_xy.y; y < ISIZE_Y; y += WG_Y) {
    for (var x: u32 = local_xy.x; x < ISIZE_X; x += WG_X) {
      let input_base = base + vec2i(i32(x), i32(y)) - vec2i(1, 1);
      inp[0][y][x] = luma709(textureLoad(input_tex, input_base, 0));
    }
  }
    workgroupBarrier();
    var result0 = vec4f(0.005000432, -0.010236794, -0.014935676, -0.046207584);
    var result1 = vec4f(-0.028179219, -0.004517557, 0.00014788302, 0.0035856056);
    var result2 = vec4f(0.032914076, 0.00020142968, -0.0065285224, -0.0065012206);
    var result3 = vec4f(0.002272252, 0.010490689, 0.014113876, -0.06348713);
    let inp_0_0_0 = inp[0][local_xy.y + 0][local_xy.x + 0];
    let inp_0_1_0 = inp[0][local_xy.y + 0][local_xy.x + 1];
    let inp_0_2_0 = inp[0][local_xy.y + 0][local_xy.x + 2];
    let inp_0_0_1 = inp[0][local_xy.y + 1][local_xy.x + 0];
    let inp_0_1_1 = inp[0][local_xy.y + 1][local_xy.x + 1];
    let inp_0_2_1 = inp[0][local_xy.y + 1][local_xy.x + 2];
    let inp_0_0_2 = inp[0][local_xy.y + 2][local_xy.x + 0];
    let inp_0_1_2 = inp[0][local_xy.y + 2][local_xy.x + 1];
    let inp_0_2_2 = inp[0][local_xy.y + 2][local_xy.x + 2];
    result0 += vec4f(-0.031936917, -0.12498426, 0.019247064, 0.043321293) * inp_0_0_0;
    result0 += vec4f(0.0324228, 0.15786779, 0.093572296, 0.12223211) * inp_0_1_0;
    result0 += vec4f(-0.008010341, 0.11386231, -0.07220623, 0.062144116) * inp_0_2_0;
    result0 += vec4f(-0.017256076, 0.051489502, -0.021640493, 0.16445197) * inp_0_0_1;
    result0 += vec4f(-0.05208898, -0.06893944, -0.34209797, 0.26306182) * inp_0_1_1;
    result0 += vec4f(-0.22330455, -0.13612887, 0.070612304, 0.11175349) * inp_0_2_1;
    result0 += vec4f(0.032759942, 0.1523859, 0.009016861, 0.094373636) * inp_0_0_2;
    result0 += vec4f(0.10492912, -0.10173742, 0.19048259, -0.00072423404) * inp_0_1_2;
    result0 += vec4f(0.16503376, -0.017707495, 0.051095057, 0.0885737) * inp_0_2_2;
    result1 += vec4f(0.075178064, -0.053005736, -0.1116903, 0.01338327) * inp_0_0_0;
    result1 += vec4f(-0.05177772, -0.03640289, 0.010358838, -0.18368039) * inp_0_1_0;
    result1 += vec4f(0.02753785, 0.112010606, 0.042722113, 0.117747955) * inp_0_2_0;
    result1 += vec4f(-0.04285177, 0.076704614, 0.11607434, -0.0305754) * inp_0_0_1;
    result1 += vec4f(0.099548064, -0.15293168, 0.12925005, 0.1437974) * inp_0_1_1;
    result1 += vec4f(-0.116974674, 0.23881362, -0.1826676, -0.091472775) * inp_0_2_1;
    result1 += vec4f(0.043361172, -0.013535253, 0.0058491337, 0.02681981) * inp_0_0_2;
    result1 += vec4f(0.08957939, -0.22580828, -0.08981081, 0.043160103) * inp_0_1_2;
    result1 += vec4f(-0.07271555, 0.051607724, 0.08303654, -0.040631983) * inp_0_2_2;
    result2 += vec4f(-0.05472001, 0.11004032, -0.06848912, -0.052433632) * inp_0_0_0;
    result2 += vec4f(0.07194944, -0.05754198, 0.11013715, 0.004388367) * inp_0_1_0;
    result2 += vec4f(0.06442394, 0.0031591335, 0.043304957, -0.0030882147) * inp_0_2_0;
    result2 += vec4f(-0.17313306, 0.24899231, 0.28330398, 0.134953) * inp_0_0_1;
    result2 += vec4f(-0.264359, -0.6773203, -0.28650266, -0.05620836) * inp_0_1_1;
    result2 += vec4f(0.12131029, 0.10487222, -0.07395276, -0.042340226) * inp_0_2_1;
    result2 += vec4f(0.04348287, 0.12302039, -0.076906785, -0.0013286016) * inp_0_0_2;
    result2 += vec4f(0.18425512, 0.056919117, 0.043003965, 0.14221072) * inp_0_1_2;
    result2 += vec4f(-0.13485871, 0.008584932, 0.025013693, -0.11905144) * inp_0_2_2;
    result3 += vec4f(0.054048687, -0.12823541, 0.22114806, -0.097227745) * inp_0_0_0;
    result3 += vec4f(-0.15910593, 0.15280719, 0.33969763, 0.158814) * inp_0_1_0;
    result3 += vec4f(-0.010616162, -0.00083789544, 0.062508926, 0.06668837) * inp_0_2_0;
    result3 += vec4f(0.036678676, -0.04860102, 0.016965836, -0.19173586) * inp_0_0_1;
    result3 += vec4f(0.01301608, -0.13192666, -0.39674488, -0.0031523537) * inp_0_1_1;
    result3 += vec4f(0.05387914, 0.1256965, -0.17243183, 0.19979002) * inp_0_2_1;
    result3 += vec4f(-0.056761082, 0.17714313, -0.053538978, -0.08099346) * inp_0_0_2;
    result3 += vec4f(0.09195001, -0.09233287, -0.16082087, 0.021915846) * inp_0_1_2;
    result3 += vec4f(-0.023340184, -0.06604176, -0.02217975, 0.15662381) * inp_0_2_2;
  let logical_out = textureDimensions(out_tex) / vec2u(PACK_X, PACK_Y);
  if (global_id.x >= logical_out.x || global_id.y >= logical_out.y) {
    return;
  }

  let output_base = global_id.xy * vec2u(PACK_X, PACK_Y);
  textureStore(out_tex, output_base + vec2u(0u, 0u), result0);
  textureStore(out_tex, output_base + vec2u(1u, 0u), result1);
  textureStore(out_tex, output_base + vec2u(0u, 1u), result2);
  textureStore(out_tex, output_base + vec2u(1u, 1u), result3);
}
