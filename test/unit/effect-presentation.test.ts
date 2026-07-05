import { describe, expect, it } from 'vitest';
import { listEffectDescriptors } from '../../src/core/effects/registry';
import {
  getEffectPresentationGroups,
  summarizeEffectChain,
} from '../../src/ui/options/modules/effect-presentation';

const visibleEffects = listEffectDescriptors(false);

describe('options effect presentation', () => {
  it('groups visible effects by backend for the all tab', () => {
    const groups = getEffectPresentationGroups({
      effects: visibleEffects,
      activeBackend: 'all',
      query: '',
    });

    expect(groups.map(group => group.label)).toEqual([
      'Anime4K',
      'ArtCNN',
      'ACNet',
      'CuNNy',
    ]);
  });

  it('does not include helper or internal resize effects in the browser source list', () => {
    expect(visibleEffects.map(effect => effect.id)).not.toContain('anime4k/Helper/ClampHighlights');
    expect(visibleEffects.map(effect => effect.id)).not.toContain('core/Resize/ToTarget');
    expect(visibleEffects.map(effect => effect.id)).not.toContain('core/internal/ResizeLinear');
  });

  it('groups ACNet models by family', () => {
    const groups = getEffectPresentationGroups({
      effects: visibleEffects,
      activeBackend: 'acnet',
      query: '',
    });

    expect(groups.map(group => group.label)).toEqual(['ACNet', 'Legacy', 'ARNet']);
    expect(groups.find(group => group.label === 'Legacy')?.items.map(item => item.descriptor.id))
      .toContain('acnet/Upscale/Legacy/GAN');
    expect(groups.find(group => group.label === 'ARNet')?.items.map(item => item.descriptor.id))
      .toContain('acnet/Upscale/ARNet/F8B64');
  });

  it('groups CuNNy models by variant', () => {
    const groups = getEffectPresentationGroups({
      effects: visibleEffects,
      activeBackend: 'cunny',
      query: '',
    });

    expect(groups.map(group => group.label)).toEqual(['DS', 'SOFT']);
    expect(groups.find(group => group.label === 'DS')?.items.map(item => item.descriptor.id))
      .toContain('cunny/Upscale/DS/Fast');
    expect(groups.find(group => group.label === 'SOFT')?.items.map(item => item.descriptor.id))
      .toContain('cunny/Upscale/SOFT/Fast');
  });

  it('searches by backend, model family, key, and name terms', () => {
    const acnet = getEffectPresentationGroups({
      effects: visibleEffects,
      activeBackend: 'all',
      query: 'acnet f8b4',
    }).flatMap(group => group.items.map(item => item.descriptor.id));
    const cunny = getEffectPresentationGroups({
      effects: visibleEffects,
      activeBackend: 'all',
      query: 'cunny soft',
    }).flatMap(group => group.items.map(item => item.descriptor.id));
    const artcnn = getEffectPresentationGroups({
      effects: visibleEffects,
      activeBackend: 'all',
      query: 'artcnn c4f32',
    }).flatMap(group => group.items.map(item => item.descriptor.id));

    expect(acnet).toContain('acnet/Upscale/F8B4');
    expect(cunny).toContain('cunny/Upscale/SOFT/Fast');
    expect(artcnn).toContain('artcnn/Upscale/C4F32');
  });

  it('summarizes effect chains with a compact overflow count', () => {
    const summary = summarizeEffectChain([
      { id: 'a', backendId: 'anime4k', key: 'a' },
      { id: 'b', backendId: 'anime4k', key: 'b' },
      { id: 'c', backendId: 'anime4k', key: 'c' },
      { id: 'd', backendId: 'anime4k', key: 'd' },
      { id: 'e', backendId: 'anime4k', key: 'e' },
      { id: 'f', backendId: 'anime4k', key: 'f' },
    ], effect => effect.key.toUpperCase());

    expect(summary).toBe('A > B > C > D +2');
  });
});
