import { syncModes, getSettings } from './utils/settings';

const RULESET_ID = 'ruleset_1';

/**
 * 根据当前设置更新 declarativeNetRequest 规则集。
 */
async function updateDNRuleset() {
  const { enableCrossOriginFix } = await getSettings();
  if (enableCrossOriginFix) {
    await chrome.declarativeNetRequest.updateEnabledRulesets({
      enableRulesetIds: [RULESET_ID]
    });
    console.log('[Background] Cross-origin DNR ruleset enabled.');
  } else {
    await chrome.declarativeNetRequest.updateEnabledRulesets({
      disableRulesetIds: [RULESET_ID]
    });
    console.log('[Background] Cross-origin DNR ruleset disabled.');
  }
}

// 后台服务脚本

// 在启动时同步内置模式和DNR规则
chrome.runtime.onStartup.addListener(() => {
  console.log('Browser startup, syncing modes and DNR rules.');
  syncModes();
  updateDNRuleset();
});

chrome.runtime.onInstalled.addListener(() => {
  console.log('Anime4K WebExtension installed or updated.');
  syncModes();
  updateDNRuleset();
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
      const target: chrome.scripting.InjectionTarget = { tabId: sender.tab.id };
      // 仅当 frameId 存在且不为0时才指定 frameIds，以确保注入到正确的 iframe
      // frameId 为 0 通常代表主框架
      if (sender.frameId) {
        target.frameIds = [sender.frameId];
      }
      
      console.log(`[Background] Received request to load module: ${scriptPath} for target:`, target);
      chrome.scripting.executeScript({
        target: target,
        files: [scriptPath],
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
  } else if (request.type === 'SETTINGS_UPDATED') {
    // 当设置更新时，检查是否需要更新DNR规则
    console.log('[Background] Settings updated, checking DNR rules...');
    updateDNRuleset();
  } else if (request.type === 'OPEN_OPTIONS_PAGE') {
    chrome.runtime.openOptionsPage();
  }
});