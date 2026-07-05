import { describe, expect, it, vi } from 'vitest';
import { installChromeMock } from '../support/chrome';

describe('chrome mock failure injection', () => {
  it('injects callback-style storage failures without mutating state', async () => {
    const chromeMock = installChromeMock();
    const failure = new Error('sync failed');
    const callback = vi.fn(() => {
      expect(chrome.runtime.lastError).toBe(failure);
    });

    chromeMock.__mock.queueStorageSetError('sync', failure);
    await chrome.storage.sync.set({ selectedModeId: 'builtin-mode-b' }, callback);

    expect(callback).toHaveBeenCalledTimes(1);
    expect(chrome.runtime.lastError).toBeUndefined();
    expect(chromeMock.__mock.syncState.selectedModeId).toBeUndefined();
  });

  it('injects promise-style storage and runtime message failures', async () => {
    const chromeMock = installChromeMock();
    const storageFailure = new Error('local failed');
    const runtimeFailure = new Error('runtime failed');

    chromeMock.__mock.queueStorageError('local', 'set', storageFailure);
    await expect(chrome.storage.local.set({ performanceTier: 'quality' })).rejects.toBe(storageFailure);
    expect(chromeMock.__mock.localState.performanceTier).toBeUndefined();

    chromeMock.__mock.queueRuntimeSendMessageError(runtimeFailure);
    await expect(chrome.runtime.sendMessage({ type: 'SETTINGS_UPDATED' })).rejects.toBe(runtimeFailure);
    expect(chromeMock.__mock.runtimeMessages).toEqual([]);
  });
});
