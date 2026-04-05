import { defineConfig } from 'vitest/config';

export default defineConfig({
  resolve: {
    preserveSymlinks: true,
  },
  plugins: [{
    name: 'wgsl-as-string',
    enforce: 'pre',
    transform(source, id) {
      if (id.endsWith('.wgsl')) {
        return {
          code: `export default ${JSON.stringify(source)};`,
          map: null,
        };
      }

      return null;
    },
  }],
  test: {
    clearMocks: true,
    restoreMocks: true,
    mockReset: true,
    fileParallelism: false,
    maxWorkers: 1,
    minWorkers: 1,
    exclude: ['test/e2e/**', 'dist-*/**', 'node_modules/**'],
    projects: [
      {
        extends: true,
        test: {
          name: 'unit-node',
          include: ['test/unit/**/*.test.ts'],
          environment: 'node',
          setupFiles: ['test/support/setup/unit-node.ts'],
        },
      },
      {
        extends: true,
        test: {
          name: 'dom',
          include: ['test/dom/**/*.test.ts'],
          environment: 'jsdom',
          setupFiles: ['test/support/setup/dom.ts'],
        },
      },
      {
        extends: true,
        test: {
          name: 'integration',
          include: ['test/integration/**/*.test.ts'],
          environment: 'jsdom',
          setupFiles: ['test/support/setup/integration.ts'],
        },
      },
    ],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'html', 'lcov'],
      reportsDirectory: 'coverage',
      all: true,
      include: ['src/**/*.ts'],
      exclude: [
        '**/*.d.ts',
        'src/**/*.test.ts',
        'src/engines/anime4k/vendor/**',
        'src/**/*.wgsl',
        'test/**',
        'dist-*/**',
      ],
      thresholds: {
        lines: 70,
        statements: 70,
        functions: 70,
        branches: 55,
      },
    },
  },
});
