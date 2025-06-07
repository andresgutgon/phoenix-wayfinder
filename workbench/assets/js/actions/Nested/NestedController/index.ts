import { queryParams, type RouteQueryOptions, type RouteDefinition } from './../../../wayfinder'

/**
 * @see WorkbenchWeb.Nested.NestedController::nested
 * @route /nested/controller
*/

export const nested = (options?: RouteQueryOptions): RouteDefinition<'get'> => ({
  url: nested.url(options),
  method: 'get',
})

nested.definition = {
  methods: ["get"],
  url: '/nested/controller'
} satisfies RouteDefinition<['get']>
nested.url = (options?: RouteQueryOptions): string => {
  
  const baseUrl = nested.definition.url
  const cleanUrl = baseUrl.replace(/\/+$/, '') || '/'
  return cleanUrl + queryParams(options)
}
nested.get = (options?: RouteQueryOptions): RouteDefinition<'get'> => ({
  url: nested.url(options),
  method: 'get',
})


const NestedController = { nested }

export default NestedController
