import type { EffectDescriptor } from '../../types';
import { createEffectReference } from '../../core/effects/reference';

export const coreBackendId = 'core';

export const resizeToTargetDescriptor: EffectDescriptor = {
  id: 'core/Resize/ToTarget',
  backendId: coreBackendId,
  key: 'resize-to-target',
  name: 'Resize To Target',
  category: 'resize',
  dimensionBehavior: { kind: 'target' },
  supportsVideoRealtime: true,
  hidden: true,
};

export const internalResizeDescriptor: EffectDescriptor = {
  id: 'core/internal/ResizeLinear',
  backendId: coreBackendId,
  key: 'resize-linear-internal',
  name: 'Linear Resize',
  category: 'resize',
  dimensionBehavior: { kind: 'target' },
  supportsVideoRealtime: true,
  hidden: true,
};

export const coreEffectDescriptors: EffectDescriptor[] = [
  resizeToTargetDescriptor,
  internalResizeDescriptor,
];

export const internalResizeEffectReference = createEffectReference(internalResizeDescriptor);
