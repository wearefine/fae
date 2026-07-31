<script setup>
import { computed, useId } from 'vue'

import FaeMarkdownEditor from './FaeMarkdownEditor.vue'

/**
 * One labelled form control.
 *
 * This is the Vue counterpart of the fae_input / fae_association helpers: the
 * controller describes a field as data, and this component decides which
 * control renders it. New field types are added here rather than by teaching a
 * Ruby helper another simple_form incantation.
 */
const props = defineProps({
  field: { type: Object, required: true },
  modelValue: { type: [String, Number, Boolean, null], default: '' },
  error: { type: String, default: null },
})

defineEmits(['update:modelValue'])

// Scoped to this instance rather than to the field name: a nested table's form
// can be open alongside the parent form and repeat its field names, and
// duplicate ids would point both labels at the first input.
const uid = useId()
const inputId = computed(() => `${uid}-${props.field.name}`)
const describedBy = computed(() => {
  const ids = []
  if (props.field.hint) ids.push(`${inputId.value}-hint`)
  if (props.error) ids.push(`${inputId.value}-error`)
  return ids.join(' ') || undefined
})

// Anything that is not a textarea, select or checkbox is an <input>; the type
// name doubles as the input's type attribute.
const inputType = computed(() =>
  ({ text: 'text' })[props.field.type] || props.field.type
)
</script>

<template>
  <div class="fae-field" :class="{ '-invalid': !!error, '-checkbox': field.type === 'checkbox' }">
    <label class="fae-field__label" :for="inputId">
      {{ field.label }}
      <abbr v-if="field.required" class="fae-field__required" title="required">*</abbr>
    </label>

    <FaeMarkdownEditor
      v-if="field.type === 'textarea' && field.markdown"
      :id="inputId"
      :model-value="modelValue"
      :described-by="describedBy"
      :invalid="!!error"
      @update:model-value="$emit('update:modelValue', $event)"
    />

    <textarea
      v-else-if="field.type === 'textarea'"
      :id="inputId"
      class="fae-field__control"
      rows="8"
      :value="modelValue"
      :aria-invalid="!!error"
      :aria-describedby="describedBy"
      @input="$emit('update:modelValue', $event.target.value)"
    />

    <select
      v-else-if="field.type === 'select'"
      :id="inputId"
      class="fae-field__control"
      :value="modelValue"
      :aria-invalid="!!error"
      :aria-describedby="describedBy"
      @change="$emit('update:modelValue', $event.target.value)"
    >
      <option value="" />
      <option v-for="option in field.collection" :key="option.value" :value="option.value">
        {{ option.label }}
      </option>
    </select>

    <input
      v-else-if="field.type === 'checkbox'"
      :id="inputId"
      class="fae-field__checkbox"
      type="checkbox"
      :checked="modelValue"
      :aria-invalid="!!error"
      :aria-describedby="describedBy"
      @change="$emit('update:modelValue', $event.target.checked)"
    >

    <input
      v-else
      :id="inputId"
      class="fae-field__control"
      :type="inputType"
      :value="modelValue"
      :aria-invalid="!!error"
      :aria-describedby="describedBy"
      @input="$emit('update:modelValue', $event.target.value)"
    >

    <p v-if="field.hint" :id="`${inputId}-hint`" class="fae-field__hint">{{ field.hint }}</p>
    <p v-if="error" :id="`${inputId}-error`" class="fae-field__error">{{ error }}</p>
  </div>
</template>
