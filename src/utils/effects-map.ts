import type { EffectDescriptor } from '../types';
import { listEffectDescriptors } from '../core/effects/registry';

/**
 * 所有可见效果的统一目录。
 * 由 backend registry 提供，而不是写死 Anime4K 类名。
 */
export const AVAILABLE_EFFECTS: EffectDescriptor[] = listEffectDescriptors(false);
