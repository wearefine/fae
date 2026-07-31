<script setup>
import { computed } from 'vue'
import { usePage } from '@inertiajs/vue3'

import FaeTopNav from '../components/FaeTopNav.vue'
import FaeSideNav from '../components/FaeSideNav.vue'
import FaeThemeToggle from '../components/FaeThemeToggle.vue'
import FaeToasts from '../components/FaeToasts.vue'

// Shared props are read via usePage() below, so keep them off the root node.
defineOptions({ inheritAttrs: false })

const page = usePage()

// Shared data from Fae::ApplicationControllerConcern (see inertia_share).
// Flash is not read here -- FaeToasts consumes it directly.
const currentUser = computed(() => page.props.currentUser)

// One navigation tree, two regions: levels 1-2 across the top, levels 3-4
// down the side. The side nav is absent on screens that aren't nested that
// deep, and the main column widens to fill the space.
const nav = computed(() => page.props.nav || {})
const topnav = computed(() => nav.value.topnav || [])
const sidenav = computed(() => nav.value.sidenav || [])

// Initials for the avatar chip. Falls back to the first character so a
// single-word name or an email address still renders something.
const userInitials = computed(() => {
  const name = currentUser.value?.name?.trim()
  if (!name) return '?'

  const parts = name.split(/\s+/)
  return (parts[0][0] + (parts.length > 1 ? parts.at(-1)[0] : '')).toUpperCase()
})
</script>

<template>
  <div class="fae-app">
    <header class="fae-app__header">
      <a class="fae-app__brand" href="/admin">
        <span class="fae-app__brand-mark" aria-hidden="true">F</span>
        Fae
      </a>

      <FaeTopNav :items="topnav" />

      <div class="fae-app__tools">
        <FaeThemeToggle />

        <span v-if="currentUser" class="fae-app__user">
          <span class="fae-app__avatar" aria-hidden="true">{{ userInitials }}</span>
          {{ currentUser.name }}
        </span>
      </div>
    </header>

    <div class="fae-app__body">
      <FaeSideNav :items="sidenav" />

      <main class="fae-app__main">
        <slot />
      </main>
    </div>

    <FaeToasts />
  </div>
</template>
