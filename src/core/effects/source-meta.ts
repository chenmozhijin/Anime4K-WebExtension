import type { EffectDescriptor } from '../../types';

export interface EffectSourceMeta<TModel = unknown> {
  backendId: string;
  descriptor: EffectDescriptor;
  model?: TModel;
}
