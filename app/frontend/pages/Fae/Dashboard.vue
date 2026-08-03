<script setup>
defineOptions({ inheritAttrs: false })

defineProps({
  greeting: { type: String, required: true },
  userName: { type: String, default: '' },
  columns: { type: Array, default: () => [] },
  // The 25 most recently updated records across every dashboard model.
  rows: { type: Array, default: () => [] },
  emptyState: { type: Object, required: true },
})
</script>

<template>
  <div class="fae-page-header">
    <div class="fae-page-header__title">
      <h1>{{ greeting }} <strong>{{ userName }}</strong></h1>
    </div>
  </div>

  <div v-if="rows.length" class="fae-table-wrap">
    <table class="fae-table">
      <thead>
        <tr>
          <th v-for="col in columns" :key="col.key">{{ col.label }}</th>
        </tr>
      </thead>

      <tbody>
        <tr v-for="row in rows" :key="row.id">
          <td>
            <!-- Full page loads, not Inertia visits: most forms and indexes
                 these link to still render Slim. -->
            <a class="fae-table__link" :href="row.editPath">{{ row.name }}</a>
          </td>
          <td><a class="fae-table__link" :href="row.typePath">{{ row.type }}</a></td>
          <td>{{ row.updatedAt }}</td>
        </tr>
      </tbody>
    </table>
  </div>

  <section v-else class="fae-empty-state">
    <h2>{{ emptyState.title }}</h2>
    <p>
      {{ emptyState.body }}
      <br />
      <a :href="emptyState.linkUrl" target="_blank" rel="noopener">{{ emptyState.linkText }}</a>
    </p>
  </section>
</template>
