<script setup>
import { ref, watch } from 'vue'
import { Link, router } from '@inertiajs/vue3'

import FaeBooleanToggle from '@fae/components/FaeBooleanToggle.vue'

defineOptions({ inheritAttrs: false })

const props = defineProps({
  title: { type: String, required: true },
  newPath: { type: String, default: null },
  newButtonText: { type: String, default: 'Add' },
  rows: { type: Array, default: () => [] },
})

const rowsState = ref(props.rows.map((row) => ({ ...row })))

watch(
  () => props.rows,
  (next) => {
    rowsState.value = next.map((row) => ({ ...row }))
  },
  { deep: true }
)

function destroy(row) {
  if (!window.confirm(`Delete "${row.label}"? This cannot be undone.`)) return
  router.delete(row.deletePath, { preserveScroll: true })
}

function updateToggle(rowId, key, value) {
  const row = rowsState.value.find((entry) => entry.id === rowId)
  if (!row) return
  row[key] = value
}
</script>

<template>
  <div>
    <div class="fae-page-header">
      <div class="fae-page-header__title">
        <h1>{{ title }}</h1>
      </div>

      <div class="fae-page-header__actions">
        <Link v-if="newPath" :href="newPath" class="fae-button">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true">
            <path d="M12 5v14M5 12h14" />
          </svg>
          {{ newButtonText }}
        </Link>
      </div>
    </div>

    <div class="fae-table-wrap">
      <table class="fae-table">
        <thead>
          <tr>
            <th>Name</th>
            <th>Modified</th>
            <th>On Stage</th>
            <th>On Prod</th>
            <th class="fae-table__actions"><span class="fae-sr-only">Actions</span></th>
          </tr>
        </thead>

        <tbody>
          <tr v-if="!rowsState.length">
            <td class="fae-table__empty" colspan="5">No items found</td>
          </tr>

          <tr v-for="row in rowsState" :key="row.id">
            <td>
              <Link class="fae-table__link" :href="row.editPath">{{ row.label }}</Link>
            </td>
            <td>{{ row.modified }}</td>
            <td>
              <FaeBooleanToggle
                :model-value="row.onStage"
                :path="row.onStageTogglePath"
                @update:model-value="updateToggle(row.id, 'onStage', $event)"
              />
            </td>
            <td>
              <FaeBooleanToggle
                :model-value="row.onProd"
                :path="row.onProdTogglePath"
                @update:model-value="updateToggle(row.id, 'onProd', $event)"
              />
            </td>
            <td class="fae-table__actions">
              <button type="button" class="fae-button -danger -sm" @click="destroy(row)">
                Delete
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>