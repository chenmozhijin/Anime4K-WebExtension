@group(0) @binding(0) var tex_in: texture_2d<f32>;
@group(0) @binding(1) var tex_out: texture_storage_2d<rgba16float, write>;

fn colorAt(x: u32, y: u32) -> vec4f {
  return textureLoad(tex_in, vec2u(x, y), 0);
}

fn max3v(a: f32, b: f32, c: f32) -> f32 {
    return max(max(a, b), c);
}

fn min3v(a: f32, b: f32, c: f32) -> f32 {
    return min(min(a, b), c);
}

fn minmax3(pos: vec2u) -> vec2<f32> {
    let a: f32 = colorAt(pos.x - 1, pos.y).x;
    let b: f32 = colorAt(pos.x, pos.y).x;
    let c: f32 = colorAt(pos.x + 1, pos.y).x;
    
    return vec2<f32>(min3v(a, b, c), max3v(a, b, c));
}

fn lumGaussian7(pos: vec2u) -> f32 {
    var g: f32 = (colorAt(pos.x - 2, pos.y).x + colorAt(pos.x + 2, pos.y).x) * 0.06136;
    g += (colorAt(pos.x - 1, pos.y).x + colorAt(pos.x + 1, pos.y).x) * 0.24477;
    g += colorAt(pos.x, pos.y).x * 0.38774;
    
    return g;
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
    
  let pos: vec2u = vec2u(pixel.x, pixel.y);

  // Call lumGaussian7 and minmax3_x
  let lum: f32 = lumGaussian7(pos); // directional vector vec2<f32>(1.0, 0.0). Adjust the directional vector as needed based on your texture coordinates and requirements.
  let minmax: vec2<f32> = minmax3(pos); // directional vector vec2<f32>(1.0, 0.0). Adjust the directional vector as needed based on your texture coordinates and requirements.

  // Store the result
  textureStore(tex_out, vec2u(pixel.x, pixel.y), vec4<f32>(lum, minmax, 1.0));
}
