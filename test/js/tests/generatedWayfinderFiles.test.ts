import { describe, it, expect } from 'vitest'
import { join } from 'path'
import { readdir } from 'fs/promises'

describe('wayfinder files', () => {
  it('copies only non-*.test.ts files', async () => {
    const wayfinderPath = join(process.cwd(), 'workbench/assets/js/wayfinder')
    const copied = await readdir(wayfinderPath)
    expect(copied.some((f) => f.endsWith('.test.ts'))).toBe(false)
  })
})
