// This file is what a Fae 5 host app writes. Everything else comes from the
// engine. The glob lets this app override any Fae screen by dropping a
// matching page into app/frontend/pages and any shared component into
// app/frontend/components.
import { createFaeApp } from '@fae/index.js'

createFaeApp({
  pages: import.meta.glob('../pages/**/*.vue'),
  components: import.meta.glob('../components/**/*.vue'),
})
