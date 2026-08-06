<script setup>
import { computed, ref, watch } from 'vue'
import FaeGenerateAltButton from './FaeGenerateAltButton.vue'

const EMPTY_LABEL = 'No alt text'

const props = defineProps({
  row: { type: Object, required: true },
  canGenerateAlt: { type: Boolean, default: false },
  generateAltPath: { type: String, required: true },
})

const emit = defineEmits(['updated'])

const editing = ref(false)
const saving = ref(false)
const draft = ref('')
const currentAlt = ref(props.row.alt || '')

watch(
  () => props.row.alt,
  (next) => {
    currentAlt.value = next || ''
  }
)

const label = computed(() => (currentAlt.value ? currentAlt.value : EMPTY_LABEL))

function notify(type, message) {
  window.dispatchEvent(new CustomEvent('fae:toast', { detail: { type, message } }))
}

function csrfToken() {
  return document.querySelector('meta[name="csrf-token"]')?.content || ''
}

function beginEdit() {
  draft.value = currentAlt.value
  editing.value = true
}

function cancel() {
  draft.value = currentAlt.value
  editing.value = false
}

async function save() {
  if (saving.value) return

  saving.value = true
  try {
    const body = new URLSearchParams({ alt: draft.value || '' })
    const response = await fetch(props.row.updatePath, {
      method: 'POST',
      credentials: 'same-origin',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': csrfToken(),
      },
      body,
    })

    if (!response.ok) throw new Error(`Save failed: ${response.status}`)

    currentAlt.value = draft.value || ''
    editing.value = false
    emit('updated', currentAlt.value)
    notify('notice', 'Alt text saved.')
  } catch (error) {
    notify('alert', 'Unable to save alt text right now.')
    console.error(error)
  } finally {
    saving.value = false
  }
}

</script>

<template>
  <div class="fae-alt-editor">
    <p v-if="!editing" class="fae-alt-editor__label">{{ label }}</p>

    <textarea
      v-else
      v-model="draft"
      class="fae-field__control fae-alt-editor__input"
      rows="3"
    />

    <div class="fae-alt-editor__actions">
      <button v-if="!editing" type="button" class="fae-button -secondary -sm" @click="beginEdit">
        Edit
      </button>

      <template v-else>
        <button type="button" class="fae-button -sm" :disabled="saving" @click="save">
          {{ saving ? 'Saving…' : 'Save' }}
        </button>

        <button type="button" class="fae-button -secondary -sm" :disabled="saving || generating" @click="cancel">
          Cancel
        </button>

        <FaeGenerateAltButton
          v-if="canGenerateAlt"
          :image-id="row.id"
          :path="generateAltPath"
          :disabled="saving"
          @generated="draft = $event"
        />
      </template>
    </div>
  </div>
</template>
