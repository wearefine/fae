// import { createApp } from 'vue'
// import App from '../App.vue'
// createApp(App).mount('#app')

// import { createApp, h } from 'vue'
// import { createInertiaApp } from '@inertiajs/vue3'

// console.log('app js')

// // const pages = import.meta.glob('../pages/**/*.vue', { eager: true });

  
// createInertiaApp({
//   id: 'app',
//   resolve: name => {
//     const pages = import.meta.glob('../pages/**/*.vue', { eager: true })
//     return pages[`../pages/${name}.vue`]
//   },
//   setup({ el, App, props, plugin }) {
//     const vueApp = createApp({
//       render: () => h(App, props),
//     });
//     vueApp.use(plugin).mount(el);
//   },
// })