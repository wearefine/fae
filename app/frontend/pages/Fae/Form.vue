<script setup>
import { computed } from 'vue'
import { useForm } from '@inertiajs/vue3'

import FaeFormField from '../../components/FaeFormField.vue'
import FaeNestedTable from '../../components/FaeNestedTable.vue'
import { assetSubmitOptions, useAssetFields } from '../../composables/useAssetFields.js'
import { useFormGuard } from '../../composables/useFormGuard.js'
import { provideUnsavedChanges } from '../../composables/useUnsavedChanges.js'

// Saving the parent would leave a half-filled nested form behind, so it is
// worth interrupting for. Wording kept from _validator.js.
const NESTED_UNSAVED_MESSAGE =
  'A nested form has unsaved changes! To return to your draft, click “Cancel.” ' +
  'To proceed without saving, click “OK.”'

// Inertia passes shared props (currentUser, flash, nav) to every page, and
// this template has multiple root nodes.
defineOptions({ inheritAttrs: false })

// Like Fae/Index, this page is generic: the controller describes the fields
// and this renders them. It replaces both _form.html.slim and the shared
// form_header partial.
const props = defineProps({
  title: { type: String, required: true },
  indexPath: { type: String, required: true },
  submitPath: { type: String, required: true },
  submitMethod: { type: String, default: 'put' },
  // Rails wants params nested under the model name; the transform below adds
  // that wrapper so `errors` still comes back keyed by the bare field name.
  paramKey: { type: String, required: true },
  // Inputs and nested tables in one ordered list, so a table renders in the
  // place the form declared it rather than after every input.
  blocks: { type: Array, default: () => [] },
  // True when the record was created by Fae::BaseController#new and has not
  // been deliberately saved yet -- see useFormGuard.
  draft: { type: Boolean, default: false },
  deletePath: { type: String, default: null },
})

const fields = computed(() =>
  props.blocks.filter((block) => block.kind === 'field').map((block) => block.field)
)

// Runs of adjacent inputs share a panel, and a nested table breaks the run.
// That reproduces the main.content / section.content structure the Slim forms
// used to get by hand.
const sections = computed(() =>
  props.blocks.reduce((out, block) => {
    if (block.kind !== 'field') {
      out.push(block)
      return out
    }

    const last = out[out.length - 1]
    if (last?.kind === 'field') last.fields.push(block.field)
    else out.push({ kind: 'field', fields: [block.field] })

    return out
  }, [])
)

const form = useForm(
  Object.fromEntries(fields.value.map((field) => [field.name, field.value]))
)

const { hasAssets, toParams } = useAssetFields(fields)

// Nested tables open forms of their own inside this one, and their input is
// not part of this form's data -- it has to be accounted for separately both
// here and in the navigation guard.
const nestedUnsavedChanges = provideUnsavedChanges()
const { cancel, allowUnload } = useFormGuard(
  props,
  () => form.isDirty || nestedUnsavedChanges()
)

function submit() {
  if (nestedUnsavedChanges() && !window.confirm(NESTED_UNSAVED_MESSAGE)) return

  allowUnload()

  const { method, extraParams, forceFormData } = assetSubmitOptions(hasAssets.value, props.submitMethod)

  form
    .transform((data) => ({ [props.paramKey]: toParams(data), ...extraParams }))
    // A failed save redirects back to this same URL, so the component is not
    // remounted and the user's input survives in `form` while the errors
    // arrive as page props.
    [method](props.submitPath, { preserveScroll: true, preserveState: true, forceFormData })
}
</script>

<template>
  <form @submit.prevent="submit">
    <div class="fae-page-header">
      <div class="fae-page-header__title">
        <h1>{{ title }}</h1>
      </div>

      <div class="fae-page-header__actions">
        <button type="button" class="fae-button -secondary" @click="cancel">Cancel</button>
        <button type="submit" class="fae-button" :disabled="form.processing">
          {{ form.processing ? 'Saving…' : 'Save' }}
        </button>
      </div>
    </div>

    <p v-if="form.hasErrors" class="fae-sr-only" role="alert">
      This form has errors.
    </p>

    <!--
      Nested tables render inside the form, where the Slim version put them.
      They still save on their own, which is safe because FaeNestedForm is a
      <div> and every control it owns is type="button" -- nothing it contains
      can be swept up by this form's submit.
    -->
    <template v-for="(section, index) in sections" :key="index">
      <div v-if="section.kind === 'field'" class="fae-panel fae-form">
        <FaeFormField
          v-for="field in section.fields"
          :key="field.name"
          :field="field"
          :error="form.errors[field.name]"
          v-model="form[field.name]"
        />
      </div>

      <FaeNestedTable v-else :table="section.table" />
    </template>
  </form>
</template>
