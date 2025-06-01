/**
 * 内容脚本主入口
 * 负责在页面视频元素上添加增强按钮并管理增强器实例
 */
import { initializeOnPage, handleSettingsUpdate } from './core/video-manager';
import { isUrlWhitelisted, getWhitelistRules } from './utils/whitelist';

// 检查当前页面是否在白名单中
async function shouldInitialize(): Promise<boolean> {
  const settings = await chrome.storage.sync.get(['whitelistEnabled']);
  if (!settings.whitelistEnabled) return true; // 白名单未启用时始终初始化
  
  const rules = await getWhitelistRules();
  return isUrlWhitelisted(window.location.href, rules);
}

// 根据白名单状态初始化页面
async function initializeBasedOnWhitelist() {
  if (await shouldInitialize()) {
    console.log('[Anime4KWebExt] 初始化增强功能...');
    initializeOnPage();
  } else {
    console.log('[Anime4KWebExt] 当前页面不在白名单中，跳过增强功能。');
  }
}

// 初始化页面
initializeBasedOnWhitelist();

// 监听来自后台的设置更新消息
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  if (request.type === 'SETTINGS_UPDATED') {
    handleSettingsUpdate(request.settings, sendResponse);
    return true; // 表示异步响应
  }
  return false;
});