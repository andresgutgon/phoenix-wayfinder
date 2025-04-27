import { expect, it } from 'vitest'
import { home } from '../../../workbench/assets/js/actions/PageController'

it('renders home url', () => {
  expect(home.url()).toBe('/')
  expect(home()).toEqual({
    url: '/',
    method: 'get',
  })
})
