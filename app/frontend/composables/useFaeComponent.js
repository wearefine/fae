import { inject } from 'vue'

import { FAE_COMPONENT_OVERRIDES } from '../overrides.js'

export function useFaeComponent(name, fallbackComponent) {
  const overrides = inject(FAE_COMPONENT_OVERRIDES, null)
  return overrides?.[name] || fallbackComponent
}
