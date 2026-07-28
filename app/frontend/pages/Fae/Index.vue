<script setup>
import { router } from '@inertiajs/vue3'

// Inertia passes shared props (currentUser, flash, nav) to every page. This
// page reads none of them, and its template has multiple root nodes, so
// without this Vue tries to apply them as DOM attributes and warns.
defineOptions({ inheritAttrs: false })

// Fae::BaseController#index is generic across every model, so this page is
// driven entirely by props rather than being generated per-resource.
defineProps({
  title: { type: String, required: true },
  newPath: { type: String, default: null },
  columns: { type: Array, default: () => [] },
  rows: { type: Array, default: () => [] },
})

function destroy(row) {
  if (!window.confirm(`Delete "${row.label}"? This cannot be undone.`)) return
  router.delete(row.deletePath, { preserveScroll: true })
}
</script>

<template>
  <!--
    These use plain anchors rather than Inertia's <Link> on purpose. The new
    and edit screens still render Slim, and <Link> performs an XHR visit that
    expects an Inertia JSON response -- pointing it at a Slim page pops
    Inertia's error modal. Swap these to <Link> as each target is converted.
  -->
  <div class="content-header">
    <h1>{{ title }}</h1>
    <a v-if="newPath" :href="newPath" class="button">Add {{ title }}</a>
  </div>

  <main class="content">
    <table>
      <thead>
        <tr>
          <th v-for="col in columns" :key="col.key">{{ col.label }}</th>
          <th class="-action"></th>
        </tr>
      </thead>

      <tbody>
        <tr v-for="row in rows" :key="row.id">
          <td v-for="(col, i) in columns" :key="col.key">
            <a v-if="i === 0" :href="row.editPath">{{ row.cells[col.key] }}</a>
            <template v-else>{{ row.cells[col.key] }}</template>
          </td>
          <td class="-action">
            <button type="button" @click="destroy(row)">Delete</button>
          </td>
        </tr>

        <tr v-if="!rows.length">
          <td :colspan="columns.length + 1">No items found</td>
        </tr>
      </tbody>
    </table>
  </main>
</template>
