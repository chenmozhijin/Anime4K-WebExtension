/**
 * 配置迁移模块
 * 处理从 v1 配置格式到 v2 配置格式的迁移
 */

import type { CustomMode, EnhancementEffect, PerformanceTier } from '../types';
import { AVAILABLE_EFFECTS } from './effects-map';

// v1 版本的模式定义（旧格式）
interface V1EnhancementMode {
    id: string;
    name: string;
    isBuiltIn: boolean;
    effects: EnhancementEffect[];
}

// 配置版本
const CURRENT_CONFIG_VERSION = 2;

/**
 * 检查是否需要迁移
 */
export async function needsMigration(): Promise<boolean> {
    const data = await chrome.storage.sync.get(['_configVersion', 'enhancementModes']);

    // 如果已经是新版本，不需要迁移
    if (data._configVersion >= CURRENT_CONFIG_VERSION) {
        return false;
    }

    // 如果有旧的 enhancementModes 数据，需要迁移
    if (data.enhancementModes) {
        return true;
    }

    return false;
}

/**
 * 执行从 v1 到 v2 的迁移
 */
export async function migrateV1ToV2(): Promise<void> {
    console.log('[Migration] Starting v1 to v2 migration...');

    const syncData = await chrome.storage.sync.get([
        'enhancementModes',
        'selectedModeId',
        'targetResolutionSetting',
        'whitelistEnabled',
        'whitelist',
        'enableCrossOriginFix',
    ]);

    const oldModes = syncData.enhancementModes as V1EnhancementMode[] | undefined;

    // 提取用户自定义模式（保留完整效果链）
    const customModes: CustomMode[] = [];
    if (oldModes) {
        for (const mode of oldModes) {
            if (!mode.isBuiltIn) {
                // 同步效果定义，移除不再存在的效果
                const syncedEffects = mode.effects
                    .map(e => AVAILABLE_EFFECTS.find(ae => ae.id === e.id))
                    .filter((e): e is EnhancementEffect => !!e);

                customModes.push({
                    id: mode.id,
                    name: mode.name,
                    isBuiltIn: false,
                    effects: syncedEffects,
                });
            }
        }
    }

    // 确定选中的模式 ID
    let selectedModeId = syncData.selectedModeId || 'builtin-mode-a';

    // 如果选中的是旧的内置模式，映射到新的 ID
    const builtInModeMap: Record<string, string> = {
        'builtin-mode-a': 'builtin-mode-a',
        'builtin-mode-b': 'builtin-mode-b',
        'builtin-mode-c': 'builtin-mode-c',
        'builtin-mode-aa': 'builtin-mode-aa',
        'builtin-mode-bb': 'builtin-mode-bb',
        'builtin-mode-ca': 'builtin-mode-ca',
    };

    if (builtInModeMap[selectedModeId]) {
        selectedModeId = builtInModeMap[selectedModeId];
    }

    // 保存迁移后的数据
    await chrome.storage.sync.set({
        customModes,
        selectedModeId,
        targetResolutionSetting: syncData.targetResolutionSetting || 'x2',
        whitelistEnabled: syncData.whitelistEnabled ?? false,
        whitelist: syncData.whitelist || [],
        enableCrossOriginFix: syncData.enableCrossOriginFix ?? false,
        _configVersion: CURRENT_CONFIG_VERSION,
    });

    // 清理旧数据
    await chrome.storage.sync.remove('enhancementModes');

    // 设置默认本地设置
    const localData = await chrome.storage.local.get(['performanceTier']);
    if (!localData.performanceTier) {
        await chrome.storage.local.set({
            performanceTier: 'balanced' as PerformanceTier,
            gpuBenchmarkResult: null,
            gpuAdapterInfo: null,
            hasCompletedOnboarding: false,
        });
    }

    console.log('[Migration] v1 to v2 migration completed');
    console.log(`[Migration] Migrated ${customModes.length} custom modes`);
}

/**
 * 确保配置是最新版本
 */
export async function ensureLatestConfig(): Promise<void> {
    const needs = await needsMigration();
    if (needs) {
        await migrateV1ToV2();
    } else {
        // 确保新字段存在（用于全新安装）
        const syncData = await chrome.storage.sync.get(['_configVersion']);
        if (!syncData._configVersion) {
            await chrome.storage.sync.set({
                customModes: [],
                selectedModeId: 'builtin-mode-a',
                targetResolutionSetting: 'x2',
                whitelistEnabled: false,
                whitelist: [],
                enableCrossOriginFix: false,
                _configVersion: CURRENT_CONFIG_VERSION,
            });

            await chrome.storage.local.set({
                performanceTier: 'balanced' as PerformanceTier,
                gpuBenchmarkResult: null,
                gpuAdapterInfo: null,
                hasCompletedOnboarding: false,
            });

            console.log('[Migration] Initialized new config with defaults');
        }
    }
}
