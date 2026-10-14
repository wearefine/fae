import { Controller } from "@hotwired/stimulus"

// Filtering, sorting and paging for index tables, attached to `fae_filter_form`.
// Replaces Fae.form.filtering on pages with a filter form; it keeps the same
// endpoints, markup, Fryr hash params and js-cookie persistence.
//
// Optional `frame` value: the id of an element wrapping the results table and
// pagination. When set, the whole element is swapped on refresh and sort and
// pagination clicks are scoped to it.
export default class extends Controller {
  static values = { frame: String }

  connect() {
    if (!window.Fryr) return

    this.hasHashOnLoadAndCookie = false
    this.dateTimer = null

    this.onSubmit = this.onSubmit.bind(this)
    this.onClick = this.onClick.bind(this)
    this.onChange = this.onChange.bind(this)
    this.onPaginationClick = this.onPaginationClick.bind(this)
    this.onSortClick = this.onSortClick.bind(this)

    // Chosen, the datepicker and specs fire jQuery-triggered change/submit
    // events, which native listeners never see. jQuery handlers receive both.
    if (window.jQuery) {
      window.jQuery(this.element)
        .on("submit.faeFiltering", this.onSubmit)
        .on("click.faeFiltering", this.onClick)
        .on("change.faeFiltering", this.onChange)
    } else {
      this.element.addEventListener("submit", this.onSubmit)
      this.element.addEventListener("click", this.onClick)
      this.element.addEventListener("change", this.onChange)
    }
    document.addEventListener("click", this.onPaginationClick)
    document.addEventListener("click", this.onSortClick)

    this.applyCookies()

    const hasHashOnLoad = window.location.hash.length > 2
    this.fry = new window.Fryr(this.refreshTable.bind(this), {}, hasHashOnLoad)
    if (hasHashOnLoad) this.fry.parse(window.location.hash)

    this.setSelects()
    this.setTextInputs()
    this.addSortingClasses()
  }

  disconnect() {
    if (!this.fry) return

    if (window.jQuery) {
      window.jQuery(this.element).off(".faeFiltering")
    } else {
      this.element.removeEventListener("submit", this.onSubmit)
      this.element.removeEventListener("click", this.onClick)
      this.element.removeEventListener("change", this.onChange)
    }
    document.removeEventListener("click", this.onPaginationClick)
    document.removeEventListener("click", this.onSortClick)

    clearTimeout(this.dateTimer)
    this.fry.destroy(true)
    this.fry = null
  }

  // Fryr callback, invoked on every hashchange (and synchronously from the
  // Fryr constructor when the page loads with a hash, before this.fry is set).
  async refreshTable(params) {
    const url = this.element.getAttribute("action")
    const frame = this.frameElement
    const table = frame ? null : this.resultsTable
    const fadeTarget = frame || table

    if (!url || !fadeTarget) return

    fadeTarget.classList.add("loading-fade")

    try {
      const html = await this.postFilter(url, (this.fry && this.fry.params) || params || {})
      const doc = new DOMParser().parseFromString(html, "text/html")

      if (frame) {
        const newFrame = doc.getElementById(this.frameValue)
        if (!newFrame) throw new Error(`#${this.frameValue} missing from filter response`)
        frame.replaceWith(newFrame)
      } else {
        this.replaceTableAndPagination(doc, table)
      }

      this.afterRefresh()
    } catch (error) {
      fadeTarget.classList.remove("loading-fade")
      console.error(error)
    }
  }

  // Mirrors the legacy lookup: an explicit .js-results-table wins, otherwise
  // the table immediately following the filter form.
  get resultsTable() {
    const explicit = document.querySelector(".js-results-table")
    if (explicit) return explicit

    const next = this.element.nextElementSibling
    return next && next.tagName === "TABLE" ? next : null
  }

  get frameElement() {
    return this.hasFrameValue && this.frameValue ? document.getElementById(this.frameValue) : null
  }

  get resultsScope() {
    return this.frameElement || document
  }

  replaceTableAndPagination(doc, table) {
    const newTable = doc.querySelector("table")
    if (!newTable) throw new Error("table missing from filter response")

    table.replaceWith(newTable)

    const stickyHead = document.querySelector(".sticky-table-header thead")
    const newHead = newTable.querySelector("thead")
    if (stickyHead && newHead) stickyHead.innerHTML = newHead.innerHTML

    const pagination = document.querySelector(".pagination")
    const newPagination = doc.querySelector(".pagination")
    if (pagination && newPagination) pagination.innerHTML = newPagination.innerHTML
  }

  async postFilter(url, params) {
    const body = new URLSearchParams()
    Object.entries(params).forEach(([key, value]) => {
      if (value !== null && value !== undefined) body.append(key, value)
    })

    const headers = {
      "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
      Accept: "text/html",
      "X-Requested-With": "XMLHttpRequest"
    }
    const token = document.querySelector('meta[name="csrf-token"]')?.content
    if (token) headers["X-CSRF-Token"] = token

    const response = await fetch(url, { method: "POST", headers, body, credentials: "same-origin" })
    if (!response.ok) throw new Error(`Filter request failed: ${response.status}`)

    return response.text()
  }

