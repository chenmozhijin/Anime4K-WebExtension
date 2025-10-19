/**
 * 内容脚本主入口
 * 负责在页面视频元素上添加增强按钮并管理增强器实例
 */
import { initializeOnPage, deinitializeOnPage, handleSettingsUpdate } from './core/video-manager';
import { isUrlWhitelisted, getWhitelistRules } from './utils/whitelist';

let isCurrentlyActive = false; // 跟踪当前页面的增强状态

// 检查当前页面是否在白名单中
async function shouldInitialize(): Promise<boolean> {
  const settings = await chrome.storage.sync.get(['whitelistEnabled']);
  if (!settings.whitelistEnabled) return true; // 白名单未启用时始终初始化
  
  const rules = await getWhitelistRules();
  return isUrlWhitelisted(window.location.href, rules);
}

// 根据白名单状态评估并应用更改
async function evaluateAndApplyWhitelistState() {
  const shouldBeActive = await shouldInitialize();

  if (shouldBeActive && !isCurrentlyActive) {
    // Case: 需要激活 (例如从非白名单页导航到白名单页)
    console.log('[Anime4KWebExt] Whitelist match found. Initializing features...');
    initializeOnPage();
    isCurrentlyActive = true;
  } else if (!shouldBeActive && isCurrentlyActive) {
    // Case: 需要反激活 (例如从白名单页导航到非白名单页)
    console.log('[Anime4KWebExt] No longer on a whitelisted page. De-initializing features...');
    deinitializeOnPage();
    isCurrentlyActive = false;
  } else {
    // Case: 状态无需改变
    console.log(`[Anime4KWebExt] Whitelist state unchanged (shouldBeActive: ${shouldBeActive}, isCurrentlyActive: ${isCurrentlyActive}). No action needed.`);
  }
}

// 初始化页面
evaluateAndApplyWhitelistState();

// 监听来自后台的设置更新消息
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  if (request.type === 'SETTINGS_UPDATED') {
    handleSettingsUpdate(request.settings, sendResponse);
    return true; // 表示异步响应
  } else if (request.type === 'URL_UPDATED') {
    // URL 变化时重新检查白名单
    console.log('[Anime4KWebExt] URL changed, re-evaluating whitelist...');
    evaluateAndApplyWhitelistState();
  }
  return false;
});