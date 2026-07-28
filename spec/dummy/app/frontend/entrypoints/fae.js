// This file is what a Fae 5 host app writes. Everything else comes from the
// engine. The glob lets this app override any Fae screen by dropping a
// matching component into app/frontend/pages.
import { createFaeApp } from '@fae/index.js'

createFaeApp({
  pages: import.meta.glob('../pages/**/*.vue'),
})
