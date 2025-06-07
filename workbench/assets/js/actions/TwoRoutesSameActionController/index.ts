import { queryParams, type RouteQueryOptions, type RouteDefinition } from './../../wayfinder'

/**
 * @see WorkbenchWeb.TwoRoutesSameActionController::same
 * @route /two-routes-one-action-1
*/

export const same = (options?: RouteQueryOptions): RouteDefinition<'get'> => ({
  url: same.url(options),
  method: 'get',
})

same.definition = {
  methods: ["get"],
  url: '/two-routes-one-action-1'
} satisfies RouteDefinition<['get']>
same.url = (options?: RouteQueryOptions): string => {
  
  const baseUrl = same.definition.url
  const cleanUrl = baseUrl.replace(/\/+$/, '') || '/'
  return cleanUrl + queryParams(options)
}
same.get = (options?: RouteQueryOptions): RouteDefinition<'get'> => ({
  url: same.url(options),
  method: 'get',
})

/**
 * @see WorkbenchWeb.TwoRoutesSameActionController::same
 * @route /two-routes-one-action-2
*/

export const same2 = (options?: RouteQueryOptions): RouteDefinition<'get'> => ({
  url: same2.url(options),
  method: 'get',
})

same2.definition = {
  methods: ["get"],
  url: '/two-routes-one-action-2'
} satisfies RouteDefinition<['get']>
same2.url = (options?: RouteQueryOptions): string => {
  
  const baseUrl = same2.definition.url
  const cleanUrl = baseUrl.replace(/\/+$/, '') || '/'
  return cleanUrl + queryParams(options)
}
same2.get = (options?: RouteQueryOptions): RouteDefinition<'get'> => ({
  url: same2.url(options),
  method: 'get',
})


const TwoRoutesSameActionController = { same, same2 }

export default TwoRoutesSameActionController
