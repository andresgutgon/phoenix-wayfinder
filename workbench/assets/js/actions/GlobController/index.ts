import { queryParams, type RouteQueryOptions, type RouteDefinition } from './../../wayfinder'

/**
 * @see WorkbenchWeb.GlobController::show
 * @route /pages/he:page/*rest
*/

export const show = (args: { page: string | number, rest: (string | number)[] }, options?: RouteQueryOptions): RouteDefinition<'get'> => ({
  url: show.url(args, options),
  method: 'get',
})

show.definition = {
  methods: ["get"],
  url: '/pages/he:page/*rest'
} satisfies RouteDefinition<['get']>
show.url = (args: { page: string | number, rest: (string | number)[] },  options?: RouteQueryOptions): string => {
  if (args == null) return show.definition.url;

args = args || {};
if (Array.isArray(args)) {
  args = {
    page: args[0],
      rest: args[1]
  }
}

const parsedArgs = { page: args.page,
  rest: args.rest }

  const baseUrl = show.definition.url
  .replace(':page', (parsedArgs.page != null ? parsedArgs.page.toString() : ''))
        .replace('/*rest', Array.isArray(parsedArgs.rest) ? `/${parsedArgs.rest.join('/')}` : '')

  const cleanUrl = baseUrl.replace(/\/+$/, '') || '/'
  return cleanUrl + queryParams(options)
}
show.get = (args: { page: string | number, rest: (string | number)[] }, options?: RouteQueryOptions): RouteDefinition<'get'> => ({
  url: show.url(args, options),
  method: 'get',
})


const GlobController = { show }

export default GlobController
