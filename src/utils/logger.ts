type LogLevel = 'debug' | 'info' | 'warn' | 'error';

const LEVEL_ORDER: Record<LogLevel, number> = {
  debug: 10,
  info: 20,
  warn: 30,
  error: 40,
};

function resolveMinLevel(): LogLevel {
  const runtimeFlag = (globalThis as typeof globalThis & {
    __NIJILUCID_LOG_LEVEL__?: LogLevel;
  }).__NIJILUCID_LOG_LEVEL__;

  return runtimeFlag ?? 'warn';
}

function shouldLog(level: LogLevel): boolean {
  return LEVEL_ORDER[level] >= LEVEL_ORDER[resolveMinLevel()];
}

export function createLogger(namespace: string) {
  const prefix = `[NijiLucid:${namespace}]`;

  return {
    debug: (...args: unknown[]) => {
      if (shouldLog('debug')) {
        console.debug(prefix, ...args);
      }
    },
    info: (...args: unknown[]) => {
      if (shouldLog('info')) {
        console.info(prefix, ...args);
      }
    },
    warn: (...args: unknown[]) => {
      if (shouldLog('warn')) {
        console.warn(prefix, ...args);
      }
    },
    error: (...args: unknown[]) => {
      if (shouldLog('error')) {
        console.error(prefix, ...args);
      }
    },
  };
}
