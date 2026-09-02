<script setup>
import { computed } from 'vue'

import { useFaeFormContext } from '../composables/useFaeFormContext.js'

defineOptions({ name: 'FaeFormNestedTable' })

const props = defineProps({
  association: { type: String, required: true },
})

const context = useFaeFormContext()
const table = computed(() => context.nestedTable(props.association))
</script>

<template>
  <component
    :is="context.nestedTableComponent"
    v-if="table"
    :table="table"
  />
</template>