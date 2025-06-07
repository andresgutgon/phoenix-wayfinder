import { expect, test } from 'vitest'
import DisallowedMethodNameController, {
  deleteMethod,
} from '../../../workbench/assets/js/actions/DisallowedMethodNameController'

test('will append `method` to invalid methods', () => {
  expect(deleteMethod.url().path).toBe('/disallowed/delete')
  expect(DisallowedMethodNameController.delete.url().path).toBe('/disallowed/delete')
})
