<script setup>
import { ref, watch } from 'vue'

import FaeBreadcrumbs from '../../components/FaeBreadcrumbs.vue'
import FaeFilterForm from '../../components/FaeFilterForm.vue'
import FaeAltTextEditor from '../../components/FaeAltTextEditor.vue'
import FaePagination from '../../components/FaePagination.vue'
import { useIndexQuery } from '../../composables/useIndexQuery.js'

defineOptions({ inheritAttrs: false })

const props = defineProps({
  title: { type: String, required: true },
  indexPath: { type: String, required: true },
  filters: { type: Object, required: true },
  rows: { type: Array, default: () => [] },
  pagination: { type: Object, required: true },
  canGenerateAlt: { type: Boolean, default: false },
  generateAltPath: { type: String, required: true },
  emptyText: { type: String, default: 'No items found' },
})

const { filters: queryFilters, applyFilters, resetFilters, goToPage } = useIndexQuery(
  props.indexPath,
  props.filters.values || {}
)

const rowsState = ref(props.rows.map((row) => ({ ...row })))

watch(
  () => props.rows,
  (next) => {
    rowsState.value = next.map((row) => ({ ...row }))
  },
  { deep: true }
)

function updateRowAlt(id, alt) {
  const row = rowsState.value.find((candidate) => candidate.id === id)
  if (row) row.alt = alt
}
</script>

<template>
  <div>
    <div class="fae-page-header">
      <div class="fae-page-header__title -stacked">
        <FaeBreadcrumbs />
        <h1>{{ title }}</h1>
      </div>
    </div>

    <FaeFilterForm
      :title="props.filters.title"
      :fields="props.filters.fields"
      :values="queryFilters"
      :search="false"
      @apply="applyFilters"
      @reset="resetFilters"
    />

    <div class="fae-table-wrap fae-alt-texts-table">
      <table class="fae-table">
        <thead>
          <tr>
            <th>ID</th>
            <th>Image</th>
            <th>Parent Model</th>
            <th>Parent ID</th>
            <th>Attached As</th>
            <th class="fae-alt-texts-table__alt-col">Alt Text</th>
            <th>Size</th>
            <th>Modified</th>
          </tr>
        </thead>

        <tbody>
          <tr v-if="!rowsState.length">
            <td class="fae-table__empty" colspan="8">{{ emptyText }}</td>
          </tr>

          <tr v-for="row in rowsState" :key="row.id">
            <td>{{ row.id }}</td>
            <td>
              <img v-if="row.imageUrl" class="fae-alt-texts-table__thumb" :src="row.imageUrl" alt="">
            </td>
            <td>{{ row.parentModel }}</td>
            <td>{{ row.parentId || '' }}</td>
            <td>{{ row.attachedAs }}</td>
            <td>
              <FaeAltTextEditor
                :row="row"
                :can-generate-alt="canGenerateAlt"
                :generate-alt-path="generateAltPath"
                @updated="updateRowAlt(row.id, $event)"
              />
            </td>
            <td>{{ row.fileSize }}</td>
            <td>{{ row.modified }}</td>
          </tr>
        </tbody>
      </table>
    </div>

    <FaePagination :pagination="pagination" @change="goToPage" />
  </div>
</template>
