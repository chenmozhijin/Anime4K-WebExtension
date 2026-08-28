import './notice.css';

type NoticeKind = 'info' | 'success' | 'warning' | 'error';

type NoticeAction = {
  label: string;
  onClick: () => void | Promise<void>;
  emphasis?: 'normal' | 'primary' | 'danger';
  closeOnClick?: boolean;
};

type NoticeOptions = {
  kind: NoticeKind;
  message: string;
  timeoutMs?: number;
  container?: HTMLElement | null;
  actions?: NoticeAction[];
};

const GLOBAL_NOTICE_CONTAINER_ATTR = 'data-nijilucid-notice-root';
const NOTICE_ATTR = 'data-nijilucid-notice';

function isAssertiveNotice(kind: NoticeKind): boolean {
  return kind === 'error' || kind === 'warning';
}

function getOrCreateGlobalContainer(): HTMLElement {
  const existing = document.querySelector<HTMLElement>(`[${GLOBAL_NOTICE_CONTAINER_ATTR}]`);
  if (existing) {
    return existing;
  }

  const container = document.createElement('div');
  container.setAttribute(GLOBAL_NOTICE_CONTAINER_ATTR, '');
  container.className = 'nijilucid-notice-root';
  container.setAttribute('aria-live', 'polite');
  container.setAttribute('aria-relevant', 'additions');
  document.body.appendChild(container);
  return container;
}

export function clearNotices(container?: HTMLElement | null): void {
  const root = container ?? document.querySelector<HTMLElement>(`[${GLOBAL_NOTICE_CONTAINER_ATTR}]`);
  root?.querySelectorAll(`[${NOTICE_ATTR}]`).forEach(node => node.remove());
}

export function showNotice(options: NoticeOptions): HTMLElement {
  const root = options.container ?? getOrCreateGlobalContainer();
  const notice = document.createElement('div');
  notice.setAttribute(NOTICE_ATTR, '');
  notice.className = 'nijilucid-notice';
  notice.dataset.kind = options.kind;
  notice.setAttribute('role', isAssertiveNotice(options.kind) ? 'alert' : 'status');
  notice.setAttribute('aria-live', isAssertiveNotice(options.kind) ? 'assertive' : 'polite');
  notice.setAttribute('aria-atomic', 'true');
  notice.tabIndex = -1;

  const content = document.createElement('div');
  content.className = 'nijilucid-notice-message';
  content.textContent = options.message;
  notice.appendChild(content);

  if (options.actions?.length) {
    const actions = document.createElement('div');
    actions.className = 'nijilucid-notice-actions';

    options.actions.forEach(action => {
      const actionButton = document.createElement('button');
      actionButton.type = 'button';
      actionButton.textContent = action.label;
      actionButton.className = 'nijilucid-notice-action';
      actionButton.dataset.emphasis = action.emphasis ?? 'normal';

      actionButton.addEventListener('click', () => {
        void Promise.resolve(action.onClick()).finally(() => {
          if (action.closeOnClick !== false) {
            notice.remove();
          }
        });
      });
      actions.appendChild(actionButton);
    });

    notice.appendChild(actions);
  }

  const dismissButton = document.createElement('button');
  dismissButton.type = 'button';
  dismissButton.textContent = chrome.i18n.getMessage('dismiss');
  dismissButton.setAttribute('aria-label', chrome.i18n.getMessage('dismiss'));
  dismissButton.className = 'nijilucid-notice-dismiss';
  dismissButton.addEventListener('click', () => notice.remove());
  notice.appendChild(dismissButton);
  notice.addEventListener('keydown', event => {
    if (event.key === 'Escape') {
      event.stopPropagation();
      notice.remove();
    }
  });

  root.appendChild(notice);
  if (options.timeoutMs === 0 || options.actions?.length) {
    notice.focus({ preventScroll: true });
  }

  if (options.timeoutMs !== 0) {
    window.setTimeout(() => notice.remove(), options.timeoutMs ?? 4000);
  }

  return notice;
}
