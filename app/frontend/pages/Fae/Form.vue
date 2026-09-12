<script setup>
import { computed, nextTick, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { useForm, usePage } from '@inertiajs/vue3'

import FaeBreadcrumbs from '../../components/FaeBreadcrumbs.vue'
import FaeFormField from '../../components/FaeFormField.vue'
import FaeFlexComponentsTable from '../../components/FaeFlexComponentsTable.vue'
import FaeNestedTable from '../../components/FaeNestedTable.vue'
import { assetSubmitOptions, useAssetFields } from '../../composables/useAssetFields.js'
import { useCtaFields } from '../../composables/useCtaFields.js'
import { useFaeComponent } from '../../composables/useFaeComponent.js'
import { useSlugger } from '../../composables/useSlugger.js'
import { useFormGuard } from '../../composables/useFormGuard.js'
import { provideFaeFormContext } from '../../composables/useFaeFormContext.js'
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
  recentChanges: { type: Object, default: null },
  // True when the record was created by Fae::BaseController#new and has not
  // been deliberately saved yet -- see useFormGuard.
  draft: { type: Boolean, default: false },
  deletePath: { type: String, default: null },
})

const page = usePage()

const languageNav = computed(() => {
  const nav = page.props.languageNav
  return nav && Array.isArray(nav.options) ? nav : null
})

const translateEnabled = computed(() => !!languageNav.value?.translateEnabled)
const translatePath = computed(() => String(languageNav.value?.translatePath || ''))

const languageOptions = computed(() => languageNav.value?.options || [])

const languageCodes = computed(() =>
  languageOptions.value
    .map((option) => String(option?.value || ''))
    .filter((value) => value.length > 0 && value !== 'all')
)

const selectedLanguage = ref('all')

watch(
  languageNav,
  (next) => {
    const allowed = new Set((next?.options || []).map((option) => String(option?.value || '')))
    const preferred = String(next?.selected || 'all')
    selectedLanguage.value = allowed.has(preferred) ? preferred : 'all'
  },
  { immediate: true }
)

const fields = computed(() =>
  props.blocks.filter((block) => block.kind === 'field').map((block) => block.field)
)

function fieldLanguage(field) {
  const name = String(field?.name || '')
  return languageCodes.value.find((language) => name.endsWith(`_${language}`)) || null
}

function isLanguageVisible(language) {
  if (!language) return true
  if (selectedLanguage.value === 'all') return true
  if (selectedLanguage.value === 'en') return language === 'en'

  return language === 'en' || language === selectedLanguage.value
}

function isFieldVisible(field) {
  return isLanguageVisible(fieldLanguage(field))
}

function visibleFields(fieldList) {
  const list = Array.isArray(fieldList) ? fieldList : []
  return list.filter((field) => isFieldVisible(field))
}

function formField(name) {
  return fields.value.find((field) => String(field?.name) === String(name)) || null
}

function tableBlock(kind, association) {
  return props.blocks.find((block) =>
    block.kind === kind && String(block.table?.association || '') === String(association)
  )?.table || null
}

function nestedTable(association) {
  return tableBlock('nestedTable', association)
}

function flexComponentsTable(association = 'flex_components') {
  return tableBlock('flexComponentsTable', association)
}

const showLanguageNav = computed(() => {
  if (!languageNav.value || languageCodes.value.length === 0) return false
  return fields.value.some((field) => fieldLanguage(field))
})

const fieldNames = computed(() => new Set(fields.value.map((field) => String(field?.name || ''))))
const translatingFieldName = ref('')

const subnavLinks = computed(() => {
  const links = (props.subnav || []).filter((entry) => entry?.label && entry?.target)
  return links
  // const withoutTop = links.filter((entry) => String(entry.target) !== 'top')
  // return [{ label: 'Top', target: 'top' }, ...withoutTop]
})

const activeSubnavTarget = ref('')

