<script setup>
import { computed, reactive, ref, watch, useId } from 'vue'
import { usePage } from '@inertiajs/vue3'

import FaeAssetField from './FaeAssetField.vue'
import FaeFlyout from './FaeFlyout.vue'
import FaeMarkdownEditor from './FaeMarkdownEditor.vue'
import FaeRankedSelectField from './FaeRankedSelectField.vue'
import FaeTypeaheadSelect from './FaeTypeaheadSelect.vue'
import { assetSubmitOptions, useAssetFields } from '../composables/useAssetFields.js'
import { useFaeComponent } from '../composables/useFaeComponent.js'
import { useSlugger } from '../composables/useSlugger.js'

defineOptions({ name: 'FaeFormField' })

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
  allowRelatedFlyout: { type: Boolean, default: true },
})

const emit = defineEmits(['update:modelValue', 'translate'])

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
const FaeFlyoutComponent = useFaeComponent('FaeFlyout', FaeFlyout)
const page = usePage()

const localOptions = ref([])
const flyoutOpen = ref(false)
const flyoutSaving = ref(false)
const flyoutError = ref('')
const flyoutFieldErrors = reactive({})
const flyoutValues = reactive({})
const flyoutTranslatingFieldName = ref('')

const languageNav = computed(() => {
  const nav = page.props.languageNav
  return nav && Array.isArray(nav.options) ? nav : null
})

const translateEnabled = computed(() => !!languageNav.value?.translateEnabled)
const translatePath = computed(() => String(languageNav.value?.translatePath || ''))
const languageCodes = computed(() =>
  (languageNav.value?.options || [])
    .map((option) => String(option?.value || ''))
    .filter((value) => value.length > 0 && value !== 'all')
)

const relatedFlyout = computed(() => {
  const config = props.field.relatedFlyout
  if (!props.allowRelatedFlyout) return null
  if (props.field.type !== 'select' || !config || !config.path) return null

  return {
    title: String(config.title || 'Create Item'),
    buttonLabel: String(config.buttonLabel || 'Add'),
    submitLabel: String(config.submitLabel || 'Create'),
    path: String(config.path),
    method: String(config.method || 'post').toUpperCase(),
    paramKey: String(config.paramKey || 'item'),
    valueKey: String(config.valueKey || 'id'),
    labelKey: String(config.labelKey || 'label'),
    fields: Array.isArray(config.fields) ? config.fields : [],
  }
})

watch(
  () => props.field.collection,
  (next) => {
    localOptions.value = Array.isArray(next)
      ? next.map((entry) => ({ label: entry.label, value: entry.value }))
      : []
  },
  { immediate: true }
)

const flyoutFields = computed(() => relatedFlyout.value?.fields || [])
useSlugger({ form: flyoutValues, fields: flyoutFields })
const { hasAssets: flyoutHasAssets, toParams: flyoutToParams } = useAssetFields(flyoutFields)

function fieldLanguage(field) {
  const name = String(field?.name || '')
  return languageCodes.value.find((language) => name.endsWith(`_${language}`)) || null
}

function translatorLanguageCode(language) {
  if (!language) return ''

  const key = String(language)
  if (key === 'zh') return 'zh-CN'
  if (key === 'frca') return 'fr-CA'
  if (key.length === 4) return `${key.slice(0, 2)}-${key.slice(2).toUpperCase()}`
  return key
}

function englishSourceCandidates(fieldName, language) {
  const name = String(fieldName || '')
  const suffix = `_${language}`
  if (!name.endsWith(suffix)) return []

  const base = name.slice(0, -suffix.length)
  return [`${base}_en`, base]
}

function canTranslateFlyoutField(field) {
  if (!translateEnabled.value || !translatePath.value) return false
  if (!field || field.translate === false) return false
  if (!['text', 'textarea'].includes(String(field.type || ''))) return false

  const language = fieldLanguage(field)
  if (!language || language === 'en') return false

  const availableFieldNames = new Set(flyoutFields.value.map((entry) => String(entry?.name || '')))
  return englishSourceCandidates(field.name, language).some((name) => availableFieldNames.has(name))
}

