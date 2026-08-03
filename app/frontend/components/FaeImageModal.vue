<script setup>
import { ref } from 'vue'

/**
 * Full-size preview of an uploaded image, the counterpart of the
 * .js-image-modal handler in fae/_modals.js.
 *
 * The legacy version measured the image and sized a jQuery modal to it. Here
 * the dialog has no padding and shrink-wraps the image, so the modal is the
 * image -- its aspect ratio matches by construction and the viewport caps live
 * entirely in CSS.
 */
defineProps({
  src: { type: String, default: null },
  alt: { type: String, default: '' },
  label: { type: String, default: 'Image preview' },
})

const dialog = ref(null)
// The form shows a thumbnail, so the full-size asset is not fetched until it
// is actually asked for.
const requested = ref(false)

// Open state is owned here rather than mirrored from a prop: <dialog> closes
// itself on Escape and on the backdrop, and holding that state in two places
// desynchronises the moment it does.
function show() {
  requested.value = true
  dialog.value?.showModal()
}

// The image fills the dialog, so a click landing on the dialog itself is the
// backdrop.
function onClick(event) {
  if (event.target === dialog.value) dialog.value.close()
}

defineExpose({ show })
</script>

<template>
  <!-- showModal() is what puts this in the top layer and brings the backdrop,
       focus trap and Escape handling with it. -->
  <dialog ref="dialog" class="fae-image-modal" :aria-label="label" @click="onClick">
    <img v-if="requested" class="fae-image-modal__image" :src="src" :alt="alt">

    <button
      type="button"
      class="fae-image-modal__close"
      aria-label="Close preview"
      @click="dialog.close()"
    >
      &times;
    </button>
  </dialog>
</template>
