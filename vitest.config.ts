import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    include: ['test/js/tests/*.test.ts'],
    environment: 'happy-dom',
    globalSetup: 'test/js/support/build.ts',
  },
  resolve: {
    alias: {
      '@routes/': './test/support/workbench/assets/js/routes/',
      '@actions/': './test/support/workbench/assets/js/actions/',
    },
  },
})
