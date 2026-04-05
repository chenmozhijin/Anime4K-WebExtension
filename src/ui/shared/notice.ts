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

const GLOBAL_NOTICE_CONTAINER_ATTR = 'data-anime4k-notice-root';
const NOTICE_ATTR = 'data-anime4k-notice';

function getOrCreateGlobalContainer(): HTMLElement {
  const existing = document.querySelector<HTMLElement>(`[${GLOBAL_NOTICE_CONTAINER_ATTR}]`);
  if (existing) {
    return existing;
  }

  const container = document.createElement('div');
  container.setAttribute(GLOBAL_NOTICE_CONTAINER_ATTR, '');
  Object.assign(container.style, {
    position: 'fixed',
    top: '20px',
    right: '20px',
    display: 'flex',
    flexDirection: 'column',
    gap: '10px',
    zIndex: '2147483647',
    maxWidth: '360px',
    pointerEvents: 'none',
  });
  document.body.appendChild(container);
  return container;
}

function getPalette(kind: NoticeKind) {
  if (kind === 'success') {
    return {
      border: '#1f7a4c',
      background: '#e9f8ef',
      color: '#12442a',
    };
  }

  if (kind === 'warning') {
    return {
      border: '#b7791f',
      background: '#fff7e6',
      color: '#7a4b00',
    };
  }

  if (kind === 'error') {
    return {
      border: '#b42318',
      background: '#fef3f2',
      color: '#7a271a',
    };
  }

  return {
    border: '#1d4ed8',
    background: '#eff6ff',
    color: '#1e3a8a',
  };
}

export function clearNotices(container?: HTMLElement | null): void {
  const root = container ?? document.querySelector<HTMLElement>(`[${GLOBAL_NOTICE_CONTAINER_ATTR}]`);
  root?.querySelectorAll(`[${NOTICE_ATTR}]`).forEach(node => node.remove());
}

export function showNotice(options: NoticeOptions): HTMLElement {
  const root = options.container ?? getOrCreateGlobalContainer();
  const palette = getPalette(options.kind);
  const notice = document.createElement('div');
  notice.setAttribute(NOTICE_ATTR, '');
  Object.assign(notice.style, {
    border: `1px solid ${palette.border}`,
    background: palette.background,
    color: palette.color,
    borderRadius: '10px',
    boxShadow: '0 10px 30px rgba(15, 23, 42, 0.12)',
    padding: '12px 14px',
    fontSize: '13px',
    lineHeight: '1.5',
    fontFamily: 'system-ui, sans-serif',
    pointerEvents: 'auto',
  });

  const content = document.createElement('div');
  content.textContent = options.message;
  notice.appendChild(content);

  if (options.actions?.length) {
    const actions = document.createElement('div');
    Object.assign(actions.style, {
      display: 'flex',
      flexWrap: 'wrap',
      gap: '8px',
      marginTop: '10px',
    });

    options.actions.forEach(action => {
      const actionButton = document.createElement('button');
      actionButton.type = 'button';
      actionButton.textContent = action.label;
      Object.assign(actionButton.style, {
        borderRadius: '999px',
        padding: '6px 12px',
        fontSize: '12px',
        fontWeight: '600',
        cursor: 'pointer',
        border: '1px solid currentColor',
        background: 'transparent',
        color: 'inherit',
      });

      if (action.emphasis === 'primary') {
        actionButton.style.background = palette.border;
        actionButton.style.borderColor = palette.border;
        actionButton.style.color = '#ffffff';
      }

      if (action.emphasis === 'danger') {
        actionButton.style.background = '#b42318';
        actionButton.style.borderColor = '#b42318';
        actionButton.style.color = '#ffffff';
      }

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
  Object.assign(dismissButton.style, {
    marginTop: '10px',
    border: 'none',
    background: 'transparent',
    color: 'inherit',
    fontWeight: '600',
    cursor: 'pointer',
    padding: '0',
  });
  dismissButton.addEventListener('click', () => notice.remove());
  notice.appendChild(dismissButton);

  root.appendChild(notice);

  if (options.timeoutMs !== 0) {
    window.setTimeout(() => notice.remove(), options.timeoutMs ?? 4000);
  }

  return notice;
}
