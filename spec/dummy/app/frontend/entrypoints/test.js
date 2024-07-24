// import { createApp, h } from 'vue'
// import { createInertiaApp } from '@inertiajs/vue3'

// console.log('test js')

// document.addEventListener('DOMContentLoaded', () => {
  
  
//   createInertiaApp({
//     id: 'app',
//     resolve: name => {
//       const pages = import.meta.glob('../pages/**/*.vue', { eager: true })
//       return pages[`./pages/${name}.vue`]
//     },
//     setup({ el, App, props, plugin }) {
//       createApp({ render: () => h(App, props) })
//         .use(plugin)
//         .mount('#app')
//     },
//   })
// });