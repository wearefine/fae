import { computed, ref } from 'vue'

/**
 * Light/dark theme preference.
 *
 * There is deliberately very little here, because the CSS does the work: every
 * semantic token in styles/tokens.css is declared with light-dark(), so the
 * only thing that has to change at runtime is the used `color-scheme`. This
 * module's entire job is to put `data-fae-theme` on <html> (or take it off) and
 * remember the choice. Persistence is best-effort localStorage with a cookie
 * fallback so full navigations still pick up the preference when storage APIs
 * are unavailable or unreliable.
 *
 * Stored states remain three values (`system`, `light`, `dark`) so a user can
 * explicitly opt back into OS-following. The UI toggle itself is deterministic
 * `light <-> dark` (and from `system` jumps to the opposite resolved mode) so
 * each click always produces a visible change.
 */

export const THEMES = ['system', 'light', 'dark']

const STORAGE_KEY = 'fae:theme'
const COOKIE_KEY = 'fae_theme'
const COOKIE_MAX_AGE = 60 * 60 * 24 * 365

// Module scope, so every component that calls useTheme() shares one ref rather
// than each getting its own copy that the others never hear about.
const theme = ref(readStoredTheme())

// Tracks the OS setting so the toggle's icon updates live while the theme is
// "system". A bare matchMedia() call inside the computed below would be read
// once and never invalidated.
const systemDark = ref(false)
let bootstrapped = false

if (typeof window !== 'undefined' && window.matchMedia) {
  const query = window.matchMedia('(prefers-color-scheme: dark)')
  systemDark.value = query.matches
  query.addEventListener('change', (event) => {
    systemDark.value = event.matches
  })
}

function readStoredTheme() {
  // User-level theme is rendered on <html> by the server. Prefer that source
  // so local browser overrides do not clobber persisted profile settings.
  const rendered = document?.documentElement?.getAttribute('data-fae-theme')
  if (THEMES.includes(rendered)) return rendered

  // localStorage can throw (Safari private mode) and is absent during SSR.
  // Cookie fallback keeps theme stable across full navigations.
  try {
    const stored = window.localStorage.getItem(STORAGE_KEY)
    if (THEMES.includes(stored)) return stored
  } catch {
    /* fall through to cookie/default */
  }

  try {
    const pair = document.cookie
      .split(';')
      .map((part) => part.trim())
      .find((part) => part.startsWith(`${COOKIE_KEY}=`))

    if (pair) {
      const value = decodeURIComponent(pair.split('=').slice(1).join('='))
      if (THEMES.includes(value)) return value
    }
  } catch {
    /* fall through to the default */
  }

  return 'system'
}

function writeStoredTheme(value) {
  try {
    window.localStorage.setItem(STORAGE_KEY, value)
  } catch {
    // Fall through to cookie write below.
  }

  try {
    document.cookie = `${COOKIE_KEY}=${encodeURIComponent(value)}; Path=/admin; Max-Age=${COOKIE_MAX_AGE}; SameSite=Lax`
  } catch {
    // Preference just won't survive the session; not worth failing over.
  }
}

function applyTheme(value) {
  const root = document.documentElement

  // No attribute means "follow the OS", which is what :root's default
  // `color-scheme: light dark` already does.
  if (value === 'system') root.removeAttribute('data-fae-theme')
  else root.setAttribute('data-fae-theme', value)
}

function bootstrapTheme() {
  if (bootstrapped || typeof window === 'undefined') return
  bootstrapped = true

  const stored = readStoredTheme()
  theme.value = stored
  applyTheme(stored)

  // Keep tabs in sync when localStorage is available.
  window.addEventListener('storage', (event) => {
    if (event.key !== STORAGE_KEY) return

    const next = THEMES.includes(event.newValue) ? event.newValue : 'system'
    theme.value = next
    applyTheme(next)
  })
}

export function useTheme() {
  bootstrapTheme()

  function setTheme(value) {
    if (!THEMES.includes(value)) return

    theme.value = value
    applyTheme(value)
    writeStoredTheme(value)
  }

  function cycleTheme() {
    const current = THEMES.includes(theme.value) ? theme.value : 'system'

    // One-click visible change every time.
    // If currently following system, jump to the opposite explicit mode.
    if (current === 'system') {
      setTheme(resolvedTheme.value === 'dark' ? 'light' : 'dark')
      return
    }

    setTheme(current === 'light' ? 'dark' : 'light')
  }

  // What the user will actually be looking at, which "system" alone can't tell
  // you -- needed to pick the right icon.
  const resolvedTheme = computed(() => {
    if (theme.value !== 'system') return theme.value

    return systemDark.value ? 'dark' : 'light'
  })

  return { theme, resolvedTheme, setTheme, cycleTheme }
}
