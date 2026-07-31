import { ref, watch } from 'vue'

/**
 * Drag-to-reorder for a Fae index table.
 *
 * Behavioural parity with the legacy jQuery UI implementation in
 * app/assets/javascripts/fae/_tables.js: dragging is initiated from a handle
 * rather than anywhere on the row, and the new order is persisted by POSTing
 * every id, in order, to Fae::UtilitiesController#sort, which rewrites each
 * record's `position` to its index in that list.
 *
 * Uses native HTML5 drag and drop rather than a library so the engine stays
 * dependency-free. Native DnD does not fire for touch, which is why the handle
 * also responds to the arrow keys -- that covers keyboard and touch users, and
 * is more than the jQuery version offered.
 *
 * @param {object} props the Fae/Index page props (rows, sortPath, sortParam)
 */
export function useSortableRows(props) {
  // A local copy, because dragging reorders the list live and props are
  // read-only. Re-synced whenever the server sends a fresh set of rows.
  const items = ref([...props.rows])
  watch(() => props.rows, (rows) => { items.value = [...rows] })

  // The row being dragged, and the row whose handle is currently held. The
  // latter gates [draggable] on the <tr>: the row itself is the drag image so
  // the whole row follows the cursor, but a drag may only start from the
  // handle, otherwise selecting cell text would begin a reorder.
  const draggingId = ref(null)
  const handleId = ref(null)
  const failed = ref(false)

  // Order at the start of the interaction, so a drag that ends where it began
  // makes no request, and a failed save can be rolled back.
  let orderBeforeDrag = []

  function indexOf(id) {
    return items.value.findIndex((row) => row.id === id)
  }

  function move(from, to) {
    if (from < 0 || to < 0 || to >= items.value.length || from === to) return false
    const next = [...items.value]
    next.splice(to, 0, ...next.splice(from, 1))
    items.value = next
    return true
  }

  function orderChanged() {
    return items.value.some((row, i) => row.id !== orderBeforeDrag[i]?.id)
  }

  function onHandleDown(row) {
    handleId.value = row.id
  }

  // A drag ends in dragend, not mouseup, so this only fires when the handle
  // was pressed and released without dragging. Without it the row would stay
  // draggable, and the next text selection inside it would start a reorder.
  function onHandleUp() {
    if (draggingId.value === null) handleId.value = null
  }

  function onDragStart(row, event) {
    // Guards against a drag started from anywhere but the handle: browsers
    // evaluate [draggable] before mousedown handlers in some edge cases.
    if (handleId.value !== row.id) {
      event.preventDefault()
      return
    }

    draggingId.value = row.id
    orderBeforeDrag = [...items.value]
    event.dataTransfer.effectAllowed = 'move'
    // Firefox refuses to start a drag unless some data is set.
    event.dataTransfer.setData('text/plain', String(row.id))
  }

  // Reorders live as the pointer passes over other rows, so the table always
  // shows the result rather than an insertion marker.
  function onDragOver(row) {
    if (draggingId.value === null || draggingId.value === row.id) return
    move(indexOf(draggingId.value), indexOf(row.id))
  }

  function onDragEnd() {
    const changed = draggingId.value !== null && orderChanged()
    draggingId.value = null
    handleId.value = null
    if (changed) persist()
  }

  function onHandleKeydown(row, event) {
    const offset = { ArrowUp: -1, ArrowDown: 1 }[event.key]
    if (offset === undefined) return

    event.preventDefault()
    orderBeforeDrag = [...items.value]
    const from = indexOf(row.id)
    if (move(from, from + offset)) persist()
  }

  async function persist() {
    const order = [...items.value]
    const body = new URLSearchParams()
    order.forEach((row) => body.append(`${props.sortParam}[]`, row.id))

    try {
      const response = await fetch(props.sortPath, {
        method: 'POST',
        credentials: 'same-origin',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
          // #sort only writes positions for XHR requests.
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': csrfToken(),
        },
        body,
      })
      if (!response.ok) throw new Error(`Sort failed: ${response.status}`)
      failed.value = false
    } catch (error) {
      // Roll back rather than leave the table showing an order the database
      // does not have.
      items.value = orderBeforeDrag
      failed.value = true
      console.error(error)
    }
  }

  function csrfToken() {
    return document.querySelector('meta[name="csrf-token"]')?.content
  }

  return {
    items,
    draggingId,
    handleId,
    failed,
    onHandleDown,
    onHandleUp,
    onHandleKeydown,
    onDragStart,
    onDragOver,
    onDragEnd,
  }
}
