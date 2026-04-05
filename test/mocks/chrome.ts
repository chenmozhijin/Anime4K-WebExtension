type Listener<TArgs extends any[] = any[]> = (...args: TArgs) => any;

class MockChromeEvent<TArgs extends any[] = any[]> {
  private listeners = new Set<Listener<TArgs>>();

  addListener(listener: Listener<TArgs>): void {
    this.listeners.add(listener);
  }

  removeListener(listener: Listener<TArgs>): void {
    this.listeners.delete(listener);
  }

  hasListener(listener: Listener<TArgs>): boolean {
    return this.listeners.has(listener);
  }

  listenerCount(): number {
    return this.listeners.size;
  }

  async trigger(...args: TArgs): Promise<any[]> {
    const results: any[] = [];
    for (const listener of this.listeners) {
      results.push(await listener(...args));
    }
    return results;
  }
}

type StorageAreaName = 'sync' | 'local';
type StorageState = Record<string, any>;

function pickKeys(source: StorageState, keys?: string[] | string | Record<string, any> | null): StorageState {
  if (keys === undefined || keys === null) {
    return { ...source };
  }

  if (Array.isArray(keys)) {
    return Object.fromEntries(keys.map(key => [key, source[key]]));
  }

  if (typeof keys === 'string') {
    return { [keys]: source[keys] };
  }

  return Object.fromEntries(
    Object.entries(keys).map(([key, fallback]) => [key, key in source ? source[key] : fallback]),
  );
}

function buildStorageArea(
  areaName: StorageAreaName,
  state: StorageState,
  onChanged: MockChromeEvent<[Record<string, chrome.storage.StorageChange>, StorageAreaName]>,
) {
  return {
    async get(keys?: string[] | string | Record<string, any> | null, callback?: (items: StorageState) => void): Promise<StorageState> {
      const result = pickKeys(state, keys);
      callback?.(result);
      return result;
    },
    async set(items: StorageState, callback?: () => void): Promise<void> {
      const changes: Record<string, chrome.storage.StorageChange> = {};
      Object.entries(items).forEach(([key, value]) => {
        changes[key] = {
          oldValue: state[key],
          newValue: value,
        };
        state[key] = value;
      });
      callback?.();
      await onChanged.trigger(changes, areaName);
    },
    async remove(keys: string[] | string, callback?: () => void): Promise<void> {
      const keyList = Array.isArray(keys) ? keys : [keys];
      const changes: Record<string, chrome.storage.StorageChange> = {};
      keyList.forEach(key => {
        changes[key] = {
          oldValue: state[key],
          newValue: undefined,
        };
        delete state[key];
      });
      callback?.();
      await onChanged.trigger(changes, areaName);
    },
    async clear(callback?: () => void): Promise<void> {
      const changes: Record<string, chrome.storage.StorageChange> = {};
      Object.keys(state).forEach(key => {
        changes[key] = {
          oldValue: state[key],
          newValue: undefined,
        };
        delete state[key];
      });
      callback?.();
      await onChanged.trigger(changes, areaName);
    },
  };
}

export interface ChromeMockOptions {
  sync?: StorageState;
  local?: StorageState;
  activeTab?: chrome.tabs.Tab;
  manifestVersion?: string;
}

