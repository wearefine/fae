<!-- 
  -- A project specific/styled implementation of BaseDialog
-->
<template>
  <BaseDialog
    no-scroll
    :model-value="state.internalShow"
    :dismissible="!noClose"
    transition="fade"
    class="base-modal bg-black/30"
    v-bind="$attrs"
    @update:model-value="toggleOpen"
    :classes="{
      content: 'relative mx-auto w-screen max-w-3xl bg-white p-8',
    }"
  >
    <template #toggle="toggleProps">
      <slot name="toggle" v-bind="toggleProps"></slot>
    </template>
    <template #default="{ isOpen }">
      <button
        v-if="!noClose && !hideX"
        aria-label="Close modal"
        class="absolute right-4 top-4 z-10"
        @click="toggleOpen(false)"
      >
        &times;
      </button>
      <slot v-bind="{ toggleOpen, isOpen }"></slot>
    </template>
  </BaseDialog>
</template>

<script lang="ts" setup>
import BaseDialog from '~/components/base/BaseDialog.vue'
import { reactive, watch } from 'vue'

const props = defineProps<{
  show?: boolean
  /**
   * Disable manual closing of the modal (with the X button or clicking on the background)
   */
  noClose?: boolean
  /**
   * Hides the X button for closing
   */

  hideX?: boolean
  /**
   * Additional classes to apply to the BaseDialog
   */
  classes?: Record<string, string>
  /**
   * Initial element to focus when modal is opened, defaults to first focusable element (close button)
   */
  initialFocus?: HTMLElement | null
}>()

const emit = defineEmits(['update:show'])

const state = reactive({
  internalShow: props.show,
})

watch(() => props.show, (value) => {
  state.internalShow = value
})

function toggleOpen(value: boolean) {
  state.internalShow = value ?? !state.internalShow
  emit('update:show', state.internalShow)
}
</script>

<style lang="postcss">
.base-modal {
}
</style>
