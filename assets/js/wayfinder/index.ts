import type { RouteQueryOptions } from './types'

function getValue(value: string | number | boolean): string {
  if (value === true) return '1'
  if (value === false) return '0'
  return value.toString()
}

const isBrowser = typeof window !== 'undefined'

function browserParams({ includeExisting }: { includeExisting: boolean }) {
  const search = isBrowser && includeExisting ? window.location.search : ''

  return new URLSearchParams(search)
}

export const queryParams = (options?: RouteQueryOptions): string => {
  if (!options || (!options.query && !options.mergeQuery)) {
    return ''
  }

  const query = options.query ?? options.mergeQuery
  const includeExisting = options.mergeQuery !== undefined
  const params = browserParams({ includeExisting })

  for (const key in query) {
    const rawValue = query[key]

    if (rawValue === undefined || rawValue === null) {
      params.delete(key)
      continue
    }

    if (Array.isArray(rawValue)) {
      if (params.has(`${key}[]`)) {
        params.delete(`${key}[]`)
      }

      rawValue.forEach((value) => {
        params.append(`${key}[]`, value.toString())
      })
    } else if (typeof rawValue === 'object') {
      // Delete previous subkeys
      params.forEach((_, paramKey) => {
        if (paramKey.startsWith(`${key}[`)) {
          params.delete(paramKey)
        }
      })

      for (const subKey in rawValue) {
        const subValue = rawValue[subKey]
        if (
          typeof subValue === 'string' ||
          typeof subValue === 'number' ||
          typeof subValue === 'boolean'
        ) {
          params.set(`${key}[${subKey}]`, getValue(subValue))
        }
      }
    } else {
      params.set(key, getValue(rawValue))
    }
  }

  const str = params.toString()
  return str.length > 0 ? `?${str}` : ''
}

export * from './types'
export * from './isCurrentUrl'
export * from './buildUrl'
