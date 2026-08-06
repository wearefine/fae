<script setup>
import { computed, ref, watch } from 'vue'

const props = defineProps({
  modelValue: { type: Boolean, default: false },
  path: { type: String, required: true },
  yesLabel: { type: String, default: 'Yes' },
  noLabel: { type: String, default: 'No' },
})

const emit = defineEmits(['update:modelValue'])

const busy = ref(false)
const value = ref(!!props.modelValue)

watch(
  () => props.modelValue,
  (next) => {
    value.value = !!next
  }
)

function csrfToken() {
  return document.querySelector('meta[name="csrf-token"]')?.content || ''
}

async function toggle() {
  if (busy.value) return

  busy.value = true
  try {
    const response = await fetch(props.path, {
      method: 'POST',
      credentials: 'same-origin',
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': csrfToken(),
      },
    })

    if (!response.ok) throw new Error(`Toggle failed: ${response.status}`)

    value.value = !value.value
    emit('update:modelValue', value.value)
  } catch (error) {
    console.error(error)
    window.dispatchEvent(new CustomEvent('fae:toast', {
      detail: { type: 'alert', message: 'Unable to update this toggle right now.' },
    }))
  } finally {
    busy.value = false
  }
}
</script>

<template>
  <button
    type="button"
    class="fae-toggle"
    :class="{ '-on': value, '-busy': busy }"
    :aria-pressed="value"
    :disabled="busy"
    @click="toggle"
  >
    <span class="fae-toggle__track">
      <span class="fae-toggle__thumb" />
    </span>
    <span class="fae-toggle__label">{{ value ? yesLabel : noLabel }}</span>
  </button>
</template>
