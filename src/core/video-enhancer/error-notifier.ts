import { buildErrorPresentation, type ErrorPresentationPhase } from '../error-presentation';

export class EnhancerErrorNotifier {
  private static readonly ERROR_NOTIFICATION_ATTR = 'data-nijilucid-error-notification';
  private notification: HTMLElement | null = null;
  private autoDismissTimer: number | null = null;

  public clear(): void {
    if (this.autoDismissTimer !== null) {
      clearTimeout(this.autoDismissTimer);
      this.autoDismissTimer = null;
    }
    this.notification?.remove();
    this.notification = null;
  }

  public present(
    error: unknown,
    phase: ErrorPresentationPhase,
    options: {
      enableCrossOriginFix: boolean;
    },
  ): void {
    const content = buildErrorPresentation(error, {
      phase,
      enableCrossOriginFix: options.enableCrossOriginFix,
      genericEnhanceMessage: chrome.i18n.getMessage('enhanceError'),
      genericRenderMessage: chrome.i18n.getMessage('renderError'),
      crossOriginHintMessage: chrome.i18n.getMessage('crossOriginHint'),
      knownMessages: {
        gpuUnsupported: chrome.i18n.getMessage('gpuUnsupported'),
        gpuOutOfMemory: chrome.i18n.getMessage('gpuOutOfMemory'),
        gpuDeviceLost: chrome.i18n.getMessage('gpuDeviceLost'),
        textureDimensionExceeded: chrome.i18n.getMessage('gpuTextureDimensionExceeded'),
        textureDimensionExceededWithAdapterLimit: chrome.i18n.getMessage('gpuTextureDimensionExceededWithAdapterLimit'),
        effectCompilationValidationFailed: chrome.i18n.getMessage('gpuEffectCompilationValidationFailed'),
        effectCompilationFailed: chrome.i18n.getMessage('gpuEffectCompilationFailed'),
        effectWarmupValidationFailed: chrome.i18n.getMessage('gpuEffectWarmupValidationFailed'),
        effectWarmupFailed: chrome.i18n.getMessage('gpuEffectWarmupFailed'),
        frameSubmissionValidationFailed: chrome.i18n.getMessage('gpuFrameSubmissionValidationFailed'),
        frameSubmissionFailed: chrome.i18n.getMessage('gpuFrameSubmissionFailed'),
      },
    });

    this.show(content.summary, {
      details: content.details,
      showOptionsLink: content.showOptionsLink,
    });
  }

  private show(
    message: string,
    options: {
      details?: string;
      showOptionsLink?: boolean;
    } = {},
  ): void {
    this.clear();

    const notification = document.createElement('div');
    notification.setAttribute(EnhancerErrorNotifier.ERROR_NOTIFICATION_ATTR, '');
    Object.assign(notification.style, {
      position: 'fixed',
      top: '20px',
      right: '20px',
      backgroundColor: '#333',
      color: '#fff',
      padding: '15px 20px',
      borderRadius: '8px',
      boxShadow: '0 2px 10px rgba(0,0,0,0.2)',
      zIndex: '10000',
      maxWidth: '380px',
      fontFamily: 'system-ui, sans-serif',
      fontSize: '14px',
      lineHeight: '1.5',
      border: '1px solid rgba(255,255,255,0.14)',
    });

    const titleNode = document.createElement('div');
    titleNode.textContent = chrome.i18n.getMessage('extensionName');
    Object.assign(titleNode.style, {
      fontWeight: '600',
      marginBottom: '8px',
      letterSpacing: '0.2px',
    });
    notification.appendChild(titleNode);

    const messageNode = document.createElement('p');
    messageNode.textContent = message;
    Object.assign(messageNode.style, {
      margin: '0',
      whiteSpace: 'pre-wrap',
    });
    notification.appendChild(messageNode);

    if (options.details) {
      const detailsNode = document.createElement('details');
      Object.assign(detailsNode.style, {
        marginTop: '10px',
        color: '#d2d8e2',
      });
      const summaryNode = document.createElement('summary');
      summaryNode.textContent = chrome.i18n.getMessage('errorTechnicalDetails');
      summaryNode.style.cursor = 'pointer';
      summaryNode.style.userSelect = 'none';
      detailsNode.appendChild(summaryNode);

      const detailText = document.createElement('pre');
      detailText.textContent = options.details;
      Object.assign(detailText.style, {
        margin: '8px 0 0',
        whiteSpace: 'pre-wrap',
        wordBreak: 'break-word',
        fontFamily: 'ui-monospace, SFMono-Regular, Consolas, monospace',
        fontSize: '12px',
        lineHeight: '1.45',
        maxHeight: '160px',
        overflow: 'auto',
      });
      detailsNode.appendChild(detailText);
      notification.appendChild(detailsNode);
    }

    if (options.showOptionsLink) {
      const link = document.createElement('a');
      link.textContent = chrome.i18n.getMessage('goToOptions');
      link.href = '#';
      link.style.color = '#8ab4f8';
      link.style.marginTop = '8px';
      link.style.display = 'block';
      link.onclick = (event) => {
        event.preventDefault();
        chrome.runtime.sendMessage({ type: 'OPEN_OPTIONS_PAGE' });
      };
      notification.appendChild(link);
    }

    const dismissButton = document.createElement('button');
    dismissButton.textContent = chrome.i18n.getMessage('dismiss');
    Object.assign(dismissButton.style, {
      marginTop: '12px',
      border: 'none',
      background: '#4b5563',
      color: '#fff',
      borderRadius: '6px',
      padding: '6px 10px',
      cursor: 'pointer',
    });
    dismissButton.onclick = () => this.clear();
    notification.appendChild(dismissButton);

    document.body.appendChild(notification);
    this.notification = notification;
    this.autoDismissTimer = window.setTimeout(() => this.clear(), options.details ? 12000 : 8000);
  }
}
