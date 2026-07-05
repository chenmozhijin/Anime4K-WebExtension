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
    result += dot(vec4f(0.48508886, 0.008611098, -0.28669113, 0.33451268), r0);
    result += dot(vec4f(0.18661453, -0.36989957, 0.19663955, -0.07720357), r1);
  }
  if (lane == 1u) {
    result += dot(vec4f(0.0030600806, -0.318058, 0.094134, 0.28446534), r0);
    result += dot(vec4f(0.13897784, 0.18307114, 0.12731533, 0.2750769), r1);
  }
  if (lane == 2u) {
    result += dot(vec4f(-0.17345434, 0.2939309, 0.01090965, 0.22377297), r0);
    result += dot(vec4f(0.2915245, -0.05183855, -0.5716754, 0.049931247), r1);
  }
  if (lane == 3u) {
    result += dot(vec4f(-0.19451335, 0.040656738, 0.22949076, 0.2619063), r0);
    result += dot(vec4f(-0.74256796, 0.2683021, 0.24297258, -0.19041258), r1);
  }
  textureStore(out_tex, pixel.xy, vec4f(clamp(result, 0.0, 1.0), 0.0, 0.0, 1.0));
}
