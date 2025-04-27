import { expect, it, describe } from 'vitest'
import {
  same,
  same2,
} from '../../../workbench/assets/js/actions/TwoRoutesSameActionController'

describe('TwoRoutesSameActionController', () => {
  describe('same action (route 1)', () => {
    it('generates correct URL for first route', () => {
      expect(same.url()).toBe('/two-routes-one-action-1')
      expect(same()).toEqual({
        url: '/two-routes-one-action-1',
        method: 'get',
      })
    })

    it('has correct definition with RouteDefinition type', () => {
      expect(same.definition).toEqual({
        methods: ['get'],
        url: '/two-routes-one-action-1',
      })
    })

    it('supports GET method', () => {
      expect(same.get()).toEqual({
        url: '/two-routes-one-action-1',
        method: 'get',
      })
    })

    it('handles query parameters correctly', () => {
      const options = { query: { page: 1, limit: 10 } }
      expect(same.url(options)).toBe('/two-routes-one-action-1?page=1&limit=10')
      expect(same(options)).toEqual({
        url: '/two-routes-one-action-1?page=1&limit=10',
        method: 'get',
      })
    })
  })

  describe('same action (route 2)', () => {
    it('generates correct URL for second route', () => {
      expect(same2.url()).toBe('/two-routes-one-action-2')
      expect(same2()).toEqual({
        url: '/two-routes-one-action-2',
        method: 'get',
      })
    })

    it('has correct definition with RouteDefinition type', () => {
      expect(same2.definition).toEqual({
        methods: ['get'],
        url: '/two-routes-one-action-2',
      })
    })

    it('supports GET method', () => {
      expect(same2.get()).toEqual({
        url: '/two-routes-one-action-2',
        method: 'get',
      })
    })

    it('handles query parameters correctly', () => {
      const options = { query: { search: 'test' } }
      expect(same2.url(options)).toBe('/two-routes-one-action-2?search=test')
      expect(same2(options)).toEqual({
        url: '/two-routes-one-action-2?search=test',
        method: 'get',
      })
    })
  })

  describe('type safety', () => {
    it("main functions return RouteDefinition<'get'>", () => {
      const result1 = same()
      const result2 = same2()

      expect(result1.method).toBe('get')
      expect(result2.method).toBe('get')
      expect(typeof result1.url).toBe('string')
      expect(typeof result2.url).toBe('string')
    })

    it("get methods return RouteDefinition<'get'>", () => {
      const result1 = same.get()
      const result2 = same2.get()

      expect(result1.method).toBe('get')
      expect(result2.method).toBe('get')
    })

    it("definitions satisfy RouteDefinition<['get']>", () => {
      expect(Array.isArray(same.definition.methods)).toBe(true)
      expect(Array.isArray(same2.definition.methods)).toBe(true)
      expect(same.definition.methods).toContain('get')
      expect(same2.definition.methods).toContain('get')
    })
  })
})
