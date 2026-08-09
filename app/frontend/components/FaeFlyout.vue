<script setup>
import { onBeforeUnmount, watch } from 'vue'

const props = defineProps({
  open: { type: Boolean, default: false },
  title: { type: String, default: '' },
})

const emit = defineEmits(['close'])

function onKeydown(event) {
  if (event.key !== 'Escape') return
  emit('close')
}

watch(
  () => props.open,
  (open) => {
    if (typeof document === 'undefined' || typeof window === 'undefined') return

    if (open) {
      window.addEventListener('keydown', onKeydown)
      document.body.style.overflow = 'hidden'
    } else {
      window.removeEventListener('keydown', onKeydown)
      document.body.style.overflow = ''
    }
  },
  { immediate: true }
)

onBeforeUnmount(() => {
  if (typeof document !== 'undefined') document.body.style.overflow = ''
  if (typeof window !== 'undefined') window.removeEventListener('keydown', onKeydown)
})
</script>

<template>
  <Teleport to="body">
    <div v-if="open" class="fae-flyout">
      <button
        type="button"
        class="fae-flyout__backdrop"
        aria-label="Close panel"
        @click="emit('close')"
      ></button>

      <aside class="fae-flyout__panel" role="dialog" aria-modal="true" :aria-label="title || 'Panel'">
        <header class="fae-flyout__header">
          <h2>{{ title }}</h2>
        </header>

        <div class="fae-flyout__body">
          <slot />
        </div>

        <footer class="fae-flyout__footer">
          <slot name="footer" />
        </footer>
      </aside>
    </div>
  </Teleport>
</template>