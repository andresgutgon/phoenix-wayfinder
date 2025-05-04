import { expect, test } from 'vitest'
import DisallowedMethodNameController, {
  deleteMethod,
} from '../../support/workbench/assets/js/actions/DisallowedMethodNameController'

test('will append `method` to invalid methods', () => {
  expect(deleteMethod.url()).toBe('/disallowed/delete')
  // FIXME: export alias with original `delete` controller action
  /* expect(DisallowedMethodNameController.delete.url()).toBe('/disallowed/delete') */
})
