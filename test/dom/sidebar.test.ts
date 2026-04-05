import { describe, expect, it } from 'vitest';
import { Sidebar } from '../../src/ui/options/Sidebar';

describe('Sidebar', () => {
  it('toggles visibility and navigates between sections', () => {
    Object.defineProperty(window, 'innerWidth', {
      configurable: true,
      value: 800,
    });
    document.body.innerHTML = `
      <aside id="sidebar"></aside>
      <button id="sidebar-toggle"></button>
      <div id="sidebar-overlay"></div>
      <nav id="sidebar-menu">
        <a class="menu-item active" data-section="general">General</a>
        <a class="menu-item" data-section="advanced">Advanced</a>
      </nav>
      <section id="general-section" class="content-section active"></section>
      <section id="advanced-section" class="content-section"></section>
    `;

    const sidebar = new Sidebar();
    sidebar.initialize();

    document.getElementById('sidebar-toggle')?.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    expect(document.getElementById('sidebar')?.classList.contains('open')).toBe(true);
    expect(document.getElementById('sidebar-overlay')?.classList.contains('active')).toBe(true);

    document.querySelector('[data-section="advanced"]')?.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    expect(document.querySelector('[data-section="advanced"]')?.classList.contains('active')).toBe(true);
    expect(document.getElementById('advanced-section')?.classList.contains('active')).toBe(true);
    expect(document.getElementById('sidebar')?.classList.contains('open')).toBe(false);

    sidebar.open();
    expect(document.getElementById('sidebar')?.classList.contains('open')).toBe(true);

    sidebar.close();
    expect(document.getElementById('sidebar-overlay')?.classList.contains('active')).toBe(false);
  });
});
