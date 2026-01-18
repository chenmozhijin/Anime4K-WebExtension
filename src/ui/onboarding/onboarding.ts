import './onboarding.css';
import '../common-vars.css';
import { saveLocalSettings, getLocalSettings } from '../../utils/settings';
import { runGPUBenchmark, BenchmarkProgress } from '../../core/gpu-benchmark';
import { themeManager } from '../theme-manager';
import type { PerformanceTier, GPUBenchmarkResult } from '../../types';

// 档位显示名称
const TIER_DISPLAY: Record<PerformanceTier, { icon: string; name: string }> = {
    performance: { icon: '🚀', name: chrome.i18n.getMessage('tierPerformance') || 'Fast' },
    balanced: { icon: '⚖️', name: chrome.i18n.getMessage('tierBalanced') || 'Balanced' },
    quality: { icon: '🎨', name: chrome.i18n.getMessage('tierQuality') || 'Quality' },
    ultra: { icon: '🔬', name: chrome.i18n.getMessage('tierUltra') || 'Ultra' },
};

let currentStep = 1;
let selectedTier: PerformanceTier = 'balanced';
let benchmarkResult: GPUBenchmarkResult | null = null;

document.addEventListener('DOMContentLoaded', async () => {
    // 初始化主题
    themeManager.getTheme();

    // 应用国际化
    applyI18n();

    // 获取元素
    const startTestBtn = document.getElementById('start-test') as HTMLButtonElement;
    const skipTestBtn = document.getElementById('skip-test') as HTMLButtonElement;
    const confirmTierBtn = document.getElementById('confirm-tier') as HTMLButtonElement;
    const finishBtn = document.getElementById('finish') as HTMLButtonElement;
    const openOptionsBtn = document.getElementById('open-options') as HTMLButtonElement;
    const tierButtons = document.querySelectorAll<HTMLButtonElement>('.tier-btn');

    // 步骤 1: GPU 测试
    startTestBtn.addEventListener('click', async () => {
        startTestBtn.disabled = true;
        skipTestBtn.style.display = 'none';

        const testStatus = document.getElementById('test-status')!;
        const progressContainer = document.getElementById('progress-container')!;
        const progressFill = document.getElementById('progress-fill')!;
        const progressText = document.getElementById('progress-text')!;

        testStatus.style.display = 'none';
        progressContainer.style.display = 'block';

        try {
            benchmarkResult = await runGPUBenchmark((progress: BenchmarkProgress) => {
                progressFill.style.width = `${progress.progress * 100}%`;
                if (progress.completed) {
                    progressText.textContent = chrome.i18n.getMessage('testComplete') || 'Test complete!';
                } else {
                    // 将 tier 键名转换为国际化文本
                    const tierKey = `tier${progress.tier.charAt(0).toUpperCase()}${progress.tier.slice(1)}` as const;
                    const tierName = chrome.i18n.getMessage(tierKey) || progress.tier;
                    progressText.textContent = chrome.i18n.getMessage('testingTier', [tierName]) || `Testing ${tierName}...`;
                }
            });

            selectedTier = benchmarkResult.tier;

            // 保存结果
            await saveLocalSettings({
                performanceTier: selectedTier,
                gpuBenchmarkResult: benchmarkResult,
            });

            // 更新结果显示
            updateResultDisplay();

            // 跳到步骤 2
            goToStep(2);
        } catch (error) {
            console.error('Benchmark failed:', error);
            progressText.textContent = chrome.i18n.getMessage('testFailedDefault') || 'Test failed. Using default settings.';
            selectedTier = 'balanced';

            await saveLocalSettings({ performanceTier: selectedTier });

            setTimeout(() => goToStep(2), 2000);
        }
    });

    // 跳过测试
    skipTestBtn.addEventListener('click', async () => {
        selectedTier = 'balanced';
        await saveLocalSettings({ performanceTier: selectedTier });
        goToStep(2);
    });

    // 档位选择
    tierButtons.forEach(btn => {
        btn.addEventListener('click', () => {
            const tier = btn.getAttribute('data-tier') as PerformanceTier;
            selectedTier = tier;
            updateTierButtons();
        });
    });

    // 确认档位
    confirmTierBtn.addEventListener('click', async () => {
        await saveLocalSettings({
            performanceTier: selectedTier,
            hasCompletedOnboarding: true,
        });
        // 通知所有渲染器更新
        chrome.runtime.sendMessage({ type: 'SETTINGS_UPDATED' });
        goToStep(3);
    });

    // 完成
    finishBtn.addEventListener('click', () => {
        window.close();
    });

    openOptionsBtn.addEventListener('click', () => {
        chrome.runtime.openOptionsPage();
        window.close();
    });
});

function applyI18n(): void {
    document.querySelectorAll<HTMLElement>('[data-i18n]').forEach(el => {
        const key = el.getAttribute('data-i18n');
        if (key) {
            const message = chrome.i18n.getMessage(key);
            if (message) el.textContent = message;
        }
    });
}

function goToStep(step: number): void {
    // 更新步骤指示器
    document.querySelectorAll('.step').forEach((el, i) => {
        el.classList.remove('active', 'completed');
        if (i + 1 < step) el.classList.add('completed');
        if (i + 1 === step) el.classList.add('active');
    });

    // 更新内容
    document.querySelectorAll('.step-content').forEach((el, i) => {
        el.classList.toggle('active', i + 1 === step);
    });

    currentStep = step;

    if (step === 2) {
        updateTierButtons();
    }
}

function updateResultDisplay(): void {
    const resultTier = document.getElementById('result-tier')!;
    const resultDesc = document.getElementById('result-desc')!;

    const display = TIER_DISPLAY[selectedTier];
    resultTier.textContent = `${display.icon} ${display.name}`;

    // 只有当选择的档位与测试推荐的档位一致时才显示推荐文本
    if (benchmarkResult && selectedTier === benchmarkResult.tier) {
        resultDesc.textContent = chrome.i18n.getMessage('resultDesc') || 'This tier is recommended based on your hardware.';
        resultDesc.style.display = 'block';
    } else if (benchmarkResult) {
        // 用户选择了不同档位
        resultDesc.textContent = chrome.i18n.getMessage('manuallySelected') || 'You have selected a different tier.';
        resultDesc.style.display = 'block';
    } else {
        // 跳过了测试
        resultDesc.textContent = chrome.i18n.getMessage('defaultTier') || 'Default tier selected.';
        resultDesc.style.display = 'block';
    }
}

function updateTierButtons(): void {
    document.querySelectorAll<HTMLButtonElement>('.tier-btn').forEach(btn => {
        const tier = btn.getAttribute('data-tier');
        btn.classList.toggle('active', tier === selectedTier);
    });

    updateResultDisplay();
}
