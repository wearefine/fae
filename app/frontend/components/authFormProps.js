/**
 * Prop contract shared by FaeAuthForm and every page that renders it.
 *
 * The page components are pass-throughs, but they still have to declare the
 * props so Inertia's page data reaches the form rather than falling through as
 * attributes -- keeping the definition here avoids restating it five times.
 */
export const authFormProps = {
  title: { type: String, required: true },
  intro: { type: String, default: null },
  submitPath: { type: String, required: true },
  submitMethod: { type: String, default: 'post' },
  paramKey: { type: String, default: 'user' },
  fields: { type: Array, default: () => [] },
  hidden: { type: Object, default: () => ({}) },
  submitText: { type: String, required: true },
}
