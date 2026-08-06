import { reactive, watch } from 'vue'
import { router } from '@inertiajs/vue3'

export function useIndexQuery(indexPath, initialValues = {}) {
  const filters = reactive({ ...(initialValues || {}) })

  watch(
    () => initialValues,
    (next) => {
      Object.keys(filters).forEach((key) => {
        if (!(key in (next || {}))) delete filters[key]
      })
      Object.assign(filters, next || {})
    },
    { deep: true }
  )

  function cleaned(values) {
    return Object.fromEntries(
      Object.entries(values || {}).filter(([, value]) => value !== null && value !== undefined && value !== '')
    )
  }

  function visit(extra = {}) {
    router.get(indexPath, { ...cleaned(filters), ...cleaned(extra) }, {
      preserveState: true,
      preserveScroll: true,
      replace: true,
    })
  }

  function applyFilters(next) {
    Object.keys(filters).forEach((key) => {
      if (!(key in (next || {}))) delete filters[key]
    })
    Object.assign(filters, next || {})
    visit({ page: '' })
  }

  function resetFilters() {
    Object.keys(filters).forEach((key) => delete filters[key])
    visit()
  }

  function goToPage(page) {
    visit({ page })
  }

  function applySort(sortBy) {
    const currentBy = filters.sort_by
    const currentDirection = (filters.sort_direction || 'asc').toLowerCase()

    const nextDirection = currentBy === sortBy && currentDirection === 'asc' ? 'desc' : 'asc'
    filters.sort_by = sortBy
    filters.sort_direction = nextDirection

    visit({ page: '' })
  }

  return { filters, applyFilters, resetFilters, goToPage, applySort }
}
