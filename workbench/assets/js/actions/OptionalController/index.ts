import { validateParameters, queryParams, type RouteQueryOptions, type RouteDefinition } from './../../wayfinder'

/**
 * @see WorkbenchWeb.OptionalController::many_optional
 * @route /many-optional/:one/:two/:three
*/

export const manyOptional = (args?: { one?: string | number, two?: string | number, three?: string | number } | [string | number, string | number, string | number], options?: RouteQueryOptions): RouteDefinition<'post'> => ({
  url: manyOptional.url(args, options),
  method: 'post',
})

manyOptional.definition = {
  methods: ["post"],
  url: '/many-optional/:one/:two/:three'
} satisfies RouteDefinition<['post']>
manyOptional.url = (args?: { one?: string | number, two?: string | number, three?: string | number } | [string | number, string | number, string | number],  options?: RouteQueryOptions): string => {
  if (args == null) {
  let basePath = manyOptional.definition.url;
  basePath = basePath.replace(/\/:three(\?)?$/, '');
basePath = basePath.replace(/\/:two(\?)?$/, '');
basePath = basePath.replace(/\/:one(\?)?$/, '');
  return basePath || '/';
}

args = args || {};
if (Array.isArray(args)) {
  args = {
    one: args[0],
      two: args[1],
      three: args[2]
  }
}

validateParameters(args, ["one", "two", "three"])
const parsedArgs = { one: args?.one,
  two: args?.two,
  three: args?.three }

  const baseUrl = manyOptional.definition.url
  .replace(':one', (parsedArgs.one != null ? parsedArgs.one.toString() : ''))
        .replace(':two', (parsedArgs.two != null ? parsedArgs.two.toString() : ''))
        .replace(':three', (parsedArgs.three != null ? parsedArgs.three.toString() : ''))

  const cleanUrl = baseUrl.replace(/\/+$/, '') || '/'
  return cleanUrl + queryParams(options)
}
manyOptional.post = (args?: { one?: string | number, two?: string | number, three?: string | number } | [string | number, string | number, string | number], options?: RouteQueryOptions): RouteDefinition<'post'> => ({
  url: manyOptional.url(args, options),
  method: 'post',
})

/**
 * @see WorkbenchWeb.OptionalController::optional
 * @route /optional/:parameter
*/

export const optional = (args?: { parameter?: string | number } | [string | number], options?: RouteQueryOptions): RouteDefinition<'get'> => ({
  url: optional.url(args, options),
  method: 'get',
})

optional.definition = {
  methods: ["get", "post"],
  url: '/optional/:parameter'
} satisfies RouteDefinition<['get', 'post']>
optional.url = (args?: { parameter?: string | number } | [string | number],  options?: RouteQueryOptions): string => {
  if (args == null) {
  let basePath = optional.definition.url;
  basePath = basePath.replace(/\/:parameter(\?)?$/, '');
  return basePath || '/';
}

if (Array.isArray(args)) {
  args = { parameter: args[0] }
}

validateParameters(args, ["parameter"])
const parsedArgs = { parameter: args?.parameter }

  const baseUrl = optional.definition.url
  .replace(':parameter', (parsedArgs.parameter != null ? parsedArgs.parameter.toString() : ''))

  const cleanUrl = baseUrl.replace(/\/+$/, '') || '/'
  return cleanUrl + queryParams(options)
}
optional.get = (options?: RouteQueryOptions): RouteDefinition<'get'> => ({
  url: optional.url(undefined, options),
  method: 'get',
})

optional.post = (args?: { parameter?: string | number } | [string | number], options?: RouteQueryOptions): RouteDefinition<'post'> => ({
  url: optional.url(args, options),
  method: 'post',
})

/**
 * @see WorkbenchWeb.OptionalController::optional
 * @route /different/path/optional
*/

export const optional2 = (options?: RouteQueryOptions): RouteDefinition<'get'> => ({
  url: optional2.url(options),
  method: 'get',
})

optional2.definition = {
  methods: ["get"],
  url: '/different/path/optional'
} satisfies RouteDefinition<['get']>
optional2.url = (options?: RouteQueryOptions): string => {
  
  const baseUrl = optional2.definition.url
  const cleanUrl = baseUrl.replace(/\/+$/, '') || '/'
  return cleanUrl + queryParams(options)
}
optional2.get = (options?: RouteQueryOptions): RouteDefinition<'get'> => ({
  url: optional2.url(options),
  method: 'get',
})

/**
 * @see WorkbenchWeb.OptionalController::optional
 * @route /different/with/alias
*/

export const optionalDifferent = (options?: RouteQueryOptions): RouteDefinition<'get'> => ({
  url: optionalDifferent.url(options),
  method: 'get',
})

optionalDifferent.definition = {
  methods: ["get"],
  url: '/different/with/alias'
} satisfies RouteDefinition<['get']>
optionalDifferent.url = (options?: RouteQueryOptions): string => {
  
  const baseUrl = optionalDifferent.definition.url
  const cleanUrl = baseUrl.replace(/\/+$/, '') || '/'
  return cleanUrl + queryParams(options)
}
optionalDifferent.get = (options?: RouteQueryOptions): RouteDefinition<'get'> => ({
  url: optionalDifferent.url(options),
  method: 'get',
})


const OptionalController = { manyOptional, optional, optional2, optionalDifferent }

export default OptionalController
