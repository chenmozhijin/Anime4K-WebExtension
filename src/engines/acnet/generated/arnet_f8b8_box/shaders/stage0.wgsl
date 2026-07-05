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

  var result: vec4f = vec4f(-0.13774215, -0.5199401, -0.6141287, -0.7442415);
      result += vec4f(0.32197002, -0.07035992, 0.023308633, -0.08147951) * sample_LUMA(pixel.xy, vec2i(-1, -1)).x;
      result += vec4f(-0.28325155, -0.39712352, -0.021224404, -1.4274639) * sample_LUMA(pixel.xy, vec2i(0, -1)).x;
      result += vec4f(0.05088182, -0.56768405, -0.18493338, -0.1598113) * sample_LUMA(pixel.xy, vec2i(1, -1)).x;
      result += vec4f(-0.030693216, 0.13883565, 0.13472588, -1.4744225) * sample_LUMA(pixel.xy, vec2i(-1, 0)).x;
      result += vec4f(2.0038338, 5.9104476, 1.202982, 8.221165) * sample_LUMA(pixel.xy, vec2i(0, 0)).x;
      result += vec4f(-0.7810252, -1.5333568, 0.027581356, -0.88854504) * sample_LUMA(pixel.xy, vec2i(1, 0)).x;
      result += vec4f(-0.16865337, -0.053768, 0.04427158, -0.23981896) * sample_LUMA(pixel.xy, vec2i(-1, 1)).x;
      result += vec4f(-0.614308, -1.1613578, 0.037568364, -1.3448546) * sample_LUMA(pixel.xy, vec2i(0, 1)).x;
      result += vec4f(-0.11691835, -0.8846602, -0.17490771, -0.7870279) * sample_LUMA(pixel.xy, vec2i(1, 1)).x;
  textureStore(out_tex, pixel.xy, result);
}
