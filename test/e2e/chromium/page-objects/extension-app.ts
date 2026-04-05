import type { BrowserContext, Page } from '@playwright/test';
import { expect } from '@playwright/test';

type StoragePayload = {
  sync?: Record<string, unknown>;
  local?: Record<string, unknown>;
};

export type WebGpuProbeResult = {
  available: boolean;
  isSoftwareAdapter: boolean;
  summary: string;
};

async function setStoragePayload(page: Page, payload: StoragePayload): Promise<void> {
  await page.evaluate(async ({ sync, local }) => {
    const wrap = (
      area: chrome.storage.StorageArea,
      method: 'set',
      value: Record<string, unknown>,
    ) => new Promise<void>((resolve, reject) => {
      area[method](value, () => {
        if (chrome.runtime.lastError) {
          reject(new Error(chrome.runtime.lastError.message));
          return;
        }
        resolve();
      });
    });

    if (sync && Object.keys(sync).length > 0) {
      await wrap(chrome.storage.sync, 'set', sync);
    }

    if (local && Object.keys(local).length > 0) {
      await wrap(chrome.storage.local, 'set', local);
    }
  }, payload);
}

async function clearStorage(page: Page): Promise<void> {
  await page.evaluate(async () => {
    const clearArea = (area: chrome.storage.StorageArea) => new Promise<void>((resolve, reject) => {
      area.clear(() => {
        if (chrome.runtime.lastError) {
          reject(new Error(chrome.runtime.lastError.message));
          return;
        }
        resolve();
      });
    });

    await clearArea(chrome.storage.sync);
    await clearArea(chrome.storage.local);
  });
}

async function probeWebGpu(page: Page): Promise<WebGpuProbeResult> {
  return page.evaluate(async () => {
    if (!navigator.gpu) {
      return {
        available: false,
        isSoftwareAdapter: false,
        summary: 'navigator.gpu unavailable',
      };
    }

    const adapter = await navigator.gpu.requestAdapter();
    if (!adapter) {
      return {
        available: false,
        isSoftwareAdapter: false,
        summary: 'no WebGPU adapter returned',
      };
    }

    let summary = 'adapter info unavailable';
    const adapterWithInfo = adapter as GPUAdapter & {
      requestAdapterInfo?: () => Promise<{
        vendor?: string;
        architecture?: string;
        device?: string;
        description?: string;
      }>;
    };

    if (typeof adapterWithInfo.requestAdapterInfo === 'function') {
      try {
        const info = await adapterWithInfo.requestAdapterInfo();
        const parts = [
          info.vendor,
          info.architecture,
          info.device,
          info.description,
        ].filter(Boolean);
        if (parts.length > 0) {
          summary = parts.join(' | ');
        }
      } catch {
        summary = 'adapter info request failed';
      }
    }

    const normalizedSummary = summary.toLowerCase();
    const isSoftwareAdapter = [
      'swiftshader',
      'software',
      'llvmpipe',
      'lavapipe',
      'microsoft basic render',
    ].some(marker => normalizedSummary.includes(marker));

    return {
      available: true,
      isSoftwareAdapter,
      summary,
    };
  });
}

export class PopupPage {
  constructor(readonly page: Page, private readonly extensionId: string) {}

  async goto(): Promise<void> {
    await this.page.goto(`chrome-extension://${this.extensionId}/popup.html`);
  }

  async expectLoaded(): Promise<void> {
    await expect(this.page.locator('#mode-select')).toBeVisible();
  }

  async selectMode(modeId: string): Promise<void> {
    await this.page.locator('#mode-select').selectOption(modeId);
  }
}

export class OptionsPage {
  constructor(readonly page: Page, private readonly extensionId: string) {}

  async goto(): Promise<void> {
    await this.page.goto(`chrome-extension://${this.extensionId}/options.html`);
  }

  async expectLoaded(): Promise<void> {
    await expect(this.page.locator('#general-section')).toBeVisible();
  }

  async openSection(section: 'modes' | 'whitelist'): Promise<void> {
    await this.page.locator(`.menu-item[data-section="${section}"]`).click();
  }

  async addMode(): Promise<void> {
    await this.page.locator('#add-mode-btn').click();
  }
}

export class OnboardingPage {
  constructor(readonly page: Page, private readonly extensionId: string) {}

  async goto(): Promise<void> {
    await this.page.goto(`chrome-extension://${this.extensionId}/onboarding.html`);
  }

  async expectLoaded(): Promise<void> {
    await expect(this.page.locator('#start-test')).toBeVisible();
  }

  async probeWebGpu(): Promise<WebGpuProbeResult> {
    return probeWebGpu(this.page);
  }
}

export class ExtensionApp {
  constructor(
    private readonly context: BrowserContext,
    readonly extensionId: string,
  ) {}

  async openPopup(): Promise<PopupPage> {
    const page = await this.context.newPage();
    const popup = new PopupPage(page, this.extensionId);
    await popup.goto();
    return popup;
  }

  async openOptions(): Promise<OptionsPage> {
    const page = await this.context.newPage();
    const options = new OptionsPage(page, this.extensionId);
    await options.goto();
    return options;
  }

  async openOnboarding(): Promise<OnboardingPage> {
    const page = await this.context.newPage();
    const onboarding = new OnboardingPage(page, this.extensionId);
    await onboarding.goto();
    return onboarding;
  }

  async probeWebGpu(): Promise<WebGpuProbeResult> {
    const onboarding = await this.openOnboarding();
    try {
      return await onboarding.probeWebGpu();
    } finally {
      await onboarding.page.close();
    }
  }

  private async withStoragePage<T>(callback: (page: Page) => Promise<T>): Promise<T> {
    const options = await this.openOptions();
    try {
      return await callback(options.page);
    } finally {
      await options.page.close();
    }
  }

  async resetStorage(): Promise<void> {
    await this.withStoragePage(async page => {
      await clearStorage(page);
      await setStoragePayload(page, {
        local: {
          hasCompletedOnboarding: true,
          performanceTier: 'balanced',
          benchmarkRunState: {
            status: 'idle',
            fallbackTierApplied: null,
          },
        },
      });
    });
  }

  async setStorage(payload: StoragePayload): Promise<void> {
    await this.withStoragePage(async page => {
      await setStoragePayload(page, payload);
    });
  }
}
