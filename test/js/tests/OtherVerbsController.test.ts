import { describe, expect, it } from 'vitest'
import {
  headAction,
  optionsAction,
  matchAction,
  matchWithParams,
} from '../../../workbench/assets/js/actions/OtherVerbsController'

describe('headAction', () => {
  it('url', () => {
    expect(headAction.url()).toBe('/other-verbs/head')
  })

  it('definition', () => {
    expect(headAction.definition).toEqual({
      url: '/other-verbs/head',
      methods: ['head'],
    })
  })
})

describe('optionsAction', () => {
  it('url', () => {
    expect(optionsAction.url()).toBe('/other-verbs/options')
  })

  it('definition', () => {
    expect(optionsAction.definition).toEqual({
      url: '/other-verbs/options',
      methods: ['options'],
    })
  })
})

describe('matchAction', () => {
  it('url', () => {
    expect(matchAction.url()).toBe('/other-verbs/match')
  })

  it('definition', () => {
    expect(matchAction.definition).toEqual({
      url: '/other-verbs/match',
      methods: ['get', 'patch', 'post', 'put'],
    })
  })
})

describe('matchWithParams', () => {
  it('url', () => {
    expect(matchWithParams.url({ id: '123' })).toBe('/other-verbs/match/123')
    expect(matchWithParams.url('456')).toBe('/other-verbs/match/456')
  })

  it('definition', () => {
    expect(matchWithParams.definition).toEqual({
      url: '/other-verbs/match/:id',
      methods: ['get', 'post'],
    })
  })

  it('parameter handling', () => {
    expect(matchWithParams.url({ id: 'it-id' })).toBe(
      '/other-verbs/match/it-id',
    )

    expect(matchWithParams.url('another-id')).toBe(
      '/other-verbs/match/another-id',
    )

    expect(matchWithParams.url(789)).toBe('/other-verbs/match/789')
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
    expect(matchWithParams.post({ id: '20' }).url).toBe(
      '/other-verbs/match/20',
    )
  })

  it('can use post method with an object number ', () => {
    expect(matchWithParams.post({ id: 20 }).url).toBe(
      '/other-verbs/match/20',
    )
  })
})
