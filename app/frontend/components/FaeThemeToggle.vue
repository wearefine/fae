<script setup>
import { computed } from 'vue'

import { useTheme } from '../composables/useTheme.js'

// One button cycling system -> light -> dark rather than three radio buttons:
// the header is a tight space, and the icon plus its title/aria-label already
// says both what is active and what clicking does.
const { theme, resolvedTheme, cycleTheme } = useTheme()

const LABELS = {
  system: 'Match system theme',
  light: 'Light theme',
  dark: 'Dark theme',
}

const label = computed(() => LABELS[theme.value])

// While on "system" the icon shows what the OS resolved to, so the button
// always reflects what is on screen.
const icon = computed(() =>
  theme.value === 'system' ? `system-${resolvedTheme.value}` : theme.value
)
</script>

<template>
  <button
    type="button"
    class="fae-button -ghost -icon fae-theme-toggle"
    :class="{ '-system': theme === 'system' }"
    :title="label"
    :aria-label="label"
    @click="cycleTheme"
  >
    <!-- Sun -->
    <svg
      v-if="icon === 'light' || icon === 'system-light'"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="2"
      stroke-linecap="round"
      aria-hidden="true"
    >
      <circle cx="12" cy="12" r="4" />
      <path
        d="M12 2v2m0 16v2M4.9 4.9l1.4 1.4m11.4 11.4 1.4 1.4M2 12h2m16 0h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4"
      />
    </svg>

    <!-- Moon -->
    <svg
      v-else
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="2"
      stroke-linecap="round"
      stroke-linejoin="round"
      aria-hidden="true"
    >
      <path d="M20 14.5A8.5 8.5 0 0 1 9.5 4a8.5 8.5 0 1 0 10.5 10.5Z" />
    </svg>

    <span class="fae-theme-toggle__dot" aria-hidden="true"></span>
  </button>
</template>

<style scoped>
/*
 * Scoped rather than living in styles/components.css because it styles nothing
 * but this component. Anything a host app might want to restyle stays in the
 * shared stylesheet; this is just the marker dot.
 */
.fae-theme-toggle {
  position: relative;
}

/* A dot in the corner distinguishes "following the system" from an explicit
   light/dark choice, which the sun/moon icon alone cannot show. */
.fae-theme-toggle__dot {
  position: absolute;
  right: 5px;
  bottom: 5px;
  width: 4px;
  height: 4px;
  background: var(--fae-accent);
  border-radius: var(--fae-radius-full);
  opacity: 0;
  transition: opacity var(--fae-transition);
}

.fae-theme-toggle.-system .fae-theme-toggle__dot {
  opacity: 1;
}
</style>
