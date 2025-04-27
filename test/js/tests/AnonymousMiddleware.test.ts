import { expect, test } from 'vitest'
import { show } from '../../support/workbench/assets/js/actions//AnonymousMiddlewareController'

test('will allow for closure middleware', () => {
  expect(show.url()).toBe('/anonymous-middleware')
})
