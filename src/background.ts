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

// 监听来自内容脚本的动态模块加载请求
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  if (request.type === 'LOAD_DYNAMIC_MODULE') {
    if (sender.tab?.id && request.chunk) {
      const scriptPath = `${request.chunk}.js`;
      console.log(`[Background] Received request to load module: ${scriptPath} for tab: ${sender.tab.id}`);
      chrome.scripting.executeScript({
        target: { tabId: sender.tab.id },
        files: [scriptPath], // 直接注入编译后的入口文件
      })
      .then(() => {
        console.log(`[Background] Successfully injected script: ${scriptPath}`);
        sendResponse({ success: true });
      })
      .catch(err => {
        console.error(`[Background] Failed to inject script: ${scriptPath}`, err);
        sendResponse({ success: false, error: err.message });
      });
    } else {
      console.error('[Background] Invalid LOAD_DYNAMIC_MODULE request', request);
      sendResponse({ success: false, error: 'Invalid request: missing tab.id or chunk name' });
    }
    // 返回 true 表示我们将异步发送响应
    return true;
  }
});