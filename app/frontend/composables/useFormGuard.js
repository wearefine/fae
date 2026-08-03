import { onBeforeUnmount, onMounted } from 'vue'
import { router } from '@inertiajs/vue3'

const DRAFT_MESSAGE =
  'You will lose any changes to this draft. Are you sure you want to cancel?'

const UNSAVED_MESSAGE =
  'You have unsaved changes. Are you sure you want to leave this page?'

/**
 * Cancel + unload behaviour for a Fae form.
 *
 * Ports app/assets/javascripts/fae/form/_cancel.js. The behaviour it guards is
 * Fae's draft-on-new: Fae::BaseController#new saves the record immediately
 * (skipping validation) and redirects to #edit with ?draft=true, so the row
 * already exists in the database while the user is still filling it in.
 * Backing out of that form therefore has to delete the record, or every
 * abandoned "New" click would leave a blank row behind.
 *
 * An existing record is guarded too, but only once something has actually been
 * typed: leaving it costs the edits rather than stranding a row, so there is
 * nothing to delete and nothing to warn about on an untouched form.
 *
 * Two escape routes are covered:
 *   - Cancel, which confirms and then DELETEs the draft.
 *   - Navigating away by any other means, which warns first. beforeunload
 *     handles full page loads; the Inertia router event handles client-side
 *     visits, which beforeunload never sees.
 *
 * @param {object} props the Fae/Form page props (draft, deletePath, indexPath)
 * @param {() => boolean} hasUnsavedChanges the form's own dirty state, plus any
 *   nested form's -- see useUnsavedChanges
 */
export function useFormGuard(props, hasUnsavedChanges = () => false) {
  // Set once the user has either saved or confirmed they want to discard, so
  // the resulting navigation is not itself challenged.
  let unloadAllowed = false

  function allowUnload() {
    unloadAllowed = true
  }

  function guarding() {
    if (unloadAllowed) return false

    // A draft is worth challenging even untouched: walking away from one
    // strands the record #new created.
    return props.draft || hasUnsavedChanges()
  }

  function confirmMessage() {
    return props.draft ? DRAFT_MESSAGE : UNSAVED_MESSAGE
  }

  function cancel() {
    if (guarding() && !window.confirm(confirmMessage())) return

    allowUnload()

    // Only a draft is deleted on the way out; an existing record is left as it
    // was last saved. Fae::BaseController#destroy redirects to the index, so
    // there is nothing to follow up with here.
    if (props.draft && props.deletePath) router.delete(props.deletePath)
    else router.visit(props.indexPath)
  }

  function onBeforeUnload(event) {
    if (!guarding()) return
    event.preventDefault()
    // Required by Chrome to trigger the dialog; the string is ignored.
    event.returnValue = ''
  }

  // Returning false from a `before` listener aborts the visit, which is how an
  // in-app navigation gets the same warning a page unload would give.
  let stopInertiaGuard

  onMounted(() => {
    window.addEventListener('beforeunload', onBeforeUnload)
    stopInertiaGuard = router.on('before', (event) => {
      // Only a GET is a navigation away from here. Everything else is this
      // page doing its job -- saving the form, deleting the draft, or a nested
      // table writing a row -- and each of those already calls allowUnload or
      // lands back on this same screen.
      if (event.detail.visit.method !== 'get') return
      if (!guarding()) return
      return window.confirm(confirmMessage())
    })
  })

  onBeforeUnmount(() => {
    window.removeEventListener('beforeunload', onBeforeUnload)
    stopInertiaGuard?.()
  })

  return { cancel, allowUnload }
}
