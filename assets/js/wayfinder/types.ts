export type Method =
  | 'get'
  | 'post'
  | 'put'
  | 'delete'
  | 'patch'
  | 'head'
  | 'options'

export type ParamConfig = {
  name: string
  required: boolean
  optional: boolean
  glob: boolean
}

export type RouteDefinition<TMethod extends Method | Method[]> = {
  url: string
} & (TMethod extends Method[] ? { methods: TMethod } : { method: TMethod })

export type ParametersDefinition = Record<string, ParamConfig>
export type RouteDefinitionWithParameters<TMethod extends Method | Method[]> =
  RouteDefinition<TMethod> & {
    parameters: ParametersDefinition
  }

export type RouteQueryOptions = {
  query?: QueryParams
  mergeQuery?: QueryParams
  currentPath?: string
  exactMatch?: boolean
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
