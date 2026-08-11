<script setup>
import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { Link } from '@inertiajs/vue3'

import FaeBreadcrumbs from '../../components/FaeBreadcrumbs.vue'

// Inertia shared props (nav/currentUser/etc.) should not leak onto the root.
defineOptions({ inheritAttrs: false })

const props = defineProps({
  title: { type: String, required: true },
  intro: { type: String, default: '' },
  enabled: { type: Boolean, default: false },
  siteId: { type: [String, Number, null], default: null },
  deployHooks: { type: Array, default: () => [] },
  deployListPath: { type: String, required: true },
  deployPath: { type: String, required: true },
  helpPath: { type: String, required: true },
  labels: { type: Object, default: () => ({}) },
})

const idleStates = ['ready', 'error', 'rejected']
const POLL_INTERVAL_MS = 5000
const deploys = ref([])
const loading = ref(false)
const requestError = ref('')
const runningDeploy = ref('')

let pollTimer = null

const runningDeploys = computed(() =>
  deploys.value.filter((deploy) => !idleStates.includes(String(deploy?.state || '')))
)

const pastDeploys = computed(() =>
  deploys.value.filter((deploy) => idleStates.includes(String(deploy?.state || '')))
)

const hasActiveDeploy = computed(() => runningDeploys.value.length > 0)
const isDeployBusy = computed(() => Boolean(runningDeploy.value) || hasActiveDeploy.value)
const showRunningSection = computed(() => hasActiveDeploy.value || Boolean(runningDeploy.value))
const deployProgressText = computed(() => {
  if (runningDeploy.value && !hasActiveDeploy.value) return 'Starting deploy...'

  const activeCount = runningDeploys.value.length
  if (!activeCount) return ''

  return activeCount === 1 ? '1 deploy in progress' : `${activeCount} deploys in progress`
})

function csrfToken() {
  return document.querySelector('meta[name="csrf-token"]')?.content || ''
}

function listUrl() {
  if (!props.siteId) return props.deployListPath

  const url = new URL(props.deployListPath, window.location.origin)
  url.searchParams.set('fae_site_id', String(props.siteId))
  return `${url.pathname}${url.search}`
}

async function fetchDeploys({ background = false } = {}) {
  if (!props.enabled) {
    deploys.value = []
    requestError.value = ''
    loading.value = false
    return
  }

  if (!background) loading.value = true

  try {
    const response = await fetch(listUrl(), {
      method: 'GET',
      credentials: 'same-origin',
      headers: {
        Accept: 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
      },
    })

    if (!response.ok) throw new Error(`Deploy list request failed (${response.status})`)

    const data = await response.json()
    deploys.value = Array.isArray(data) ? data : []
    requestError.value = ''
  } catch (error) {
    // Keep stale rows visible during background refresh failures.
    if (!background) deploys.value = []
    requestError.value = 'Unable to fetch deploys right now.'
    console.error(error)
  } finally {
    if (!background) loading.value = false
  }
}

async function runDeploy(environment) {
  if (!props.enabled || !environment || runningDeploy.value) return

  runningDeploy.value = String(environment)

  try {
    const payload = new FormData()
    payload.append('deploy_hook_type', String(environment))
    if (props.siteId) payload.append('fae_site_id', String(props.siteId))

    const response = await fetch(props.deployPath, {
      method: 'POST',
      credentials: 'same-origin',
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': csrfToken(),
      },
      body: payload,
    })

    if (!response.ok) throw new Error(`Deploy request failed (${response.status})`)

    await fetchDeploys({ background: true })
  } catch (error) {
    requestError.value = 'Unable to trigger deploy right now.'
    console.error(error)
  } finally {
    runningDeploy.value = ''
  }
}

function startPolling() {
  stopPolling()

  if (!props.enabled) return

  pollTimer = window.setTimeout(async () => {
    await fetchDeploys({ background: true })
    startPolling()
  }, POLL_INTERVAL_MS)
}

function stopPolling() {
  if (pollTimer) {
    window.clearTimeout(pollTimer)
    pollTimer = null
  }
}

function onVisibilityChange() {
  if (document.visibilityState === 'visible') {
    fetchDeploys({ background: true }).then(startPolling)
  } else {
    stopPolling()
  }
}

function deployTitle(deploy) {
  if (deploy?.committer) return 'Developer update'
  return deploy?.title || '-'
}

function deployedAt(deploy) {
  if (!deploy?.updated_at) return '-'

  const date = new Date(deploy.updated_at)
  if (Number.isNaN(date.getTime())) return '-'
  return date.toLocaleString()
}

function deployDuration(deploy) {
  const seconds = Number(deploy?.deploy_time)
  if (!Number.isFinite(seconds)) return '-'

  const hours = Math.floor(seconds / 3600)
  const minutes = Math.floor((seconds % 3600) / 60)
  const remaining = Math.floor(seconds % 60)

  const hh = String(hours).padStart(2, '0')
  const mm = String(minutes).padStart(2, '0')
  const ss = String(remaining).padStart(2, '0')

  return `${hh}:${mm}:${ss}`
}

