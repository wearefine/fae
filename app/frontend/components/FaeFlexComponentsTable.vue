<script setup>
import { computed, nextTick, ref, useId, watch } from 'vue'
import { router } from '@inertiajs/vue3'

import FaeBooleanToggle from './FaeBooleanToggle.vue'
import FaeNestedForm from './FaeNestedForm.vue'
import FaeNestedTable from './FaeNestedTable.vue'
import FaeTypeaheadSelect from './FaeTypeaheadSelect.vue'
import { useSortableRows } from '../composables/useSortableRows.js'

const props = defineProps({
  table: { type: Object, required: true },
})

const pickerId = useId()
const pickerValue = ref('')
const adding = ref(false)
const openId = ref(props.table.openRowId || null)
const rows = ref([...(props.table.rows || [])])
const root = ref(null)

watch(
  () => props.table.rows,
  (next) => {
    rows.value = [...(next || [])]
  },
  { deep: true }
)

watch(
  () => props.table.openRowId,
  (next) => {
    if (next) openId.value = next
  }
)

watch(openId, async (next) => {
  if (!next) return

  await nextTick()
  const target = root.value?.querySelector(`[data-flex-form-row="${next}"]`)
  target?.scrollIntoView({ behavior: 'smooth', block: 'center' })
})

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
} = useSortableRows({
  rows,
  persistOrder,
})

const componentOptions = computed(() => props.table.componentOptions || [])
const colspan = computed(() => 8)

function formBodyFromObject(values) {
  const body = new URLSearchParams()
  Object.entries(values).forEach(([key, value]) => {
    if (Array.isArray(value)) {
      value.forEach((entry) => body.append(`${key}[]`, String(entry)))
    } else if (value !== null && value !== undefined) {
      body.append(key, String(value))
    }
  })
  return body
}

function csrfToken() {
  return document.querySelector('meta[name="csrf-token"]')?.content || ''
}

async function persistOrder(order) {
  if (!props.table.sortPath || !props.table.sortParam) return

  const ids = order.map((row) => row.id)
  if (ids.length <= 1) return

  const response = await fetch(props.table.sortPath, {
    method: 'POST',
    credentials: 'same-origin',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
      'X-Requested-With': 'XMLHttpRequest',
      'X-CSRF-Token': csrfToken(),
    },
    body: formBodyFromObject({ [props.table.sortParam]: ids }),
  })

  if (!response.ok) throw new Error(`Sort failed: ${response.status}`)
}

watch(pickerValue, (next) => {
  if (!next || adding.value) return

  adding.value = true
  router.post(
    props.table.createPath,
    {
      flex_component: {
        ...(props.table.createParams || {}),
        component_model: next,
      },
    },
    {
      preserveScroll: true,
      preserveState: true,
      onFinish: () => {
        pickerValue.value = ''
        adding.value = false
      },
    }
  )
})

function toggleEdit(row) {
  if (!row.form) return
  openId.value = openId.value === row.id ? null : row.id
}

function closeEditor() {
  openId.value = null
}

function destroy(row) {
  if (!window.confirm(`Delete "${row.label}"? This cannot be undone.`)) return

  closeEditor()
  router.delete(row.deletePath, {
    preserveScroll: true,
    preserveState: true,
  })
}

function updateToggle(rowId, key, value) {
  const row = items.value.find((entry) => entry.id === rowId)
  if (!row) return
  row[key] = value
}
</script>

<template>
  <section ref="root" class="fae-flex-components">
    <div class="fae-flex-components__header">
      <h2>{{ table.title || 'Flex Components' }}</h2>

      <div class="fae-flex-components__picker">
        <FaeTypeaheadSelect
          :id="`${pickerId}-component`"
          v-model="pickerValue"
          :options="componentOptions"
          placeholder="+ Add Component"
        />
      </div>
    </div>

    <p v-if="table.helperText" class="fae-nested-table__helper">{{ table.helperText }}</p>
    <p v-if="failed" class="fae-alert -alert" role="alert">
      That order could not be saved, so the previous order has been restored.
    </p>

    <div class="fae-table-wrap">
      <table class="fae-table">
        <thead>
          <tr>
            <th class="fae-table__handle"><span class="fae-sr-only">Reorder</span></th>
            <th>Component Type</th>
            <th>Preview</th>
            <th>Image</th>
            <th class="-action-wide">On Stage</th>
            <th class="-action-wide">On Prod</th>
            <th class="fae-table__actions"><span class="fae-sr-only">Actions</span></th>
            <th class="fae-table__actions"><span class="fae-sr-only">Delete</span></th>
          </tr>
        </thead>

        <tbody>
          <template v-for="row in items" :key="row.id">
            <tr
              :draggable="handleId === row.id"
              :class="{ '-dragging': draggingId === row.id, '-editing': openId === row.id }"
              @dragstart="onDragStart(row, $event)"
              @dragover.prevent="onDragOver(row)"
              @drop.prevent
              @dragend="onDragEnd"
            >
              <td class="fae-table__handle">
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

              <td>
                <button
                  v-if="row.form"
                  type="button"
                  class="fae-table__link"
                  @click="toggleEdit(row)"
                >
                  {{ row.label }}
                </button>
                <a v-else-if="row.editPath" class="fae-table__link" :href="row.editPath">{{ row.label }}</a>
                <span v-else>{{ row.label }}</span>
              </td>

              <td>{{ row.preview }}</td>
              <td>
                <img v-if="row.imageUrl" class="fae-flex-components__thumb" :src="row.imageUrl" alt="">
              </td>

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
                <button v-if="row.form" type="button" class="fae-button -secondary -sm" @click="toggleEdit(row)">
                  {{ openId === row.id ? 'Close' : 'Edit' }}
                </button>
                <a v-else-if="row.editPath" class="fae-button -secondary -sm" :href="row.editPath">Edit</a>
              </td>

              <td class="fae-table__actions">
                <button type="button" class="fae-button -danger -sm" @click="destroy(row)">
                  Delete
                </button>
              </td>
            </tr>

            <tr v-if="openId === row.id && row.form" class="fae-nested-table__form-row" :data-flex-form-row="String(row.id)">
              <td :colspan="colspan">
                <FaeNestedForm
                  :fields="row.form.fields"
                  :action="row.form.action"
                  :method="row.form.method"
                  :param-key="row.form.paramKey"
                  :error-bag="row.form.errorBag"
                  :form-page="row.form.formPage"
                  @saved="closeEditor"
                  @cancel="closeEditor"
                />

                <FaeNestedTable
                  v-for="nested in row.form.tables || []"
                  :key="`${row.id}-${nested.title}`"
                  :table="nested"
                />
              </td>
            </tr>
          </template>

          <tr v-if="!items.length">
            <td class="fae-table__empty" :colspan="colspan">No components yet.</td>
          </tr>
        </tbody>
      </table>
    </div>
  </section>
</template>
