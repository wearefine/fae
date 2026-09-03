<script setup>
import { computed } from 'vue'

import { useFaeFormContext } from '../composables/useFaeFormContext.js'

defineOptions({ name: 'FaeFormFlexComponentsTable' })

const props = defineProps({
  association: { type: String, default: 'flex_components' },
})

const context = useFaeFormContext()
const table = computed(() => context.flexComponentsTable(props.association))
</script>

<template>
  <component
    :is="context.flexComponentsTableComponent"
    v-if="table"
    :table="table"
  />
</template>