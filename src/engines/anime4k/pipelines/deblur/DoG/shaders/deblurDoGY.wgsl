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
    let a0: f32 = colorAt(pos.x, pos.y - 1).y;
    let b0: f32 = colorAt(pos.x, pos.y).y;
    let c0: f32 = colorAt(pos.x, pos.y + 1).y;

    let a1: f32 = colorAt(pos.x, pos.y - 1).z;
    let b1: f32 = colorAt(pos.x, pos.y).z;
    let c1: f32 = colorAt(pos.x, pos.y + 1).z;
    
    return vec2<f32>(min3v(a0, b0, c0), max3v(a1, b1, c1));
}

fn lumGaussian7(pos: vec2u) -> f32 {
    var g: f32 = (colorAt(pos.x, pos.y - 2).x + colorAt(pos.x, pos.y + 2).x) * 0.06136;
    g += (colorAt(pos.x, pos.y - 1).x + colorAt(pos.x, pos.y + 1).x) * 0.24477;
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
    
  //var color: vec4f = colorAt(pixel.x, pixel.y);
  //textureStore(tex_out, vec2u(pixel.x, pixel.y), vec4f(get_luma(color), 0, 0, 1));

  let pos: vec2u = vec2u(pixel.x, pixel.y);

  // Call lumGaussian7 and minmax3_y
  let lum: f32 = lumGaussian7(pos);
  let minmax: vec2<f32> = minmax3(pos);

// Store the result
  textureStore(tex_out, vec2u(pixel.x, pixel.y), vec4<f32>(lum, minmax, 1.0));
}
