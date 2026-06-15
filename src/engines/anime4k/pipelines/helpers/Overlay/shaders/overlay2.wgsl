@group(0) @binding(0) var mySampler: sampler;
@group(0) @binding(1) var tex_diff: texture_2d<f32>;
@group(0) @binding(2) var tex_origin: texture_2d<f32>;

@fragment
fn main(@location(0) fragUV: vec2<f32>) -> @location(0) vec4<f32> {
    let color_bilinear: vec4f = textureSample(tex_origin, mySampler, fragUV);
    let color_addon: vec4f = textureSample(tex_diff, mySampler, fragUV);
    return clamp(color_bilinear + color_addon, vec4<f32>(0., 0., 0., 0.), vec4<f32>(1., 1., 1., 1.));
}
