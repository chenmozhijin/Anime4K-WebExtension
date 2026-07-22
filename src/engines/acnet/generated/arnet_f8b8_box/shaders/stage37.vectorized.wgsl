const WG_X: u32 = 8u;
const WG_Y: u32 = 8u;

@group(0) @binding(0) var tex_TMP2_TEX_0: texture_2d<f32>;
@group(0) @binding(1) var out_tex: texture_storage_2d<rgba16float, write>;

@compute
@workgroup_size(WG_X, WG_Y)
fn computeMain(@builtin(global_invocation_id) pixel: vec3u) {
  let sourceSize = textureDimensions(tex_TMP2_TEX_0);
  if (pixel.x >= sourceSize.x || pixel.y >= sourceSize.y) {
    return;
  }

  let values = textureLoad(tex_TMP2_TEX_0, vec2i(pixel.xy), 0);
  let outputBase = pixel.xy * vec2u(2u, 2u);
  textureStore(out_tex, outputBase, vec4f(clamp(values.x, 0.0, 1.0), 0.0, 0.0, 1.0));
  textureStore(out_tex, outputBase + vec2u(1u, 0u), vec4f(clamp(values.y, 0.0, 1.0), 0.0, 0.0, 1.0));
  textureStore(out_tex, outputBase + vec2u(0u, 1u), vec4f(clamp(values.z, 0.0, 1.0), 0.0, 0.0, 1.0));
  textureStore(out_tex, outputBase + vec2u(1u, 1u), vec4f(clamp(values.w, 0.0, 1.0), 0.0, 0.0, 1.0));
}