function deployEnvironment(deploy) {
  const branch = String(deploy?.branch || '')
  if (branch === 'master' || branch === 'main') return 'Production'
  if (!branch) return '-'

  return branch.charAt(0).toUpperCase() + branch.slice(1)
}

onMounted(async () => {
  await fetchDeploys()
  startPolling()
  document.addEventListener('visibilitychange', onVisibilityChange)
})

watch(
  isDeployBusy,
  (busy) => {
    document.body.style.cursor = busy ? 'progress' : ''
  },
  { immediate: true }
)

onBeforeUnmount(() => {
  stopPolling()
  document.body.style.cursor = ''
  document.removeEventListener('visibilitychange', onVisibilityChange)
})
</script>

<template>
  <div class="fae-page-header">
    <div class="fae-page-header__title -stacked">
      <FaeBreadcrumbs :title="title" :append-title="true" />
      <h1>{{ title }}</h1>
    </div>
  </div>

  <section class="fae-panel fae-deploy__actions">
    <p v-if="!enabled" class="fae-alert -alert" role="alert">
      Netlify configuration is not available yet. Add deploy environment variables to enable this screen.
    </p>

    <div class="fae-deploy__buttons">
      <button
        v-for="hook in deployHooks"
        :key="hook.environment"
        type="button"
        class="fae-button"
        :disabled="!enabled || isDeployBusy"
        @click="runDeploy(hook.environment)"
      >
        {{ runningDeploy === hook.environment ? 'Starting...' : hook.label }}
      </button>
    </div>

    <p v-if="isDeployBusy" class="fae-deploy__progress" aria-live="polite">
      <span class="fae-deploy__progress-dot" aria-hidden="true"></span>
      {{ deployProgressText }}
    </p>
  </section>

  <section class="fae-panel fae-deploy__helper">
    <p v-if="intro" class="fae-deploy__intro">{{ intro }}</p>
    <p class="fae-deploy__copy" v-html="labels.deployingHelper"></p>
    <p v-if="requestError" class="fae-alert -alert" role="alert">{{ requestError }}</p>
  </section>

  <section v-if="showRunningSection" class="fae-panel fae-deploy__table-wrap">
    <h2 class="fae-deploy__running-heading" :class="{ '-running': isDeployBusy }">
      {{ labels.runningHeading || 'Deploying' }}
    </h2>
    <div class="fae-table-wrap">
      <table class="fae-table">
        <thead>
          <tr>
            <th>{{ labels.activity || 'Activity' }}</th>
            <th>{{ labels.deployed || 'Date/Time' }}</th>
            <th>{{ labels.duration || 'Duration' }}</th>
            <th>{{ labels.context || 'Environment' }}</th>
            <th>{{ labels.error || 'Error' }}</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="deploy in runningDeploys" :key="deploy.name">
            <td>{{ deployTitle(deploy) }}</td>
            <td>{{ deployedAt(deploy) }}</td>
            <td>{{ deployDuration(deploy) }}</td>
            <td>{{ deployEnvironment(deploy) }}</td>
            <td>
              <span v-if="deploy.error_message">
                An error occurred. Please contact your
                <Link :href="helpPath">FINE team</Link>.
              </span>
              <span v-else>-</span>
            </td>
          </tr>

          <tr v-if="!runningDeploys.length && runningDeploy">
            <td class="fae-table__empty" colspan="5">Waiting for deploy status...</td>
          </tr>
        </tbody>
      </table>
    </div>
  </section>

  <section class="fae-panel fae-deploy__table-wrap">
    <h2>{{ labels.pastHeading || 'Past Deploys' }}</h2>
    <div v-if="loading" class="fae-deploy__loading">Loading deploys...</div>
    <div v-if="!loading" class="fae-table-wrap">
      <table class="fae-table">
        <thead>
          <tr>
            <th>{{ labels.activity || 'Activity' }}</th>
            <th>{{ labels.deployed || 'Date/Time' }}</th>
            <th>{{ labels.duration || 'Duration' }}</th>
            <th>{{ labels.context || 'Environment' }}</th>
            <th>{{ labels.error || 'Error' }}</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="deploy in pastDeploys" :key="deploy.name">
            <td>{{ deployTitle(deploy) }}</td>
            <td>{{ deployedAt(deploy) }}</td>
            <td>{{ deployDuration(deploy) }}</td>
            <td>{{ deployEnvironment(deploy) }}</td>
            <td>
              <span v-if="deploy.error_message">
                An error occurred. Please contact your
                <Link :href="helpPath">FINE team</Link>.
              </span>
              <span v-else>-</span>
            </td>
          </tr>

          <tr v-if="!pastDeploys.length">
            <td class="fae-table__empty" colspan="5">{{ labels.noDeploys || 'No deploys were found.' }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </section>
</template>
