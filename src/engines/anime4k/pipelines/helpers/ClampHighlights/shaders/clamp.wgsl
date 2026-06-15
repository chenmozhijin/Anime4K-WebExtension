@group(0) @binding(0) var tex_in: texture_2d<f32>; // original frame
@group(0) @binding(1) var tex_lumi: texture_2d<f32>; // lumination Y
@group(0) @binding(2) var tex_out: texture_storage_2d<rgba16float, write>; // output texture

fn colorAt(x: u32, y: u32) -> vec4f {
  return textureLoad(tex_in, vec2u(x, y), 0);
}

fn lumaAt(x: u32, y: u32) -> f32 {
  return textureLoad(tex_lumi, vec2u(x, y), 0).x;
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

  let color: vec4f = colorAt(pixel.x, pixel.y);
  let luma: f32 = get_luma(color);
  let new_luma: f32 = min(luma, lumaAt(pixel.x, pixel.y));
  let luma_diff: f32 = luma - new_luma;
  let new_color: vec4f = color - vec4f(luma_diff, luma_diff, luma_diff, 0.0);

  textureStore(tex_out, vec2u(pixel.x, pixel.y), new_color);
}