export function createChromeMock(options: ChromeMockOptions = {}) {
  const syncState: StorageState = { ...(options.sync ?? {}) };
  const localState: StorageState = { ...(options.local ?? {}) };
  const storageOnChanged = new MockChromeEvent<[Record<string, chrome.storage.StorageChange>, StorageAreaName]>();
  const runtimeOnMessage = new MockChromeEvent<[any, chrome.runtime.MessageSender, (response?: any) => void]>();
  const runtimeOnInstalled = new MockChromeEvent<[chrome.runtime.InstalledDetails]>();
  const runtimeOnStartup = new MockChromeEvent<[]>();
  const tabsOnUpdated = new MockChromeEvent<[number, chrome.tabs.TabChangeInfo, chrome.tabs.Tab]>();
  const tabsCreated: chrome.tabs.CreateProperties[] = [];
  const runtimeMessages: any[] = [];
  const sentTabMessages: Array<{ tabId: number; message: any }> = [];
  const dnrUpdates: chrome.declarativeNetRequest.UpdateRulesetOptions[] = [];
  const openOptionsPageCalls: Array<{ openedAt: number }> = [];
  const tabSendMessageErrors: Error[] = [];
  const activeTab = (options.activeTab ?? {
    id: 1,
    active: true,
    url: 'https://example.com/watch',
  }) as chrome.tabs.Tab;

  const chromeMock = {
    runtime: {
      lastError: null as chrome.runtime.LastError | null,
      onMessage: runtimeOnMessage,
      onInstalled: runtimeOnInstalled,
      onStartup: runtimeOnStartup,
      getURL: (path: string) => `chrome-extension://test-extension/${path}`,
      getManifest: () => ({ version: options.manifestVersion ?? '0.4.0' }),
      openOptionsPage: async () => {
        openOptionsPageCalls.push({ openedAt: Date.now() });
      },
      async sendMessage(message: any): Promise<any> {
        runtimeMessages.push(message);
        let responsePayload: any;
        let responseResolved = false;
        let resolveAsyncResponse!: (value: any) => void;
        const asyncResponse = new Promise(resolve => {
          resolveAsyncResponse = resolve;
        });
        const returnValues = await runtimeOnMessage.trigger(
          message,
          {} as chrome.runtime.MessageSender,
          (response?: any) => {
            responsePayload = response;
            responseResolved = true;
            resolveAsyncResponse(response);
          },
        );
        if (responseResolved) {
          return responsePayload;
        }
        if (returnValues.some(value => value === true)) {
          return asyncResponse;
        }
        return responsePayload;
      },
    },
    tabs: {
      onUpdated: tabsOnUpdated,
      async create(createProperties: chrome.tabs.CreateProperties): Promise<chrome.tabs.Tab> {
        tabsCreated.push(createProperties);
        return {
          id: tabsCreated.length,
          url: createProperties.url,
          active: true,
        } as chrome.tabs.Tab;
      },
      async query(): Promise<chrome.tabs.Tab[]> {
        return [activeTab];
      },
      async sendMessage(tabId: number, message: any): Promise<any> {
        sentTabMessages.push({ tabId, message });
        const nextError = tabSendMessageErrors.shift();
        if (nextError) {
          throw nextError;
        }
        return undefined;
      },
    },
    storage: {
      onChanged: storageOnChanged,
      sync: buildStorageArea('sync', syncState, storageOnChanged),
      local: buildStorageArea('local', localState, storageOnChanged),
    },
    declarativeNetRequest: {
      async updateEnabledRulesets(update: chrome.declarativeNetRequest.UpdateRulesetOptions): Promise<void> {
        dnrUpdates.push(update);
      },
    },
    i18n: {
      getMessage: (key: string) => key,
    },
    __mock: {
      syncState,
      localState,
      tabsCreated,
      runtimeMessages,
      sentTabMessages,
      dnrUpdates,
      openOptionsPageCalls,
      queueTabSendMessageError: (error: string | Error) => {
        tabSendMessageErrors.push(error instanceof Error ? error : new Error(error));
      },
      runtimeOnInstalled,
      runtimeOnStartup,
      runtimeOnMessage,
      tabsOnUpdated,
    },
  };

  return chromeMock as unknown as typeof chrome & { __mock: typeof chromeMock.__mock };
}

export function installChromeMock(options: ChromeMockOptions = {}) {
  const chromeMock = createChromeMock(options);
  (globalThis as typeof globalThis & { chrome: typeof chromeMock }).chrome = chromeMock;
  return chromeMock;
}
