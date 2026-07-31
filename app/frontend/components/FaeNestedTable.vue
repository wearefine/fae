<script setup>
import { computed, ref } from 'vue'
import { router } from '@inertiajs/vue3'

import FaeNestedForm from './FaeNestedForm.vue'

/**
 * A has_many association listed on its parent's form, with add/edit forms that
 * open in a row of the table itself.
 *
 * Vue counterpart of fae/shared/_nested_table plus the half of form/_ajax.js
 * that drove it. The behaviour being preserved is where the form appears:
 * directly beneath the record it edits, or at the foot of the table when
 * adding -- not in a modal and not on a separate screen.
 */
const props = defineProps({
  table: { type: Object, required: true },
})

// Which form is open: a row id, the string 'new', or nothing. One at a time,
// as in the legacy version, so the table never grows two forms deep.
const openId = ref(null)

const colspan = computed(() => props.table.columns.length + 1)

function toggle(row) {
  openId.value = openId.value === row.id ? null : row.id
}

function close() {
  openId.value = null
}

function destroy(row) {
  if (!window.confirm(`Delete "${row.label}"? This cannot be undone.`)) return

  close()
  router.delete(row.path, { preserveScroll: true, preserveState: true })
}
</script>

<template>
  <section class="fae-nested-table">
    <div class="fae-nested-table__header">
      <h2>{{ table.title }}</h2>

      <button
        v-if="!table.hideAddButton"
        type="button"
        class="fae-button -sm"
        @click="openId = 'new'"
      >
        {{ table.addButtonText }}
      </button>
    </div>

    <p v-if="table.helperText" class="fae-nested-table__helper">{{ table.helperText }}</p>

    <div class="fae-table-wrap">
      <table class="fae-table">
        <thead>
          <tr>
            <th v-for="col in table.columns" :key="col.key">{{ col.label }}</th>
            <th class="fae-table__actions"><span class="fae-sr-only">Actions</span></th>
          </tr>
        </thead>

        <tbody>
          <template v-for="row in table.rows" :key="row.id">
            <tr :class="{ '-editing': openId === row.id }">
              <td v-for="(col, i) in table.columns" :key="col.key">
                <button v-if="i === 0" type="button" class="fae-table__link" @click="toggle(row)">
                  {{ row.cells[col.key] }}
                </button>
                <template v-else>{{ row.cells[col.key] }}</template>
              </td>

              <td class="fae-table__actions">
                <button
                  v-if="!table.hideDeleteButton"
                  type="button"
                  class="fae-button -danger -sm"
                  @click="destroy(row)"
                >
                  Delete
                </button>
              </td>
            </tr>

            <!-- The form takes a row of its own directly beneath the record it
                 edits, which is where form/_ajax.js spliced it in. -->
            <tr v-if="openId === row.id" class="fae-nested-table__form-row">
              <td :colspan="colspan">
                <FaeNestedForm
                  :fields="row.fields"
                  :action="row.path"
                  method="put"
                  :param-key="table.paramKey"
                  :error-bag="table.errorBag"
                  @saved="close"
                  @cancel="close"
                />
              </td>
            </tr>
          </template>

          <tr v-if="!table.rows.length && openId !== 'new'">
            <td class="fae-table__empty" :colspan="colspan">No {{ table.title }} yet.</td>
          </tr>

          <!-- Adding appends to the foot of the table, the position the legacy
               add link put it in. -->
          <tr v-if="openId === 'new'" class="fae-nested-table__form-row">
            <td :colspan="colspan">
              <FaeNestedForm
                :fields="table.newFields"
                :action="table.createPath"
                method="post"
                :param-key="table.paramKey"
                :error-bag="table.errorBag"
                :parent-key="table.parentKey"
                :parent-id="table.parentId"
                @saved="close"
                @cancel="close"
              />
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </section>
</template>
