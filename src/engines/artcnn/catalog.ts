import type { EffectDescriptor } from '../../types';

export const artcnnBackendId = 'artcnn';

export const artcnnEffectDescriptors: EffectDescriptor[] = [
  {
    id: 'artcnn/Upscale/C4F16',
    backendId: artcnnBackendId,
    key: 'C4F16',
    name: 'Upscale ArtCNN x2 (C4F16)',
    category: 'upscale',
    dimensionBehavior: { kind: 'scale', scale: 2 },
    supportsVideoRealtime: true,
  },
  {
    id: 'artcnn/Upscale/C4F16_DS',
    backendId: artcnnBackendId,
    key: 'C4F16_DS',
    name: 'Upscale ArtCNN x2 (C4F16 DS)',
    category: 'upscale',
    dimensionBehavior: { kind: 'scale', scale: 2 },
    supportsVideoRealtime: true,
  },
  {
    id: 'artcnn/Upscale/C4F16_DN',
    backendId: artcnnBackendId,
    key: 'C4F16_DN',
    name: 'Upscale ArtCNN x2 (C4F16 DN)',
    category: 'upscale',
    dimensionBehavior: { kind: 'scale', scale: 2 },
    supportsVideoRealtime: true,
  },
  {
    id: 'artcnn/Upscale/C4F32',
    backendId: artcnnBackendId,
    key: 'C4F32',
    name: 'Upscale ArtCNN x2 (C4F32)',
    category: 'upscale',
    dimensionBehavior: { kind: 'scale', scale: 2 },
    supportsVideoRealtime: true,
  },
  {
    id: 'artcnn/Upscale/C4F32_DS',
    backendId: artcnnBackendId,
    key: 'C4F32_DS',
    name: 'Upscale ArtCNN x2 (C4F32 DS)',
    category: 'upscale',
    dimensionBehavior: { kind: 'scale', scale: 2 },
    supportsVideoRealtime: true,
  },
  {
    id: 'artcnn/Upscale/C4F32_DN',
    backendId: artcnnBackendId,
    key: 'C4F32_DN',
    name: 'Upscale ArtCNN x2 (C4F32 DN)',
    category: 'upscale',
    dimensionBehavior: { kind: 'scale', scale: 2 },
    supportsVideoRealtime: true,
  },
];