function englishSourceTextForFlyout(field) {
  const language = fieldLanguage(field)
  if (!language || language === 'en') return null

  const availableFieldNames = new Set(flyoutFields.value.map((entry) => String(entry?.name || '')))
  const candidates = englishSourceCandidates(field?.name, language)
  for (const candidate of candidates) {
    if (!availableFieldNames.has(candidate)) continue
    const value = String(flyoutValues[candidate] ?? '').trim()
    if (value.length > 0) return value
  }

  return null
}

async function translateFlyoutField(fieldName) {
  const targetField = flyoutFields.value.find((field) => String(field.name) === String(fieldName))
  if (!targetField || !canTranslateFlyoutField(targetField)) return

  const sourceText = englishSourceTextForFlyout(targetField)
  if (!sourceText) return

  const language = fieldLanguage(targetField)
  const translationLanguage = translatorLanguageCode(language)
  if (!translationLanguage) return

  flyoutTranslatingFieldName.value = String(fieldName)

  try {
    const payload = new FormData()
    payload.append('translation_text[language]', translationLanguage)
    payload.append('translation_text[en_text]', sourceText)

    const response = await fetch(translatePath.value, {
      method: 'POST',
      credentials: 'same-origin',
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': csrfToken(),
      },
      body: payload,
    })

    const data = await response.json().catch(() => null)
    const entry = Array.isArray(data) ? data[0] : null
    if (entry?.translated_text) {
      flyoutValues[String(fieldName)] = entry.translated_text
    }
  } catch (error) {
    console.error(error)
  } finally {
    flyoutTranslatingFieldName.value = ''
  }
}

