import { queryParams, type RouteQueryOptions, type RouteDefinition } from './../../wayfinder'

/**
 * @see WorkbenchWeb.PageController::home
 * @route /
*/

export const home = (options?: RouteQueryOptions): RouteDefinition<'get'> => ({
  url: home.url(options),
  method: 'get',
})

home.definition = {
  methods: ["get"],
  url: '/'
} satisfies RouteDefinition<['get']>
home.url = (options?: RouteQueryOptions): string => {
  
  const baseUrl = home.definition.url
  const cleanUrl = baseUrl.replace(/\/+$/, '') || '/'
  return cleanUrl + queryParams(options)
}
home.get = (options?: RouteQueryOptions): RouteDefinition<'get'> => ({
  url: home.url(options),
  method: 'get',
})


const PageController = { home }

export default PageController
