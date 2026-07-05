@group(0) @binding(0) var mySampler: sampler;
@group(0) @binding(1) var tex_main: texture_2d<f32>;
@group(0) @binding(2) var tex_residual: texture_2d<f32>;

@fragment
fn main(@location(0) fragUV: vec2<f32>) -> @location(0) vec4<f32> {
  let color_main: vec4f = textureSample(tex_main, mySampler, fragUV);
  let color_residual: vec4f = textureSample(tex_residual, mySampler, fragUV);
  let color = color_main + color_residual * 0.5;
  return vec4f(color.rgb, 1.0);
}
