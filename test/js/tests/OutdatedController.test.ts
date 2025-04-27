import { expect, it } from 'vitest'
import { existsSync } from 'node:fs'

it('removes stale files', async () => {
  const path =
    '../../../workbench/assets/js/actions/OutdatedController/index.ts'
  const fileExists = existsSync(new URL(path, import.meta.url))
  expect(fileExists).toBe(false)
})