// Runs of adjacent inputs share a panel, and a nested table breaks the run.
// Sections add the content-anchor structure legacy subnav relied on.
const sections = computed(() => {
  const grouped = props.blocks.reduce((out, block) => {
    const id = block.sectionId || '__default'
    const title = block.sectionTitle || null
    const helperText = block.sectionHelperText || null
    const showTitle = block.sectionShowTitle
    const last = out[out.length - 1]

    if (last?.id === id) {
      if (!last.title && title) last.title = title
      if (!last.helperText && helperText) last.helperText = helperText
      if (typeof last.showTitle === 'undefined' && typeof showTitle !== 'undefined') {
        last.showTitle = showTitle
      }
      last.blocks.push(block)
    } else {
      out.push({
        id: id === '__default' ? null : id,
        title,
        helperText,
        showTitle,
        blocks: [block],
      })
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

    return {
      id: section.id,
      title: section.title,
      helperText: section.helperText,
      showTitle: section.showTitle,
      blocks: mergedBlocks,
    }
  })
})

function sectionHasVisibleContent(section) {
  if (!section?.blocks?.length) return false

  return section.blocks.some((block) => {
    if (block.kind === 'field') return visibleFields(block.fields).length > 0
    return true
  })
}

function sectionShowsHeading(section) {
  if (!section?.title) return false
  if (section?.showTitle === false) return false
  return sectionHasVisibleContent(section)
}

function sectionShowsHelperText(section) {
  if (!section?.helperText) return false
  return sectionHasVisibleContent(section)
}

const hasHiddenLanguageErrors = computed(() => {
  if (!showLanguageNav.value || selectedLanguage.value === 'all' || !form.hasErrors) return false

  const hiddenFieldNames = new Set(
    fields.value
      .filter((field) => !isFieldVisible(field))
      .map((field) => String(field.name))
  )

  if (hiddenFieldNames.size === 0) return false

  return Object.keys(form.errors).some((errorKey) =>
    Array.from(hiddenFieldNames).some((fieldName) =>
      errorKey === fieldName || errorKey.startsWith(`${fieldName}.`)
    )
  )
})

const form = useForm(
  Object.fromEntries(fields.value.map((field) => [field.name, field.value]))
)

const FaeFormFieldComponent = useFaeComponent('FaeFormField', FaeFormField)
const FaeNestedTableComponent = useFaeComponent('FaeNestedTable', FaeNestedTable)
const FaeFlexComponentsTableComponent = useFaeComponent('FaeFlexComponentsTable', FaeFlexComponentsTable)

provideFaeFormContext({
  form,
  field: formField,
  fieldVisible: isFieldVisible,
  nestedTable,
  flexComponentsTable,
  formFieldComponent: FaeFormFieldComponent,
  nestedTableComponent: FaeNestedTableComponent,
  flexComponentsTableComponent: FaeFlexComponentsTableComponent,
  recentChanges: computed(() => props.recentChanges),
  canTranslate: canTranslateField,
  translatingFieldName,
  translateField,
})

const { hasAssets, toParams } = useAssetFields(fields)
const { toParams: ctaToParams } = useCtaFields(fields)
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

function csrfToken() {
  return document.querySelector('meta[name="csrf-token"]')?.content || ''
}

async function saveLanguagePreference(language) {
  const base = languageNav.value?.savePathBase
  if (!base) return

  const selected = language || 'all'

  try {
    await fetch(`${base}/${selected}`, {
      method: 'POST',
      credentials: 'same-origin',
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': csrfToken(),
      },
    })
  } catch (error) {
    console.error(error)
  }
}

function translatorLanguageCode(language) {
  if (!language) return ''

  const key = String(language)
  if (key === 'zh') return 'zh-CN'
  if (key === 'frca') return 'fr-CA'
  if (key.length === 4) return `${key.slice(0, 2)}-${key.slice(2).toUpperCase()}`
  return key
}

function englishSourceCandidates(fieldName, language) {
  const name = String(fieldName || '')
  const suffix = `_${language}`
  if (!name.endsWith(suffix)) return []

  const base = name.slice(0, -suffix.length)
  return [`${base}_en`, base]
}

function englishSourceText(field) {
  const language = fieldLanguage(field)
  if (!language || language === 'en') return null

  const candidates = englishSourceCandidates(field?.name, language)
  for (const candidate of candidates) {
    if (!fieldNames.value.has(candidate)) continue
    const value = String(form[candidate] ?? '').trim()
    if (value.length > 0) return value
  }

  return null
}

function canTranslateField(field) {
  if (!translateEnabled.value || !translatePath.value) return false
  if (!field || field.translate === false) return false
  if (!['text', 'textarea'].includes(String(field.type || ''))) return false

  const language = fieldLanguage(field)
  if (!language || language === 'en') return false

  return englishSourceCandidates(field.name, language).some((name) => fieldNames.value.has(name))
}

