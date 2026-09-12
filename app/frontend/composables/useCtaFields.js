import { computed } from 'vue'

export function useCtaFields(fields) {
  const ctaFields = computed(() => fields.value.filter((field) => field.cta))

  function toParams(data) {
    const params = { ...data }

    for (const field of ctaFields.value) {
      const value = data[field.name] || {}
      delete params[field.name]

      params[field.cta.paramKey] = {
        ...(value.id ? { id: value.id } : {}),
        cta_label: value.label || '',
        cta_link: value.link || '',
        cta_alt_text: value.altText || '',
      }
    }

    return params
  }

  return { ctaFields, toParams }
}