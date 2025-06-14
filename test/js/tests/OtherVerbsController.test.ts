import { describe, expect, it } from 'vitest'
import {
  headAction,
  optionsAction,
  matchAction,
  matchWithParams,
} from '../../../workbench/assets/js/actions/OtherVerbsController'

describe('headAction', () => {
  it('url', () => {
    expect(headAction.url().path).toBe('/other-verbs/head')
  })

  it('definition', () => {
    expect(headAction.definition).toEqual({
      url: '/other-verbs/head',
      parameters: {},
      methods: ['head'],
    })
  })
})

describe('optionsAction', () => {
  it('url', () => {
    expect(optionsAction.url().path).toBe('/other-verbs/options')
  })

  it('definition', () => {
    expect(optionsAction.definition).toEqual({
      url: '/other-verbs/options',
      parameters: {},
      methods: ['options'],
    })
  })
})

describe('matchAction', () => {
  it('url', () => {
    expect(matchAction.url().path).toBe('/other-verbs/match')
  })

  it('definition', () => {
    expect(matchAction.definition).toEqual({
      url: '/other-verbs/match',
      parameters: {},
      methods: ['get', 'patch', 'post', 'put'],
    })
  })
})

describe('matchWithParams', () => {
  it('url', () => {
    expect(matchWithParams.url({ id: '123' }).path).toBe(
      '/other-verbs/match/123',
    )
    expect(matchWithParams.url('456').path).toBe('/other-verbs/match/456')
  })

  it('definition', () => {
    expect(matchWithParams.definition).toEqual({
      url: '/other-verbs/match/:id',
      parameters: {
        id: { name: 'id', required: true, optional: false, glob: false },
      },
      methods: ['get', 'post'],
    })
  })

  it('parameter handling', () => {
    expect(matchWithParams.url({ id: 'it-id' }).path).toBe(
      '/other-verbs/match/it-id',
    )

    expect(matchWithParams.url('another-id').path).toBe(
      '/other-verbs/match/another-id',
    )

    expect(matchWithParams.url(789).path).toBe('/other-verbs/match/789')
  })

  it('can use post method with a number', () => {
    expect(matchWithParams.post(20).url).toBe('/other-verbs/match/20')
  })

  it('can use post method with a string', () => {
    expect(matchWithParams.post('20').url).toBe('/other-verbs/match/20')
  })

  it('can use post method with a string array', () => {
    expect(matchWithParams.post(['20']).url).toBe('/other-verbs/match/20')
  })

  it('can use post method with an object string ', () => {
    expect(matchWithParams.post({ id: '20' }).url).toBe('/other-verbs/match/20')
  })

  it('can use post method with an object number ', () => {
    expect(matchWithParams.post({ id: 20 }).url).toBe('/other-verbs/match/20')
  })
})
