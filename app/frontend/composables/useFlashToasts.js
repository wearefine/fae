import { onBeforeUnmount, ref, watch } from 'vue'
import { usePage } from '@inertiajs/vue3'

// Matches the legacy timings in fae/navigation/_navigation.js#showToasts.
const DURATION = 5000
const STAGGER = 100

/**
 * Turns Inertia's shared `flash` prop into a self-dismissing toast queue.
 *
 * Ports Fae.navigation.showToasts. The Slim stack rendered every flash entry
 * as a hidden `.flash-toast[data-message]` element and jQuery moved it into a
 * fixed container, faded it in, and removed it after five seconds. Here the
 * flash arrives as a prop instead of markup, so the queue is reactive state
 * and the animation is a <TransitionGroup>, but the behaviour is the same:
 * messages appear staggered and disappear on their own.
 *
 * Flash props are replaced on every Inertia visit, so the watcher fires once
 * per navigation -- including a redirect back to the same URL after a failed
 * save, which is exactly when the alert needs to show again.
 */
export function useFlashToasts() {
  const page = usePage()
  const toasts = ref([])

  // Tracked so a navigation away mid-timeout cannot dismiss a toast belonging
  // to a later page, or fire against an unmounted component.
  const timers = new Set()
  let nextId = 0

  function later(fn, delay) {
    const timer = setTimeout(() => {
      timers.delete(timer)
      fn()
    }, delay)
    timers.add(timer)
  }

  function show(type, message) {
    const id = (nextId += 1)
    toasts.value = [...toasts.value, { id, type, message }]
    later(() => {
      toasts.value = toasts.value.filter((toast) => toast.id !== id)
    }, DURATION)
  }

  watch(
    () => page.props.flash,
    (flash) => {
      // The prop is keyed by flash type, so entries are already unique -- the
      // legacy dedupe existed only because several partials could each render
      // the same message into the DOM.
      Object.entries(flash || {}).forEach(([type, message], index) => {
        if (index === 0) show(type, message)
        else later(() => show(type, message), index * STAGGER)
      })
    },
    { immediate: true }
  )

  onBeforeUnmount(() => {
    timers.forEach(clearTimeout)
    timers.clear()
  })

  return { toasts }
}
