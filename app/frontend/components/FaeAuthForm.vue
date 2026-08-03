<script setup>
import { computed, onMounted, ref } from 'vue'
import { usePage } from '@inertiajs/vue3'

import FaeFormField from './FaeFormField.vue'
import { authFormProps } from './authFormProps.js'

/**
 * The form shared by every signed-out screen. Each page component is a thin
 * wrapper around this, so a host app can override one screen through the
 * `pages` seam without inheriting the others.
 *
 * Deliberately a NATIVE submit, unlike the signed-in forms which post through
 * Inertia's useForm. Signing in redirects to the dashboard, which is still a
 * Slim screen; an Inertia visit that follows a redirect into unconverted HTML
 * pops the client's error modal. Letting the browser submit also means these
 * screens keep working with JavaScript disabled and stay legible to password
 * managers.
 */
const props = defineProps(authFormProps)

const page = usePage()

const form = ref(null)
const submitting = ref(false)

// Errors from a failed submit; the controller stashes them in the session and
// inertia_rails republishes them on the redirected-to page.
const errors = computed(() => page.props.errors || {})

const csrfToken = ref('')

const values = ref(
  Object.fromEntries(props.fields.map((field) => [field.name, field.value ?? '']))
)

// Adds the name attribute the browser needs to serialize the form. The
// signed-in forms leave it off, since Inertia sends their data as JSON.
const fields = computed(() =>
  props.fields.map((field) => ({ ...field, inputName: `${props.paramKey}[${field.name}]` }))
)

onMounted(() => {
  csrfToken.value = document.querySelector('meta[name="csrf-token"]')?.content || ''

  // Every one of these screens autofocused its first input; doing it here
  // rather than with the autofocus attribute is what makes it fire, since Vue
  // mounts the form long after the document has loaded.
  form.value?.querySelector('input:not([type="hidden"]), textarea, select')?.focus()
})
</script>

<template>
  <form
    ref="form"
    class="fae-auth__form"
    :action="submitPath"
    method="post"
    @submit="submitting = true"
  >
    <input type="hidden" name="authenticity_token" :value="csrfToken">
    <!-- Rack::MethodOverride turns this into the real verb. -->
    <input v-if="submitMethod !== 'post'" type="hidden" name="_method" :value="submitMethod">
    <input
      v-for="(value, key) in hidden"
      :key="key"
      type="hidden"
      :name="`${paramKey}[${key}]`"
      :value="value"
    >

    <h2 class="fae-auth__heading">{{ title }}</h2>
    <p v-if="intro" class="fae-auth__intro">{{ intro }}</p>

    <template v-for="field in fields" :key="field.name">
      <!-- An unchecked box sends nothing, so Rails needs the companion the
           check_box helper emits to record a deliberate "no". -->
      <input v-if="field.type === 'checkbox'" type="hidden" :name="field.inputName" value="0">

      <FaeFormField
        :field="field"
        :error="errors[field.name]"
        v-model="values[field.name]"
      />
    </template>

    <button type="submit" class="fae-button" :disabled="submitting">
      {{ submitting ? 'Working…' : submitText }}
    </button>
  </form>
</template>
