import { inject, onBeforeUnmount, provide } from 'vue'

const UNSAVED_CHANGES = Symbol('fae:unsaved-changes')

/**
 * Collects the dirty state of the forms nested inside a Fae form.
 *
 * A Fae form screen is rarely one form: every nested table opens an add/edit
 * form of its own, with its own useForm state, inside the parent's. Both the
 * navigation guard and the parent's Save button need to know whether any of
 * them is holding input the user has not committed -- which is what
 * _preventFormSaveDueToNestedForm did by serializing the visible nested form.
 *
 * Called by the page component; returns a plain function rather than a
 * computed because every caller reads it imperatively, at the moment it has to
 * decide whether to confirm.
 */
export function provideUnsavedChanges() {
  const sources = new Set()

  provide(UNSAVED_CHANGES, (isDirty) => {
    sources.add(isDirty)
    return () => sources.delete(isDirty)
  })

  return () => [...sources].some((isDirty) => isDirty())
}

/**
 * Registers one form's dirty state with the page above it.
 *
 * @param {() => boolean} isDirty
 */
export function registerUnsavedChanges(isDirty) {
  // Absent when the component is rendered outside a Fae form page, which is
  // legal -- a nested table is only ever guarded by the form containing it.
  const register = inject(UNSAVED_CHANGES, null)
  if (!register) return

  const unregister = register(isDirty)
  onBeforeUnmount(unregister)
}
