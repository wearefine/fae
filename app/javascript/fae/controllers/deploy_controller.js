import { Controller } from "@hotwired/stimulus"

// Deploy page: runs deploy hooks and polls Netlify for build status while the tab is visible.
// Replaces Fae.deploy. Attached to the `main.content` element holding the deploy buttons; the
// deploy tables elsewhere on the page are found by their `.js-deploys-list` classes.
export default class extends Controller {
  static targets = ["button"]
  static values = {
    siteId: String,
    listPath: String,
    deployPath: String,
    pollInterval: { type: Number, default: 5000 }
  }

  static idleStates = ["ready", "error", "rejected"]

  connect() {
    this.deployFinished = true
    this.buttonsEnabled = true
    this.pollTimeout = null

    this.onVisibilityChange = this.onVisibilityChange.bind(this)
    document.addEventListener("visibilitychange", this.onVisibilityChange)

    this.notifyIdle()
    this.poll()
  }

  disconnect() {
    document.removeEventListener("visibilitychange", this.onVisibilityChange)
    this.stopPolling()
  }

  deploy(event) {
    event.preventDefault()
    this.disableButtons()

    const body = new URLSearchParams({ deploy_hook_type: event.currentTarget.dataset.buildHookType })
    if (this.siteIdValue) body.set("fae_site_id", this.siteIdValue)

    // Netlify returns nothing useful for deploy hook posts; the next poll shows the build
    fetch(this.deployPathValue, {
      method: "POST",
      headers: this.requestHeaders,
      body,
      credentials: "same-origin"
    }).catch(() => {})
  }

  onVisibilityChange() {
    if (document.visibilityState === "visible") {
      this.poll()
    } else {
      this.stopPolling()
    }
  }

  poll() {
    this.stopPolling()
    const generation = this.pollGeneration

    this.refresh().finally(() => {
      // Skip if polling was stopped or restarted while the request was in flight
      if (generation === this.pollGeneration) {
        this.pollTimeout = setTimeout(() => this.poll(), this.pollIntervalValue)
      }
    })
  }

  stopPolling() {
    clearTimeout(this.pollTimeout)
    this.pollTimeout = null
    this.pollGeneration = (this.pollGeneration || 0) + 1
  }

  async refresh() {
    try {
      const url = new URL(this.listPathValue, window.location.origin)
      if (this.siteIdValue) url.searchParams.set("fae_site_id", this.siteIdValue)

      const response = await fetch(url, { headers: { Accept: "application/json", ...this.requestHeaders }, credentials: "same-origin" })
      if (!response.ok) return

      const deploys = await response.json()
      if (!deploys || !this.element.isConnected) return

      this.drawTables(deploys)
      this.stateChecks(deploys)
    } catch (error) {
      // Transient network errors are retried on the next poll
    }
  }

  drawTables(deploys) {
    const running = deploys.filter((deploy) => !this.isIdle(deploy))
    const past = deploys.filter((deploy) => this.isIdle(deploy))

    this.fillTable(document.querySelector(".js-deploys-list.running tbody"), running)
    this.fillTable(document.querySelector(".js-deploys-list.past tbody"), past)

    window.Fae?.navigation?.lockFooter()
  }

  fillTable(tbody, deploys) {
    if (!tbody) return

    tbody.replaceChildren(...deploys.map((deploy) => {
      const row = document.createElement("tr")
      const cells = [
        deploy.commit_ref !== null ? "FINE dev update" : deploy.title,
        window.moment(deploy.updated_at).format("MM/DD/YYYY h:mm a"),
        this.duration(deploy),
        this.environment(deploy)
      ]

      cells.forEach((text) => {
        const cell = document.createElement("td")
        cell.textContent = text
        row.append(cell)
      })

      const errorCell = document.createElement("td")
      if (deploy.error_message) {
        errorCell.append("An error occurred. Please contact your ")
        const link = document.createElement("a")
        link.href = "/admin/help"
        link.textContent = "FINE team"
        errorCell.append(link, ".")
      }
      row.append(errorCell)

      return row
    }))
  }

  stateChecks(deploys) {
    if (deploys.some((deploy) => !this.isIdle(deploy))) {
      this.notifyRunning()
      this.disableButtons()
      this.deployFinished = false
    } else if (!this.deployFinished) {
      this.notifyIdle()
      this.enableButtons()
      this.deployFinished = true
    }
  }

  isIdle(deploy) {
    return this.constructor.idleStates.includes(deploy.state)
  }

  duration(deploy) {
    if (deploy.deploy_time === null) return "–"

    return window.moment.utc(parseInt(deploy.deploy_time) * 1000).format("HH:mm:ss")
  }

  environment(deploy) {
    if (deploy.branch === "master" || deploy.branch === "main") return "Production"

    return deploy.branch.charAt(0).toUpperCase() + deploy.branch.slice(1)
  }

  notifyRunning() {
    document.querySelector(".deploying-heading")?.classList.add("running")
    document.querySelector("#js-deploying-section")?.classList.remove("hidden")
  }

  notifyIdle() {
    document.querySelector(".deploying-heading")?.classList.remove("running")
    document.querySelector("#js-deploying-section")?.classList.add("hidden")
  }

  enableButtons() {
    if (this.buttonsEnabled) return

    this.buttonsEnabled = true
    this.buttonTargets.forEach((button) => { button.disabled = false })
  }

  disableButtons() {
    if (!this.buttonsEnabled) return

    this.buttonsEnabled = false
    this.buttonTargets.forEach((button) => { button.disabled = true })
  }

  get requestHeaders() {
    const headers = { "X-Requested-With": "XMLHttpRequest" }
    const token = document.querySelector('meta[name="csrf-token"]')?.content
    if (token) headers["X-CSRF-Token"] = token

    return headers
  }
}
