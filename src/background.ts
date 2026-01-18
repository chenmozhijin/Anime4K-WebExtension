import { getSettings, getLocalSettings } from './utils/settings';
import { ensureLatestConfig } from './utils/migration';

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

/**
 * 检查是否需要打开引导页面
 */
async function checkOnboarding(): Promise<boolean> {
  const local = await getLocalSettings();

  // 如果未完成引导，打开引导页
  if (!local.hasCompletedOnboarding) {
    console.log('[Background] Opening onboarding page...');
    chrome.tabs.create({ url: chrome.runtime.getURL('onboarding.html') });
    return true;
  }

  return false;
}

/**
 * 检查上次测试是否崩溃
 */
async function checkBenchmarkCrash(): Promise<void> {
  const local = await chrome.storage.local.get(['_benchmarkInProgress']);

  if (local._benchmarkInProgress) {
    console.warn('[Background] Previous benchmark may have crashed, using safe defaults');

    await chrome.storage.local.set({
      performanceTier: 'performance',
      hasCompletedOnboarding: true,
    });
    await chrome.storage.local.remove('_benchmarkInProgress');
  }
}

// 后台服务脚本

// 在启动时检查 DNR 规则
chrome.runtime.onStartup.addListener(async () => {
  console.log('[Background] Browser startup');

  await checkBenchmarkCrash();
  await updateDNRuleset();
});

// 安装或更新时初始化
chrome.runtime.onInstalled.addListener(async (details) => {
  console.log('[Background] Extension installed/updated:', details.reason);

  // 确保配置是最新版本（处理迁移）
  await ensureLatestConfig();

  await checkBenchmarkCrash();
  await updateDNRuleset();

  // 新安装或更新时，如果未完成引导则打开引导页
  if (details.reason === 'install' || details.reason === 'update') {
    await checkOnboarding();
  }
});

// 监听标签页更新
chrome.tabs.onUpdated.addListener((tabId, changeInfo, tab) => {
  if (changeInfo.status === 'complete' && tab.url) {
    chrome.tabs.sendMessage(tabId, {
      type: 'URL_UPDATED',
      url: tab.url
    }).catch(error => {
      if (!error.message.includes('Receiving end does not exist')) {
        console.error(`[Background] Error sending URL_UPDATED message: ${error.message}`);
      }
    });
  }
});

// 监听来自内容脚本/popup/options 的请求
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  if (request.type === 'SETTINGS_UPDATED') {
    console.log('[Background] Settings updated, checking DNR rules...');
    updateDNRuleset();
  } else if (request.type === 'OPEN_OPTIONS_PAGE') {
    chrome.runtime.openOptionsPage();
  } else if (request.type === 'OPEN_ONBOARDING') {
    chrome.tabs.create({ url: chrome.runtime.getURL('onboarding.html') });
  }
});