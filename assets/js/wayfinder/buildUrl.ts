import type {
  Method,
  ParamConfig,
  RouteDefinitionWithParameters,
  RouteQueryOptions,
  WayfinderUrl,
} from './types'
import { queryParams, isCurrentUrl } from './index'

type ObjectParameters = Record<string, string | number | (string | number)[]>
type NonNullArgs =
  | string
  | number
  | Array<string | number | Array<string | number>>
  | ObjectParameters
type RawArgs = NonNullArgs | null

type ValidationResult = { valid: true } | { valid: false; error: string }

function parseArgs({
  args,
  parameters,
}: {
  args?: RawArgs
  parameters: ParamConfig[]
}): ObjectParameters {
  const isEmpty = args === undefined || args === null || args === ''
  if (isEmpty) return {}

  if (typeof args === 'string' || typeof args === 'number') {
    if (parameters.length === 0) return {}
    return { [parameters[0].name]: args }
  }

  if (Array.isArray(args)) {
    return parameters.reduce((result, param, index) => {
      if (index < args.length && args[index] !== null) {
        result[param.name] = args[index]
      }
      return result
    }, {} as ObjectParameters)
  }

  if (typeof args === 'object') {
    return parameters.reduce((result, param) => {
      if (args[param.name] !== null) {
        result[param.name] = args[param.name]
      }
      return result
    }, {} as ObjectParameters)
  }

  return {}
}

function validateArgs({
  parsedArgs,
  parameters,
}: {
  parsedArgs: ObjectParameters
  parameters: ParamConfig[]
}): ValidationResult {
  const requiredParams = parameters.filter((p) => p.required)
  const optionalParams = parameters.filter((p) => p.optional) // Check required parameters
  if (requiredParams.length > 0) {
    const missing = requiredParams
      .filter((param) => parsedArgs[param.name] == null)
      .map((p) => p.name)

    if (missing.length > 0) {
      const paramWord = parameters.length === 1 ? 'parameter' : 'parameters'
      const errorMessage = `Missing required ${paramWord}: ${missing.join(', ')}`
      return { valid: false, error: errorMessage }
    }
  }

  if (optionalParams.length > 0) {
    const optionalNames = optionalParams.map((p) => p.name)
    const missing = optionalNames.filter((key) => parsedArgs[key] == null)

    if (missing.length > 0 && missing.length < optionalNames.length) {
      // Some optional params are provided, check if they're consecutive
      const expectedMissing = optionalNames.slice(missing.length * -1)

      for (let i = 0; i < missing.length; i++) {
        if (missing[i] !== expectedMissing[i]) {
          return {
            valid: false,
            error:
              'Unexpected optional parameters missing. Unable to generate a URL.',
          }
        }
      }
    }
  }

  return { valid: true }
}

function generateUrl({
  routePath,
  parameters,
  parsedArgs,
  options,
}: {
  routePath: string
  parameters: ParamConfig[]
  parsedArgs: ObjectParameters
  options: RouteQueryOptions
}): WayfinderUrl {
  const reversedParameters = [...parameters].reverse()

  const url = reversedParameters.reduce((currentUrl, param) => {
    const value = parsedArgs[param.name]

    if (param.glob) {
      // For glob parameters: if value is an array, join with slashes; otherwise remove the glob
      const replacement = Array.isArray(value) ? `/${value.join('/')}` : ''
      return currentUrl.replace(`/*${param.name}`, replacement)
    } else {
      if (value !== null && value !== undefined) {
        return currentUrl.replace(`:${param.name}`, value.toString())
      } else {
        return currentUrl.replace(new RegExp(`\\/:${param.name}(?=\\/|$)`), '')
      }
    }
  }, routePath)

  const cleanPath = url.replace(/\/+$/, '') || '/'
  const finalPath = cleanPath + queryParams(options)

  return {
    path: finalPath,
    isCurrent: isCurrentUrl({
      routePath: url,
      currentPath: options?.currentPath,
      exactMatch: options?.exactMatch,
    }),
  }
}

export function buildUrl<M extends Method | Method[]>({
  definition,
  args,
  options = {},
}: {
  definition: RouteDefinitionWithParameters<M>
  args?: RawArgs
  options?: RouteQueryOptions
}): WayfinderUrl {
  const routePath = definition.url
  const parameters = Object.values(definition.parameters)
  const parsedArgs = parseArgs({ args, parameters })

  const validation = validateArgs({ parsedArgs, parameters })

  if (!validation.valid) {
    throw new Error(validation.error)
  }

  return generateUrl({ routePath, parameters, parsedArgs, options })
}
