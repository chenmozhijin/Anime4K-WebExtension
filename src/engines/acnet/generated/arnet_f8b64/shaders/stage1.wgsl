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
fn computeMain(@builtin(global_invocation_id) pixel: vec3u) {
  let outputSize = textureDimensions(out_tex);
  if (pixel.x >= outputSize.x || pixel.y >= outputSize.y) {
    return;
  }

  var result: vec4f = vec4f(1.5242712, 0.2960494, 0.20062274, -0.32666284);
      result += vec4f(0.21192881, 0.05775382, -0.28610945, -0.26018393) * sample_LUMA(pixel.xy, vec2i(-1, -1)).x;
      result += vec4f(1.6006638, -0.2630084, -1.9043515, -1.1194842) * sample_LUMA(pixel.xy, vec2i(0, -1)).x;
      result += vec4f(0.53629, -0.17797138, -0.48201984, -0.23620981) * sample_LUMA(pixel.xy, vec2i(1, -1)).x;
      result += vec4f(0.9025363, -0.018474659, -0.6858059, -0.7590978) * sample_LUMA(pixel.xy, vec2i(-1, 0)).x;
      result += vec4f(-8.658363, 1.4868551, 3.8018408, 4.0865803) * sample_LUMA(pixel.xy, vec2i(0, 0)).x;
      result += vec4f(1.3678224, -0.662151, -0.8090146, -0.47496805) * sample_LUMA(pixel.xy, vec2i(1, 0)).x;
      result += vec4f(0.13898209, -0.07251676, 0.13954227, -0.077793926) * sample_LUMA(pixel.xy, vec2i(-1, 1)).x;
      result += vec4f(0.8923017, -0.6339215, -0.122063264, -0.26319084) * sample_LUMA(pixel.xy, vec2i(0, 1)).x;
      result += vec4f(0.183662, -0.16005392, 0.045014337, -0.012193643) * sample_LUMA(pixel.xy, vec2i(1, 1)).x;
  textureStore(out_tex, pixel.xy, result);
}
