import { createApp, h } from 'vue'
import { createInertiaApp } from '@inertiajs/vue3'
import FaeLayout from './layouts/FaeLayout.vue'
import { FAE_COMPONENT_OVERRIDES, normalizeComponentOverrides } from './overrides.js'

// Fae 5's own stylesheet, built by Vite. Deliberately unrelated to the
// Sprockets Sass bundle that styles the remaining Slim screens -- see
// styles/index.css. Host apps restyle by overriding the custom properties in
// styles/tokens.css, not by importing anything from here.
import './styles/index.css'

// Pages shipped by the engine itself.
const enginePages = import.meta.glob('./pages/**/*.vue')

// Glob keys are relative to the file that called import.meta.glob, so engine
// and host maps arrive with different prefixes. Reduce both to the bare page
// name ("Fae/Index") so they can be looked up interchangeably.
function byPageName(modules) {
  const out = {}
  for (const [key, loader] of Object.entries(modules)) {
    const match = key.match(/pages\/(.+)\.vue$/)
    if (match) out[match[1]] = loader
  }
  return out
}

/**
 * Boots the Fae admin.
 *
 * This is the v5 replacement for overriding Slim partials. A host app passes
 * its own page modules and they take precedence over Fae's, so any screen can
 * be replaced without forking the engine:
 *
 *   createFaeApp({ pages: import.meta.glob('../pages/**\/*.vue') })
 *
 * Host apps can also override engine components globally without replacing an
 * entire page:
 *
 *   createFaeApp({
 *     pages: import.meta.glob('../pages/**\/*.vue'),
 *     components: import.meta.glob('../components/**\/*.vue')
 *   })
 */
export function createFaeApp({ pages = {}, components = {} } = {}) {
  const engine = byPageName(enginePages)
  const host = byPageName(pages)
  const componentOverrides = normalizeComponentOverrides(components)

  return createInertiaApp({
    resolve: (name) => {
      const loader = host[name] || engine[name]

      if (!loader) {
        throw new Error(
          `[Fae] No page component found for "${name}". ` +
            `Expected "pages/${name}.vue" in the host app or the engine.`
        )
      }

      return Promise.resolve(loader()).then((mod) => {
        const page = mod.default
        // Opt out with `defineOptions({ layout: null })` in a page component.
        if (page.layout === undefined) page.layout = FaeLayout
        return page
      })
    },

    setup({ el, App, props, plugin }) {
      const app = createApp({ render: () => h(App, props) })
      app.provide(FAE_COMPONENT_OVERRIDES, componentOverrides)
      app.use(plugin).mount(el)
    },
  })
}

export { FaeLayout }
