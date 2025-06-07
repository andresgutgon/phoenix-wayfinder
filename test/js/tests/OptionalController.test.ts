import { describe, expect, it } from 'vitest'
import {
  manyOptional,
  optional,
} from '../../../workbench/assets/js/actions/OptionalController'

describe('optional', async () => {
  it('url', () => {
    expect(optional.url()).toBe('/optional')
    expect(optional.url({ parameter: 'xxxx' })).toBe('/optional/xxxx')
  })

  it('definition', () => {
    expect(optional.definition.url).toBe('/optional/:parameter')
  })
})

describe('manyOptional', async () => {
  it('url', () => {
    expect(manyOptional.url()).toBe('/many-optional')
    expect(manyOptional.url({ one: '1' })).toBe('/many-optional/1')
    expect(manyOptional.url({ one: '1', two: '2' })).toBe('/many-optional/1/2')
    expect(manyOptional.url({ one: '1', two: '2', three: '3' })).toBe(
      '/many-optional/1/2/3',
    )
  })

  it('throws an error when passing optional parameters with missing optional parameters before', () => {
    expect(() => manyOptional.url({ two: '2' })).toThrow()
    expect(() => manyOptional.url({ three: '3' })).toThrow()
    expect(() => manyOptional.url({ two: '2', three: '3' })).toThrow()
  })

  it('definition', () => {
    expect(manyOptional.definition.url).toBe(
      '/many-optional/:one/:two/:three',
    )
  })
})
