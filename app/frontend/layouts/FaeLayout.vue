<script setup>
import { computed } from 'vue'
import { usePage } from '@inertiajs/vue3'

// Shared props are read via usePage() below, so keep them off the root node.
defineOptions({ inheritAttrs: false })

const page = usePage()

// Shared data from Fae::ApplicationControllerConcern (see inertia_share).
const flash = computed(() => page.props.flash || {})
const nav = computed(() => page.props.nav || [])
const currentUser = computed(() => page.props.currentUser)
</script>

<template>
  <div class="fae-app">
    <header class="fae-app__header">
      <a class="fae-app__brand" href="/admin">Fae</a>
      <span v-if="currentUser" class="fae-app__user">{{ currentUser.name }}</span>
    </header>

    <div class="fae-app__body">
      <nav v-if="nav.length" class="fae-app__sidenav">
        <a v-for="link in nav" :key="link.path" :href="link.path">
          {{ link.title }}
        </a>
      </nav>

      <main class="fae-app__main">
        <p v-if="flash.notice" class="fae-alert -notice">{{ flash.notice }}</p>
        <p v-if="flash.alert" class="fae-alert -alert">{{ flash.alert }}</p>

        <slot />
      </main>
    </div>
  </div>
</template>
