<script setup>
import { computed } from 'vue'

const props = defineProps({
  label: { type: String, required: true },
  sortKey: { type: String, required: true },
  sortBy: { type: String, default: '' },
  sortDirection: { type: String, default: 'asc' },
})

const emit = defineEmits(['sort'])

const active = computed(() => props.sortBy === props.sortKey)
const direction = computed(() => (props.sortDirection || 'asc').toLowerCase())

function onSort() {
  emit('sort', props.sortKey)
}
</script>

<template>
  <th class="fae-sort-header" :class="{ '-active': active, '-desc': active && direction === 'desc' }">
    <button type="button" class="fae-sort-header__button" @click="onSort">
      <span>{{ label }}</span>
      <span class="fae-sort-header__icon" aria-hidden="true">▾</span>
    </button>
  </th>
</template>
