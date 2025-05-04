import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    include: ['assets/js/**/*.test.ts', 'test/js/tests/*.test.ts'],
    environment: 'happy-dom',
    globalSetup: 'test/js/support/build.ts',
  },
})
