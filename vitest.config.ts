import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    include: ['test/js/tests/*.test.ts'],
    environment: 'happy-dom',
    globalSetup: 'test/js/support/build.ts',
  },
  resolve: {
    alias: {
      '@wayfinder/': './test/support/workbench/assets/js/wayfinder/',
    },
  },
})
