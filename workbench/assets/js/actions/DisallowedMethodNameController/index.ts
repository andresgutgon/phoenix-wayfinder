import { queryParams, type RouteQueryOptions, type RouteDefinition } from './../../wayfinder'

/**
 * @see WorkbenchWeb.DisallowedMethodNameController::delete
 * @route /disallowed/delete
*/

export const deleteMethod = (options?: RouteQueryOptions): RouteDefinition<'get'> => ({
  url: deleteMethod.url(options),
  method: 'get',
})

deleteMethod.definition = {
  methods: ["get"],
  url: '/disallowed/delete'
} satisfies RouteDefinition<['get']>
deleteMethod.url = (options?: RouteQueryOptions): string => {
  
  const baseUrl = deleteMethod.definition.url
  const cleanUrl = baseUrl.replace(/\/+$/, '') || '/'
  return cleanUrl + queryParams(options)
}
deleteMethod.get = (options?: RouteQueryOptions): RouteDefinition<'get'> => ({
  url: deleteMethod.url(options),
  method: 'get',
})


const DisallowedMethodNameController = { delete: deleteMethod }

export default DisallowedMethodNameController
