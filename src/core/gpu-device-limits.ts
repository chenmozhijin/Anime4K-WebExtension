export function getRequiredDeviceLimits(adapter: GPUAdapter): NonNullable<GPUDeviceDescriptor['requiredLimits']> {
  const { limits } = adapter;

  return {
    maxTextureDimension2D: limits.maxTextureDimension2D,
    maxBufferSize: limits.maxBufferSize,
    maxStorageBufferBindingSize: limits.maxStorageBufferBindingSize,
    maxComputeWorkgroupStorageSize: limits.maxComputeWorkgroupStorageSize,
    maxStorageTexturesPerShaderStage: limits.maxStorageTexturesPerShaderStage,
    maxSampledTexturesPerShaderStage: limits.maxSampledTexturesPerShaderStage,
  };
}
