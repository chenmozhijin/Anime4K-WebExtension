// 后台服务脚本
chrome.runtime.onInstalled.addListener(() => {
  console.log('Anime4K WebExtension installed');
});

// 监听标签页更新
chrome.tabs.onUpdated.addListener((tabId, changeInfo, tab) => {
  // 当URL变化时，通知内容脚本
  if (changeInfo.url && tab.url) {
    chrome.tabs.sendMessage(tabId, {
      type: 'URL_UPDATED',
      url: changeInfo.url
    });
  }
});