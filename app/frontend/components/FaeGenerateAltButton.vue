<script setup>
import { computed, ref } from 'vue'

const props = defineProps({
  imageId: { type: [String, Number, null], default: null },
  imageFile: { type: [File, Object, null], default: null },
  path: { type: String, required: true },
  disabled: { type: Boolean, default: false },
  buttonClass: { type: String, default: 'fae-button -secondary -sm' },
})

const emit = defineEmits(['generated', 'error'])

const generating = ref(false)

const unavailable = computed(() => !props.imageId && !props.imageFile)
const blocked = computed(() => props.disabled || generating.value || unavailable.value)

function notify(type, message) {
  window.dispatchEvent(new CustomEvent('fae:toast', { detail: { type, message } }))
}

function csrfToken() {
  return document.querySelector('meta[name="csrf-token"]')?.content || ''
}

function readFileAsDataUrl(file) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader()
    reader.onload = () => resolve(reader.result)
    reader.onerror = () => reject(reader.error)
    reader.readAsDataURL(file)
  })
}

async function generate() {
  if (blocked.value) return

  generating.value = true
  try {
    let response

    if (props.imageFile) {
      const image = await readFileAsDataUrl(props.imageFile)
      const body = new URLSearchParams({ image })

      response = await fetch(props.path, {
        method: 'POST',
        credentials: 'same-origin',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': csrfToken(),
        },
        body,
      })
    } else {
      response = await fetch(`${props.path}?image_id=${props.imageId}`, {
        method: 'POST',
        credentials: 'same-origin',
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': csrfToken(),
        },
      })
    }

    const data = await response.json()

    if (!response.ok || data.success === false || !data.content) {
      const message = data?.message || 'Unable to generate alt text.'
      notify('alert', message)
      emit('error', message)
      return
    }

    notify('notice', 'Alt text generated.')
    emit('generated', data.content)
  } catch (error) {
    notify('alert', 'Unable to generate alt text right now.')
    emit('error', error)
    console.error(error)
  } finally {
    generating.value = false
  }
}
</script>

<template>
  <button
    type="button"
    :class="buttonClass"
    :disabled="blocked"
    @click="generate"
  >
    {{ generating ? 'Generating…' : 'Generate' }}
  </button>
</template>
