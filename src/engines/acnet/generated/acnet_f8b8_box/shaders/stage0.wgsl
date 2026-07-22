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

  var result: vec4f = vec4f(-0.052993968, -0.0051282123, -0.6393323, -0.05048977);
      result += vec4f(-0.020188145, 0.5571246, 0.09281374, -0.9868372) * sample_LUMA(pixel.xy, vec2i(-1, -1)).x;
      result += vec4f(0.39145198, -3.2761428, 1.6847824, -1.4359862) * sample_LUMA(pixel.xy, vec2i(0, -1)).x;
      result += vec4f(-0.19799729, 3.1791904, -0.61437666, -0.19219871) * sample_LUMA(pixel.xy, vec2i(1, -1)).x;
      result += vec4f(0.602555, 0.6295203, 0.9689318, -1.1298919) * sample_LUMA(pixel.xy, vec2i(-1, 0)).x;
      result += vec4f(-5.9924135, 0.14589846, -2.6444702, 4.576476) * sample_LUMA(pixel.xy, vec2i(0, 0)).x;
      result += vec4f(4.468645, -2.9274526, 1.4199321, 0.104792126) * sample_LUMA(pixel.xy, vec2i(1, 0)).x;
      result += vec4f(-0.08120907, 0.2450445, -0.7706757, -0.6849453) * sample_LUMA(pixel.xy, vec2i(-1, 1)).x;
      result += vec4f(0.57151455, 0.62378395, 1.289986, 0.30089936) * sample_LUMA(pixel.xy, vec2i(0, 1)).x;
      result += vec4f(0.27252963, 0.7600826, -0.20575918, -0.64050883) * sample_LUMA(pixel.xy, vec2i(1, 1)).x;
      result = max(result, vec4f(0.0)) + vec4f(-0.09460905, -0.5526919, 0.94729483, -0.3257628) * min(result, vec4f(0.0));
  textureStore(out_tex, pixel.xy, result);
}
