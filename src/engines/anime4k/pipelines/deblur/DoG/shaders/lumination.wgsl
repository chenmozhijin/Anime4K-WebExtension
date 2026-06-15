@group(0) @binding(0) var tex_in: texture_2d<f32>;
@group(0) @binding(1) var tex_out: texture_storage_2d<rgba16float, write>;

fn colorAt(x: u32, y: u32) -> vec4f {
  return textureLoad(tex_in, vec2u(x, y), 0);
}

// Function to calculate luminance
fn get_luma(rgba: vec4<f32>) -> f32 {
    return dot(rgba, vec4<f32>(0.299, 0.587, 0.114, 0.0));
}

@compute
@workgroup_size(8, 8)
fn computeMain(@builtin(global_invocation_id) pixel: vec3u) {
  // OOB check
  let dim_in: vec2u = textureDimensions(tex_in);
  let dim_out: vec2u = textureDimensions(tex_out);
  if (pixel.x >= dim_out.x || pixel.y >= dim_out.y) {
    return;
  }

  var color: vec4f = colorAt(pixel.x, pixel.y);
  textureStore(tex_out, vec2u(pixel.x, pixel.y), vec4f(get_luma(color), 0, 0, 1));
}
