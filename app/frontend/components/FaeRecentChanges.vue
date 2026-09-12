<script setup>
import { useFaeFormContext } from '../composables/useFaeFormContext.js'

defineOptions({ name: 'FaeRecentChanges' })

const context = useFaeFormContext()
const changes = context.recentChanges
</script>

<template>
  <section
    v-if="changes"
    id="recent_changes"
    class="fae-form-section"
    data-fae-section="recent_changes"
  >
    <h2 class="fae-form-section__title">{{ changes.title }}</h2>

    <div class="fae-table-wrap">
      <table class="fae-table">
        <thead>
          <tr>
            <th>{{ changes.columns.user }}</th>
            <th>{{ changes.columns.type }}</th>
            <th>{{ changes.columns.attrs }}</th>
            <th>{{ changes.columns.modified }}</th>
          </tr>
        </thead>
        <tbody>
          <tr v-if="!changes.rows.length">
            <td class="fae-table__empty" colspan="4">{{ changes.emptyText }}</td>
          </tr>
          <tr v-for="row in changes.rows" :key="row.id">
            <td>{{ row.user }}</td>
            <td>{{ row.type }}</td>
            <td>{{ row.attrs }}</td>
            <td>{{ row.modified }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </section>
</template>