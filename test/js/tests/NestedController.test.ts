import { expect, it } from 'vitest'
import { nested } from '../../../workbench/assets/js/actions/Nested/NestedController'

it('generates a nested controller', () => {
  expect(nested.url()).toBe('/nested/controller')
  expect(nested().url).toBe('/nested/controller')
})
