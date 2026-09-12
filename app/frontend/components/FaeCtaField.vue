<script setup>
import { computed, ref, useId, watch } from 'vue'

const props = defineProps({
  field: { type: Object, required: true },
  modelValue: { type: Object, default: () => ({}) },
  error: { type: String, default: null },
})

const emit = defineEmits(['update:modelValue'])
const uid = useId()
const config = computed(() => props.field.cta)
const currentValue = ref({ ...props.modelValue })

watch(() => props.modelValue, (next) => {
  currentValue.value = { ...(next || {}) }
}, { deep: true })

function update(key, value) {
  currentValue.value = { ...currentValue.value, [key]: value }
  emit('update:modelValue', currentValue.value)
}
</script>

<template>
  <fieldset class="fae-cta-field" :class="{ '-invalid': !!error }">
    <legend class="fae-cta-field__title">{{ field.label }}</legend>

    <div class="fae-field">
      <label class="fae-field__label" :for="`${uid}-label`">{{ config.labelLabel }}</label>
      <input
        :id="`${uid}-label`"
        class="fae-field__control"
        type="text"
        :value="modelValue?.label"
        @input="update('label', $event.target.value)"
      >
    </div>

    <div class="fae-field">
      <label class="fae-field__label" :for="`${uid}-link`">{{ config.linkLabel }}</label>
      <p v-if="config.linkHelperText" class="fae-field__helper">{{ config.linkHelperText }}</p>
      <input
        :id="`${uid}-link`"
        class="fae-field__control"
        type="text"
        :value="modelValue?.link"
        @input="update('link', $event.target.value)"
      >
    </div>

    <div class="fae-field">
      <label class="fae-field__label" :for="`${uid}-alt-text`">{{ config.altTextLabel }}</label>
      <p v-if="config.altTextHelperText" class="fae-field__helper">{{ config.altTextHelperText }}</p>
      <input
        :id="`${uid}-alt-text`"
        class="fae-field__control"
        type="text"
        :value="modelValue?.altText"
        @input="update('altText', $event.target.value)"
      >
    </div>

    <p v-if="error" class="fae-field__error">{{ error }}</p>
  </fieldset>
</template>