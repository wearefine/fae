<script setup>
import { computed } from 'vue'
import { usePage } from '@inertiajs/vue3'

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

// Inline rather than toasts: a failed sign in has to stay on screen while the
// visitor retypes, and .fae-toast auto-dismisses after five seconds.
const messages = computed(() => Object.entries(page.props.flash || {}))
</script>

<template>
  <div class="fae-auth">
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
        <p
          v-for="[type, message] in messages"
          :key="type"
          class="fae-alert"
          :class="`-${type}`"
          role="alert"
        >
          {{ message }}
        </p>

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
  </div>
</template>
