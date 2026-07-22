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

  var result: vec4f = vec4f(2.0046337, 0.26826012, 0.16384932, -0.36358577);
      result += vec4f(0.126612, 0.17777242, -0.25084028, -0.35836744) * sample_LUMA(pixel.xy, vec2i(-1, -1)).x;
      result += vec4f(1.4578364, -0.19014685, -2.1067884, -0.7641048) * sample_LUMA(pixel.xy, vec2i(0, -1)).x;
      result += vec4f(0.7156445, -0.30827603, -0.69250715, -0.12720412) * sample_LUMA(pixel.xy, vec2i(1, -1)).x;
      result += vec4f(0.6299465, 0.20227046, -0.4586683, -0.7578738) * sample_LUMA(pixel.xy, vec2i(-1, 0)).x;
      result += vec4f(-9.420214, 1.9240965, 3.3638167, 3.178292) * sample_LUMA(pixel.xy, vec2i(0, 0)).x;
      result += vec4f(1.4145769, -1.0004753, -0.7343159, 0.009286448) * sample_LUMA(pixel.xy, vec2i(1, 0)).x;
      result += vec4f(0.10842773, -0.07995809, 0.3277927, -0.1877223) * sample_LUMA(pixel.xy, vec2i(-1, 1)).x;
      result += vec4f(0.81207556, -0.79234916, 0.2010029, -0.06489094) * sample_LUMA(pixel.xy, vec2i(0, 1)).x;
      result += vec4f(0.40630546, -0.37837362, 0.04929405, -0.02418369) * sample_LUMA(pixel.xy, vec2i(1, 1)).x;
  textureStore(out_tex, pixel.xy, result);
}
