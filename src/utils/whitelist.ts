/**
 * 白名单管理模块
 * 提供白名单规则匹配、验证和持久化功能
 */
import { getSettings, saveSettings } from './settings';

// 白名单规则接口
export interface WhitelistRule {
  pattern: string; // 通配符模式
  enabled: boolean;
}

/**
 * 验证白名单规则语法
 * @param pattern 通配符模式
 */
export function validateRulePattern(pattern: string): boolean {
  try {
    // 简单验证：不能为空且至少包含一个有效字符
    return pattern.trim().length > 0;
  } catch {
    return false;
  }
}

/**
 * 检查URL是否匹配任何白名单规则
 * @param url 要检查的URL
 * @param rules 白名单规则数组
 */
export function isUrlWhitelisted(url: string, rules: WhitelistRule[]): boolean {
  if (!rules || rules.length === 0) return false;
  
  try {
    const parsedUrl = new URL(url);
    // 移除协议和查询参数
    const baseUrl = parsedUrl.hostname + parsedUrl.pathname;
    
    const result = rules.some(rule => {
      if (!rule.enabled) return false;
      
      // 将通配符模式转换为正则表达式
      const regexPattern = rule.pattern
        .replace(/\./g, '\\.')
        .replace(/\*/g, '.*');
        
      // 创建不区分大小写的正则表达式
      const regex = new RegExp(regexPattern, 'i');
      const matchResult = regex.test(baseUrl);
      
      return matchResult;
    });
    
    return result;
  } catch (error) {
    console.error('[Whitelist] URL匹配失败:', error);
    return false;
  }
}

/**
 * 添加新规则到白名单
 * @param pattern 通配符模式
 * @param enabled 是否启用
 */
export async function addWhitelistRule(pattern: string, enabled: boolean = true): Promise<void> {
  const settings = await getSettings();
  const newRule: WhitelistRule = { pattern, enabled };
  
  if (!settings.whitelist) {
    settings.whitelist = [];
  }
  
  // 避免重复添加
  if (!settings.whitelist.some(r => r.pattern === pattern)) {
    settings.whitelist.push(newRule);
    await saveSettings(settings);
    
    // 通知白名单已更新
    chrome.runtime.sendMessage({ type: 'WHITELIST_UPDATED' });
  }
}

/**
 * 删除白名单规则
 * @param pattern 要删除的规则模式
 */
export async function removeWhitelistRule(pattern: string): Promise<void> {
  const settings = await getSettings();
  
  if (settings.whitelist) {
    settings.whitelist = settings.whitelist.filter(r => r.pattern !== pattern);
    await saveSettings(settings);
    
    // 通知白名单已更新
    chrome.runtime.sendMessage({ type: 'WHITELIST_UPDATED' });
  }
}

/**
 * 更新白名单规则
 * @param oldPattern 要更新的规则模式
 * @param update 更新内容（可以是新的启用状态或新的模式）
 */
export async function updateWhitelistRule(oldPattern: string, update: boolean | string): Promise<void> {
  const settings = await getSettings();
  
  if (settings.whitelist) {
    const ruleIndex = settings.whitelist.findIndex(r => r.pattern === oldPattern);
    if (ruleIndex !== -1) {
      if (typeof update === 'boolean') {
        // 更新启用状态
        settings.whitelist[ruleIndex].enabled = update;
      } else {
        // 更新模式字符串
        settings.whitelist[ruleIndex].pattern = update;
      }
      await saveSettings(settings);
      
      // 通知白名单已更新
      chrome.runtime.sendMessage({ type: 'WHITELIST_UPDATED' });
    }
  }
}

/**
 * 获取当前所有白名单规则
 */
export async function getWhitelistRules(): Promise<WhitelistRule[]> {
  const settings = await getSettings();
  return settings.whitelist || [];
}

/**
 * 设置默认白名单规则
 */
export async function setDefaultWhitelist(): Promise<void> {
  const defaultRules = [
    { pattern: 'ani.gamer.com.tw/animeVideo.php', enabled: true },
    { pattern: 'www.bilibili.com/bangumi/play/*', enabled: true }
  ];
  
  await saveSettings({
    ...await getSettings(),
    whitelist: defaultRules,
    whitelistEnabled: true
  });
}