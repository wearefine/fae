import { computed, ref } from 'vue'

/**
 * Light/dark theme preference.
 *
 * There is deliberately very little here, because the CSS does the work: every
 * semantic token in styles/tokens.css is declared with light-dark(), so the
 * only thing that has to change at runtime is the used `color-scheme`. This
 * module's entire job is to put `data-fae-theme` on <html> (or take it off) and
 * remember the choice.
 *
 * Three states, not two. "system" is a real value rather than the absence of a
 * choice -- an admin whose OS is dark but who wants a light CMS needs to be
 * able to say so, and to change their mind back.
 */

export const THEMES = ['system', 'light', 'dark']

const STORAGE_KEY = 'fae:theme'

// Module scope, so every component that calls useTheme() shares one ref rather
// than each getting its own copy that the others never hear about.
const theme = ref(readStoredTheme())

// Tracks the OS setting so the toggle's icon updates live while the theme is
// "system". A bare matchMedia() call inside the computed below would be read
// once and never invalidated.
const systemDark = ref(false)

if (typeof window !== 'undefined' && window.matchMedia) {
  const query = window.matchMedia('(prefers-color-scheme: dark)')
  systemDark.value = query.matches
  query.addEventListener('change', (event) => {
    systemDark.value = event.matches
  })
}

function readStoredTheme() {
  // localStorage throws in Safari private mode and is absent during SSR.
  try {
    const stored = window.localStorage.getItem(STORAGE_KEY)
    if (THEMES.includes(stored)) return stored
  } catch {
    /* fall through to the default */
  }

  return 'system'
}

function applyTheme(value) {
  const root = document.documentElement

  // No attribute means "follow the OS", which is what :root's default
  // `color-scheme: light dark` already does.
  if (value === 'system') root.removeAttribute('data-fae-theme')
  else root.setAttribute('data-fae-theme', value)
}

export function useTheme() {
  function setTheme(value) {
    if (!THEMES.includes(value)) return

    theme.value = value
    applyTheme(value)

    try {
      window.localStorage.setItem(STORAGE_KEY, value)
    } catch {
      // Preference just won't survive the session; not worth failing over.
    }
  }

  function cycleTheme() {
    setTheme(THEMES[(THEMES.indexOf(theme.value) + 1) % THEMES.length])
  }

  // What the user will actually be looking at, which "system" alone can't tell
  // you -- needed to pick the right icon.
  const resolvedTheme = computed(() => {
    if (theme.value !== 'system') return theme.value

    return systemDark.value ? 'dark' : 'light'
  })

  return { theme, resolvedTheme, setTheme, cycleTheme }
}