  // Re-run the legacy table plugins against the fresh markup.
  afterRefresh() {
    if (!this.fry) return

    const Fae = window.Fae
    if (Fae) {
      Fae.tables?.columnSorting()
      Fae.tables?.rowSorting()
      Fae.navigation?.lockFooter()
      Fae.altTextManager?.init()
    }

    this.addSortingClasses()

    // Don't overwrite a saved filter cookie when arriving via a deep link.
    if (!this.hasHashOnLoadAndCookie) this.setCookie()
  }

  onSubmit(event) {
    event.preventDefault()
    this.showResetButtons()
    this.updateAndResetPaging("search", this.searchValue)
  }

  onClick(event) {
    const target = event.target

    if (target.closest(".table-filter-keyword-wrapper i")) {
      event.preventDefault()
      this.updateAndResetPaging("search", this.searchValue)
    } else if (target.closest(".js-reset-btn")) {
      event.preventDefault()
      this.reset(target.closest(".js-reset-btn"))
    }
  }

  onChange(event) {
    const target = event.target
    const key = (target.id || "").split("filter_")[1]
    if (!key) return

    if (target.matches("select")) {
      this.updateAndResetPaging(key, target.value)
      this.showResetButtons()
    } else if (target.matches(".datepicker input")) {
      clearTimeout(this.dateTimer)
      this.dateTimer = setTimeout(() => {
        this.updateAndResetPaging(key, target.value)
        this.showResetButtons()
      }, 500)
    }
  }

  onPaginationClick(event) {
    const link = event.target.closest(".pagination a")
    if (!link || !this.resultsScope.contains(link)) return

    let page = link.dataset.page
    if (!page) {
      try {
        page = new URL(link.href, window.location.origin).searchParams.get("page")
      } catch (_error) {
        page = null
      }
    }

    event.preventDefault()
    this.fry.merge({ page: page || "" })
  }

  onSortClick(event) {
    const header = event.target.closest("th[data-sort]")
    if (!header || !this.resultsScope.contains(header)) return

    const direction = header.classList.contains("-asc") ? "desc" : "asc"
    header.classList.toggle("-asc", direction === "asc")
    header.classList.toggle("-desc", direction === "desc")

    this.fry.merge({ sort_by: header.dataset.sort, sort_direction: direction, page: "" })
  }

  get searchValue() {
    const input = this.element.querySelector("#filter_search")
    return input ? input.value : ""
  }

  updateAndResetPaging(key, value) {
    this.fry.merge({ page: "", [key]: value })
  }

  reset(button) {
    this.fry.merge({ page: "" }, true)

    this.element.querySelectorAll("#filter_search, .table-filter-group.text-input input").forEach((input) => {
      input.value = ""
    })
    this.element.querySelectorAll("select").forEach((select) => {
      select.value = ""
      this.updateChosen(select)
    })

    button.style.display = "none"
  }

  showResetButtons() {
    this.element.querySelectorAll(".js-reset-btn").forEach((button) => {
      button.classList.remove("hidden")
      button.style.display = "inline-block"
    })
  }

  // Sets filter selects from the Fryr params on load.
  setSelects() {
    if (this.paramsEmpty) return

    Object.entries(this.fry.params).forEach(([key, value]) => {
      const select = this.element.querySelector(`.table-filter-group select[id="filter_${key}"]`)
      if (!select) return

      const option = Array.from(select.options).find((opt) => opt.value === String(value))
      if (option && !option.selected) {
        option.selected = true
        this.updateChosen(select)
      }
    })

    this.showResetButtons()
  }

  setTextInputs() {
    if (this.paramsEmpty) return

    Object.entries(this.fry.params).forEach(([key, value]) => {
      const input = this.element.querySelector(`.table-filter-group.text-input [id="filter_${key}"]`)
      if (!input) return

      try {
        input.value = decodeURIComponent(value)
      } catch (_error) {
        input.value = value
      }
    })

    this.showResetButtons()
  }

  addSortingClasses() {
    const sortBy = this.fry.params.sort_by
    const direction = this.fry.params.sort_direction || "asc"

    this.resultsScope.querySelectorAll("th[data-sort]").forEach((header) => {
      if (header.dataset.sort === sortBy) header.classList.add(`-${direction}`)

      if (!header.querySelector(".th-sortable-title")) {
        const wrapper = document.createElement("div")
        wrapper.className = "th-sortable-title"
        while (header.firstChild) wrapper.appendChild(header.firstChild)
        header.appendChild(wrapper)
      }
    })
  }

  get paramsEmpty() {
    return !this.fry.params || Object.keys(this.fry.params).length === 0
  }

  get cookieKey() {
    return this.element.dataset.cookieKey
  }

  setCookie() {
    if (this.cookieKey && window.Cookies) window.Cookies.set(this.cookieKey, this.fry.params)
  }

  // Restores saved filters into the hash, unless the page was deep-linked.
  applyCookies() {
    if (!this.cookieKey || !window.Cookies) return

    const cookie = window.Cookies.getJSON(this.cookieKey)
    if (!cookie || Object.keys(cookie).length === 0) return

    if (window.location.hash.length > 2) {
      this.hasHashOnLoadAndCookie = true
      return
    }

    const hash = Object.keys(cookie).map((key) => `${key}=${cookie[key]}`).join("&")
    if (hash) window.location.hash = `?${hash}`
  }

  updateChosen(select) {
    if (window.jQuery) window.jQuery(select).trigger("chosen:updated")
  }
}
