<script setup>
import { useFlashToasts } from '../composables/useFlashToasts.js'

/**
 * The flash toast stack. Replaces fae/application/_flash_messages.slim plus
 * the jQuery that animated it.
 */
const { toasts } = useFlashToasts()
</script>

<template>
  <!--
    aria-live rather than role="alert": a saved-confirmation should be
    announced once the screen reader finishes what it is saying, not cut it
    off. The region has to exist before a toast enters it or nothing is
    announced, so it is always rendered.
  -->
  <div class="fae-toasts" aria-live="polite" aria-atomic="false">
    <TransitionGroup name="fae-toast">
      <div
        v-for="toast in toasts"
        :key="toast.id"
        class="fae-toast"
        :class="`-${toast.type}`"
      >
        {{ toast.message }}
      </div>
    </TransitionGroup>
  </div>
</template>
