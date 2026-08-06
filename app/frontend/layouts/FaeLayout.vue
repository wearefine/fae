<script setup>
import { computed, onBeforeUnmount, onMounted, ref, watchEffect } from 'vue'
import { Link, router, usePage } from '@inertiajs/vue3'

import FaeTopNav from '../components/FaeTopNav.vue'
import FaeSideNav from '../components/FaeSideNav.vue'
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
const utilityNav = computed(() => page.props.utilityNav || [])
const theme = computed(() => page.props.theme || {})
const navigating = ref(false)

let hideProgressTimer
const stopProgressListeners = []

function showProgress() {
  if (typeof window === 'undefined') return
  window.clearTimeout(hideProgressTimer)
  navigating.value = true
}

function hideProgress() {
  if (typeof window === 'undefined') return
  window.clearTimeout(hideProgressTimer)
  // Small delay prevents a flash on very fast responses.
  hideProgressTimer = window.setTimeout(() => {
    navigating.value = false
  }, 120)
}

function blurAfterNavigate(event) {
  event.currentTarget?.blur?.()
}

watchEffect(() => {
  const mode = theme.value.mode
  const color = theme.value.highlightColor
  if (!document?.documentElement) return

  if (mode === 'light' || mode === 'dark') {
    document.documentElement.setAttribute('data-fae-theme', mode)
  } else {
    document.documentElement.removeAttribute('data-fae-theme')
  }

  if (color) {
    document.documentElement.style.setProperty('--fae-highlight', color)
  } else {
    document.documentElement.style.removeProperty('--fae-highlight')
  }
})

// Initials for the avatar chip. Falls back to the first character so a
// single-word name or an email address still renders something.
const userInitials = computed(() => {
  const name = currentUser.value?.name?.trim()
  if (!name) return '?'

  const parts = name.split(/\s+/)
  return (parts[0][0] + (parts.length > 1 ? parts.at(-1)[0] : '')).toUpperCase()
})

onMounted(() => {
  stopProgressListeners.push(router.on('start', showProgress))
  stopProgressListeners.push(router.on('finish', hideProgress))
  stopProgressListeners.push(router.on('error', hideProgress))
  stopProgressListeners.push(router.on('invalid', hideProgress))
})

onBeforeUnmount(() => {
  stopProgressListeners.forEach((stop) => stop?.())
  stopProgressListeners.length = 0

  if (typeof window !== 'undefined') window.clearTimeout(hideProgressTimer)
})
</script>

<template>
  <div class="fae-app">
    <div class="fae-app__progress" :class="{ '-active': navigating }" aria-hidden="true">
      <span class="fae-app__progress-bar"></span>
    </div>

    <header class="fae-app__header">
      <Link class="fae-app__brand" href="/admin">
        <span class="fae-app__brand-mark" aria-hidden="true">F</span>
        Faenix
      </Link>

      <FaeTopNav :items="topnav" />

      <div class="fae-app__tools">
        <nav v-if="utilityNav.length" class="fae-utility-nav" aria-label="Utility">
          <ul class="fae-utility-nav__list">
            <li
              v-for="item in utilityNav"
              :key="item.key"
              class="fae-utility-nav__item"
              :class="{ '-dropdown': item.children?.length }"
            >
              <button
                v-if="item.children?.length"
                type="button"
                class="fae-utility-nav__trigger"
                :aria-label="item.ariaLabel || item.text"
              >
                <svg
                  v-if="item.icon === 'gear'"
                  class="fae-utility-nav__gear"
                  viewBox="0 0 24 24"
                  aria-hidden="true"
                >
                  <path
                    d="M9.6 2h4.8l.5 2.4a8 8 0 0 1 1.8.8l2.1-1.2 3.4 3.4-1.2 2.1c.3.6.6 1.2.8 1.8L24 11.8v4.8l-2.4.5a8 8 0 0 1-.8 1.8l1.2 2.1-3.4 3.4-2.1-1.2c-.6.3-1.2.6-1.8.8L14.2 27H9.4l-.5-2.4a8 8 0 0 1-1.8-.8l-2.1 1.2-3.4-3.4 1.2-2.1a8 8 0 0 1-.8-1.8L0 16.6v-4.8l2.4-.5c.2-.6.5-1.2.8-1.8L2 7.4 5.4 4l2.1 1.2c.6-.3 1.2-.6 1.8-.8L9.6 2Zm2.4 6.5a3.7 3.7 0 1 0 0 7.4 3.7 3.7 0 0 0 0-7.4Z"
                    transform="translate(0 -3)"
                  />
                </svg>

                <span v-else-if="item.icon === 'avatar'" class="fae-app__avatar" aria-hidden="true">
                  {{ userInitials }}
                </span>

                <span v-else class="fae-utility-nav__dot" aria-hidden="true" />
              </button>

              <component
                :is="item.external ? 'a' : Link"
                v-else
                :href="item.path"
                class="fae-utility-nav__link"
                :target="item.external ? '_blank' : null"
                :rel="item.external ? 'noopener noreferrer' : null"
                @click="blurAfterNavigate"
              >{{ item.text }}</component>

              <ul v-if="item.children?.length" class="fae-utility-nav__menu">
                <li v-for="child in item.children" :key="child.key" class="fae-utility-nav__menu-item">
                  <component
                    :is="child.external ? 'a' : Link"
                    :href="child.path"
                    class="fae-utility-nav__menu-link"
                    :target="child.external ? '_blank' : null"
                    :rel="child.external ? 'noopener noreferrer' : null"
                    @click="blurAfterNavigate"
                  >{{ child.text }}</component>
                </li>
              </ul>
            </li>
          </ul>
        </nav>

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
