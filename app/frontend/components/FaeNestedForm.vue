<script setup>
import { computed, ref, toRef } from 'vue'
import { useForm } from '@inertiajs/vue3'

import FaeFormField from './FaeFormField.vue'
import { assetSubmitOptions, useAssetFields } from '../composables/useAssetFields.js'
import { useCtaFields } from '../composables/useCtaFields.js'
import { useFaeComponent } from '../composables/useFaeComponent.js'
import { useFaePageComponent } from '../composables/useFaePageComponent.js'
import { useSlugger } from '../composables/useSlugger.js'
import { provideFaeFormContext } from '../composables/useFaeFormContext.js'
import { registerUnsavedChanges } from '../composables/useUnsavedChanges.js'

/**
 * The add/edit form that opens inside a nested table.
 *
 * Replaces the GET-and-splice dance in form/_ajax.js: the fields arrive with
 * the page, so revealing this is instant and there is no server-rendered
 * markup being injected into a live form.
 */
const props = defineProps({
  fields: { type: Array, required: true },
  // Rails wants params nested under the model name; the transform below adds
  // that wrapper so `errors` still comes back keyed by the bare field name.
  paramKey: { type: String, required: true },
  // Scopes this form's validation errors, so failing here cannot mark up the
  // parent form's fields or a sibling table's.
  errorBag: { type: String, required: true },
  action: { type: String, required: true },
  method: { type: String, default: 'post' },
  // The association column. Sent with every save, as the hidden foreign key
  // field in the Slim nested form was.
  parentKey: { type: String, default: null },
  parentId: { type: [Number, String], default: null },
  extraHidden: { type: Object, default: () => ({}) },
  formComponent: { type: [Object, Function], default: null },
  formPage: { type: String, default: null },
})

const emit = defineEmits(['saved', 'cancel'])

const form = useForm({
  ...Object.fromEntries(props.fields.map((field) => [field.name, field.value])),
  ...(props.parentKey ? { [props.parentKey]: props.parentId } : {}),
  ...(props.extraHidden || {}),
})

const { hasAssets, toParams } = useAssetFields(toRef(props, 'fields'))
const { toParams: ctaToParams } = useCtaFields(toRef(props, 'fields'))
useSlugger({ form, fields: toRef(props, 'fields') })
const FaeFormFieldComponent = useFaeComponent('FaeFormField', FaeFormField)
const generatedFormComponent = useFaePageComponent(props.formPage)
const nestedFormComponent = computed(() => props.formComponent || generatedFormComponent)

function formField(name) {
  return props.fields.find((field) => String(field?.name) === String(name)) || null
}

provideFaeFormContext({
  form,
  field: formField,
  fieldVisible: () => true,
  formFieldComponent: FaeFormFieldComponent,
  canTranslate: () => false,
  translatingFieldName: ref(''),
  translateField: () => {},
})

// Open forms only: closing one unmounts it, which is also how the user
// discards it, so the parent stops counting it.
registerUnsavedChanges(() => form.isDirty)

function submit() {
  const { method, extraParams, forceFormData } = assetSubmitOptions(hasAssets.value, props.method)

  form.transform((data) => ({ [props.paramKey]: ctaToParams(toParams(data)), ...extraParams }))[method](props.action, {
    preserveScroll: true,
    forceFormData,
    // Load-bearing rather than incidental: the response re-renders the parent
    // screen, and remounting it would throw away whatever the user had typed
    // into the parent form before opening this one.
    preserveState: true,
    errorBag: props.errorBag,
    onSuccess: () => emit('saved'),
  })
}

// This is a <div>, so Enter has no default submit behaviour to rely on -- and
// where a nested table sits inside the parent form, Enter would otherwise
// submit that instead.
function onEnter(event) {
  if (event.target.tagName === 'TEXTAREA') return

  event.preventDefault()
  submit()
}
</script>

<template>
  <!--
    Deliberately not a <form>: a nested table may be rendered inside the
    parent's form, and nested <form> elements are invalid HTML -- browsers drop
    the inner one. This is the same conclusion _convertNestedFormToDiv reached,
    without the DOM surgery.
  -->
  <div class="fae-nested-form" @keydown.enter="onEnter">
    <div class="fae-nested-form__fields">
      <component :is="nestedFormComponent" v-if="nestedFormComponent" />
      <component
        v-else
        :is="FaeFormFieldComponent"
        v-for="field in fields"
        :key="field.name"
        :field="field"
        :error="form.errors[field.name]"
        v-model="form[field.name]"
      />
    </div>

    <div class="fae-nested-form__actions">
      <button type="button" class="fae-button -secondary -sm" @click="emit('cancel')">
        Cancel
      </button>
      <button type="button" class="fae-button -sm" :disabled="form.processing" @click="submit">
        {{ form.processing ? 'Saving…' : 'Save' }}
      </button>
    </div>
  </div>
</template>
