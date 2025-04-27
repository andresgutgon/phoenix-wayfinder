import { expect, it } from 'vitest'
import { existsSync } from 'node:fs'

it('does not generates this module', async () => {
  const path = '../../../workbench/assets/js/actions/IgnoreMeController/index.ts'
  const fileExists = existsSync(new URL(path, import.meta.url))
  expect(fileExists).toBe(false)
})
