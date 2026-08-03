<script setup>
import { computed, ref, useId, watch } from 'vue'

import FaeImageModal from './FaeImageModal.vue'

/**
 * An image or file uploader: the Vue counterpart of fae_image_form and
 * fae_file_form (fae/images/_image_uploader, fae/application/_file_uploader).
 *
 * Behavioural parity with form/drag_drop.js and form/fileinputer.js -- drop a
 * file anywhere on the field, refuse anything over the initializer's limit,
 * preview what is stored, and delete it without saving the parent form.
 */
const props = defineProps({
  field: { type: Object, required: true },
  modelValue: { type: Object, default: () => ({}) },
  error: { type: String, default: null },
})

const emit = defineEmits(['update:modelValue'])

const config = computed(() => props.field.asset)

// Mirrored locally because deleting an asset is a bare DELETE that answers
// `head :ok` -- there is no Inertia response to re-render the page from, which
// is also why the legacy handler just faded the preview out.
const stored = ref(props.field.asset.current)
watch(() => props.field.asset.current, (current) => { stored.value = current })

const dragging = ref(false)
const sizeError = ref(null)
const deleting = ref(false)
const preview = ref(null)
const input = ref(null)

const uid = useId()
const inputId = computed(() => `${uid}-${props.field.name}`)
const altId = computed(() => `${uid}-${props.field.name}-alt`)
const captionId = computed(() => `${uid}-${props.field.name}-caption`)

const chosen = computed(() => props.modelValue?.asset || null)
const message = computed(() => sizeError.value || props.error)

const describedBy = computed(() => {
  const ids = []
  if (props.field.helperText) ids.push(`${inputId.value}-helper`)
  if (props.field.hint) ids.push(`${inputId.value}-hint`)
  if (message.value) ids.push(`${inputId.value}-error`)
  return ids.join(' ') || undefined
})

function update(patch) {
  emit('update:modelValue', { ...props.modelValue, ...patch })
}

// Modified clicks keep the anchor's normal behaviour, so the full-size asset
// can still be opened in a new tab.
function onFilenameClick(event) {
  if (config.value.kind !== 'image') return
  if (event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) return

  event.preventDefault()
  preview.value?.show()
}

// The only gate on either path into the field, so dropping and choosing are
// policed identically.
function choose(file) {
  if (!file) return

  if (file.size / 1024 / 1024 > config.value.maxSize) {
    sizeError.value = config.value.maxSizeMessage
    clear()
    return
  }

  sizeError.value = null
  update({ asset: file })
}

function clear() {
  // The picker keeps its selection otherwise, and re-choosing the same file
  // would then fire no change event.
  if (input.value) input.value.value = ''
  update({ asset: null })
}

function onDrop(event) {
  dragging.value = false
  const file = event.dataTransfer?.files?.[0]
  if (!file) return

  // Assigning the FileList keeps the native input and the model in step, so
  // the field behaves the same however the file arrived.
  if (input.value) input.value.files = event.dataTransfer.files
  choose(file)
}

async function destroy() {
  if (!window.confirm(config.value.deleteConfirmation)) return

  deleting.value = true
  try {
    const response = await fetch(stored.value.deletePath, {
      method: 'DELETE',
      credentials: 'same-origin',
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content,
      },
    })
    if (!response.ok) throw new Error(`Delete failed: ${response.status}`)
    // The row survives with its asset stripped, so the id stays in the model
    // and the next upload updates the same record.
    stored.value = null
  } catch (error) {
    console.error(error)
  } finally {
    deleting.value = false
  }
}
</script>

<template>
  <div class="fae-field fae-asset-field" :class="{ '-invalid': !!message }">
    <label class="fae-field__label" :for="inputId">
      {{ field.label }}
      <abbr v-if="field.required" class="fae-field__required" title="required">*</abbr>
    </label>

    <p v-if="field.helperText" :id="`${inputId}-helper`" class="fae-field__helper">
      {{ field.helperText }}
    </p>

    <div v-if="stored" class="fae-asset-field__preview">
      <button
        v-if="config.kind === 'image'"
        type="button"
        class="fae-asset-field__zoom"
        :aria-label="`Preview ${field.label}`"
        @click="preview?.show()"
      >
        <img
          class="fae-asset-field__thumb"
          :src="stored.thumbUrl || stored.url"
          :alt="modelValue?.alt || ''"
        >
      </button>

      <a
        class="fae-asset-field__filename"
        :href="stored.url"
        target="_blank"
        rel="noopener noreferrer"
        @click="onFilenameClick"
      >{{ stored.filename }}</a>

      <button
        type="button"
        class="fae-asset-field__delete"
        :disabled="deleting"
        :aria-label="`Delete ${field.label}`"
        @click="destroy"
      >
        &times;
      </button>
    </div>

    <FaeImageModal
      v-if="config.kind === 'image' && stored"
      ref="preview"
      :src="stored.url"
      :alt="modelValue?.alt || ''"
      :label="field.label"
    />

    <!--
      The whole zone is the drop target, not just the input, which is what the
      legacy handler bound to .input.field. dragover must be cancelled or the
      browser navigates to the dropped file instead.
    -->
    <div
      class="fae-asset-field__dropzone"
      :class="{ '-dragging': dragging }"
      @dragenter.prevent.stop="dragging = true"
      @dragover.prevent.stop="dragging = true"
      @dragleave.prevent.stop="dragging = false"
      @drop.prevent.stop="onDrop"
    >
      <input
        :id="inputId"
        ref="input"
        class="fae-asset-field__input"
        type="file"
        :accept="config.accept"
        :aria-invalid="!!message"
        :aria-describedby="describedBy"
        @change="choose($event.target.files[0])"
      >

      <p class="fae-asset-field__prompt">
        <template v-if="chosen">
          {{ chosen.name }}
          <button type="button" class="fae-asset-field__undo" @click="clear">Remove</button>
        </template>
        <template v-else>
          or drop {{ config.kind === 'image' ? 'an image' : 'a file' }} here
          <span class="fae-asset-field__limit">(max {{ config.maxSize }} MB)</span>
        </template>
      </p>
    </div>

    <template v-if="config.showAlt">
      <label class="fae-field__label" :for="altId">{{ config.altLabel }}</label>
      <p v-if="config.altHelperText" class="fae-field__helper">{{ config.altHelperText }}</p>
      <input
        :id="altId"
        class="fae-field__control"
        type="text"
        :value="modelValue?.alt"
        @input="update({ alt: $event.target.value })"
      >
    </template>

    <template v-if="config.showCaption">
      <label class="fae-field__label" :for="captionId">{{ config.captionLabel }}</label>
      <p v-if="config.captionHelperText" class="fae-field__helper">{{ config.captionHelperText }}</p>
      <input
        :id="captionId"
        class="fae-field__control"
        type="text"
        :value="modelValue?.caption"
        @input="update({ caption: $event.target.value })"
      >
    </template>

    <p v-if="field.hint" :id="`${inputId}-hint`" class="fae-field__hint">{{ field.hint }}</p>
    <p v-if="message" :id="`${inputId}-error`" class="fae-field__error">{{ message }}</p>
  </div>
</template>