async function translateField(fieldName) {
  const targetField = fields.value.find((field) => String(field.name) === String(fieldName))
  if (!targetField || !canTranslateField(targetField)) return

  const sourceText = englishSourceText(targetField)
  if (!sourceText) return

  const language = fieldLanguage(targetField)
  const translationLanguage = translatorLanguageCode(language)
  if (!translationLanguage) return

  translatingFieldName.value = String(fieldName)

  try {
    const payload = new FormData()
    payload.append('translation_text[language]', translationLanguage)
    payload.append('translation_text[en_text]', sourceText)

    const response = await fetch(translatePath.value, {
      method: 'POST',
      credentials: 'same-origin',
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': csrfToken(),
      },
      body: payload,
    })

    const data = await response.json()
    const entry = Array.isArray(data) ? data[0] : null
    if (entry?.translated_text) {
      form[String(fieldName)] = entry.translated_text
    }
  } catch (error) {
    console.error(error)
  } finally {
    translatingFieldName.value = ''
  }
}

function showAllLanguages() {
  selectedLanguage.value = 'all'
}

function submit() {
  if (nestedUnsavedChanges() && !window.confirm(NESTED_UNSAVED_MESSAGE)) return

  allowUnload()

  const { method, extraParams, forceFormData } = assetSubmitOptions(hasAssets.value, props.submitMethod)

  form
    .transform((data) => ({ [props.paramKey]: ctaToParams(toParams(data)), ...extraParams }))
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

function stickyHeaderOffset() {
  if (typeof document === 'undefined') return 0

  const stickyHeader = document.querySelector('.fae-page-header.-sticky-form')
  if (!stickyHeader) return 0

  // The sticky form header sits below the global fixed header via `top`, so
  // both the inset and the sticky header's own height obscure target content.
  const stickyTop = Number.parseFloat(window.getComputedStyle(stickyHeader).top) || 0
  return stickyTop + stickyHeader.getBoundingClientRect().height
}

function updateActiveSubnav() {
  if (!subnavLinks.value.length || typeof document === 'undefined') return

  const offset = stickyHeaderOffset() + 8
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

  const offset = stickyHeaderOffset() + 12
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
        <div v-if="showLanguageNav" class="fae-page-header__language">
          <label for="fae-language-select" class="fae-sr-only">Content language</label>
          <select
            id="fae-language-select"
            v-model="selectedLanguage"
            class="fae-field__control"
            @change="saveLanguagePreference(selectedLanguage)"
          >
            <option
              v-for="option in languageOptions"
              :key="option.value"
              :value="option.value"
            >
              {{ option.label }}
            </option>
          </select>
        </div>

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

    <p v-if="hasHiddenLanguageErrors" class="fae-alert -alert" role="alert">
      There are hidden errors. Click "All Languages" in the language nav to view all errors.
      <button type="button" class="fae-button -secondary -sm" @click="showAllLanguages">
        All Languages
      </button>
    </p>

    <!--
      Nested tables render inside the form, where the Slim version put them.
      They still save on their own, which is safe because FaeNestedForm is a
      <div> and every control it owns is type="button" -- nothing it contains
      can be swept up by this form's submit.
    -->
    <slot
      name="form"
      :form="form"
      :field="formField"
      :field-visible="isFieldVisible"
      :nested-table="nestedTable"
      :flex-components-table="flexComponentsTable"
      :form-field-component="FaeFormFieldComponent"
      :nested-table-component="FaeNestedTableComponent"
      :flex-components-table-component="FaeFlexComponentsTableComponent"
      :can-translate="canTranslateField"
      :translating-field-name="translatingFieldName"
      :translate-field="translateField"
    >
      <section
        v-for="(section, sectionIndex) in sections"
        :id="section.id || null"
        :key="section.id || `section-${sectionIndex}`"
        class="fae-form-section"
        :data-fae-section="section.id || null"
      >
        <h2 v-if="sectionShowsHeading(section)" class="fae-form-section__title">{{ section.title }}</h2>
        <p v-if="sectionShowsHelperText(section)" class="fae-form-section__helper-text">
          {{ section.helperText }}
        </p>

        <template v-for="(block, blockIndex) in section.blocks" :key="`${section.id || sectionIndex}-${block.kind}-${blockIndex}`">
          <div v-if="block.kind === 'field' && visibleFields(block.fields).length" class="fae-panel fae-form">
            <component
              :is="FaeFormFieldComponent"
              v-for="field in visibleFields(block.fields)"
              :key="field.name"
              :field="field"
              :error="form.errors[field.name]"
              :can-translate="canTranslateField(field)"
              :translating="translatingFieldName === field.name"
              v-model="form[field.name]"
              @translate="translateField"
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
    </slot>
  </form>
</template>
