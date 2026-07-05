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
    result += dot(vec4f(0.49078947, -0.0014691342, -0.29807493, 0.33307847), r0);
    result += dot(vec4f(0.23635788, -0.37147278, 0.23777665, -0.08506925), r1);
  }
  if (lane == 1u) {
    result += dot(vec4f(-0.045654465, -0.31522423, 0.09122834, 0.28530642), r0);
    result += dot(vec4f(0.07923404, 0.1403556, 0.15704143, 0.27706197), r1);
  }
  if (lane == 2u) {
    result += dot(vec4f(-0.17156102, 0.30449453, 0.012190725, 0.22100307), r0);
    result += dot(vec4f(0.28854126, -0.026041213, -0.57340115, 0.041496564), r1);
  }
  if (lane == 3u) {
    result += dot(vec4f(-0.21146137, 0.032976013, 0.22809118, 0.26108578), r0);
    result += dot(vec4f(-0.7122354, 0.21438986, 0.2076892, -0.18576363), r1);
  }
  textureStore(out_tex, pixel.xy, vec4f(clamp(result, 0.0, 1.0), 0.0, 0.0, 1.0));
}
