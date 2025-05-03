import { expect, it } from 'vitest'
import { camel } from '@actions/ParameterNameController/index'

it("doesn't add a / to an empty route", () => {
  expect(camel.url({ camel_case: 'ACamel' })).toBe('/')
})
