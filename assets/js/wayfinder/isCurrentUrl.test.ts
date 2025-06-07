import { describe, it, expect } from 'vitest'
import { isCurrentUrl } from './isCurrentUrl'

describe('isCurrentUrl', () => {
  it('matches the URL even with /', () => {
    expect(
      isCurrentUrl({
        routePath: '/venues/1',
        currentPath: '/venues/1/',
      }),
    ).toBe(true)
  })

  it('matches exact', () => {
    expect(
      isCurrentUrl({
        routePath: '/',
        currentPath: '/venues/1',
        matchExact: true,
      }),
    ).toBe(false)
  })

  it('matches nested URLs with additional segments', () => {
    expect(
      isCurrentUrl({
        routePath: '/venues/1',
        currentPath: '/venues/1/events/2',
      }),
    ).toBe(true)
  })

  it('does not match unrelated URLs', () => {
    expect(
      isCurrentUrl({
        routePath: '/venues/1',
        currentPath: '/venues/2',
      }),
    ).toBe(false)
  })

  it('matches routes without params', () => {
    expect(
      isCurrentUrl({
        routePath: '/venues',
        currentPath: '/venues',
      }),
    ).toBe(true)
  })

  it('handles trailing slashes consistently', () => {
    expect(
      isCurrentUrl({
        routePath: '/venues/1',
        currentPath: '/venues/1/',
      }),
    ).toBe(true)

    expect(
      isCurrentUrl({
        routePath: '/venues/1',
        currentPath: '/venues/1////',
      }),
    ).toBe(true)
  })

  it('handles extra slashes inside path', () => {
    expect(
      isCurrentUrl({
        routePath: '/venues/1',
        currentPath: '/venues////1',
      }),
    ).toBe(true)
  })

  it('falls back to window.location.pathname if currentPath is not provided', () => {
    const originalWindow = global.window
    // @ts-ignore
    global.window = Object.create(window)
    Object.defineProperty(global.window, 'location', {
      value: { pathname: '/venues/1' },
      writable: true,
    })

    expect(
      isCurrentUrl({
        routePath: '/venues/1',
      }),
    ).toBe(true)

    global.window = originalWindow
  })

  it('returns false if no currentPath and no window object', () => {
    const originalWindow = global.window
    // @ts-ignore
    delete global.window

    expect(
      isCurrentUrl({
        routePath: '/venues/1',
      }),
    ).toBe(false)

    global.window = originalWindow
  })
})
