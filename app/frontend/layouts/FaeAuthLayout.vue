<script setup>
import { computed, onBeforeUnmount, onMounted, ref, watchEffect } from 'vue'
import { router, usePage } from '@inertiajs/vue3'
import FaeToasts from '../components/FaeToasts.vue'

/**
 * Chrome for the signed-out screens -- the Vue counterpart of
 * app/views/layouts/devise.html.slim.
 *
 * There is no header or navigation to identify the install here, so the logo
 * configured under /admin/root is the branding, falling back to the site title
 * when none has been uploaded.
 */
defineOptions({ inheritAttrs: false })

const page = usePage()

const branding = computed(() => page.props.branding || {})
const links = computed(() => page.props.links || [])
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
  hideProgressTimer = window.setTimeout(() => {
    navigating.value = false
  }, 120)
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
  <div class="fae-auth">
    <div class="fae-app__progress" :class="{ '-active': navigating }" aria-hidden="true">
      <span class="fae-app__progress-bar"></span>
    </div>

    <div class="fae-auth__panel">
      <div class="fae-auth__brand">
        <img
          v-if="branding.logoUrl"
          class="fae-auth__logo"
          :src="branding.logoUrl"
          :alt="branding.title"
        >
        <h1 v-else class="fae-auth__title">{{ branding.title }}</h1>
      </div>

      <div class="fae-auth__card">
        <slot />
      </div>
    </div>

    <footer class="fae-auth__footer">
      <nav v-if="links.length" class="fae-auth__links">
        <a v-for="link in links" :key="link.path" :href="link.path">{{ link.text }}</a>
      </nav>

      <p class="fae-auth__credit">
        a <a href="https://wearefine.com" target="_blank" rel="noopener">FINE</a>
        Admin<template v-if="branding.version"> v{{ branding.version }}</template>
      </p>
    </footer>

    <FaeToasts />
  </div>
</template>
