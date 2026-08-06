import { computed, ref, watch } from 'vue'

function normalize(value) {
  return String(value ?? '').trim()
}

function slugify(text, separator = '-') {
  const escaped = separator.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')

  return normalize(text)
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replace(new RegExp(`[^${escaped}\\w\\s]`, 'g'), '')
    .replace(new RegExp(`[${escaped}\\s]+`, 'g'), separator)
    .replace(new RegExp(`(^${escaped})|(${escaped}$)`, 'g'), '')
}

function isSlugField(field) {
  const name = String(field?.name || '')
  return /(^|_)slug$/.test(name)
}

/**
 * Legacy slugger parity:
 * - fields marked slugSource generate a slug into slug fields in the same form
 * - generation stops as soon as any slug field has a pre-existing or user-edited value
 */
export function useSlugger({ form, fields, slugSeparator = '-' }) {
  const sourceNames = computed(() =>
    fields.value.filter((field) => field?.slugSource).map((field) => field.name)
  )

  const targetNames = computed(() =>
    fields.value.filter((field) => isSlugField(field)).map((field) => field.name)
  )

  const enabled = computed(() => sourceNames.value.length > 0 && targetNames.value.length > 0)

  const initialized = ref(false)
  const locked = ref(false)
  const programmaticWrite = ref(false)
  const sourceSignature = computed(() => sourceNames.value.map((name) => normalize(form[name])).join('\u0001'))

  const generated = computed(() => {
    const sourceText = sourceNames.value.map((name) => form[name]).join(' ')
    return slugify(sourceText, slugSeparator)
  })

  // Source typing drives slug updates until a slug field is manually edited.
  watch(
    () => ({
      enabled: enabled.value,
      sourceSignature: sourceSignature.value,
      generated: generated.value,
      targetValues: targetNames.value.map((name) => normalize(form[name])),
    }),
    ({ enabled: active, generated: candidate, targetValues }) => {
      if (!active) return

      if (!initialized.value) {
        initialized.value = true
        // Existing slug means this record already chose its permalink.
        locked.value = targetValues.some((value) => value !== '')
      }

      if (locked.value) return

      const unchanged = targetValues.every((value) => value === candidate)
      if (unchanged) return

      programmaticWrite.value = true
      targetNames.value.forEach((name) => {
        form[name] = candidate
      })
      queueMicrotask(() => {
        programmaticWrite.value = false
      })
    },
    { deep: true, immediate: true }
  )

  // Direct slug-field edits lock auto-generation for the rest of the session.
  watch(
    () => ({
      enabled: enabled.value,
      targets: targetNames.value.map((name) => normalize(form[name])),
      generated: generated.value,
    }),
    ({ enabled: active, targets, generated: candidate }) => {
      if (!active || !initialized.value || locked.value || programmaticWrite.value) return
      if (targets.some((value) => value !== '' && value !== candidate)) locked.value = true
    },
    { deep: true }
  )
}
