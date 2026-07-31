<script setup>
import { computed } from 'vue'
import { Link, router } from '@inertiajs/vue3'

import { useSortableRows } from '../composables/useSortableRows.js'

/**
 * One index table. Extracted from pages/Fae/Index.vue because a grouped index
 * renders several of these, and each group reorders independently -- the
 * legacy screens gave every category its own js-sort-row table for exactly the
 * same reason.
 */
const props = defineProps({
  rows: { type: Array, default: () => [] },
  columns: { type: Array, default: () => [] },
  sortable: { type: Boolean, default: false },
  sortPath: { type: String, default: null },
  sortParam: { type: String, default: null },
  // Anchors stay plain <a> until the target screen is converted -- an Inertia
  // visit to a Slim page pops Inertia's error modal.
  inertiaLinks: { type: Boolean, default: false },
})

// The table renders `items`, not `rows`: dragging reorders it live, and props
// are read-only.
const {
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
} = useSortableRows(props)

const linkTag = computed(() => (props.inertiaLinks ? Link : 'a'))

function destroy(row) {
  if (!window.confirm(`Delete "${row.label}"? This cannot be undone.`)) return
  router.delete(row.deletePath, { preserveScroll: true })
}
</script>

<template>
  <!-- Single root: a grouped index toggles whole tables with v-show, and a
       directive on a fragment root would be dropped. -->
  <div>
    <p v-if="failed" class="fae-alert -alert" role="alert">
      That order could not be saved, so the previous order has been restored.
    </p>

    <div class="fae-table-wrap">
      <table class="fae-table">
        <thead>
          <tr>
            <th v-if="sortable" class="fae-table__handle">
              <span class="fae-sr-only">Reorder</span>
            </th>
            <th v-for="col in columns" :key="col.key">{{ col.label }}</th>
            <th class="fae-table__actions"><span class="fae-sr-only">Actions</span></th>
          </tr>
        </thead>

        <tbody>
          <!--
            The row is the thing dragged, so it doubles as its own drag image,
            but [draggable] only switches on while the handle is held --
            otherwise selecting text in a cell would begin a reorder.
          -->
          <tr
            v-for="row in items"
            :key="row.id"
            :draggable="sortable && handleId === row.id"
            :class="{ '-dragging': draggingId === row.id }"
            @dragstart="onDragStart(row, $event)"
            @dragover.prevent="onDragOver(row)"
            @drop.prevent
            @dragend="onDragEnd"
          >
            <td v-if="sortable" class="fae-table__handle">
              <button
                type="button"
                class="fae-drag-handle"
                :aria-label="`Reorder ${row.label}`"
                @mousedown="onHandleDown(row)"
                @mouseup="onHandleUp"
                @keydown="onHandleKeydown(row, $event)"
              >
                <svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
                  <circle cx="9" cy="6" r="1.5" />
                  <circle cx="15" cy="6" r="1.5" />
                  <circle cx="9" cy="12" r="1.5" />
                  <circle cx="15" cy="12" r="1.5" />
                  <circle cx="9" cy="18" r="1.5" />
                  <circle cx="15" cy="18" r="1.5" />
                </svg>
              </button>
            </td>

            <td v-for="(col, i) in columns" :key="col.key">
              <component :is="linkTag" v-if="i === 0" class="fae-table__link" :href="row.editPath">
                {{ row.cells[col.key] }}
              </component>
              <template v-else>{{ row.cells[col.key] }}</template>
            </td>

            <td class="fae-table__actions">
              <button type="button" class="fae-button -danger -sm" @click="destroy(row)">
                Delete
              </button>
            </td>
          </tr>

          <tr v-if="!items.length">
            <td class="fae-table__empty" :colspan="columns.length + (sortable ? 2 : 1)">
              No items found
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>
