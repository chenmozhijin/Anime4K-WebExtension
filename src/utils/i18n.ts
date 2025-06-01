// 提供国际化支持
export const getMessage = (key: string): string => chrome.i18n.getMessage(key);