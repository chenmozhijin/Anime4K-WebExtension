import { describe, expect, it, vi } from 'vitest';
import { installChromeMock } from '../support/chrome';
import { clearNotices, showNotice } from '../../src/ui/shared/notice';

describe('showNotice', () => {
  it('creates notices with actions and removes them after action clicks', async () => {
    installChromeMock();
    const action = vi.fn().mockResolvedValue(undefined);

    const notice = showNotice({
      kind: 'warning',
      message: 'Heads up',
      timeoutMs: 0,
      actions: [
        {
          label: 'Retry',
          emphasis: 'primary',
          onClick: action,
        },
      ],
    });

    expect(document.querySelector('[data-anime4k-notice-root]')).not.toBeNull();
    expect(notice.textContent).toContain('Heads up');

    notice.querySelector('button')?.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    await Promise.resolve();

    expect(action).toHaveBeenCalledTimes(1);
    expect(notice.isConnected).toBe(false);
  });

  it('uses custom containers and clears notices on demand', () => {
    installChromeMock();
    const container = document.createElement('div');
    document.body.appendChild(container);

    showNotice({
      kind: 'success',
      message: 'Saved',
      timeoutMs: 0,
      container,
    });

    expect(container.querySelector('[data-anime4k-notice]')).not.toBeNull();

    clearNotices(container);
    expect(container.querySelector('[data-anime4k-notice]')).toBeNull();
  });
});
