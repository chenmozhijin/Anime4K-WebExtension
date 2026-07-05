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
    result += dot(vec4f(0.08823079, -0.32090637, 0.103366494, 0.36212367), r0);
    result += dot(vec4f(0.2229542, -0.20973343, 0.2420552, 0.113712706), r1);
  }
  if (lane == 1u) {
    result += dot(vec4f(0.04217615, -0.48703396, 0.017324746, -0.16450234), r0);
    result += dot(vec4f(0.30264825, 0.18938252, 0.3362843, -0.21652377), r1);
  }
  if (lane == 2u) {
    result += dot(vec4f(0.37754962, -0.03835839, 0.5011001, -0.13042568), r0);
    result += dot(vec4f(0.1618423, -0.032564044, -0.09384978, 0.22727896), r1);
  }
  if (lane == 3u) {
    result += dot(vec4f(0.4754364, 0.053030144, 0.38997793, 0.0012911111), r0);
    result += dot(vec4f(-0.45135668, 0.14343265, 0.31557024, -0.12837523), r1);
  }
  textureStore(out_tex, pixel.xy, vec4f(clamp(result, 0.0, 1.0), 0.0, 0.0, 1.0));
}
