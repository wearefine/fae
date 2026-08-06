<script setup>
import { computed, ref, useId, watch } from 'vue'

import FaeTypeaheadSelect from './FaeTypeaheadSelect.vue'
import { useSortableRows } from '../composables/useSortableRows.js'

const props = defineProps({
  field: { type: Object, required: true },
  modelValue: { type: Array, default: () => [] },
})

const emit = defineEmits(['update:modelValue'])

const ranked = computed(() => props.field.ranked || {})
const selectedRows = ref([])
const busy = ref(false)
const pickerValue = ref('')
const pickerId = useId()
const hydrating = ref(false)

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
  rows: selectedRows,
  persistOrder: persistSort,
})

const selectedIds = computed(() => items.value.map((row) => String(row.associatedId)))
const modelIds = computed(() => Array.isArray(props.modelValue) ? props.modelValue.map(String) : [])

const availableOptions = computed(() => {
  const selectedSet = new Set(selectedIds.value.map(String))

  return (props.field.collection || []).filter((option) => {
    if (selectedSet.has(String(option.value))) return false
    return true
  })
})

function initRows() {
  hydrating.value = true
  selectedRows.value = (ranked.value.rows || []).map((row) => ({
    id: row.id,
    associatedId: row.associatedId,
    label: row.label,
    previewImageUrl: row.previewImageUrl || null,
  }))

  // Keep mount-time hydration from flagging the parent form as dirty.
  queueMicrotask(() => {
    hydrating.value = false
  })
}

watch(() => props.field.ranked, initRows, { immediate: true, deep: true })

function csrfToken() {
  return document.querySelector('meta[name="csrf-token"]')?.content || ''
}

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

function optionById(id) {
  return (props.field.collection || []).find((option) => String(option.value) === String(id))
}

function sameIds(left, right) {
  if (left.length !== right.length) return false
  return left.every((value, index) => value === right[index])
}

async function add(option) {
  if (!ranked.value.parentId || !ranked.value.rankedItemPath) return

  busy.value = true
  try {
    const response = await fetch(ranked.value.rankedItemPath, {
      method: 'POST',
      credentials: 'same-origin',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': csrfToken(),
      },
      body: formBodyFromObject({
        action_type: 'add',
        parent_model: ranked.value.parentModel,
        parent_id: ranked.value.parentId,
        join_model: ranked.value.joinModel,
        associated_model: ranked.value.associatedModel,
        associated_id: option.value,
      }),
    })

    const data = await response.json()
    if (!response.ok || !data.success) throw new Error(data.error || 'Failed to add ranked item')

    items.value.push({
      id: data.join_record_id,
      associatedId: option.value,
      label: option.label,
      previewImageUrl: option.previewImageUrl || null,
    })
    pickerValue.value = ''
  } catch (error) {
    console.error(error)
    window.dispatchEvent(new CustomEvent('fae:toast', {
      detail: { type: 'alert', message: 'Unable to add ranked item right now.' },
    }))
  } finally {
    busy.value = false
  }
}

async function remove(row, index) {
  if (!ranked.value.parentId || !ranked.value.rankedItemPath) return

  busy.value = true
  try {
    const response = await fetch(ranked.value.rankedItemPath, {
      method: 'POST',
      credentials: 'same-origin',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': csrfToken(),
      },
      body: formBodyFromObject({
        action_type: 'remove',
        parent_model: ranked.value.parentModel,
        parent_id: ranked.value.parentId,
        join_model: ranked.value.joinModel,
        associated_model: ranked.value.associatedModel,
        associated_id: row.associatedId,
      }),
    })

    const data = await response.json()
    if (!response.ok || !data.success) throw new Error(data.error || 'Failed to remove ranked item')

    items.value.splice(index, 1)
  } catch (error) {
    console.error(error)
    window.dispatchEvent(new CustomEvent('fae:toast', {
      detail: { type: 'alert', message: 'Unable to remove ranked item right now.' },
    }))
  } finally {
    busy.value = false
  }
}

async function persistSort() {
  if (!ranked.value.sortPath || !ranked.value.sortObject) return
  const joinIds = items.value.map((row) => row.id).filter(Boolean)
  if (joinIds.length <= 1) return

  busy.value = true
  try {
    const response = await fetch(ranked.value.sortPath, {
      method: 'POST',
      credentials: 'same-origin',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': csrfToken(),
      },
      body: formBodyFromObject({ [ranked.value.sortObject]: joinIds }),
    })

    if (!response.ok) throw new Error(`Sort failed: ${response.status}`)
  } catch (error) {
    console.error(error)
    window.dispatchEvent(new CustomEvent('fae:toast', {
      detail: { type: 'alert', message: 'Unable to reorder ranked items right now.' },
    }))
  } finally {
    busy.value = false
  }
}

watch(items, () => {
  if (hydrating.value) return
  if (sameIds(selectedIds.value, modelIds.value)) return
  emit('update:modelValue', selectedIds.value)
}, { deep: true })

watch(pickerValue, (next) => {
  if (!next) return
  const option = optionById(next)
  if (!option) return
  add(option)
})
</script>

<template>
  <div class="fae-ranked-select">
    <div class="fae-ranked-select__picker">
      <FaeTypeaheadSelect
        :id="`${pickerId}-${field.name}-picker`"
        v-model="pickerValue"
        :options="availableOptions"
        :placeholder="field.placeholder || 'Type to search…'"
      />
    </div>

    <div class="fae-ranked-select__ranking">
      <h4>{{ ranked.rankingTitle || 'Ranking' }}</h4>
      <p v-if="ranked.rankingHelperText" class="fae-field__hint">{{ ranked.rankingHelperText }}</p>
      <p v-if="failed" class="fae-alert -alert" role="alert">
        That order could not be saved, so the previous order has been restored.
      </p>

      <ul v-if="items.length" class="fae-ranked-select__list">
        <li
          v-for="(row, index) in items"
          :key="row.associatedId"
          class="fae-ranked-select__item"
          :draggable="handleId === row.id"
          :class="{ '-dragging': draggingId === row.id }"
          @dragstart="onDragStart(row, $event)"
          @dragover.prevent="onDragOver(row)"
          @drop.prevent
          @dragend="onDragEnd"
        >
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
          <span class="fae-ranked-select__label">{{ row.label }}</span>
          <span class="fae-ranked-select__preview" aria-hidden="true">
            <img v-if="row.previewImageUrl" :src="row.previewImageUrl" alt="" class="fae-ranked-select__thumb">
          </span>
          <div class="fae-ranked-select__actions">
            <button type="button" class="fae-button -danger -sm" :disabled="busy" @click="remove(row, index)">
              Remove
            </button>
          </div>
        </li>
      </ul>

      <p v-else class="fae-field__hint">No items selected yet.</p>
    </div>
  </div>
</template>
