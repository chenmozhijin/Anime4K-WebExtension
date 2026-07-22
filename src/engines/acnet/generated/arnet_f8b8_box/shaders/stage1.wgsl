const WG_X: u32 = 8u;
const WG_Y: u32 = 8u;
const BT709_LUMA: vec3f = vec3f(0.2126, 0.7152, 0.0722);

fn luma709(color: vec3f) -> f32 {
  return dot(color, BT709_LUMA);
}

@group(0) @binding(0) var tex_LUMA: texture_2d<f32>;

fn sample_LUMA(pos: vec2u, offset: vec2i) -> vec4f {
  let size = vec2i(textureDimensions(tex_LUMA));
  let coord = clamp(vec2i(pos) + offset, vec2i(0, 0), size - vec2i(1, 1));
  let color = textureLoad(tex_LUMA, coord, 0);
  return vec4f(luma709(color.rgb), 0.0, 0.0, color.a);
}


@group(0) @binding(1) var out_tex: texture_storage_2d<rgba16float, write>;

@compute
@workgroup_size(WG_X, WG_Y)
fn computeMain(
  @builtin(global_invocation_id) pixel: vec3u,
  @builtin(local_invocation_id) localId: vec3u,
) {
  let outputSize = textureDimensions(out_tex);

  if (pixel.x >= outputSize.x || pixel.y >= outputSize.y) {
    return;
  }

  var result: vec4f = vec4f(-0.013836779, 0.6106958, 0.2579807, -0.2619122);
      result += vec4f(-0.25182074, 0.24298307, -0.27829987, -0.2597332) * sample_LUMA(pixel.xy, vec2i(-1, -1)).x;
      result += vec4f(0.089551516, 0.21013577, -0.16318183, 0.07740412) * sample_LUMA(pixel.xy, vec2i(0, -1)).x;
      result += vec4f(-0.39475387, -0.34675127, -0.17819838, 0.5135834) * sample_LUMA(pixel.xy, vec2i(1, -1)).x;
      result += vec4f(0.4902884, 0.48182353, -0.2588557, -1.6111723) * sample_LUMA(pixel.xy, vec2i(-1, 0)).x;
      result += vec4f(1.1737783, -1.9090741, 0.6528152, 0.8062201) * sample_LUMA(pixel.xy, vec2i(0, 0)).x;
      result += vec4f(-0.6446201, 0.3292444, 0.13989411, 1.704308) * sample_LUMA(pixel.xy, vec2i(1, 0)).x;
      result += vec4f(-0.0048784036, 0.08701676, 0.13715205, -0.12296808) * sample_LUMA(pixel.xy, vec2i(-1, 1)).x;
      result += vec4f(-0.027853692, 0.27601245, -0.024743922, -0.5354552) * sample_LUMA(pixel.xy, vec2i(0, 1)).x;
      result += vec4f(-0.27569813, -0.4406241, -0.2684059, 0.012131155) * sample_LUMA(pixel.xy, vec2i(1, 1)).x;
  textureStore(out_tex, pixel.xy, result);
}
