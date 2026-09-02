<script setup>
import { computed } from 'vue'

import { useFaeFormContext } from '../composables/useFaeFormContext.js'

defineOptions({ name: 'FaeInput' })

const props = defineProps({
  name: { type: String, required: true },
})

const context = useFaeFormContext()
const field = computed(() => context.field(props.name))
const model = computed({
  get: () => context.form[props.name],
  set: (value) => { context.form[props.name] = value },
})
</script>

<template>
  <component
    :is="context.formFieldComponent"
    v-if="field && context.fieldVisible(field)"
    :field="field"
    :error="context.form.errors[props.name]"
    :can-translate="context.canTranslate(field)"
    :translating="context.translatingFieldName.value === props.name"
    v-model="model"
    @translate="context.translateField"
  />
</template>