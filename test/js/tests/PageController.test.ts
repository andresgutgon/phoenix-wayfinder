import { expect, it } from 'vitest'
import { home } from '../../../workbench/assets/js/actions/PageController'

it('renders home url', () => {
  expect(home.url().path).toBe('/')
  expect(home()).toEqual({
    url: '/',
    method: 'get',
  })
})

it('match exact url', () => {
  expect(
    home.url({
      currentPath: '/events',
      matchExact: true,
    }).isCurrent,
  ).toBe(false)
})
