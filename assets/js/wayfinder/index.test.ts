import { vi, describe, it, expect, beforeEach, afterEach } from 'vitest'
import { queryParams } from './index'

function expectQuery(actual: string, expected: string) {
  expect(decodeURIComponent(actual)).toBe(expected)
}

describe('queryParams', () => {
  const ROOT_URL = 'http://localhost:3000'

  describe('browser', () => {
    beforeEach(() => {
      const url = new URL(`${ROOT_URL}?existing=1&foo[]=a`)
      window.history.replaceState({}, '', url)
    })

    afterEach(() => {
      window.history.replaceState({}, '', ROOT_URL)
    })

    it('returns empty string when no options provided', () => {
      expectQuery(queryParams(), '')
    })

    it('returns empty string when query and mergeQuery are undefined', () => {
      expectQuery(queryParams({}), '')
    })

    it('sets simple string, number, boolean values', () => {
      const result = queryParams({
        query: {
          name: 'john',
          age: 30,
          subscribed: true,
          unsubscribed: false,
        },
      })

      expectQuery(result, '?name=john&age=30&subscribed=1&unsubscribed=0')
    })

    it('removes keys with null or undefined', () => {
      const result = queryParams({
        mergeQuery: {
          existing: null,
          unknown: undefined,
        },
      })

      expectQuery(result, '?foo[]=a')
    })

    it('handles array values', () => {
      const result = queryParams({
        query: {
          tags: ['a', 'b', 'c'],
        },
      })

      expectQuery(result, '?tags[]=a&tags[]=b&tags[]=c')
    })

    it('merges with existing URL params', () => {
      const result = queryParams({
        mergeQuery: {
          foo: ['x', 'y'],
          bar: 'z',
        },
      })

      expectQuery(result, '?existing=1&foo[]=x&foo[]=y&bar=z')
    })

    it('handles nested object params', () => {
      const result = queryParams({
        query: {
          user: {
            name: 'alice',
            age: 25,
            active: true,
          },
        },
      })

      expectQuery(result, '?user[name]=alice&user[age]=25&user[active]=1')
    })

    it('overwrites existing nested keys on merge', () => {
      const result = queryParams({
        mergeQuery: {
          nested: {
            key: 'new',
          },
        },
      })

      expectQuery(result, '?existing=1&foo[]=a&nested[key]=new')
    })

    it('deletes previous nested keys before adding new ones', () => {
      const result = queryParams({
        mergeQuery: {
          nested: {
            one: '1',
            two: '2',
          },
        },
      })

      expectQuery(result, '?existing=1&foo[]=a&nested[one]=1&nested[two]=2')
    })
  })

  describe('SSR', () => {
    const originalWindow = global.window

    beforeEach(() => {
      // Simulate SSR by removing `window`
      // @ts-expect-error: we are intentionally deleting window
      delete global.window

      vi.resetModules()
    })

    afterEach(() => {
      global.window = originalWindow
    })

    it('works without window (SSR)', async () => {
      const mod = await import('./index')
      const queryParams = mod.queryParams

      const result = queryParams({
        query: {
          foo: 'bar',
          count: 5,
          enabled: true,
        },
      })

      expectQuery(result, '?foo=bar&count=5&enabled=1')
    })

    it('ignores merging with existing params in SSR', async () => {
      const mod = await import('./index')
      const queryParams = mod.queryParams

      const result = queryParams({
        mergeQuery: {
          foo: 'baz',
        },
      })

      expectQuery(result, '?foo=baz')
    })

    it('returns empty string if nothing is passed', async () => {
      const mod = await import('./index')
      const queryParams = mod.queryParams

      const result = queryParams({})
      expectQuery(result, '')
    })
  })
})
