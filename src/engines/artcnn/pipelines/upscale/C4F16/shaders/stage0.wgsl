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
    var result0 = vec4f(-0.0027198044, -0.013629392, -0.015712878, -0.050803013);
    var result1 = vec4f(-0.02707489, -0.0062177293, 0.0026368732, -0.0029379292);
    var result2 = vec4f(0.03127001, -0.0039273943, -0.0040966137, -0.0016518718);
    var result3 = vec4f(0.0028380281, 0.00058883557, 0.013085538, -0.058857743);
    let inp_0_0_0 = inp[0][local_xy.y + 0][local_xy.x + 0];
    let inp_0_1_0 = inp[0][local_xy.y + 0][local_xy.x + 1];
    let inp_0_2_0 = inp[0][local_xy.y + 0][local_xy.x + 2];
    let inp_0_0_1 = inp[0][local_xy.y + 1][local_xy.x + 0];
    let inp_0_1_1 = inp[0][local_xy.y + 1][local_xy.x + 1];
    let inp_0_2_1 = inp[0][local_xy.y + 1][local_xy.x + 2];
    let inp_0_0_2 = inp[0][local_xy.y + 2][local_xy.x + 0];
    let inp_0_1_2 = inp[0][local_xy.y + 2][local_xy.x + 1];
    let inp_0_2_2 = inp[0][local_xy.y + 2][local_xy.x + 2];
    result0 += vec4f(-0.016452063, -0.1258466, 0.013886958, 0.036870774) * inp_0_0_0;
    result0 += vec4f(0.04311634, 0.15515013, 0.12190506, 0.12543218) * inp_0_1_0;
    result0 += vec4f(-0.0049624983, 0.1029244, -0.10124424, 0.06448426) * inp_0_2_0;
    result0 += vec4f(0.001886782, 0.06120591, 0.020384936, 0.16804346) * inp_0_0_1;
    result0 += vec4f(-0.04256893, -0.07616671, -0.37889892, 0.27856478) * inp_0_1_1;
    result0 += vec4f(-0.20398517, -0.12900643, 0.113083735, 0.11175711) * inp_0_2_1;
    result0 += vec4f(0.009553091, 0.13118562, -0.031063978, 0.09478131) * inp_0_0_2;
    result0 += vec4f(0.066157505, -0.114692695, 0.22418123, -0.009412468) * inp_0_1_2;
    result0 += vec4f(0.15508306, 0.011386595, 0.014014352, 0.09318008) * inp_0_2_2;
    result1 += vec4f(0.08046117, -0.07086712, -0.102300294, 0.014950261) * inp_0_0_0;
    result1 += vec4f(-0.06476857, -0.014190924, -0.017589286, -0.19119741) * inp_0_1_0;
    result1 += vec4f(0.05054515, 0.115604624, 0.06517106, 0.13799176) * inp_0_2_0;
    result1 += vec4f(-0.045681432, 0.08269155, 0.10319298, -0.026858954) * inp_0_0_1;
    result1 += vec4f(0.11229104, -0.17059296, 0.13794285, 0.18026339) * inp_0_1_1;
    result1 += vec4f(-0.1267971, 0.23877597, -0.18725446, -0.12132741) * inp_0_2_1;
    result1 += vec4f(0.05785694, -0.015154775, 0.026422592, 0.002328838) * inp_0_0_2;
    result1 += vec4f(0.07150728, -0.22784448, -0.12155527, 0.027110105) * inp_0_1_2;
    result1 += vec4f(-0.08247087, 0.06362491, 0.08973536, -0.02196324) * inp_0_2_2;
    result2 += vec4f(-0.06092033, 0.1256232, -0.11233013, -0.061837807) * inp_0_0_0;
    result2 += vec4f(0.08898802, -0.028417582, 0.15791786, -0.01610648) * inp_0_1_0;
    result2 += vec4f(0.06330266, -0.009340407, 0.017859828, -0.007937439) * inp_0_2_0;
    result2 += vec4f(-0.17722517, 0.31189576, 0.32109433, 0.18112311) * inp_0_0_1;
    result2 += vec4f(-0.2903746, -0.72364086, -0.3329427, -0.08360631) * inp_0_1_1;
    result2 += vec4f(0.14228302, 0.11720193, -0.056604996, -0.027815754) * inp_0_2_1;
    result2 += vec4f(0.035853237, 0.118430145, -0.12544365, -0.02719196) * inp_0_0_2;
    result2 += vec4f(0.20537417, 0.07353585, 0.10881828, 0.1451791) * inp_0_1_2;
    result2 += vec4f(-0.1517126, -0.010349405, 0.018765846, -0.09707698) * inp_0_2_2;
    result3 += vec4f(0.052764144, -0.10130216, 0.22795214, -0.09385554) * inp_0_0_0;
    result3 += vec4f(-0.16102873, 0.18050277, 0.36273104, 0.1743911) * inp_0_1_0;
    result3 += vec4f(0.008320275, -0.031096114, 0.06665433, 0.047147725) * inp_0_2_0;
    result3 += vec4f(0.039706435, -0.0059984834, 0.026533028, -0.19475575) * inp_0_0_1;
    result3 += vec4f(0.017116806, -0.1657458, -0.4245533, 0.011194904) * inp_0_1_1;
    result3 += vec4f(0.03566397, 0.1254953, -0.16895337, 0.20406392) * inp_0_2_1;
    result3 += vec4f(-0.0622524, 0.11329407, -0.052762877, -0.081980705) * inp_0_0_2;
    result3 += vec4f(0.08946176, -0.05226282, -0.15308078, -0.0015630769) * inp_0_1_2;
    result3 += vec4f(-0.018317576, -0.06487258, -0.012865839, 0.13352033) * inp_0_2_2;
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
