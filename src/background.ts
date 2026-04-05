import { getSettings, getLocalSettings } from './utils/settings';
import { ensureLatestConfig } from './utils/migration';
import { createLogger } from './utils/logger';

const RULESET_ID = 'ruleset_1';
const logger = createLogger('background');

export type BackgroundBootstrapDeps = {
  chromeApi: typeof chrome;
  getSettings: typeof getSettings;
  getLocalSettings: typeof getLocalSettings;
  ensureLatestConfig: typeof ensureLatestConfig;
};

type ResolvedBackgroundBootstrapDeps = BackgroundBootstrapDeps;

export interface BackgroundBootstrap {
  updateDNRuleset(): Promise<void>;
  checkOnboarding(): Promise<boolean>;
  checkBenchmarkCrash(): Promise<void>;
  registerListeners(): void;
  dispose(): void;
}

function resolveBackgroundDependencies(overrides: Partial<BackgroundBootstrapDeps> = {}): ResolvedBackgroundBootstrapDeps {
  return {
    chromeApi: chrome,
    getSettings,
    getLocalSettings,
    ensureLatestConfig,
    ...overrides,
  };
}

export function createBackgroundBootstrap(
  overrides: Partial<BackgroundBootstrapDeps> = {},
): BackgroundBootstrap {
  const deps = resolveBackgroundDependencies(overrides);
  const { chromeApi } = deps;
  let listenersRegistered = false;

  async function updateDNRuleset(): Promise<void> {
    const { enableCrossOriginFix } = await deps.getSettings();
    if (enableCrossOriginFix) {
      await chromeApi.declarativeNetRequest.updateEnabledRulesets({
        enableRulesetIds: [RULESET_ID],
      });
      logger.info('Cross-origin DNR ruleset enabled.');
    } else {
      await chromeApi.declarativeNetRequest.updateEnabledRulesets({
        disableRulesetIds: [RULESET_ID],
      });
      logger.info('Cross-origin DNR ruleset disabled.');
    }
  }

  async function checkOnboarding(): Promise<boolean> {
    const local = await deps.getLocalSettings();

    if (!local.hasCompletedOnboarding) {
      logger.info('Opening onboarding page.');
      chromeApi.tabs.create({ url: chromeApi.runtime.getURL('onboarding.html') });
      return true;
    }

    return false;
  }

  async function checkBenchmarkCrash(): Promise<void> {
    const local = await chromeApi.storage.local.get(['_benchmarkInProgress', 'benchmarkRunState']);
    const currentLocalSettings = await deps.getLocalSettings();
    const benchmarkRunState = local.benchmarkRunState ?? currentLocalSettings.benchmarkRunState;

    if (local._benchmarkInProgress || benchmarkRunState?.status === 'running') {
      logger.warn('Previous benchmark did not finish. Falling back to performance tier.');

      await chromeApi.storage.local.set({
        performanceTier: 'performance',
        benchmarkRunState: {
          status: 'interrupted',
          failureReason: 'crash',
          fallbackTierApplied: 'performance',
          startedAt: benchmarkRunState?.startedAt,
          endedAt: Date.now(),
        },
      });
      await chromeApi.storage.local.remove('_benchmarkInProgress');
    }
  }

  const onStartup = async () => {
    logger.info('Browser startup.');

    await checkBenchmarkCrash();
    await updateDNRuleset();
  };

  const onInstalled = async (details: chrome.runtime.InstalledDetails) => {
    logger.info('Extension installed/updated:', details.reason);

    await deps.ensureLatestConfig();
    await checkBenchmarkCrash();
    await updateDNRuleset();

    if (details.reason === 'install' || details.reason === 'update') {
      await checkOnboarding();
    }
  };

  const onTabUpdated = (tabId: number, changeInfo: chrome.tabs.TabChangeInfo, tab: chrome.tabs.Tab) => {
    if (changeInfo.status === 'complete' && tab.url) {
      chromeApi.tabs.sendMessage(tabId, {
        type: 'URL_UPDATED',
        url: tab.url,
      }).catch(error => {
        if (!error.message.includes('Receiving end does not exist')) {
          logger.error(`Error sending URL_UPDATED message: ${error.message}`);
        }
      });
    }
  };

  const onMessage = (request: { type?: string }) => {
    if (request.type === 'SETTINGS_UPDATED') {
      logger.debug('Settings updated, checking DNR rules.');
      void updateDNRuleset();
    } else if (request.type === 'OPEN_OPTIONS_PAGE') {
      chromeApi.runtime.openOptionsPage();
    } else if (request.type === 'OPEN_ONBOARDING') {
      chromeApi.tabs.create({ url: chromeApi.runtime.getURL('onboarding.html') });
    }
  };

  function registerListeners(): void {
    if (listenersRegistered) {
      return;
    }

    listenersRegistered = true;
    chromeApi.runtime.onStartup.addListener(onStartup);
    chromeApi.runtime.onInstalled.addListener(onInstalled);
    chromeApi.tabs.onUpdated.addListener(onTabUpdated);
    chromeApi.runtime.onMessage.addListener(onMessage);
  }

  function dispose(): void {
    if (!listenersRegistered) {
      return;
    }

    listenersRegistered = false;
    chromeApi.runtime.onStartup.removeListener(onStartup);
    chromeApi.runtime.onInstalled.removeListener(onInstalled);
    chromeApi.tabs.onUpdated.removeListener(onTabUpdated);
    chromeApi.runtime.onMessage.removeListener(onMessage);
  }

  return {
    updateDNRuleset,
    checkOnboarding,
    checkBenchmarkCrash,
    registerListeners,
    dispose,
  };
}

let defaultBackgroundBootstrap: BackgroundBootstrap | null = null;

function getDefaultBackgroundBootstrap(): BackgroundBootstrap {
  defaultBackgroundBootstrap ??= createBackgroundBootstrap();
  return defaultBackgroundBootstrap;
}

/**
 * 根据当前设置更新 declarativeNetRequest 规则集。
 */
export async function updateDNRuleset(): Promise<void> {
  await getDefaultBackgroundBootstrap().updateDNRuleset();
}

/**
 * 检查是否需要打开引导页面
 */
export async function checkOnboarding(): Promise<boolean> {
  return getDefaultBackgroundBootstrap().checkOnboarding();
}

/**
 * 检查上次测试是否崩溃
 */
export async function checkBenchmarkCrash(): Promise<void> {
  await getDefaultBackgroundBootstrap().checkBenchmarkCrash();
}

export function registerBackgroundListeners(): void {
  getDefaultBackgroundBootstrap().registerListeners();
}

export function resetBackgroundBootstrapForTests(): void {
  defaultBackgroundBootstrap?.dispose();
  defaultBackgroundBootstrap = null;
}

if (!globalThis.__ANIME4K_DISABLE_AUTO_BOOTSTRAP__) {
  registerBackgroundListeners();
}
