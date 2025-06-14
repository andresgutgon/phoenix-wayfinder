import { describe, expect, it } from 'vitest'

import type {
  RouteDefinitionWithParameters,
  ParamConfig,
  ParametersDefinition,
} from './types'
import { buildUrl } from './buildUrl'

function createRouteDefinition(
  url: string,
  parameters: Record<string, Omit<ParamConfig, 'name'>>,
): RouteDefinitionWithParameters<'get'> {
  const parametersWithName = Object.entries(parameters).reduce(
    (acc, [name, config]) => {
      acc[name] = { ...config, name }
      return acc
    },
    {} as ParametersDefinition,
  )

  return {
    url,
    method: 'get',
    parameters: parametersWithName,
  }
}

function required(): Omit<ParamConfig, 'name'> {
  return { required: true, optional: false, glob: false }
}

function optional(): Omit<ParamConfig, 'name'> {
  return { required: false, optional: true, glob: false }
}

function glob(): Omit<ParamConfig, 'name'> {
  return { required: true, optional: false, glob: true }
}

function optionalGlob(): Omit<ParamConfig, 'name'> {
  return { required: false, optional: true, glob: true }
}

describe('buildUrl', () => {
  describe('routes with no parameters', () => {
    const definition = createRouteDefinition('/posts', {})

    it('builds URL without arguments', () => {
      expect(buildUrl({ definition })).toEqual({
        path: '/posts',
        isCurrent: false,
      })
    })

    it('builds URL with null arguments', () => {
      expect(buildUrl({ definition, args: null })).toEqual({
        path: '/posts',
        isCurrent: false,
      })
    })

    it('builds URL with undefined arguments', () => {
      expect(buildUrl({ definition, args: undefined })).toEqual({
        path: '/posts',
        isCurrent: false,
      })
    })

    it('builds URL with empty string arguments', () => {
      expect(buildUrl({ definition, args: '' })).toEqual({
        path: '/posts',
        isCurrent: false,
      })
    })

    it('ignores invalid arguments when no parameters exist', () => {
      expect(buildUrl({ definition, args: { invalid: 'value' } })).toEqual({
        path: '/posts',
        isCurrent: false,
      })
    })

    it('handles query options', () => {
      expect(
        buildUrl({
          definition,
          options: { query: { page: 1 } },
        }),
      ).toEqual({
        path: '/posts?page=1',
        isCurrent: false,
      })
    })

    it('removes trailing slashes except for root', () => {
      const rootDefinition = createRouteDefinition('/', {})
      expect(
        buildUrl({
          definition: rootDefinition,
          options: { currentPath: '/other' },
        }),
      ).toEqual({
        path: '/',
        isCurrent: false,
      })

      const trailingSlashDefinition = createRouteDefinition('/posts/', {})
      expect(
        buildUrl({
          definition: trailingSlashDefinition,
          options: { currentPath: '/other' },
        }),
      ).toEqual({
        path: '/posts',
        isCurrent: false,
      })
    })
  })

  describe('routes with single required parameter', () => {
    const definition = createRouteDefinition('/posts/:id', {
      id: required(),
    })

    describe('valid arguments', () => {
      it('accepts string argument', () => {
        expect(
          buildUrl({
            definition,
            args: 'test-id',
            options: { currentPath: '/posts/test-id' },
          }),
        ).toEqual({
          path: '/posts/test-id',
          isCurrent: true,
        })
      })

      it('accepts number argument', () => {
        expect(buildUrl({ definition, args: 123 })).toEqual({
          path: '/posts/123',
          isCurrent: false,
        })
      })

      it('accepts object argument', () => {
        expect(buildUrl({ definition, args: { id: 'test-id' } })).toEqual({
          path: '/posts/test-id',
          isCurrent: false,
        })
      })

      it('accepts array argument (uses first element)', () => {
        expect(buildUrl({ definition, args: ['test-id', 'ignored'] })).toEqual({
          path: '/posts/test-id',
          isCurrent: false,
        })
      })

      it('converts number in object to string', () => {
        expect(buildUrl({ definition, args: { id: 456 } })).toEqual({
          path: '/posts/456',
          isCurrent: false,
        })
      })

      it('converts number in array to string', () => {
        expect(buildUrl({ definition, args: [789] })).toEqual({
          path: '/posts/789',
          isCurrent: false,
        })
      })

      it('ignores extra properties in object', () => {
        expect(
          buildUrl({ definition, args: { id: 'test', extra: 'ignored' } }),
        ).toEqual({
          path: '/posts/test',
          isCurrent: false,
        })
      })
    })

    describe('missing arguments', () => {
      it('throws error when no arguments provided', () => {
        expect(() => buildUrl({ definition })).toThrow(
          'Missing required parameter: id',
        )
      })

      it('throws error when null arguments provided', () => {
        expect(() => buildUrl({ definition, args: null })).toThrow(
          'Missing required parameter: id',
        )
      })

      it('throws error when undefined arguments provided', () => {
        expect(() => buildUrl({ definition, args: undefined })).toThrow(
          'Missing required parameter: id',
        )
      })

      it('throws error when empty string provided', () => {
        expect(() => buildUrl({ definition, args: '' })).toThrow(
          'Missing required parameter: id',
        )
      })

      it('throws error when empty array provided', () => {
        expect(() => buildUrl({ definition, args: [] })).toThrow(
          'Missing required parameter: id',
        )
      })

      it('throws error when parameter missing from object', () => {
        expect(() =>
          buildUrl({ definition, args: { other: 'value' } }),
        ).toThrow('Missing required parameter: id')
      })

      it('throws error when parameter is null in object', () => {
        // @ts-expect-error - Runtime case
        expect(() => buildUrl({ definition, args: { id: null } })).toThrow(
          'Missing required parameter: id',
        )
      })

      it('throws error when parameter is undefined in object', () => {
        // @ts-expect-error - Runtime case
        expect(() => buildUrl({ definition, args: { id: undefined } })).toThrow(
          'Missing required parameter: id',
        )
      })
    })
  })

  describe('routes with single optional parameter', () => {
    const definition = createRouteDefinition('/posts/:id', {
      id: optional(),
    })

    it('builds URL without arguments (removes optional parameter)', () => {
      expect(buildUrl({ definition })).toEqual({
        path: '/posts',
        isCurrent: false,
      })
    })

    it('builds URL with null arguments (removes optional parameter)', () => {
      expect(buildUrl({ definition, args: null })).toEqual({
        path: '/posts',
        isCurrent: false,
      })
    })

    it('builds URL with undefined arguments (removes optional parameter)', () => {
      expect(buildUrl({ definition, args: undefined })).toEqual({
        path: '/posts',
        isCurrent: false,
      })
    })

    it('builds URL with empty string (removes optional parameter)', () => {
      expect(buildUrl({ definition, args: '' })).toEqual({
        path: '/posts',
        isCurrent: false,
      })
    })

    it('builds URL with valid string argument', () => {
      expect(buildUrl({ definition, args: 'test-id' })).toEqual({
        path: '/posts/test-id',
        isCurrent: false,
      })
    })

    it('builds URL with valid number argument', () => {
      expect(buildUrl({ definition, args: 123 })).toEqual({
        path: '/posts/123',
        isCurrent: false,
      })
    })

    it('builds URL with valid object argument', () => {
      expect(buildUrl({ definition, args: { id: 'test-id' } })).toEqual({
        path: '/posts/test-id',
        isCurrent: false,
      })
    })

    it('builds URL with valid array argument', () => {
      expect(buildUrl({ definition, args: ['test-id'] })).toEqual({
        path: '/posts/test-id',
        isCurrent: false,
      })
    })

    it('removes parameter when not provided in object', () => {
      expect(buildUrl({ definition, args: { other: 'value' } })).toEqual({
        path: '/posts',
        isCurrent: false,
      })
    })

    it('removes parameter when null in object', () => {
      // @ts-expect-error - Runtime case
      expect(buildUrl({ definition, args: { id: null } })).toEqual({
        path: '/posts',
        isCurrent: false,
      })
    })

    it('removes parameter when undefined in object', () => {
      // @ts-expect-error - Runtime case
      expect(buildUrl({ definition, args: { id: undefined } })).toEqual({
        path: '/posts',
        isCurrent: false,
      })
    })

    it('removes parameter when empty array provided', () => {
      expect(buildUrl({ definition, args: [] })).toEqual({
        path: '/posts',
        isCurrent: false,
      })
    })
  })

  describe('routes with multiple required parameters', () => {
    const definition = createRouteDefinition(
      '/posts/:postId/comments/:commentId',
      {
        postId: required(),
        commentId: required(),
      },
    )

    it('accepts object with all parameters', () => {
      expect(
        buildUrl({
          definition,
          args: { postId: 'post-1', commentId: 'comment-1' },
        }),
      ).toEqual({
        path: '/posts/post-1/comments/comment-1',
        isCurrent: false,
      })
    })

    it('accepts array with all parameters in order', () => {
      expect(buildUrl({ definition, args: ['post-1', 'comment-1'] })).toEqual({
        path: '/posts/post-1/comments/comment-1',
        isCurrent: false,
      })
    })

    it('converts numbers to strings', () => {
      expect(buildUrl({ definition, args: [123, 456] })).toEqual({
        path: '/posts/123/comments/456',
        isCurrent: false,
      })

      expect(
        buildUrl({
          definition,
          args: { postId: 789, commentId: 101112 },
        }),
      ).toEqual({
        path: '/posts/789/comments/101112',
        isCurrent: false,
      })
    })

    describe('missing parameters', () => {
      it('throws error when no arguments provided', () => {
        expect(() => buildUrl({ definition })).toThrow(
          'Missing required parameters: postId, commentId',
        )
      })

      it('throws error when some parameters missing from object', () => {
        expect(() =>
          buildUrl({ definition, args: { postId: 'test' } }),
        ).toThrow('Missing required parameters: commentId')
      })

      it('throws error when array is too short', () => {
        expect(() => buildUrl({ definition, args: ['post-1'] })).toThrow(
          'Missing required parameters: commentId',
        )
      })

      it('throws error when parameters are null in object', () => {
        expect(() =>
          buildUrl({
            definition,
            // @ts-expect-error - Runtime case
            args: { postId: 'test', commentId: null },
          }),
        ).toThrow('Missing required parameters: commentId')
      })
    })
  })

  describe('routes with multiple optional parameters', () => {
    const definition = createRouteDefinition('/posts/:one/:two/:three', {
      one: optional(),
      two: optional(),
      three: optional(),
    })

    it('builds URL without arguments (removes all optional parameters)', () => {
      expect(buildUrl({ definition })).toEqual({
        path: '/posts',
        isCurrent: false,
      })
    })

    it('builds URL with first parameter only', () => {
      expect(buildUrl({ definition, args: { one: 'value1' } })).toEqual({
        path: '/posts/value1',
        isCurrent: false,
      })
    })

    it('builds URL with first two parameters', () => {
      expect(
        buildUrl({
          definition,
          args: { one: 'value1', two: 'value2' },
        }),
      ).toEqual({
        path: '/posts/value1/value2',
        isCurrent: false,
      })
    })

    it('builds URL with all parameters', () => {
      expect(
        buildUrl({
          definition,
          args: { one: 'value1', two: 'value2', three: 'value3' },
        }),
      ).toEqual({
        path: '/posts/value1/value2/value3',
        isCurrent: false,
      })
    })

    it('accepts array arguments in order', () => {
      expect(buildUrl({ definition, args: ['value1'] })).toEqual({
        path: '/posts/value1',
        isCurrent: false,
      })

      expect(buildUrl({ definition, args: ['value1', 'value2'] })).toEqual({
        path: '/posts/value1/value2',
        isCurrent: false,
      })

      expect(
        buildUrl({ definition, args: ['value1', 'value2', 'value3'] }),
      ).toEqual({
        path: '/posts/value1/value2/value3',
        isCurrent: false,
      })
    })

    describe('validation of optional parameter order', () => {
      it('throws error when skipping optional parameters (missing first)', () => {
        expect(() => buildUrl({ definition, args: { two: 'value2' } })).toThrow(
          'Unexpected optional parameters missing. Unable to generate a URL.',
        )
      })

      it('throws error when skipping optional parameters (missing middle)', () => {
        expect(() =>
          buildUrl({
            definition,
            args: { one: 'value1', three: 'value3' },
          }),
        ).toThrow(
          'Unexpected optional parameters missing. Unable to generate a URL.',
        )
      })

      it('throws error when providing only last parameter', () => {
        expect(() =>
          buildUrl({ definition, args: { three: 'value3' } }),
        ).toThrow(
          'Unexpected optional parameters missing. Unable to generate a URL.',
        )
      })
    })
  })

  describe('routes with mixed required and optional parameters', () => {
    const definition = createRouteDefinition(
      '/posts/:postId/comments/:commentId/:optional',
      {
        postId: required(),
        commentId: required(),
        optional: optional(),
      },
    )

    it('builds URL with only required parameters', () => {
      expect(
        buildUrl({
          definition,
          args: { postId: 'post-1', commentId: 'comment-1' },
        }),
      ).toEqual({
        path: '/posts/post-1/comments/comment-1',
        isCurrent: false,
      })
    })

    it('builds URL with all parameters', () => {
      expect(
        buildUrl({
          definition,
          args: {
            postId: 'post-1',
            commentId: 'comment-1',
            optional: 'extra',
          },
        }),
      ).toEqual({
        path: '/posts/post-1/comments/comment-1/extra',
        isCurrent: false,
      })
    })

    it('accepts array arguments', () => {
      expect(buildUrl({ definition, args: ['post-1', 'comment-1'] })).toEqual({
        path: '/posts/post-1/comments/comment-1',
        isCurrent: false,
      })

      expect(
        buildUrl({ definition, args: ['post-1', 'comment-1', 'extra'] }),
      ).toEqual({
        path: '/posts/post-1/comments/comment-1/extra',
        isCurrent: false,
      })
    })

    it('throws error when required parameters are missing', () => {
      expect(() =>
        buildUrl({ definition, args: { optional: 'value' } }),
      ).toThrow('Missing required parameters: postId, commentId')
    })

    it('throws error when some required parameters are missing', () => {
      expect(() =>
        buildUrl({
          definition,
          args: { postId: 'test', optional: 'value' },
        }),
      ).toThrow('Missing required parameters: commentId')
    })
  })

  describe('routes with required glob parameters', () => {
    const definition = createRouteDefinition('/files/*path', {
      path: glob(),
    })

    it('builds URL with array argument for glob', () => {
      expect(
        buildUrl({
          definition,
          args: { path: ['folder1', 'folder2', 'file.txt'] },
        }),
      ).toEqual({
        path: '/files/folder1/folder2/file.txt',
        isCurrent: false,
      })
    })

    it('builds URL with string array as direct argument', () => {
      expect(
        buildUrl({ definition, args: [['folder1', 'folder2', 'file.txt']] }),
      ).toEqual({
        path: '/files/folder1/folder2/file.txt',
        isCurrent: false,
      })
    })

    it('builds URL with empty array (removes glob path)', () => {
      expect(buildUrl({ definition, args: { path: [] } })).toEqual({
        path: '/files',
        isCurrent: false,
      })
    })

    it('builds URL with single item array', () => {
      expect(buildUrl({ definition, args: { path: ['file.txt'] } })).toEqual({
        path: '/files/file.txt',
        isCurrent: false,
      })
    })

    it('throws error when required glob parameter is missing', () => {
      expect(() => buildUrl({ definition })).toThrow(
        'Missing required parameter: path',
      )
    })

    it('throws error when glob parameter is null', () => {
      // @ts-expect-error - Runtime case
      expect(() => buildUrl({ definition, args: { path: null } })).toThrow(
        'Missing required parameter: path',
      )
    })

    it('handles non-array values for glob (treats as empty)', () => {
      expect(buildUrl({ definition, args: { path: 'not-array' } })).toEqual({
        path: '/files',
        isCurrent: false,
      })
    })
  })

  describe('routes with optional glob parameters', () => {
    const definition = createRouteDefinition('/files/*path', {
      path: optionalGlob(),
    })

    it('builds URL without arguments (removes optional glob)', () => {
      expect(buildUrl({ definition })).toEqual({
        path: '/files',
        isCurrent: false,
      })
    })

    it('builds URL with null arguments (removes optional glob)', () => {
      expect(buildUrl({ definition, args: null })).toEqual({
        path: '/files',
        isCurrent: false,
      })
    })

    it('builds URL with undefined arguments (removes optional glob)', () => {
      expect(buildUrl({ definition, args: undefined })).toEqual({
        path: '/files',
        isCurrent: false,
      })
    })

    it('builds URL with empty string arguments (removes optional glob)', () => {
      expect(buildUrl({ definition, args: '' })).toEqual({
        path: '/files',
        isCurrent: false,
      })
    })

    it('builds URL with array argument for optional glob', () => {
      expect(
        buildUrl({
          definition,
          args: { path: ['folder1', 'folder2', 'file.txt'] },
        }),
      ).toEqual({
        path: '/files/folder1/folder2/file.txt',
        isCurrent: false,
      })
    })

    it('builds URL with empty array', () => {
      expect(buildUrl({ definition, args: { path: [] } })).toEqual({
        path: '/files',
        isCurrent: false,
      })
    })

    it('builds URL when parameter is missing from object', () => {
      expect(buildUrl({ definition, args: { other: 'value' } })).toEqual({
        path: '/files',
        isCurrent: false,
      })
    })

    it('builds URL when glob parameter is null in object', () => {
      // @ts-expect-error - Runtime case
      expect(buildUrl({ definition, args: { path: null } })).toEqual({
        path: '/files',
        isCurrent: false,
      })
    })

    it('builds URL when glob parameter is undefined in object', () => {
      // @ts-expect-error - Runtime case
      expect(buildUrl({ definition, args: { path: undefined } })).toEqual({
        path: '/files',
        isCurrent: false,
      })
    })

    it('builds URL with single item in glob array', () => {
      expect(buildUrl({ definition, args: { path: ['file.txt'] } })).toEqual({
        path: '/files/file.txt',
        isCurrent: false,
      })
    })

    it('handles non-array values for optional glob (treats as empty)', () => {
      expect(buildUrl({ definition, args: { path: 'not-array' } })).toEqual({
        path: '/files',
        isCurrent: false,
      })
    })

    it('handles single parameter with direct array argument', () => {
      expect(buildUrl({ definition, args: [['folder', 'file.txt']] })).toEqual({
        path: '/files/folder/file.txt',
        isCurrent: false,
      })
    })

    it('handles single parameter with empty array as direct argument', () => {
      expect(buildUrl({ definition, args: [[]] })).toEqual({
        path: '/files',
        isCurrent: false,
      })
    })
  })

  describe('routes with mixed parameters including glob', () => {
    const definition = createRouteDefinition('/users/:userId/files/*path', {
      userId: required(),
      path: glob(),
    })

    it('builds URL with all parameters', () => {
      expect(
        buildUrl({
          definition,
          args: {
            userId: 'user-123',
            path: ['documents', 'important', 'file.pdf'],
          },
        }),
      ).toEqual({
        path: '/users/user-123/files/documents/important/file.pdf',
        isCurrent: false,
      })
    })

    it('builds URL with array arguments', () => {
      expect(
        buildUrl({
          definition,
          args: ['user-123', ['documents', 'file.pdf']],
        }),
      ).toEqual({
        path: '/users/user-123/files/documents/file.pdf',
        isCurrent: false,
      })
    })

    it('builds URL with empty glob array', () => {
      expect(
        buildUrl({
          definition,
          args: { userId: 'user-123', path: [] },
        }),
      ).toEqual({
        path: '/users/user-123/files',
        isCurrent: false,
      })
    })

    it('throws error when required parameter is missing', () => {
      expect(() =>
        buildUrl({
          definition,
          args: { path: ['file.txt'] },
        }),
      ).toThrow('Missing required parameters: userId')
    })

    it('throws error when glob parameter is missing', () => {
      expect(() =>
        buildUrl({
          definition,
          args: { userId: 'user-123' },
        }),
      ).toThrow('Missing required parameters: path')
    })
  })

  describe('realistic optional glob scenarios', () => {
    // This represents a scenario where there are multiple routes:
    // GET /docs -> DocsController.index
    // GET /docs/*path -> DocsController.index
    // This would make the glob parameter optional
    const optionalGlobDefinition = createRouteDefinition('/docs/*path', {
      path: optionalGlob(),
    })

    it('handles documentation browsing without path (root docs)', () => {
      expect(buildUrl({ definition: optionalGlobDefinition })).toEqual({
        path: '/docs',
        isCurrent: false,
      })
    })

    it('handles documentation browsing with nested path', () => {
      expect(
        buildUrl({
          definition: optionalGlobDefinition,
          args: { path: ['api', 'users', 'create'] },
        }),
      ).toEqual({
        path: '/docs/api/users/create',
        isCurrent: false,
      })
    })

    it('handles single-level documentation path', () => {
      expect(
        buildUrl({
          definition: optionalGlobDefinition,
          args: { path: ['getting-started'] },
        }),
      ).toEqual({
        path: '/docs/getting-started',
        isCurrent: false,
      })
    })

    // Another realistic scenario: file serving with optional path
    const fileServingDefinition = createRouteDefinition('/assets/*file', {
      file: optionalGlob(),
    })

    it('serves root assets directory', () => {
      expect(buildUrl({ definition: fileServingDefinition })).toEqual({
        path: '/assets',
        isCurrent: false,
      })
    })

    it('serves nested asset files', () => {
      expect(
        buildUrl({
          definition: fileServingDefinition,
          args: { file: ['css', 'app.css'] },
        }),
      ).toEqual({
        path: '/assets/css/app.css',
        isCurrent: false,
      })
    })

    it('serves single asset file', () => {
      expect(
        buildUrl({
          definition: fileServingDefinition,
          args: { file: ['app.js'] },
        }),
      ).toEqual({
        path: '/assets/app.js',
        isCurrent: false,
      })
    })
  })

  describe('query options', () => {
    const definition = createRouteDefinition('/posts/:id', {
      id: required(),
    })

    it('adds query parameters', () => {
      expect(
        buildUrl({
          definition,
          args: { id: 'test' },
          options: { query: { page: 1, limit: 10 } },
        }),
      ).toEqual({
        path: '/posts/test?page=1&limit=10',
        isCurrent: false,
      })
    })

    it('handles currentPath for isCurrent', () => {
      expect(
        buildUrl({
          definition,
          args: { id: 'test' },
          options: { currentPath: '/posts/test' },
        }),
      ).toEqual({
        path: '/posts/test',
        isCurrent: true,
      })
    })

    it('handles exactMatch option', () => {
      expect(
        buildUrl({
          definition,
          args: { id: 'test' },
          options: {
            currentPath: '/posts/test/comments',
            exactMatch: true,
          },
        }),
      ).toEqual({
        path: '/posts/test',
        isCurrent: false,
      })

      expect(
        buildUrl({
          definition,
          args: { id: 'test' },
          options: {
            currentPath: '/posts/test/comments',
            exactMatch: false,
          },
        }),
      ).toEqual({
        path: '/posts/test',
        isCurrent: true,
      })
    })

    it('works with routes without parameters', () => {
      const noParamDef = createRouteDefinition('/posts', {})
      expect(
        buildUrl({
          definition: noParamDef,
          options: { query: { search: 'test' } },
        }),
      ).toEqual({
        path: '/posts?search=test',
        isCurrent: false,
      })
    })
  })

  describe('edge cases and error handling', () => {
    it('handles empty parameter object gracefully', () => {
      const definition = createRouteDefinition('/posts', {})
      expect(buildUrl({ definition, args: {} })).toEqual({
        path: '/posts',
        isCurrent: false,
      })
    })

    it('throws descriptive error for multiple missing required parameters', () => {
      const definition = createRouteDefinition(
        '/posts/:postId/comments/:commentId/replies/:replyId',
        {
          postId: required(),
          commentId: required(),
          replyId: required(),
        },
      )

      expect(() => buildUrl({ definition, args: {} })).toThrow(
        'Missing required parameters: postId, commentId, replyId',
      )

      expect(() => buildUrl({ definition, args: { postId: 'test' } })).toThrow(
        'Missing required parameters: commentId, replyId',
      )
    })

    it('filters out invalid parameter names in object args', () => {
      const definition = createRouteDefinition('/posts/:id', {
        id: required(),
      })

      expect(
        buildUrl({
          definition,
          args: {
            id: 'valid',
            invalidParam: 'should-be-ignored',
            anotherInvalid: 123,
          },
        }),
      ).toEqual({
        path: '/posts/valid',
        isCurrent: false,
      })
    })

    it('handles array arguments longer than parameter list', () => {
      const definition = createRouteDefinition('/posts/:id', {
        id: required(),
      })

      expect(
        buildUrl({ definition, args: ['valid', 'extra', 'ignored'] }),
      ).toEqual({
        path: '/posts/valid',
        isCurrent: false,
      })
    })

    it('handles mixed type values in arrays', () => {
      const definition = createRouteDefinition(
        '/posts/:postId/comments/:commentId',
        {
          postId: required(),
          commentId: required(),
        },
      )

      expect(buildUrl({ definition, args: ['string-id', 123] })).toEqual({
        path: '/posts/string-id/comments/123',
        isCurrent: false,
      })
    })

    it('handles complex realistic parameter scenarios', () => {
      const definition1 = createRouteDefinition('/pages/:page/*rest', {
        page: required(),
        rest: glob(),
      })

      expect(
        buildUrl({
          definition: definition1,
          args: {
            page: 'home',
            rest: ['section1', 'section2'],
          },
        }),
      ).toEqual({
        path: '/pages/home/section1/section2',
        isCurrent: false,
      })

      expect(
        buildUrl({
          definition: definition1,
          args: {
            page: 'home',
            rest: [],
          },
        }),
      ).toEqual({
        path: '/pages/home',
        isCurrent: false,
      })

      const definition2 = createRouteDefinition(
        '/posts/:postId/comments/:commentId',
        {
          postId: required(),
          commentId: required(),
        },
      )

      expect(
        buildUrl({
          definition: definition2,
          args: {
            postId: 'post-1',
            commentId: 'comment-1',
          },
        }),
      ).toEqual({
        path: '/posts/post-1/comments/comment-1',
        isCurrent: false,
      })

      expect(() =>
        buildUrl({
          definition: definition1,
          args: { rest: ['section1'] }, // missing page
        }),
      ).toThrow('Missing required parameters: page')

      expect(() =>
        buildUrl({
          definition: definition1,
          args: { page: 'home' }, // missing rest (glob)
        }),
      ).toThrow('Missing required parameters: rest')
    })
  })

  describe('parameter type coercion', () => {
    const definition = createRouteDefinition('/posts/:id', {
      id: required(),
    })

    it('converts number to string in object', () => {
      expect(buildUrl({ definition, args: { id: 0 } })).toEqual({
        path: '/posts/0',
        isCurrent: false,
      })

      expect(buildUrl({ definition, args: { id: -123 } })).toEqual({
        path: '/posts/-123',
        isCurrent: false,
      })

      expect(buildUrl({ definition, args: { id: 1.5 } })).toEqual({
        path: '/posts/1.5',
        isCurrent: false,
      })
    })

    it('converts number to string as direct argument', () => {
      expect(buildUrl({ definition, args: 0 })).toEqual({
        path: '/posts/0',
        isCurrent: false,
      })

      expect(buildUrl({ definition, args: -456 })).toEqual({
        path: '/posts/-456',
        isCurrent: false,
      })
    })

    it('handles special number values', () => {
      expect(
        buildUrl({ definition, args: { id: Number.MAX_SAFE_INTEGER } }),
      ).toEqual({
        path: '/posts/9007199254740991',
        isCurrent: false,
      })
    })
  })

  describe('single parameter special cases', () => {
    describe('single required parameter', () => {
      const definition = createRouteDefinition('/posts/:id', {
        id: required(),
      })

      it('throws specific error for single missing required parameter', () => {
        expect(() => buildUrl({ definition, args: null })).toThrow(
          'Missing required parameter: id',
        )
        expect(() => buildUrl({ definition, args: undefined })).toThrow(
          'Missing required parameter: id',
        )
      })
    })

    describe('single optional parameter', () => {
      const definition = createRouteDefinition('/posts/:id', {
        id: optional(),
      })

      it('removes optional parameter when null or undefined', () => {
        expect(buildUrl({ definition, args: null })).toEqual({
          path: '/posts',
          isCurrent: false,
        })

        expect(buildUrl({ definition, args: undefined })).toEqual({
          path: '/posts',
          isCurrent: false,
        })
      })

      it('handles single parameter with various argument types', () => {
        expect(buildUrl({ definition, args: 'test' })).toEqual({
          path: '/posts/test',
          isCurrent: false,
        })

        expect(buildUrl({ definition, args: 123 })).toEqual({
          path: '/posts/123',
          isCurrent: false,
        })

        expect(buildUrl({ definition, args: ['test'] })).toEqual({
          path: '/posts/test',
          isCurrent: false,
        })

        expect(buildUrl({ definition, args: [] })).toEqual({
          path: '/posts',
          isCurrent: false,
        })
      })
    })
  })

  describe('all optional parameters edge case', () => {
    const definition = createRouteDefinition('/posts/:cat/:subcat/:item', {
      cat: optional(),
      subcat: optional(),
      item: optional(),
    })

    it('removes all optional parameters when args are undefined', () => {
      expect(buildUrl({ definition, args: undefined })).toEqual({
        path: '/posts',
        isCurrent: false,
      })

      expect(buildUrl({ definition, args: null })).toEqual({
        path: '/posts',
        isCurrent: false,
      })

      expect(buildUrl({ definition, args: '' })).toEqual({
        path: '/posts',
        isCurrent: false,
      })
    })

    it('correctly processes parameters in reverse order for removal', () => {
      // This tests the reverse() logic in whenAllOptional
      expect(buildUrl({ definition })).toEqual({
        path: '/posts',
        isCurrent: false,
      })
    })
  })

  describe('string argument edge cases', () => {
    const definition = createRouteDefinition('/posts/:id', {
      id: required(),
    })

    it('handles empty string (treated as missing for required)', () => {
      expect(() => buildUrl({ definition, args: '' })).toThrow(
        'Missing required parameter: id',
      )
    })

    it('handles whitespace-only strings', () => {
      expect(buildUrl({ definition, args: '   ' })).toEqual({
        path: '/posts/   ',
        isCurrent: false,
      })
    })

    it('handles special characters in strings', () => {
      expect(buildUrl({ definition, args: 'test-with-dashes' })).toEqual({
        path: '/posts/test-with-dashes',
        isCurrent: false,
      })

      expect(buildUrl({ definition, args: 'test_with_underscores' })).toEqual({
        path: '/posts/test_with_underscores',
        isCurrent: false,
      })
    })
  })
})
