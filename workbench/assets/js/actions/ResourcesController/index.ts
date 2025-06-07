import { queryParams, type RouteQueryOptions, type RouteDefinition } from './../../wayfinder'

/**
 * @see WorkbenchWeb.ResourcesController::create
 * @route /resources
*/

export const create = (options?: RouteQueryOptions): RouteDefinition<'post'> => ({
  url: create.url(options),
  method: 'post',
})

create.definition = {
  methods: ["post"],
  url: '/resources'
} satisfies RouteDefinition<['post']>
create.url = (options?: RouteQueryOptions): string => {
  
  const baseUrl = create.definition.url
  const cleanUrl = baseUrl.replace(/\/+$/, '') || '/'
  return cleanUrl + queryParams(options)
}
create.post = (options?: RouteQueryOptions): RouteDefinition<'post'> => ({
  url: create.url(options),
  method: 'post',
})

/**
 * @see WorkbenchWeb.ResourcesController::delete
 * @route /resources/:id
*/

export const deleteMethod = (args: { id: string | number } | [string | number] | string | number, options?: RouteQueryOptions): RouteDefinition<'delete'> => ({
  url: deleteMethod.url(args, options),
  method: 'delete',
})

deleteMethod.definition = {
  methods: ["delete"],
  url: '/resources/:id'
} satisfies RouteDefinition<['delete']>
deleteMethod.url = (args: { id: string | number } | [string | number] | string | number,  options?: RouteQueryOptions): string => {
  if (args == null) return deleteMethod.definition.url;
if (typeof args === 'string' || typeof args === 'number') {
  args = { id: args }
}

if (Array.isArray(args)) {
  args = { id: args[0] }
}

const parsedArgs = { id: args.id }

  const baseUrl = deleteMethod.definition.url
  .replace(':id', (parsedArgs.id != null ? parsedArgs.id.toString() : ''))

  const cleanUrl = baseUrl.replace(/\/+$/, '') || '/'
  return cleanUrl + queryParams(options)
}
deleteMethod.delete = (args: { id: string | number } | [string | number] | string | number, options?: RouteQueryOptions): RouteDefinition<'delete'> => ({
  url: deleteMethod.url(args, options),
  method: 'delete',
})

/**
 * @see WorkbenchWeb.ResourcesController::index
 * @route /resources
*/

export const index = (options?: RouteQueryOptions): RouteDefinition<'get'> => ({
  url: index.url(options),
  method: 'get',
})

index.definition = {
  methods: ["get"],
  url: '/resources'
} satisfies RouteDefinition<['get']>
index.url = (options?: RouteQueryOptions): string => {
  
  const baseUrl = index.definition.url
  const cleanUrl = baseUrl.replace(/\/+$/, '') || '/'
  return cleanUrl + queryParams(options)
}
index.get = (options?: RouteQueryOptions): RouteDefinition<'get'> => ({
  url: index.url(options),
  method: 'get',
})

/**
 * @see WorkbenchWeb.ResourcesController::show
 * @route /resources/:id
*/

export const show = (args: { id: string | number } | [string | number] | string | number, options?: RouteQueryOptions): RouteDefinition<'get'> => ({
  url: show.url(args, options),
  method: 'get',
})

show.definition = {
  methods: ["get"],
  url: '/resources/:id'
} satisfies RouteDefinition<['get']>
show.url = (args: { id: string | number } | [string | number] | string | number,  options?: RouteQueryOptions): string => {
  if (args == null) return show.definition.url;
if (typeof args === 'string' || typeof args === 'number') {
  args = { id: args }
}

if (Array.isArray(args)) {
  args = { id: args[0] }
}

const parsedArgs = { id: args.id }

  const baseUrl = show.definition.url
  .replace(':id', (parsedArgs.id != null ? parsedArgs.id.toString() : ''))

  const cleanUrl = baseUrl.replace(/\/+$/, '') || '/'
  return cleanUrl + queryParams(options)
}
show.get = (args: { id: string | number } | [string | number] | string | number, options?: RouteQueryOptions): RouteDefinition<'get'> => ({
  url: show.url(args, options),
  method: 'get',
})

/**
 * @see WorkbenchWeb.ResourcesController::update
 * @route /resources/:id
*/

export const update = (args: { id: string | number } | [string | number] | string | number, options?: RouteQueryOptions): RouteDefinition<'patch'> => ({
  url: update.url(args, options),
  method: 'patch',
})

update.definition = {
  methods: ["patch", "put"],
  url: '/resources/:id'
} satisfies RouteDefinition<['patch', 'put']>
update.url = (args: { id: string | number } | [string | number] | string | number,  options?: RouteQueryOptions): string => {
  if (args == null) return update.definition.url;
if (typeof args === 'string' || typeof args === 'number') {
  args = { id: args }
}

if (Array.isArray(args)) {
  args = { id: args[0] }
}

const parsedArgs = { id: args.id }

  const baseUrl = update.definition.url
  .replace(':id', (parsedArgs.id != null ? parsedArgs.id.toString() : ''))

  const cleanUrl = baseUrl.replace(/\/+$/, '') || '/'
  return cleanUrl + queryParams(options)
}
update.patch = (args: { id: string | number } | [string | number] | string | number, options?: RouteQueryOptions): RouteDefinition<'patch'> => ({
  url: update.url(args, options),
  method: 'patch',
})

update.put = (args: { id: string | number } | [string | number] | string | number, options?: RouteQueryOptions): RouteDefinition<'put'> => ({
  url: update.url(args, options),
  method: 'put',
})

/**
 * @see WorkbenchWeb.ResourcesController::edit
 * @route /resources/:id/edit
*/

export const edit = (args: { id: string | number } | [string | number] | string | number, options?: RouteQueryOptions): RouteDefinition<'get'> => ({
  url: edit.url(args, options),
  method: 'get',
})

edit.definition = {
  methods: ["get"],
  url: '/resources/:id/edit'
} satisfies RouteDefinition<['get']>
edit.url = (args: { id: string | number } | [string | number] | string | number,  options?: RouteQueryOptions): string => {
  if (args == null) return edit.definition.url;
if (typeof args === 'string' || typeof args === 'number') {
  args = { id: args }
}

if (Array.isArray(args)) {
  args = { id: args[0] }
}

const parsedArgs = { id: args.id }

  const baseUrl = edit.definition.url
  .replace(':id', (parsedArgs.id != null ? parsedArgs.id.toString() : ''))

  const cleanUrl = baseUrl.replace(/\/+$/, '') || '/'
  return cleanUrl + queryParams(options)
}
edit.get = (args: { id: string | number } | [string | number] | string | number, options?: RouteQueryOptions): RouteDefinition<'get'> => ({
  url: edit.url(args, options),
  method: 'get',
})

/**
 * @see WorkbenchWeb.ResourcesController::new
 * @route /resources/new
*/

export const newMethod = (options?: RouteQueryOptions): RouteDefinition<'get'> => ({
  url: newMethod.url(options),
  method: 'get',
})

newMethod.definition = {
  methods: ["get"],
  url: '/resources/new'
} satisfies RouteDefinition<['get']>
newMethod.url = (options?: RouteQueryOptions): string => {
  
  const baseUrl = newMethod.definition.url
  const cleanUrl = baseUrl.replace(/\/+$/, '') || '/'
  return cleanUrl + queryParams(options)
}
newMethod.get = (options?: RouteQueryOptions): RouteDefinition<'get'> => ({
  url: newMethod.url(options),
  method: 'get',
})


const ResourcesController = { create, delete: deleteMethod, index, show, update, edit, new: newMethod }

export default ResourcesController
