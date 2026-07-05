const WG_X: u32 = 8u;
const WG_Y: u32 = 8u;

@group(0) @binding(0) var tex_0: texture_2d<f32>;
@group(0) @binding(1) var tex_1: texture_2d<f32>;
@group(0) @binding(2) var out_tex: texture_storage_2d<rgba16float, write>;

@compute
@workgroup_size(WG_X, WG_Y)
fn computeMain(@builtin(global_invocation_id) pixel: vec3u) {
  let outputSize = textureDimensions(out_tex);
  if (pixel.x >= outputSize.x || pixel.y >= outputSize.y) {
    return;
  }

  let sourcePixel = pixel.xy / vec2u(2u, 2u);
  let lane = (pixel.y % 2u) * 2u + (pixel.x % 2u);
  let r0 = textureLoad(tex_0, vec2i(sourcePixel), 0);
  let r1 = textureLoad(tex_1, vec2i(sourcePixel), 0);
  var result: f32 = 0.0;
  if (lane == 0u) {
    result += dot(vec4f(0.42401108, -0.09849026, -0.1368322, 0.2458229), r0);
    result += dot(vec4f(-0.3976746, 0.39020374, 0.04952383, 0.3061316), r1);
  }
  if (lane == 1u) {
    result += dot(vec4f(0.41652867, -0.4454817, 0.4412722, -0.32561386), r0);
    result += dot(vec4f(-0.042187653, 0.059423674, 0.13089569, 0.1826789), r1);
  }
  if (lane == 2u) {
    result += dot(vec4f(0.1648087, 0.46388388, 0.25386885, -0.047912773), r0);
    result += dot(vec4f(-0.27362013, -0.07206775, -0.17031361, 0.2443201), r1);
  }
  if (lane == 3u) {
    result += dot(vec4f(0.19086978, -0.053325247, 0.32935733, 0.31999472), r0);
    result += dot(vec4f(0.10534088, -0.298755, 0.0033250283, -0.1259047), r1);
  }
  textureStore(out_tex, pixel.xy, vec4f(clamp(result, 0.0, 1.0), 0.0, 0.0, 1.0));
}
