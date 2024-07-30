import { createApp, h } from 'vue'
import { createInertiaApp } from '@inertiajs/vue3'
import '@fae/app/frontend/assets/stylesheets/global.css'


console.log('host app')

// const pages = import.meta.glob('../pages/**/*.vue', { eager: true });

  
createInertiaApp({
  resolve: name => {
    const pages = import.meta.glob('../pages/**/*.vue', { eager: true })
    return pages[`../pages/${name}.vue`]
  },
  setup({ el, App, props, plugin }) {
    const vueApp = createApp({
      render: () => h(App, props),
    });
    vueApp.use(plugin).mount(el);
  },
})