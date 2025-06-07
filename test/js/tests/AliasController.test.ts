import { expect, it } from 'vitest'
import { myAlias } from '../../../workbench/assets/js/actions/AliasController'

it('use the alias defined in the Phoenix router', () => {
  expect(myAlias.url().path).toBe('/alias')
  expect(myAlias()).toEqual({
    url: '/alias',
    method: 'get',
  })
})
