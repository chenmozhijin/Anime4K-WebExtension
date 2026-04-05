@group(0) @binding(0) var tex_in: texture_2d<f32>;
@group(0) @binding(1) var tex_out: texture_storage_2d<rgba16float, write>;
@group(0) @binding(2) var<uniform> strength: f32;
@group(0) @binding(3) var<uniform> strength2: f32;

fn gaussianVec(x: vec4f, s: vec4f, m: vec4f) -> vec4f {
  let scaled = (x - m) / s;
  return exp(-0.5 * scaled * scaled);
}

fn gaussian(x: f32, s: f32, m: f32) -> f32 {
  let scaled = (x - m) / s;
  return exp(-0.5 * scaled * scaled);
}

fn colorAt(x: i32, y: i32) -> vec4f { // read from Kernel-Y output texture
  return textureLoad(tex_in, vec2i(x, y), 0);
}

@compute
@workgroup_size(8, 8)
fn denoiseMain(@builtin(global_invocation_id) pixel: vec3u) {
  // OOB check
  let dim_in: vec2u = textureDimensions(tex_in);
  let dim_out: vec2u = textureDimensions(tex_out);
  if (pixel.x >= dim_out.x || pixel.y >= dim_out.y) {
    return;
  }
  let pos: vec2i = vec2i(i32(pixel.x), i32(pixel.y));

  // constants
  // Intensity window size, higher is stronger denoise, must be a positive real number
  let intensitySigma: f32 = strength;
  // Spatial window size, higher is stronger denoise, must be a positive real number.
  let spatialSigma: f32 = strength2;
  // Intensity window power curve.
  //    Setting it to 0 will make the intensity window treat all intensities equally, 
  //    while increasing it will make the window narrower in darker intensities and 
  //    wider in brighter intensities.
  let intensityPowerCurve = 1.0;
  // Kernel size, must be an positive odd integer.
  let kernelSize: i32 = max(i32(ceil(spatialSigma * 2.0)), 1) * 2 + 1;
  let kernelHalfSize: i32 = kernelSize / 2;
  let kernelLen: i32 = kernelSize * kernelSize;

  var sum: vec4f = vec4f(0.0);
  var n: vec4f = vec4f(0.0);

  let vc: vec4f = colorAt(pos.x, pos.y);
  let is = pow(vc + 0.0001, vec4f(intensityPowerCurve)) * intensitySigma;

  for (var i = 0; i < kernelLen; i++) {
    var offset: vec2<i32> = vec2((i % kernelSize) - kernelHalfSize,
                                  (i / kernelSize - kernelHalfSize));
    var v: vec4f = colorAt(pos.x + offset.x, pos.y + offset.y);
    var d: vec4f = gaussianVec(v, is, vc) * gaussian(length(vec2f(offset)), spatialSigma, 0.0);
    sum += d * v;
    n += d;
  }

  textureStore(tex_out, vec2u(pixel.x, pixel.y), sum / n);
}
