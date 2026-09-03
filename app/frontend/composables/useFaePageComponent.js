import { defineAsyncComponent, inject } from 'vue'

export const FAE_PAGE_COMPONENTS = Symbol('fae-page-components')

export function useFaePageComponent(name) {
  const pages = inject(FAE_PAGE_COMPONENTS, {})
  const loader = pages[name]

  if (!loader) return null

  return defineAsyncComponent(() => Promise.resolve(loader()).then((mod) => mod.default || mod))
}