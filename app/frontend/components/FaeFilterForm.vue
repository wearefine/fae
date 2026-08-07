<script setup>
import { reactive, watch } from 'vue'
import FaeTypeaheadSelect from './FaeTypeaheadSelect.vue'

const props = defineProps({
  title: { type: String, required: true },
  fields: { type: Array, default: () => [] },
  values: { type: Object, default: () => ({}) },
  search: { type: Boolean, default: true },
  searchKey: { type: String, default: 'search' },
  searchPlaceholder: { type: String, default: 'Search by Keyword' },
})

const emit = defineEmits(['apply', 'reset'])

const form = reactive({ ...props.values })

watch(
  () => props.values,
  (next) => {
    Object.keys(form).forEach((key) => {
      if (!(key in next)) delete form[key]
    })
    Object.assign(form, next || {})
  },
  { deep: true }
)

function apply() {
  emit('apply', { ...form })
}

function reset() {
  Object.keys(form).forEach((key) => {
    form[key] = ''
  })
  emit('reset')
}

function filterInputType(field) {
  if (field.type === 'datepicker') return 'date'
  return field.type || 'text'
}

function openDatePicker(event) {
  const input = event?.target
  if (!(input instanceof HTMLInputElement)) return
  if (input.type !== 'date') return
  if (typeof input.showPicker !== 'function') return

  try {
    input.showPicker()
  } catch (error) {
    // Some browsers restrict showPicker; fallback is native focus behavior.
  }
}
</script>

<template>
  <form class="fae-filter" @submit.prevent="apply">
    <div class="fae-filter__header">
      <h2>{{ title }}</h2>

      <div v-if="search" class="fae-filter__search">
        <input
          v-model="form[searchKey]"
          class="fae-field__control"
          type="text"
          :placeholder="searchPlaceholder"
        >
      </div>
    </div>

    <div class="fae-filter__groups">
      <div v-for="field in fields" :key="field.key" class="fae-filter__group">
        <label class="fae-field__label" :for="`filter-${field.key}`">{{ field.label }}</label>

        <FaeTypeaheadSelect
          v-if="field.type === 'select'"
          :id="`filter-${field.key}`"
          v-model="form[field.key]"
          :options="field.options || []"
          :placeholder="field.placeholder || 'All'"
        />

        <input
          v-else
          :id="`filter-${field.key}`"
          v-model="form[field.key]"
          class="fae-field__control"
          :type="filterInputType(field)"
          :placeholder="field.placeholder || ''"
          @focus="openDatePicker"
          @click="openDatePicker"
        >
      </div>

      <div class="fae-filter__actions">
        <button type="submit" class="fae-button -sm">Apply Filters</button>
        <button type="button" class="fae-button -secondary -sm" @click="reset">Reset Search</button>
      </div>
    </div>
  </form>
</template>
