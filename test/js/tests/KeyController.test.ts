import { expect, it, test } from 'vitest'
import { edit } from '../../support/workbench/assets/js/actions//KeyController'

it('can pass primitive values to routes with custom keys', () => {
  expect(edit.url({ key: '547a7452-9dc5-4f64-a275-d646dea6ebcf' })).toBe(
    '/keys/547a7452-9dc5-4f64-a275-d646dea6ebcf/edit',
  )
})

test('definition', () => {
  expect(Object.keys(edit.definition)).toEqual(['methods', 'url'])
  expect(edit.definition.methods).toEqual(['get', 'head'])
  expect(edit.definition.url).toBe('/keys/:key/edit')
})
