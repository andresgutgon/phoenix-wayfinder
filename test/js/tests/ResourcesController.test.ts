import { describe, expect, it } from 'vitest'
import ResourceController, {
  index,
  show,
  newMethod,
  create,
  edit,
  update,
  deleteMethod,
} from '../../../workbench/assets/js/actions/ResourcesController'

describe('ResourcesController RESTful routes', () => {
  describe('index', () => {
    it('generates correct URL for listing all resources', () => {
      expect(index.url()).toBe('/resources')
      expect(index().url).toBe('/resources')
    })

    it('has correct definition', () => {
      expect(index.definition).toEqual({
        url: '/resources',
        methods: ['get'],
      })
    })

    it('supports GET method', () => {
      expect(index.get().method).toBe('get')
      expect(index.get().url).toBe('/resources')
    })
  })

  describe('show', () => {
    it('generates correct URL for showing a specific resource', () => {
      expect(show.url({ id: '123' })).toBe('/resources/123')
      expect(show.url('456')).toBe('/resources/456')
      expect(show({ id: '789' }).url).toBe('/resources/789')
      expect(show('abc').url).toBe('/resources/abc')
    })

    it('has correct definition', () => {
      expect(show.definition).toEqual({
        url: '/resources/:id',
        methods: ['get'],
      })
    })

    it('supports GET method', () => {
      expect(show.get({ id: '123' }).method).toBe('get')
      expect(show.get({ id: '123' }).url).toBe('/resources/123')
      expect(show.get('456').url).toBe('/resources/456')
    })
  })

  describe('new', () => {
    it('generates correct URL for new resource form', () => {
      expect(newMethod.url()).toBe('/resources/new')
      expect(newMethod().url).toBe('/resources/new')
    })

    it('has correct definition', () => {
      expect(newMethod.definition).toEqual({
        url: '/resources/new',
        methods: ['get'],
      })
    })

    it('supports GET method', () => {
      expect(newMethod.get().method).toBe('get')
      expect(newMethod.get().url).toBe('/resources/new')
    })
  })

  describe('create', () => {
    it('generates correct URL for creating a resource', () => {
      expect(create.url()).toBe('/resources')
      expect(create().url).toBe('/resources')
    })

    it('has correct definition', () => {
      expect(create.definition).toEqual({
        url: '/resources',
        methods: ['post'],
      })
    })

    it('supports POST method', () => {
      expect(create.post().method).toBe('post')
      expect(create.post().url).toBe('/resources')
    })
  })

  describe('edit', () => {
    it('generates correct URL for editing a specific resource', () => {
      expect(edit.url({ id: '123' })).toBe('/resources/123/edit')
      expect(edit.url('456')).toBe('/resources/456/edit')
      expect(edit({ id: '789' }).url).toBe('/resources/789/edit')
      expect(edit('abc').url).toBe('/resources/abc/edit')
    })

    it('has correct definition', () => {
      expect(edit.definition).toEqual({
        url: '/resources/:id/edit',
        methods: ['get'],
      })
    })

    it('supports GET method', () => {
      expect(edit.get({ id: '123' }).method).toBe('get')
      expect(edit.get({ id: '123' }).url).toBe('/resources/123/edit')
      expect(edit.get('456').url).toBe('/resources/456/edit')
    })
  })

  describe('update', () => {
    it('generates correct URL for updating a specific resource', () => {
      expect(update.url({ id: '123' })).toBe('/resources/123')
      expect(update.url('456')).toBe('/resources/456')
      expect(update({ id: '789' }).url).toBe('/resources/789')
      expect(update('abc').url).toBe('/resources/abc')
    })

    it('has correct definition', () => {
      expect(update.definition).toEqual({
        methods: ['patch', 'put'],
        url: '/resources/:id',
      })
    })

    it('supports PATCH method', () => {
      expect(update.patch({ id: '123' }).method).toBe('patch')
      expect(update.patch({ id: '123' }).url).toBe('/resources/123')
      expect(update.patch('456').url).toBe('/resources/456')
    })

    it('supports PUT method', () => {
      expect(update.put({ id: '123' }).method).toBe('put')
      expect(update.put({ id: '123' }).url).toBe('/resources/123')
      expect(update.put('456').url).toBe('/resources/456')
    })
  })

  describe('delete', () => {
    it('generates correct URL for deleting a specific resource', () => {
      expect(deleteMethod.url({ id: '123' })).toBe('/resources/123')
      expect(deleteMethod.url('456')).toBe('/resources/456')
      expect(deleteMethod({ id: '789' }).url).toBe('/resources/789')
      expect(deleteMethod('abc').url).toBe('/resources/abc')
    })

    it('has correct definition', () => {
      expect(deleteMethod.definition).toEqual({
        url: '/resources/:id',
        methods: ['delete'],
      })
    })

    it('supports DELETE method', () => {
      expect(deleteMethod.delete({ id: '123' }).method).toBe('delete')
      expect(deleteMethod.delete({ id: '123' }).url).toBe('/resources/123')
      expect(deleteMethod.delete('456').url).toBe('/resources/456')
    })
  })

  describe('parameter handling', () => {
    it('handles different parameter formats for routes with :id', () => {
      const resourceActions = [show, edit, update, deleteMethod]

      resourceActions.forEach((action) => {
        expect(action.url({ id: 'test-id' })).toContain('test-id')
        expect(action.url('string-id')).toContain('string-id')
        expect(action.url(123)).toContain('123')
        expect(action.url(['array-id'])).toContain('array-id')
      })
    })
  })

  it('exports forbidden JS methods under ResourceController namespace', () => {
    expect(ResourceController.create).toBeDefined()
    expect(ResourceController.delete).toBeDefined()
  })
})
