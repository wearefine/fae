import { createApp, h } from 'vue'
import { createInertiaApp } from '@inertiajs/vue3'
// import { createInertiaApp } from '@fae/node_modules/@inertiajs/vue3'
import '@fae/app/frontend/assets/stylesheets/global.css'


console.log('host app')

const pages = import.meta.glob('../pages/**/*.vue', { eager: true });

createInertiaApp({
  resolve: name => {
    console.log('resolve run')
    const component = pages[`../pages/${name}.vue`];
    if (!component)
      throw new Error(
        `Unknown page ${name}. Check path and file extension is correct.`,
      );

    return component
  },
  setup({ el, App, props, plugin }) {
    console.log('setup run')
    const vueApp = createApp({
      render: () => h(App, props),
    });
    vueApp.use(plugin).mount(el);
  },
})

  