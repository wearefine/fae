<script setup>
import { nextTick, ref } from 'vue'

/**
 * A textarea with a markdown toolbar, for fields declared `markdown: true`.
 *
 * The control stays a real <textarea> rather than the contenteditable surface
 * SimpleMDE swapped in, so the value, the label association and the browser's
 * own spellcheck/undo all keep working. The toolbar only rewrites the
 * selection.
 */
const props = defineProps({
  modelValue: { type: String, default: '' },
  id: { type: String, required: true },
  describedBy: { type: String, default: undefined },
  invalid: { type: Boolean, default: false },
})

const emit = defineEmits(['update:modelValue'])

const textarea = ref(null)

// Editing through execCommand rather than by assigning to .value keeps the
// browser's native undo stack intact -- otherwise ctrl-Z wipes the whole field
// after any toolbar click. Deprecated, but there is still no replacement for
// undoable programmatic edits, and setRangeText covers browsers that refuse.
function replace(start, end, text, selectionStart, selectionEnd) {
  const el = textarea.value

  el.focus()
  el.setSelectionRange(start, end)

  if (!document.execCommand('insertText', false, text)) {
    el.setRangeText(text, start, end, 'end')
  }

  emit('update:modelValue', el.value)
  nextTick(() => el.setSelectionRange(selectionStart, selectionEnd ?? selectionStart))
}

function escapeRegExp(string) {
  return string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
}

// Wraps the selection, or unwraps it when the tokens are already there, so the
// toolbar button reads as a toggle the way every other editor's does.
function wrap(token) {
  const el = textarea.value
  const value = el.value
  const { selectionStart: start, selectionEnd: end } = el
  const length = token.length

  if (value.slice(start - length, start) === token && value.slice(end, end + length) === token) {
    replace(start - length, end + length, value.slice(start, end), start - length, end - length)
    return
  }

  const selected = value.slice(start, end)
  replace(start, end, token + selected + token, start + length, start + length + selected.length)
}

// Applies to every line the selection touches, not just the character range,
// since a heading or list marker belongs at the start of a line.
function prefix(token) {
  const el = textarea.value
  const value = el.value
  const ordered = token === '1. '
  const pattern = ordered ? /^\d+\. / : new RegExp(`^${escapeRegExp(token)}`)

  const start = value.lastIndexOf('\n', el.selectionStart - 1) + 1
  const end = value.indexOf('\n', el.selectionEnd) === -1
    ? value.length
    : value.indexOf('\n', el.selectionEnd)

  const lines = value.slice(start, end).split('\n')
  const applied = lines.every((line) => pattern.test(line))
  const next = lines
    .map((line, index) => (applied ? line.replace(pattern, '') : (ordered ? `${index + 1}. ` : token) + line))
    .join('\n')

  replace(start, end, next, start, start + next.length)
}

function link() {
  const el = textarea.value
  const { selectionStart: start, selectionEnd: end } = el
  const text = el.value.slice(start, end) || 'text'

  // Leaves "url" selected so it can be typed straight over.
  replace(start, end, `[${text}](url)`, start + text.length + 3, start + text.length + 6)
}

const tools = [
  { label: 'Bold', mark: 'B', className: '-bold', run: () => wrap('**') },
  { label: 'Italic', mark: 'I', className: '-italic', run: () => wrap('_') },
  { label: 'Heading', mark: 'H', run: () => prefix('## ') },
  { label: 'Link', mark: '🔗', run: link },
  { label: 'Bulleted list', mark: '•', run: () => prefix('- ') },
  { label: 'Numbered list', mark: '1.', run: () => prefix('1. ') },
  { label: 'Quote', mark: '❝', run: () => prefix('> ') },
  { label: 'Code', mark: '</>', run: () => wrap('`') },
]

function onKeydown(event) {
  if (!(event.metaKey || event.ctrlKey)) return

  const shortcut = { b: () => wrap('**'), i: () => wrap('_'), k: link }[event.key.toLowerCase()]
  if (!shortcut) return

  event.preventDefault()
  shortcut()
}
</script>

<template>
  <div class="fae-markdown" :class="{ '-invalid': invalid }">
    <!-- mousedown.prevent on each button: taking focus would collapse the
         textarea's selection, and every command works on that selection. -->
    <div class="fae-markdown__toolbar" role="toolbar" aria-label="Markdown formatting">
      <button
        v-for="tool in tools"
        :key="tool.label"
        type="button"
        class="fae-markdown__tool"
        :class="tool.className"
        :title="tool.label"
        :aria-label="tool.label"
        @mousedown.prevent
        @click="tool.run"
      >
        {{ tool.mark }}
      </button>
    </div>

    <textarea
      :id="id"
      ref="textarea"
      class="fae-markdown__input"
      rows="12"
      spellcheck="true"
      :value="modelValue"
      :aria-invalid="invalid"
      :aria-describedby="describedBy"
      @input="emit('update:modelValue', $event.target.value)"
      @keydown="onKeydown"
    />
  </div>
</template>
