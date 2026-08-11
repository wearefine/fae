<script setup>
import { computed, ref } from 'vue'
import { Link } from '@inertiajs/vue3'

import FaeBreadcrumbs from '../../components/FaeBreadcrumbs.vue'
import FaeIndexTable from '../../components/FaeIndexTable.vue'
import { useFaeComponent } from '../../composables/useFaeComponent.js'

// Inertia passes shared props (currentUser, flash, nav) to every page. This
// page reads none of them, and its template has multiple root nodes, so
// without this Vue tries to apply them as DOM attributes and warns.
defineOptions({ inheritAttrs: false })

// Fae::BaseController#index is generic across every model, so this page is
// driven entirely by props rather than being generated per-resource.
const props = defineProps({
  title: { type: String, required: true },
  newPath: { type: String, default: null },
  newButtonText: { type: String, default: 'Add' },
  csvPath: { type: String, default: null },
  csvButtonText: { type: String, default: 'CSV Export' },
  columns: { type: Array, default: () => [] },
  rows: { type: Array, default: () => [] },
  // A sectioned index: [{ title, rows }]. When present it replaces `rows`, and
  // every section gets its own independently reorderable table -- the shape
  // the articles screen has always had, grouped by category.
  groups: { type: Array, default: null },
  // Set by the controller when the model has a position column, matching the
  // js-sort-row tables on the Slim screens.
  sortable: { type: Boolean, default: false },
  sortPath: { type: String, default: null },
  sortParam: { type: String, default: null },
  // False while this resource's form still renders Slim -- see FaeIndexTable.
  inertiaLinks: { type: Boolean, default: false },
})

const count = computed(() =>
  props.groups
    ? props.groups.reduce((total, group) => total + group.rows.length, 0)
    : props.rows.length
)

// Collapsed sections, keyed by group title. The legacy grouped index shipped a
// "Close All" control over the same accordions.
const collapsed = ref(new Set())
const FaeIndexTableComponent = useFaeComponent('FaeIndexTable', FaeIndexTable)
const allCollapsed = computed(
  () => !!props.groups?.length && collapsed.value.size === props.groups.length
)
const csvDownloading = ref(false)

function toggle(title) {
  const next = new Set(collapsed.value)
  if (next.has(title)) next.delete(title)
  else next.add(title)
  collapsed.value = next
}

function toggleAll() {
  collapsed.value = allCollapsed.value
    ? new Set()
    : new Set(props.groups.map((group) => group.title))
}

function csvFilenameFromHeader(contentDisposition) {
  const value = String(contentDisposition || '')
  const utf8Match = value.match(/filename\*=UTF-8''([^;]+)/i)
  if (utf8Match?.[1]) return decodeURIComponent(utf8Match[1])

  const quotedMatch = value.match(/filename="([^"]+)"/i)
  if (quotedMatch?.[1]) return quotedMatch[1]

  const plainMatch = value.match(/filename=([^;]+)/i)
  if (plainMatch?.[1]) return plainMatch[1].trim()

  return 'export.csv'
}

async function downloadCsv() {
  if (!props.csvPath || csvDownloading.value) return

  csvDownloading.value = true
  try {
    const response = await fetch(props.csvPath, {
      method: 'GET',
      credentials: 'same-origin',
      headers: { 'X-Requested-With': 'XMLHttpRequest' },
    })

    if (!response.ok) throw new Error(`CSV download failed (${response.status})`)

    const blob = await response.blob()
    const filename = csvFilenameFromHeader(response.headers.get('content-disposition'))
    const url = window.URL.createObjectURL(blob)

    const link = document.createElement('a')
    link.href = url
    link.download = filename
    document.body.appendChild(link)
    link.click()
    link.remove()
    window.URL.revokeObjectURL(url)
  } catch (error) {
    // Fallback keeps export usable even if fetch/blob is unavailable.
    window.open(props.csvPath, '_blank', 'noopener')
  } finally {
    csvDownloading.value = false
  }
}
</script>

<template>
  <div class="fae-page-header">
    <div class="fae-page-header__title -stacked">
      <FaeBreadcrumbs />

      <div class="fae-page-header__heading">
        <h1>{{ title }}</h1>
        <span v-if="count" class="fae-page-header__count">{{ count }}</span>
      </div>
    </div>

    <div class="fae-page-header__actions">
      <button v-if="groups?.length" type="button" class="fae-button -secondary" @click="toggleAll">
        {{ allCollapsed ? 'Open all' : 'Close all' }}
      </button>

      <button
        v-if="csvPath"
        type="button"
        class="fae-button -secondary"
        :disabled="csvDownloading"
        @click="downloadCsv"
      >
        {{ csvDownloading ? 'Exporting...' : csvButtonText }}
      </button>

      <component :is="inertiaLinks ? Link : 'a'" v-if="newPath" :href="newPath" class="fae-button">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
          stroke-linecap="round" aria-hidden="true">
          <path d="M12 5v14M5 12h14" />
        </svg>
        {{ newButtonText }}
      </component>
    </div>
  </div>

  <template v-if="groups">
    <section v-for="group in groups" :key="group.title" class="fae-index-group">
      <button
        type="button"
        class="fae-index-group__toggle"
        :aria-expanded="!collapsed.has(group.title)"
        @click="toggle(group.title)"
      >
        <svg
          class="fae-index-group__chevron"
          :class="{ '-collapsed': collapsed.has(group.title) }"
          viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
          stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"
        >
          <path d="M6 9l6 6 6-6" />
        </svg>
        <h2>{{ group.title }}</h2>
        <span class="fae-index-group__count">{{ group.rows.length }}</span>
      </button>

      <!-- v-show, not v-if: collapsing must not throw away a table's local
           drag state, and these lists are small. -->
      <component
        :is="FaeIndexTableComponent"
        v-show="!collapsed.has(group.title)"
        :rows="group.rows"
        :columns="columns"
        :sortable="sortable"
        :sort-path="sortPath"
        :sort-param="sortParam"
        :inertia-links="inertiaLinks"
      />
    </section>
  </template>

  <component
    :is="FaeIndexTableComponent"
    v-else
    :rows="rows"
    :columns="columns"
    :sortable="sortable"
    :sort-path="sortPath"
    :sort-param="sortParam"
    :inertia-links="inertiaLinks"
  />
</template>
