export type Method = 'get' | 'post' | 'put' | 'delete' | 'patch' | 'head'

export type RouteDefinition<TMethod extends Method | Method[]> = {
  url: string
} & (TMethod extends Method[] ? { methods: TMethod } : { method: TMethod })

export type RouteQueryOptions = {
  query?: QueryParams
  mergeQuery?: QueryParams
  currentPath?: string
  matchExact?: boolean
}

export type QueryParams = Record<
  string,
  | string
  | number
  | boolean
  | string[]
  | null
  | undefined
  | Record<string, string | number | boolean>
>

export type WayfinderUrl = { path: string; isCurrent: boolean }
