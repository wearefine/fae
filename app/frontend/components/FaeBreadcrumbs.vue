<script setup>
import { computed } from 'vue'
import { Link, usePage } from '@inertiajs/vue3'

const props = defineProps({
  title: { type: String, default: '' },
  appendTitle: { type: Boolean, default: false },
})

const page = usePage()
const nav = computed(() => page.props.nav || {})
const homePath = computed(() => page.props.rootPath || '/admin')

function pickActive(items) {
  return (items || []).find((item) => item?.open) || null
}

function pickCurrent(items) {
  return (items || []).find((item) => item?.current) || null
}

const crumbs = computed(() => {
  const top = nav.value.topnav || []
  const side = nav.value.sidenav || []
  const out = []

  const topParent = pickActive(top)
  if (topParent) out.push({ text: topParent.text, path: topParent.path })

  const topChild = pickCurrent(topParent?.children)
  if (topChild) out.push({ text: topChild.text, path: topChild.path })

  const sideParent = pickActive(side)
  if (sideParent) out.push({ text: sideParent.text, path: sideParent.path })

  const sideChild = pickCurrent(sideParent?.children)
  if (sideChild) out.push({ text: sideChild.text, path: sideChild.path })

  return out
})

function linkable(crumb, index) {
  if (!crumb?.path) return false
  if (props.appendTitle) return true
  return index < crumbs.value.length - 1
}
</script>

<template>
  <nav class="fae-breadcrumbs" aria-label="Breadcrumb">
    <ol class="fae-breadcrumbs__list">
      <li class="fae-breadcrumbs__item -home">
        <Link class="fae-breadcrumbs__home" :href="homePath" aria-label="Home">
          <svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
            <path d="M12 3.5 3 11h2v9h5v-6h4v6h5v-9h2z" />
          </svg>
        </Link>
      </li>

      <li v-for="(crumb, index) in crumbs" :key="`${index}-${crumb.text}`" class="fae-breadcrumbs__item">
        <component
          :is="linkable(crumb, index) ? Link : 'span'"
          class="fae-breadcrumbs__link"
          :href="linkable(crumb, index) ? crumb.path : null"
        >{{ crumb.text }}</component>
      </li>

      <li v-if="appendTitle && title" class="fae-breadcrumbs__item">
        <span class="fae-breadcrumbs__link">{{ title }}</span>
      </li>
    </ol>
  </nav>
</template>