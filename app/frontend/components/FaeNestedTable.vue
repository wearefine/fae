<script setup>
import { computed, nextTick, ref, watch } from 'vue'
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
const openId = ref(props.table.openNewRow ? 'new' : (props.table.openRowId || null))
const root = ref(null)

const colspan = computed(() => props.table.columns.length + 1)

watch(
  () => props.table.openRowId,
  (next) => {
    if (next) openId.value = next
  }
)

watch(
  () => props.table.openNewRow,
  (next) => {
    if (next) openId.value = 'new'
  }
)

watch(openId, async (next) => {
  if (!next) return

  await nextTick()
  const selector = next === 'new'
    ? '[data-nested-form-row="new"]'
    : `[data-nested-form-row="${next}"]`
  const target = root.value?.querySelector(selector)
  target?.scrollIntoView({ behavior: 'smooth', block: 'center' })
})

function cellFor(row, columnKey) {
  return row.cells?.[columnKey] || { kind: 'text', text: '' }
}

function cellText(row, columnKey) {
  const cell = cellFor(row, columnKey)
  return typeof cell === 'object' ? (cell.text || '') : String(cell || '')
}

function cellImageUrl(row, columnKey) {
  const cell = cellFor(row, columnKey)
  if (typeof cell !== 'object') return null
  return cell.kind === 'image' ? cell.url : null
}

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
  <section ref="root" class="fae-nested-table">
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
                  <img
                    v-if="cellImageUrl(row, col.key)"
                    :src="cellImageUrl(row, col.key)"
                    alt=""
                    class="fae-nested-table__thumb"
                  >
                  <template v-else>{{ cellText(row, col.key) }}</template>
                </button>
                <template v-else>
                  <img
                    v-if="cellImageUrl(row, col.key)"
                    :src="cellImageUrl(row, col.key)"
                    alt=""
                    class="fae-nested-table__thumb"
                  >
                  <template v-else>{{ cellText(row, col.key) }}</template>
                </template>
              </td>

              <td class="fae-table__actions">
                <button
                  type="button"
                  class="fae-button -secondary -sm"
                  @click="toggle(row)"
                >
                  {{ openId === row.id ? 'Close' : 'Edit' }}
                </button>

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
            <tr v-if="openId === row.id" class="fae-nested-table__form-row" :data-nested-form-row="String(row.id)">
              <td :colspan="colspan">
                <FaeNestedForm
                  :fields="row.fields"
                  :action="row.path"
                  method="put"
                  :param-key="table.paramKey"
                  :error-bag="table.errorBag"
                  :extra-hidden="table.extraHidden || {}"
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
          <tr v-if="openId === 'new'" class="fae-nested-table__form-row" data-nested-form-row="new">
            <td :colspan="colspan">
              <FaeNestedForm
                :fields="table.newFields"
                :action="table.createPath"
                method="post"
                :param-key="table.paramKey"
                :error-bag="table.errorBag"
                :parent-key="table.parentKey"
                :parent-id="table.parentId"
                :extra-hidden="table.extraHidden || {}"
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
