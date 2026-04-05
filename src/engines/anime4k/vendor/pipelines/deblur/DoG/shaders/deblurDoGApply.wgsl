@group(0) @binding(0) var tex_in: texture_2d<f32>; // Kernel-Y output
@group(0) @binding(1) var tex_lum: texture_2d<f32>; // lumination texture
@group(0) @binding(2) var tex_original: texture_2d<f32>;
@group(0) @binding(3) var tex_out: texture_storage_2d<rgba16float, write>;
@group(0) @binding(4) var<uniform> strength: f32;

fn lumAt(x: u32, y: u32) -> vec4f { // read from lumination texture
  return textureLoad(tex_lum, vec2u(x, y), 0);
}

fn colorAt(x: u32, y: u32) -> vec4f { // read from Kernel-Y output texture
  return textureLoad(tex_in, vec2u(x, y), 0);
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


  let BLUR_CURVE: f32 = strength;
  let BLUR_THRESHOLD: f32 = 0.1;
  let NOISE_THRESHOLD: f32 = 0.001;

  let luma: vec4f = lumAt(pos.x, pos.y);
  let color: vec4f = colorAt(pos.x, pos.y);

  let c: f32 = (luma.x - color.x) * strength;

  let t_range: f32 = BLUR_THRESHOLD - NOISE_THRESHOLD;

  var c_t: f32 = abs(c);

  if (c_t > NOISE_THRESHOLD) {
    c_t = (c_t - NOISE_THRESHOLD) / t_range;
    c_t = pow(c_t, BLUR_CURVE);
    c_t = c_t * t_range + NOISE_THRESHOLD;
    c_t = c_t * sign(c);
  } else {
    c_t = c;
  }

  let cc: f32 = clamp(c_t + luma.x, color.y, color.z) - luma.x;

  textureStore(tex_out, vec2u(pixel.x, pixel.y), cc + textureLoad(tex_original, vec2u(pos.x, pos.y), 0));
}
