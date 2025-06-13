// 后台服务脚本
chrome.runtime.onInstalled.addListener(() => {
  console.log('Anime4K WebExtension installed');
});

// 监听标签页更新
chrome.tabs.onUpdated.addListener((tabId, changeInfo, tab) => {
  // 当页面加载完成且URL存在时，通知内容脚本
  if (changeInfo.status === 'complete' && tab.url) {
    chrome.tabs.sendMessage(tabId, {
      type: 'URL_UPDATED',
      url: tab.url
    }).catch(error => {
      // 如果内容脚本不存在（例如在chrome://页面），这个错误是正常的，可以忽略
      if (!error.message.includes('Receiving end does not exist')) {
        console.error(`[Background] Error sending URL_UPDATED message: ${error.message}`);
      }
    });
  }
});