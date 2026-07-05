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
    result += dot(vec4f(-0.09669538, 0.25469694, -0.30128008, 0.15643239), r0);
    result += dot(vec4f(-0.48546574, 0.37434444, -0.3577022, 0.105220184), r1);
  }
  if (lane == 1u) {
    result += dot(vec4f(-0.3093563, 0.33597073, -0.16020074, 0.37725404), r0);
    result += dot(vec4f(-0.19720809, -0.11557118, 0.07532467, -0.41802093), r1);
  }
  if (lane == 2u) {
    result += dot(vec4f(0.35373536, -0.07184828, 0.45196483, -0.021611717), r0);
    result += dot(vec4f(-0.20259249, 0.44079074, -0.3396386, 0.07994658), r1);
  }
  if (lane == 3u) {
    result += dot(vec4f(0.57046866, -0.06997593, 0.04950216, 0.43667406), r0);
    result += dot(vec4f(-0.43897602, -0.31229037, 0.033558372, -0.35870978), r1);
  }
  textureStore(out_tex, pixel.xy, vec4f(clamp(result, 0.0, 1.0), 0.0, 0.0, 1.0));
}
