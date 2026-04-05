import { createBackgroundBootstrap, type BackgroundBootstrapDeps } from '../../src/background';
import { createContentBootstrap, type ContentBootstrapDeps } from '../../src/content';
import { installChromeMock, type ChromeMockOptions } from './chrome';

export function createBackgroundHarness(
  overrides: Partial<BackgroundBootstrapDeps> = {},
  chromeOptions: ChromeMockOptions = {},
) {
  const chromeMock = installChromeMock(chromeOptions);
  const bootstrap = createBackgroundBootstrap({
    chromeApi: chromeMock,
    ...overrides,
  });

  return {
    chromeMock,
    bootstrap,
  };
}

export function createContentHarness(
  overrides: Partial<ContentBootstrapDeps> = {},
  chromeOptions: ChromeMockOptions = {},
) {
  const chromeMock = installChromeMock(chromeOptions);
  const bootstrap = createContentBootstrap({
    chromeApi: chromeMock,
    ...overrides,
  });

  return {
    chromeMock,
    bootstrap,
  };
}
