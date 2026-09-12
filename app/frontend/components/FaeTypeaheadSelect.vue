<script setup>
import { computed, ref, watch } from 'vue'

const props = defineProps({
  modelValue: { type: [String, Number, null], default: '' },
  options: { type: Array, default: () => [] },
  placeholder: { type: String, default: 'All' },
  id: { type: String, required: true },
})

const emit = defineEmits(['update:modelValue'])

const open = ref(false)
const query = ref('')
const highlightedIndex = ref(-1)

const normalizedValue = computed(() => String(props.modelValue ?? ''))

const selected = computed(() =>
  props.options.find((option) => String(option.value) === normalizedValue.value) || null
)

const selectedLabel = computed(() => selected.value?.label?.toLowerCase() || '')

const filtered = computed(() => {
  const term = query.value.trim().toLowerCase()
  if (!term) return props.options

  // Do not self-filter when the input only mirrors the current selection.
  if (selected.value && term === selectedLabel.value) return props.options

  return props.options.filter((option) => option.label.toLowerCase().includes(term))
})

const menuOptions = computed(() => {
  const options = [{ label: props.placeholder, value: '', key: '__clear__' }]
  let previousGroup

  filtered.value.forEach((option) => {
    if (option.group && option.group !== previousGroup) {
      options.push({ label: option.group, key: `__group__-${option.group}`, groupHeading: true })
      previousGroup = option.group
    }
    options.push({ ...option, key: String(option.value) })
  })

  return options
})

const activeDescendant = computed(() => {
  if (!open.value || highlightedIndex.value < 0) return undefined
  return `${props.id}-option-${highlightedIndex.value}`
})

watch(
  () => props.modelValue,
  () => {
    query.value = selected.value?.label || ''
  },
  { immediate: true }
)

function choose(option) {
  emit('update:modelValue', option.value)
  query.value = option.label
  open.value = false
  highlightedIndex.value = -1
}

function clear() {
  emit('update:modelValue', '')
  query.value = ''
  open.value = false
  highlightedIndex.value = -1
}

function onFocus() {
  open.value = true
  highlightedIndex.value = 0
}

function onClick() {
  open.value = true
  if (highlightedIndex.value < 0) highlightedIndex.value = 0
}

function onInput() {
  open.value = true
  highlightedIndex.value = 0
  if (!query.value) emit('update:modelValue', '')
}

function moveHighlight(delta) {
  if (!open.value) open.value = true

  const length = menuOptions.value.length
  if (!length) return

  let next = highlightedIndex.value
  do {
    next += delta
    if (next < 0) next = length - 1
    else if (next >= length) next = 0
  } while (menuOptions.value[next]?.groupHeading)
  highlightedIndex.value = next
}

function selectHighlighted() {
  if (!open.value) {
    open.value = true
    return
  }

  const option = menuOptions.value[highlightedIndex.value]
  if (!option) return
  if (option.key === '__clear__') clear()
  else choose(option)
}

function onKeydown(event) {
  if (event.key === 'ArrowDown') {
    event.preventDefault()
    moveHighlight(1)
    return
  }

  if (event.key === 'ArrowUp') {
    event.preventDefault()
    moveHighlight(-1)
    return
  }

  if (event.key === 'Enter') {
    event.preventDefault()
    selectHighlighted()
    return
  }

  if (event.key === 'Escape') {
    event.preventDefault()
    open.value = false
    highlightedIndex.value = -1
    query.value = selected.value?.label || ''
  }
}

function closeSoon() {
  // Delay so option mousedown can run before blur closes the list.
  window.setTimeout(() => {
    open.value = false
    highlightedIndex.value = -1
    // Revert to the chosen label if the user typed a non-matching value.
    if (!selected.value && query.value) query.value = ''
    else if (selected.value) query.value = selected.value.label
  }, 120)
}
</script>

<template>
  <div class="fae-typeahead">
    <input
      :id="id"
      v-model="query"
      class="fae-field__control"
      type="text"
      role="combobox"
      autocomplete="off"
      :placeholder="placeholder"
      :aria-expanded="open"
      :aria-controls="`${id}-menu`"
      :aria-activedescendant="activeDescendant"
      @focus="onFocus"
      @click="onClick"
      @input="onInput"
      @keydown="onKeydown"
      @blur="closeSoon"
    >

    <button
      v-if="modelValue"
      type="button"
      class="fae-typeahead__clear"
      aria-label="Clear selection"
      @mousedown.prevent
      @click="clear"
    >
      ×
    </button>

    <ul v-if="open" :id="`${id}-menu`" class="fae-typeahead__menu" role="listbox">
      <li
        v-for="(option, index) in menuOptions"
        :id="`${id}-option-${index}`"
        :key="`${id}-${option.key}`"
        :class="[
          option.groupHeading ? 'fae-typeahead__group' : 'fae-typeahead__option',
          {
            '-selected': String(option.value) === normalizedValue,
            '-active': highlightedIndex === index
          }
        ]"
        :role="option.groupHeading ? 'presentation' : 'option'"
        :aria-selected="option.groupHeading ? undefined : highlightedIndex === index"
        @mousedown.prevent
        @mousemove="option.groupHeading ? undefined : highlightedIndex = index"
        @click="option.groupHeading ? undefined : option.key === '__clear__' ? clear() : choose(option)"
      >
        {{ option.label }}
      </li>

      <li v-if="menuOptions.length === 1" class="fae-typeahead__empty">No matches</li>
    </ul>
  </div>
</template>
