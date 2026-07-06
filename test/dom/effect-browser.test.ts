import type { EffectDescriptor } from '../../src/types';
import { describe, expect, it, vi } from 'vitest';
import { installChromeMock } from '../support/chrome';
import { renderEffectBrowser } from '../../src/ui/options/modules/effect-browser';

const effects: EffectDescriptor[] = [
  {
    id: 'anime4k/CNNM',
    backendId: 'anime4k',
    key: 'CNNM',
    name: 'CNNM',
    category: 'restore',
    dimensionBehavior: { kind: 'same' },
    supportsVideoRealtime: true,
  },
  {
    id: 'acnet/Upscale/F8B4',
    backendId: 'acnet',
    key: 'ACNET_F8B4',
    name: 'Upscale ACNet F8B4 x2',
    category: 'upscale',
    dimensionBehavior: { kind: 'scale', scale: 2 },
    supportsVideoRealtime: true,
  },
];

describe('effect browser', () => {
  it('renders ARIA state and supports keyboard tab navigation and Escape close', () => {
    installChromeMock();
    const onToggle = vi.fn();
    const onBackendChange = vi.fn();
    const onQueryChange = vi.fn();
    const onAddEffect = vi.fn();

    document.body.appendChild(renderEffectBrowser({
      modeId: 'custom-1',
      effects,
      state: { modeId: 'custom-1', backendId: 'all', query: '' },
      onToggle,
      onBackendChange,
      onQueryChange,
      onAddEffect,
    }));

    const toggleButton = document.querySelector('.btn-toggle-effect-browser') as HTMLButtonElement;
    const browser = document.querySelector('.effect-browser') as HTMLElement;
    const tabs = Array.from(document.querySelectorAll<HTMLButtonElement>('.effect-backend-tab'));
    const search = document.querySelector('.effect-search-input') as HTMLInputElement;

    expect(toggleButton.getAttribute('aria-expanded')).toBe('true');
    expect(toggleButton.getAttribute('aria-controls')).toBe(browser.id);
    expect(browser.getAttribute('role')).toBe('region');
    expect(document.querySelector('.effect-backend-tabs')?.getAttribute('role')).toBe('tablist');
    expect(tabs).toHaveLength(5);
    expect(tabs.map(tab => tab.textContent)).not.toContain('Core');
    expect(tabs[0].getAttribute('role')).toBe('tab');
    expect(tabs[0].getAttribute('aria-selected')).toBe('true');
    expect(search.getAttribute('aria-controls')).toBe(document.querySelector('.effect-browser-results')?.id);

    tabs[0].dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowRight', bubbles: true }));
    expect(onBackendChange).toHaveBeenCalledWith('anime4k');
    expect(tabs[1].getAttribute('aria-selected')).toBe('true');

    search.value = 'acnet';
    search.dispatchEvent(new Event('input', { bubbles: true }));
    expect(onQueryChange).toHaveBeenCalledWith('acnet');

    browser.dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape', bubbles: true }));
    expect(onToggle).toHaveBeenCalledTimes(1);
  });
});
