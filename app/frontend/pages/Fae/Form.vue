<script setup>
import { computed, nextTick, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { useForm, usePage } from '@inertiajs/vue3'

import FaeBreadcrumbs from '../../components/FaeBreadcrumbs.vue'
import FaeFormField from '../../components/FaeFormField.vue'
import FaeFlexComponentsTable from '../../components/FaeFlexComponentsTable.vue'
import FaeNestedTable from '../../components/FaeNestedTable.vue'
import { assetSubmitOptions, useAssetFields } from '../../composables/useAssetFields.js'
import { useFaeComponent } from '../../composables/useFaeComponent.js'
import { useSlugger } from '../../composables/useSlugger.js'
import { useFormGuard } from '../../composables/useFormGuard.js'
import { provideUnsavedChanges } from '../../composables/useUnsavedChanges.js'

// Saving the parent would leave a half-filled nested form behind, so it is
// worth interrupting for. Wording kept from _validator.js.
const NESTED_UNSAVED_MESSAGE =
  'A nested form has unsaved changes! To return to your draft, click “Cancel.” ' +
  'To proceed without saving, click “OK.”'

// Inertia passes shared props (currentUser, flash, nav) to every page, and
// this template has multiple root nodes.
defineOptions({ inheritAttrs: false })

// Like Fae/Index, this page is generic: the controller describes the fields
// and this renders them. It replaces both _form.html.slim and the shared
// form_header partial.
const props = defineProps({
  title: { type: String, required: true },
  indexPath: { type: String, required: true },
  submitPath: { type: String, required: true },
  submitMethod: { type: String, default: 'put' },
  // Rails wants params nested under the model name; the transform below adds
  // that wrapper so `errors` still comes back keyed by the bare field name.
  paramKey: { type: String, required: true },
  // Inputs and nested tables in one ordered list, so a table renders in the
  // place the form declared it rather than after every input.
  blocks: { type: Array, default: () => [] },
  subnav: { type: Array, default: () => [] },
  // True when the record was created by Fae::BaseController#new and has not
  // been deliberately saved yet -- see useFormGuard.
  draft: { type: Boolean, default: false },
  deletePath: { type: String, default: null },
})

const page = usePage()

const fields = computed(() =>
  props.blocks.filter((block) => block.kind === 'field').map((block) => block.field)
)

const subnavLinks = computed(() => {
  const links = (props.subnav || []).filter((entry) => entry?.label && entry?.target)
  const withoutTop = links.filter((entry) => String(entry.target) !== 'top')
  return [{ label: 'Top', target: 'top' }, ...withoutTop]
})

const activeSubnavTarget = ref('')

// Runs of adjacent inputs share a panel, and a nested table breaks the run.
// Sections add the content-anchor structure legacy subnav relied on.
const sections = computed(() => {
  const grouped = props.blocks.reduce((out, block) => {
    const id = block.sectionId || '__default'
    const title = block.sectionTitle || null
    const last = out[out.length - 1]

    if (last?.id === id) {
      if (!last.title && title) last.title = title
      last.blocks.push(block)
    } else {
      out.push({ id: id === '__default' ? null : id, title, blocks: [block] })
    }

    return out
  }, [])

  return grouped.map((section) => {
    const mergedBlocks = section.blocks.reduce((out, block) => {
      if (block.kind !== 'field') {
        out.push(block)
        return out
      }

      const last = out[out.length - 1]
      if (last?.kind === 'field') last.fields.push(block.field)
      else out.push({ kind: 'field', fields: [block.field] })

      return out
    }, [])

    return { id: section.id, title: section.title, blocks: mergedBlocks }
  })
})

function sectionShowsHeading(section) {
  if (!section?.title) return false
  return section.blocks.some((block) => block.kind === 'field')
}

const form = useForm(
  Object.fromEntries(fields.value.map((field) => [field.name, field.value]))
)

const FaeFormFieldComponent = useFaeComponent('FaeFormField', FaeFormField)
const FaeNestedTableComponent = useFaeComponent('FaeNestedTable', FaeNestedTable)
const FaeFlexComponentsTableComponent = useFaeComponent('FaeFlexComponentsTable', FaeFlexComponentsTable)

const { hasAssets, toParams } = useAssetFields(fields)
useSlugger({ form, fields })

const USER_THEME_PREVIEWS = {
  light: { mode: 'light' },
  dark: { mode: 'dark' },
  indigo: { mode: 'light', highlight: '#4B0082' },
  darkstar: { mode: 'dark', highlight: '#ed0c0c' },
}

const canPreviewUserTheme = computed(() =>
  props.paramKey === 'user' && fields.value.some((field) => field.name === 'theme')
)

function applyUserThemePreview(themeName) {
  if (typeof document === 'undefined') return

  const root = document.documentElement
  const sharedTheme = page.props.theme || {}
  const key = String(themeName || '').toLowerCase()
  const preview = USER_THEME_PREVIEWS[key]

  const mode = preview?.mode || sharedTheme.mode || 'light'
  const highlight = preview?.highlight || sharedTheme.defaultHighlightColor || sharedTheme.highlightColor

  root.setAttribute('data-fae-theme', mode)
  if (highlight) root.style.setProperty('--fae-highlight', highlight)
  else root.style.removeProperty('--fae-highlight')
}

watch(
  () => form.theme,
  (next) => {
    if (!canPreviewUserTheme.value) return
    applyUserThemePreview(next)
  },
  { immediate: true }
)

// Nested tables open forms of their own inside this one, and their input is
// not part of this form's data -- it has to be accounted for separately both
// here and in the navigation guard.
const nestedUnsavedChanges = provideUnsavedChanges()
const { cancel, allowUnload } = useFormGuard(
  props,
  () => form.isDirty || nestedUnsavedChanges()
)

function submit() {
  if (nestedUnsavedChanges() && !window.confirm(NESTED_UNSAVED_MESSAGE)) return

  allowUnload()

  const { method, extraParams, forceFormData } = assetSubmitOptions(hasAssets.value, props.submitMethod)

  form
    .transform((data) => ({ [props.paramKey]: toParams(data), ...extraParams }))
    // A failed save redirects back to this same URL, so the component is not
    // remounted and the user's input survives in `form` while the errors
    // arrive as page props.
    [method](props.submitPath, { preserveScroll: true, preserveState: true, forceFormData })
}

function clearTransientOpenHints() {
  if (typeof window === 'undefined') return

  const url = new URL(window.location.href)
  const keys = [
    'open_flex_component_id',
    'open_nested_assoc',
    'open_nested_row_id',
    'open_nested_new',
  ]

  const hadAny = keys.some((key) => url.searchParams.has(key))
  if (!hadAny) return

  keys.forEach((key) => url.searchParams.delete(key))
  window.history.replaceState({}, '', `${url.pathname}${url.search}${url.hash}`)
}

function updateActiveSubnav() {
  if (!subnavLinks.value.length || typeof document === 'undefined') return

  const stickyHeader = document.querySelector('.fae-page-header.-sticky-form')
  const offset = (stickyHeader?.getBoundingClientRect().height || 0) + 8
  let active = subnavLinks.value[0]?.target || ''

  for (const link of subnavLinks.value) {
    const el = document.getElementById(link.target)
    if (!el) continue

    const top = el.getBoundingClientRect().top
    if (top - offset <= 0) active = link.target
  }

  activeSubnavTarget.value = active
}

function scrollToSection(target) {
  if (typeof document === 'undefined') return

  const el = document.getElementById(target)
  if (!el) return

  const stickyHeader = document.querySelector('.fae-page-header.-sticky-form')
  const offset = (stickyHeader?.getBoundingClientRect().height || 0) + 12
  const top = el.getBoundingClientRect().top + window.scrollY - offset

  window.scrollTo({ top, behavior: 'smooth' })
  activeSubnavTarget.value = target
}

onMounted(() => {
  clearTransientOpenHints()

  if (subnavLinks.value.length && typeof window !== 'undefined') {
    window.addEventListener('scroll', updateActiveSubnav, { passive: true })
    nextTick(updateActiveSubnav)
  }
})

onBeforeUnmount(() => {
  if (typeof window !== 'undefined') {
    window.removeEventListener('scroll', updateActiveSubnav)
  }
})

watch(
  () => props.blocks,
  () => {
    clearTransientOpenHints()
    nextTick(updateActiveSubnav)
  },
  { deep: true }
)
</script>

<template>
  <form @submit.prevent="submit">
    <div id="top" aria-hidden="true"></div>

    <div class="fae-page-header -sticky-form">
      <div class="fae-page-header__title -stacked">
        <FaeBreadcrumbs :title="title" :append-title="true" />
        <h1>{{ title }}</h1>
      </div>

      <div class="fae-page-header__actions">
        <button type="button" class="fae-button -secondary" @click="cancel">Cancel</button>
        <button type="submit" class="fae-button" :disabled="form.processing">
          {{ form.processing ? 'Saving…' : 'Save' }}
        </button>
      </div>

      <nav v-if="subnavLinks.length" class="fae-form-subnav" aria-label="Form sections">
        <ul class="fae-form-subnav__list">
          <li v-for="link in subnavLinks" :key="link.target" class="fae-form-subnav__item">
            <a
              :href="`#${link.target}`"
              class="fae-form-subnav__link"
              :class="{ '-active': activeSubnavTarget === link.target }"
              @click.prevent="scrollToSection(link.target)"
            >{{ link.label }}</a>
          </li>
        </ul>
      </nav>
    </div>

    <p v-if="form.hasErrors" class="fae-sr-only" role="alert">
      This form has errors.
    </p>

    <!--
      Nested tables render inside the form, where the Slim version put them.
      They still save on their own, which is safe because FaeNestedForm is a
      <div> and every control it owns is type="button" -- nothing it contains
      can be swept up by this form's submit.
    -->
    <section
      v-for="(section, sectionIndex) in sections"
      :id="section.id || null"
      :key="section.id || `section-${sectionIndex}`"
      class="fae-form-section"
      :data-fae-section="section.id || null"
    >
      <h2 v-if="sectionShowsHeading(section)" class="fae-form-section__title">{{ section.title }}</h2>

      <template v-for="(block, blockIndex) in section.blocks" :key="`${section.id || sectionIndex}-${block.kind}-${blockIndex}`">
        <div v-if="block.kind === 'field'" class="fae-panel fae-form">
          <component
            :is="FaeFormFieldComponent"
            v-for="field in block.fields"
            :key="field.name"
            :field="field"
            :error="form.errors[field.name]"
            v-model="form[field.name]"
          />
        </div>

        <component
          :is="FaeNestedTableComponent"
          v-else-if="block.kind === 'nestedTable'"
          :table="block.table"
        />

        <component
          :is="FaeFlexComponentsTableComponent"
          v-else-if="block.kind === 'flexComponentsTable'"
          :table="block.table"
        />
      </template>
    </section>
  </form>
</template>
