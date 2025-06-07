import { queryParams, type RouteQueryOptions, type RouteDefinition } from './../../wayfinder'

/**
 * @see WorkbenchWeb.OtherVerbsController::head_action
 * @route /other-verbs/head
*/

export const headAction = (options?: RouteQueryOptions): RouteDefinition<'head'> => ({
  url: headAction.url(options),
  method: 'head',
})

headAction.definition = {
  methods: ["head"],
  url: '/other-verbs/head'
} satisfies RouteDefinition<['head']>
headAction.url = (options?: RouteQueryOptions): string => {
  
  const baseUrl = headAction.definition.url
  const cleanUrl = baseUrl.replace(/\/+$/, '') || '/'
  return cleanUrl + queryParams(options)
}
headAction.head = (options?: RouteQueryOptions): RouteDefinition<'head'> => ({
  url: headAction.url(options),
  method: 'head',
})

/**
 * @see WorkbenchWeb.OtherVerbsController::match_action
 * @route /other-verbs/match
*/

export const matchAction = (options?: RouteQueryOptions): RouteDefinition<'get'> => ({
  url: matchAction.url(options),
  method: 'get',
})

matchAction.definition = {
  methods: ["get", "patch", "post", "put"],
  url: '/other-verbs/match'
} satisfies RouteDefinition<['get', 'patch', 'post', 'put']>
matchAction.url = (options?: RouteQueryOptions): string => {
  
  const baseUrl = matchAction.definition.url
  const cleanUrl = baseUrl.replace(/\/+$/, '') || '/'
  return cleanUrl + queryParams(options)
}
matchAction.get = (options?: RouteQueryOptions): RouteDefinition<'get'> => ({
  url: matchAction.url(options),
  method: 'get',
})

matchAction.patch = (options?: RouteQueryOptions): RouteDefinition<'patch'> => ({
  url: matchAction.url(options),
  method: 'patch',
})

matchAction.post = (options?: RouteQueryOptions): RouteDefinition<'post'> => ({
  url: matchAction.url(options),
  method: 'post',
})

matchAction.put = (options?: RouteQueryOptions): RouteDefinition<'put'> => ({
  url: matchAction.url(options),
  method: 'put',
})

/**
 * @see WorkbenchWeb.OtherVerbsController::match_with_params
 * @route /other-verbs/match/:id
*/

export const matchWithParams = (args: { id: string | number } | [string | number] | string | number, options?: RouteQueryOptions): RouteDefinition<'get'> => ({
  url: matchWithParams.url(args, options),
  method: 'get',
})

matchWithParams.definition = {
  methods: ["get", "post"],
  url: '/other-verbs/match/:id'
} satisfies RouteDefinition<['get', 'post']>
matchWithParams.url = (args: { id: string | number } | [string | number] | string | number,  options?: RouteQueryOptions): string => {
  if (args == null) return matchWithParams.definition.url;
if (typeof args === 'string' || typeof args === 'number') {
  args = { id: args }
}

if (Array.isArray(args)) {
  args = { id: args[0] }
}

const parsedArgs = { id: args.id }

  const baseUrl = matchWithParams.definition.url
  .replace(':id', (parsedArgs.id != null ? parsedArgs.id.toString() : ''))

  const cleanUrl = baseUrl.replace(/\/+$/, '') || '/'
  return cleanUrl + queryParams(options)
}
matchWithParams.get = (args: { id: string | number } | [string | number] | string | number, options?: RouteQueryOptions): RouteDefinition<'get'> => ({
  url: matchWithParams.url(args, options),
  method: 'get',
})

matchWithParams.post = (args: { id: string | number } | [string | number] | string | number, options?: RouteQueryOptions): RouteDefinition<'post'> => ({
  url: matchWithParams.url(args, options),
  method: 'post',
})

/**
 * @see WorkbenchWeb.OtherVerbsController::options_action
 * @route /other-verbs/options
*/

export const optionsAction = (options?: RouteQueryOptions): RouteDefinition<'options'> => ({
  url: optionsAction.url(options),
  method: 'options',
})

optionsAction.definition = {
  methods: ["options"],
  url: '/other-verbs/options'
} satisfies RouteDefinition<['options']>
optionsAction.url = (options?: RouteQueryOptions): string => {
  
  const baseUrl = optionsAction.definition.url
  const cleanUrl = baseUrl.replace(/\/+$/, '') || '/'
  return cleanUrl + queryParams(options)
}
optionsAction.options = (options?: RouteQueryOptions): RouteDefinition<'options'> => ({
  url: optionsAction.url(options),
  method: 'options',
})


const OtherVerbsController = { headAction, matchAction, matchWithParams, optionsAction }

export default OtherVerbsController
