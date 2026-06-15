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
    var result0 = vec4f(-0.006840266, -0.012440474, -0.012945435, -0.04645404);
    var result1 = vec4f(-0.03236463, -0.0050622425, -0.0045825113, 0.006420765);
    var result2 = vec4f(0.030867014, -0.0024917293, 0.007428549, -0.0090537695);
    var result3 = vec4f(-0.0012738375, 0.013379571, 0.008391121, -0.06455159);
    let inp_0_0_0 = inp[0][local_xy.y + 0][local_xy.x + 0];
    let inp_0_1_0 = inp[0][local_xy.y + 0][local_xy.x + 1];
    let inp_0_2_0 = inp[0][local_xy.y + 0][local_xy.x + 2];
    let inp_0_0_1 = inp[0][local_xy.y + 1][local_xy.x + 0];
    let inp_0_1_1 = inp[0][local_xy.y + 1][local_xy.x + 1];
    let inp_0_2_1 = inp[0][local_xy.y + 1][local_xy.x + 2];
    let inp_0_0_2 = inp[0][local_xy.y + 2][local_xy.x + 0];
    let inp_0_1_2 = inp[0][local_xy.y + 2][local_xy.x + 1];
    let inp_0_2_2 = inp[0][local_xy.y + 2][local_xy.x + 2];
    result0 += vec4f(-0.035472848, -0.14499138, 0.010996882, 0.043425154) * inp_0_0_0;
    result0 += vec4f(0.025666144, 0.15189208, 0.106125966, 0.12280825) * inp_0_1_0;
    result0 += vec4f(-0.0059361006, 0.12564982, -0.08410422, 0.061385795) * inp_0_2_0;
    result0 += vec4f(-0.032784533, 0.039960023, -0.007927497, 0.16533956) * inp_0_0_1;
    result0 += vec4f(-0.0575242, -0.08458494, -0.36564967, 0.2639598) * inp_0_1_1;
    result0 += vec4f(-0.22559616, -0.15471613, 0.08640329, 0.111541584) * inp_0_2_1;
    result0 += vec4f(0.02868958, 0.18487, -0.0071559404, 0.094328836) * inp_0_0_2;
    result0 += vec4f(0.12985429, -0.09587503, 0.22276698, -0.00030755106) * inp_0_1_2;
    result0 += vec4f(0.19284648, -0.0036720308, 0.046878424, 0.087355375) * inp_0_2_2;
    result1 += vec4f(0.074089326, -0.05675305, -0.09985263, -0.009709773) * inp_0_0_0;
    result1 += vec4f(-0.05789924, -0.043006446, 0.0020396519, -0.17014614) * inp_0_1_0;
    result1 += vec4f(0.04783098, 0.116548575, 0.04523142, 0.13470247) * inp_0_2_0;
    result1 += vec4f(-0.05063743, 0.08730553, 0.13439637, -0.026661385) * inp_0_0_1;
    result1 += vec4f(0.09525456, -0.16270195, 0.1547691, 0.15802628) * inp_0_1_1;
    result1 += vec4f(-0.11239273, 0.27577797, -0.20400351, -0.11836694) * inp_0_2_1;
    result1 += vec4f(0.04961805, -0.025907341, 0.004669451, 0.0224939) * inp_0_0_2;
    result1 += vec4f(0.10036262, -0.2565832, -0.10639526, 0.05117149) * inp_0_1_2;
    result1 += vec4f(-0.06141705, 0.0645962, 0.073470935, -0.05072495) * inp_0_2_2;
    result2 += vec4f(-0.05530217, 0.10601906, -0.078338385, -0.06250365) * inp_0_0_0;
    result2 += vec4f(0.07705957, -0.047928665, 0.13465533, 0.007932151) * inp_0_1_0;
    result2 += vec4f(0.06636978, -0.00021219392, 0.024917463, -0.03883686) * inp_0_2_0;
    result2 += vec4f(-0.17326315, 0.26141313, 0.32149935, 0.15181658) * inp_0_0_1;
    result2 += vec4f(-0.2644004, -0.671686, -0.2870538, -0.059954405) * inp_0_1_1;
    result2 += vec4f(0.119587556, 0.112419866, -0.08982401, -0.049265414) * inp_0_2_1;
    result2 += vec4f(0.038703833, 0.11872192, -0.12390658, 0.0075279525) * inp_0_0_2;
    result2 += vec4f(0.18729559, 0.057575975, 0.070585884, 0.17390902) * inp_0_1_2;
    result2 += vec4f(-0.13925101, 0.0038511057, 0.015638566, -0.12646236) * inp_0_2_2;
    result3 += vec4f(0.04861797, -0.12658298, 0.22940855, -0.092168994) * inp_0_0_0;
    result3 += vec4f(-0.17647275, 0.16706389, 0.3450641, 0.15214883) * inp_0_1_0;
    result3 += vec4f(-0.0019383872, -0.010804838, 0.061069414, 0.080609985) * inp_0_2_0;
    result3 += vec4f(0.04252093, -0.04149563, 0.02318568, -0.21245834) * inp_0_0_1;
    result3 += vec4f(0.011523845, -0.14079979, -0.37102658, -0.026639262) * inp_0_1_1;
    result3 += vec4f(0.057185087, 0.11133354, -0.17895421, 0.20168874) * inp_0_2_1;
    result3 += vec4f(-0.056966644, 0.16069722, -0.06554181, -0.08890916) * inp_0_0_2;
    result3 += vec4f(0.09564253, -0.08339483, -0.16765916, 0.026718881) * inp_0_1_2;
    result3 += vec4f(-0.01259612, -0.05284743, -0.03444009, 0.18512487) * inp_0_2_2;
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
