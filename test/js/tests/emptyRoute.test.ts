import { expect, it } from 'vitest'
import { home } from '@wayfinder/routes'

it("doesn't add a / to an empty route", () => {
  expect(home.url()).toBe('/')
  expect(home()).toEqual({
    url: '/',
    method: 'get',
  })
})
