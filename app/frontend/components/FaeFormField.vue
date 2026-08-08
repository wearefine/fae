<script setup>
import { computed, useId } from 'vue'

import FaeAssetField from './FaeAssetField.vue'
import FaeMarkdownEditor from './FaeMarkdownEditor.vue'
import FaeRankedSelectField from './FaeRankedSelectField.vue'
import FaeTypeaheadSelect from './FaeTypeaheadSelect.vue'
import { useFaeComponent } from '../composables/useFaeComponent.js'

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
  modelValue: { type: [String, Number, Boolean, Array, Object, null], default: '' },
  error: { type: String, default: null },
  canTranslate: { type: Boolean, default: false },
  translating: { type: Boolean, default: false },
})

defineEmits(['update:modelValue', 'translate'])

// Scoped to this instance rather than to the field name: a nested table's form
// can be open alongside the parent form and repeat its field names, and
// duplicate ids would point both labels at the first input.
const uid = useId()
const inputId = computed(() => `${uid}-${props.field.name}`)
const describedBy = computed(() => {
  const ids = []
  if (props.field.helperText) ids.push(`${inputId.value}-helper`)
  if (props.field.hint) ids.push(`${inputId.value}-hint`)
  if (props.error) ids.push(`${inputId.value}-error`)
  return ids.join(' ') || undefined
})

// Anything that is not a textarea, select or checkbox is an <input>; the type
// name doubles as the input's type attribute.
const inputType = computed(() =>
  ({ text: 'text', datepicker: 'date' })[props.field.type] || props.field.type
)

const FaeRankedSelectFieldComponent = useFaeComponent('FaeRankedSelectField', FaeRankedSelectField)
const FaeTypeaheadSelectComponent = useFaeComponent('FaeTypeaheadSelect', FaeTypeaheadSelect)

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
  <FaeAssetField
    v-if="field.asset"
    :field="field"
    :model-value="modelValue"
    :error="error"
    @update:model-value="$emit('update:modelValue', $event)"
  />

  <div
    v-else
    class="fae-field"
    :class="{ '-invalid': !!error, '-checkbox': field.type === 'checkbox' }"
  >
    <label class="fae-field__label" :for="inputId">
      {{ field.label }}
      <abbr v-if="field.required" class="fae-field__required" title="required">*</abbr>
    </label>

    <!-- Above the control, where the Slim label's h6.helper_text sat. `hint`
         is the separate, below-the-control note simple_form rendered. -->
    <p v-if="field.helperText" :id="`${inputId}-helper`" class="fae-field__helper">
      {{ field.helperText }}
    </p>

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
      :name="field.inputName"
      :autocomplete="field.autocomplete"
      :value="modelValue"
      :aria-invalid="!!error"
      :aria-describedby="describedBy"
      @input="$emit('update:modelValue', $event.target.value)"
    />

    <component
      :is="FaeTypeaheadSelectComponent"
      v-else-if="field.type === 'select' && field.typeahead"
      :id="inputId"
      :model-value="modelValue"
      :options="field.collection || []"
      :placeholder="field.placeholder || 'Select...'"
      @update:model-value="$emit('update:modelValue', $event)"
    />

    <select
      v-else-if="field.type === 'select'"
      :id="inputId"
      class="fae-field__control"
      :name="field.inputName"
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

    <select
      v-else-if="field.type === 'multiselect'"
      :id="inputId"
      class="fae-field__control"
      multiple
      :name="field.inputName"
      :aria-invalid="!!error"
      :aria-describedby="describedBy"
      @change="$emit('update:modelValue', Array.from($event.target.selectedOptions).map((option) => option.value))"
    >
      <option
        v-for="option in field.collection"
        :key="option.value"
        :value="option.value"
        :selected="Array.isArray(modelValue) && modelValue.map(String).includes(String(option.value))"
      >
        {{ option.label }}
      </option>
    </select>

    <component
      :is="FaeRankedSelectFieldComponent"
      v-else-if="field.type === 'ranked_select'"
      :field="field"
      :model-value="Array.isArray(modelValue) ? modelValue : []"
      @update:model-value="$emit('update:modelValue', $event)"
    />

    <input
      v-else-if="field.type === 'checkbox'"
      :id="inputId"
      class="fae-field__checkbox"
      type="checkbox"
      :name="field.inputName"
      value="1"
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
      :name="field.inputName"
      :autocomplete="field.autocomplete"
      :value="modelValue"
      :aria-invalid="!!error"
      :aria-describedby="describedBy"
      @focus="openDatePicker"
      @click="openDatePicker"
      @input="$emit('update:modelValue', $event.target.value)"
    >

    <button
      v-if="canTranslate"
      type="button"
      class="fae-button -secondary -sm fae-field__translate"
      :disabled="translating"
      @click="$emit('translate', field.name)"
    >
      {{ translating ? 'Translating...' : 'Translate from English' }}
    </button>

    <p v-if="field.hint" :id="`${inputId}-hint`" class="fae-field__hint">{{ field.hint }}</p>
    <p v-if="error" :id="`${inputId}-error`" class="fae-field__error">{{ error }}</p>
  </div>
</template>
