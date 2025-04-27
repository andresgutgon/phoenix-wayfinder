import { expect, it } from 'vitest'
import { show } from '../../../workbench/assets/js/actions/GlobController'

it('handle glob-like paths', () => {
  expect(show.url({ page: 'llo', rest: ['there', 'world'] })).toBe(
    '/pages/hello/there/world',
  )
  expect(show({ page: 'llo', rest: ['there', 'world'] }).url).toBe(
    '/pages/hello/there/world',
  )
})
