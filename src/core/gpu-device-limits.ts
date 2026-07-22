export function getRequiredDeviceLimits(adapter: GPUAdapter): NonNullable<GPUDeviceDescriptor['requiredLimits']> {
  const { limits } = adapter;

  return {
    maxBufferSize: limits.maxBufferSize,
    maxStorageBufferBindingSize: limits.maxStorageBufferBindingSize,
    maxComputeWorkgroupStorageSize: limits.maxComputeWorkgroupStorageSize,
    maxStorageTexturesPerShaderStage: limits.maxStorageTexturesPerShaderStage,
    maxSampledTexturesPerShaderStage: limits.maxSampledTexturesPerShaderStage,
  };
}