function appendFormData(formData, key, value) {
  if (value === undefined || value === null) return

  if (value instanceof File) {
    formData.append(key, value)
    return
  }

  if (Array.isArray(value)) {
    value.forEach((entry, index) => {
      appendFormData(formData, `${key}[${index}]`, entry)
    })
    return
  }

  if (typeof value === 'object') {
    Object.entries(value).forEach(([childKey, childValue]) => {
      appendFormData(formData, `${key}[${childKey}]`, childValue)
    })
    return
  }

  formData.append(key, String(value))
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

function csrfToken() {
  return document.querySelector('meta[name="csrf-token"]')?.content || ''
}

function showToast(type, message) {
  if (!message) return

  window.dispatchEvent(new CustomEvent('fae:toast', {
    detail: { type, message },
  }))
}

function resetFlyoutForm() {
  const config = relatedFlyout.value

  Object.keys(flyoutValues).forEach((key) => {
    delete flyoutValues[key]
  })

  Array(config?.fields || []).forEach((field) => {
    if (field.type === 'checkbox') {
      flyoutValues[field.name] = false
      return
    }

    flyoutValues[field.name] = field.value ?? ''
  })

  Object.keys(flyoutFieldErrors).forEach((key) => {
    delete flyoutFieldErrors[key]
  })
  flyoutError.value = ''
}

function openFlyout() {
  if (!relatedFlyout.value || flyoutSaving.value) return
  resetFlyoutForm()
  flyoutOpen.value = true
}

function closeFlyout() {
  if (flyoutSaving.value) return
  flyoutOpen.value = false
}

async function saveFlyout() {
  const config = relatedFlyout.value
  if (!config) return

  const rawPayload = {}
  const validationErrors = {}

  config.fields.forEach((field) => {
    const rawValue = flyoutValues[field.name]
    const value = typeof rawValue === 'string' ? rawValue.trim() : rawValue
    rawPayload[field.name] = value

    if (field.required && !value) {
      validationErrors[field.name] = `${field.label || field.name} is required.`
    }
  })

  Object.keys(flyoutFieldErrors).forEach((key) => {
    delete flyoutFieldErrors[key]
  })
  Object.assign(flyoutFieldErrors, validationErrors)
  flyoutError.value = ''
  if (Object.keys(validationErrors).length) return

  flyoutSaving.value = true

  try {
    const params = flyoutToParams(rawPayload)
    const submitMethod = String(config.method || 'post').toLowerCase()
    const { method, extraParams, forceFormData } = assetSubmitOptions(flyoutHasAssets.value, submitMethod)

    const requestInit = {
      method: method.toUpperCase(),
      credentials: 'same-origin',
      headers: {
        Accept: 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': csrfToken(),
      },
    }

    if (forceFormData) {
      const formData = new FormData()
      appendFormData(formData, config.paramKey, params)
      Object.entries(extraParams).forEach(([extraKey, extraValue]) => {
        appendFormData(formData, extraKey, extraValue)
      })
      requestInit.body = formData
    } else {
      requestInit.headers['Content-Type'] = 'application/json'
      requestInit.body = JSON.stringify({ [config.paramKey]: params, ...extraParams })
    }

    const response = await fetch(config.path, {
      ...requestInit,
    })

    const data = await response.json().catch(() => ({}))

    if (!response.ok) {
      const errors = data?.errors
      if (errors && typeof errors === 'object' && !Array.isArray(errors)) {
        const mapped = {}
        Object.keys(errors).forEach((key) => {
          const value = errors[key]
          mapped[key] = Array.isArray(value) ? value[0] : String(value)
        })
        Object.keys(flyoutFieldErrors).forEach((key) => {
          delete flyoutFieldErrors[key]
        })
        Object.assign(flyoutFieldErrors, mapped)
      }

      if (Array.isArray(data?.messages) && data.messages.length) {
        flyoutError.value = data.messages[0]
      } else {
        flyoutError.value = 'Unable to create this item right now.'
      }
      showToast('alert', flyoutError.value)
      return
    }

    const optionValue = data?.[config.valueKey]
    const optionLabel = data?.[config.labelKey]

    if (optionValue === undefined || optionValue === null || !optionLabel) {
      flyoutError.value = 'Create succeeded, but response data was incomplete.'
      showToast('alert', flyoutError.value)
      return
    }

    const exists = localOptions.value.some((option) => String(option.value) === String(optionValue))
    if (!exists) {
      localOptions.value = [...localOptions.value, { value: optionValue, label: String(optionLabel) }]
    }

    emit('update:modelValue', String(optionValue))
    flyoutOpen.value = false
    showToast('notice', `${optionLabel} was created.`)
  } catch (error) {
    flyoutError.value = 'Unable to create this item right now.'
    showToast('alert', flyoutError.value)
    console.error(error)
  } finally {
    flyoutSaving.value = false
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
      v-else-if="field.type === 'select'"
      :id="inputId"
      :model-value="modelValue"
      :options="localOptions"
      :placeholder="field.placeholder || 'Select...'"
      @update:model-value="$emit('update:modelValue', $event)"
    />

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
      v-if="relatedFlyout"
      type="button"
      class="fae-button -secondary -sm fae-field__translate"
      :disabled="flyoutSaving"
      @click="openFlyout"
    >
      {{ relatedFlyout.buttonLabel }}
    </button>

    <component :is="FaeFlyoutComponent" :open="flyoutOpen" :title="relatedFlyout?.title" @close="closeFlyout">
      <div class="fae-flyout__fields">
        <FaeFormField
          v-for="flyoutField in relatedFlyout?.fields || []"
          :key="`flyout-${inputId}-${flyoutField.name}`"
          :field="flyoutField"
          :model-value="flyoutValues[flyoutField.name]"
          :error="flyoutFieldErrors[flyoutField.name]"
          :can-translate="canTranslateFlyoutField(flyoutField)"
          :translating="flyoutTranslatingFieldName === flyoutField.name"
          :allow-related-flyout="false"
          @update:model-value="flyoutValues[flyoutField.name] = $event"
          @translate="translateFlyoutField"
        />

        <p v-if="flyoutError" class="fae-field__error">{{ flyoutError }}</p>
      </div>

      <template #footer>
        <button type="button" class="fae-button -secondary" :disabled="flyoutSaving" @click="closeFlyout">Cancel</button>
        <button type="button" class="fae-button" :disabled="flyoutSaving" @click="saveFlyout">
          {{ flyoutSaving ? 'Creating...' : (relatedFlyout?.submitLabel || 'Create') }}
        </button>
      </template>
    </component>

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
