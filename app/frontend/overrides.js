import { defineAsyncComponent } from 'vue'

export const FAE_COMPONENT_OVERRIDES = Symbol('fae-component-overrides')

function byComponentName(modules) {
  const out = {}

  for (const [key, loader] of Object.entries(modules || {})) {
    const match = key.match(/components\/(.+)\.vue$/)
    if (!match) continue

    out[match[1]] = loader
  }

  return out
}

function toComponent(loaderOrComponent) {
  if (typeof loaderOrComponent !== 'function') return loaderOrComponent

  return defineAsyncComponent(() => Promise.resolve(loaderOrComponent()).then((mod) => mod.default || mod))
}

// Accepts either a glob map (import.meta.glob) or a direct
// { ComponentName: Component } / { ComponentName: () => import(...) } map.
export function normalizeComponentOverrides(overrides = {}) {
  const fromGlob = byComponentName(overrides)
  const source = Object.keys(fromGlob).length ? fromGlob : overrides
  const out = {}

  Object.entries(source || {}).forEach(([name, value]) => {
    out[name] = toComponent(value)
  })

  return out
}
