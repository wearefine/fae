import { inject, provide } from 'vue'

const FAE_FORM_CONTEXT = Symbol('fae-form-context')

export function provideFaeFormContext(context) {
  provide(FAE_FORM_CONTEXT, context)
  return context
}

export function useFaeFormContext() {
  const context = inject(FAE_FORM_CONTEXT, null)

  if (!context) {
    throw new Error('[Fae] Form building blocks must be rendered inside Fae/Form.')
  }

  return context
}