<script setup>
import { watch } from 'vue'

import FaeBreadcrumbs from '../../components/FaeBreadcrumbs.vue'
import FaeFilterForm from '../../components/FaeFilterForm.vue'
import FaePagination from '../../components/FaePagination.vue'
import FaeSortHeader from '../../components/FaeSortHeader.vue'
import { useIndexQuery } from '../../composables/useIndexQuery.js'

defineOptions({ inheritAttrs: false })

const props = defineProps({
  title: { type: String, required: true },
  indexPath: { type: String, required: true },
  filters: { type: Object, required: true },
  sort: { type: Object, default: () => ({ by: '', direction: 'asc' }) },
  rows: { type: Array, default: () => [] },
  pagination: { type: Object, required: true },
  emptyText: { type: String, default: 'No changes' },
})

const { filters: queryFilters, applyFilters, resetFilters, goToPage, applySort } = useIndexQuery(
  props.indexPath,
  props.filters.values || {}
)

watch(
  () => props.sort,
  (next) => {
    if (next?.by) queryFilters.sort_by = next.by
    if (next?.direction) queryFilters.sort_direction = next.direction
  },
  { deep: true, immediate: true }
)

function sortBy(key) {
  applySort(key)
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
      :search="true"
      search-placeholder="Search by Keyword"
      @apply="applyFilters"
      @reset="resetFilters"
    />

    <div class="fae-table-wrap">
      <table class="fae-table">
        <thead>
          <tr>
            <FaeSortHeader
              label="User"
              sort-key="user.first_name"
              :sort-by="queryFilters.sort_by || ''"
              :sort-direction="queryFilters.sort_direction || 'asc'"
              @sort="sortBy"
            />
            <FaeSortHeader
              label="Item"
              sort-key="changeable_type"
              :sort-by="queryFilters.sort_by || ''"
              :sort-direction="queryFilters.sort_direction || 'asc'"
              @sort="sortBy"
            />
            <FaeSortHeader
              label="Type"
              sort-key="change_type"
              :sort-by="queryFilters.sort_by || ''"
              :sort-direction="queryFilters.sort_direction || 'asc'"
              @sort="sortBy"
            />
            <th>Attrs</th>
            <FaeSortHeader
              label="Modified"
              sort-key="updated_at"
              :sort-by="queryFilters.sort_by || ''"
              :sort-direction="queryFilters.sort_direction || 'asc'"
              @sort="sortBy"
            />
          </tr>
        </thead>

        <tbody>
          <tr v-if="!rows.length">
            <td class="fae-table__empty" colspan="5">{{ emptyText }}</td>
          </tr>

          <tr v-for="row in rows" :key="row.id">
            <td>{{ row.user }}</td>
            <td>
              <a v-if="row.itemPath" :href="row.itemPath" class="fae-table__link">{{ row.itemText }}</a>
              <span v-else>{{ row.itemText }}</span>
            </td>
            <td>{{ row.type }}</td>
            <td>{{ row.attrs }}</td>
            <td>{{ row.modified }}</td>
          </tr>
        </tbody>
      </table>
    </div>

    <FaePagination :pagination="pagination" @change="goToPage" />
  </div>
</template>
