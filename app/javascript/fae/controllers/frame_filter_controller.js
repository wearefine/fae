import { Controller } from "@hotwired/stimulus"

// Filtering, sorting and paging for a results area wrapped by `fae_filter_frame` (a <turbo-frame>).
//
// Turbo does the requests and the swapping, and the server renders the whole state (filter values, results,
// pagination) from the query string, so there is no client state to keep. This controller only turns the interactions
// that aren't plain links or form submissions into frame navigations:
//
// - changing a filter select or date submits the filter form
// - clicking a sortable column header or a pagination link loads that URL into the frame
//
// The URL carries the whole state, so the back and forward buttons reload the list at that URL. (Turbo's own
// restoration of an `advance`d frame leaves the old results showing under the new URL.)
//
// Replaces the Fryr hash and cookie machinery of `fae-filtering` for pages that opt in with `fae_filter_frame`.
export default class extends Controller {
  connect() {
    this.onClick = this.onClick.bind(this)
    this.onChange = this.onChange.bind(this)
    this.onPopState = this.onPopState.bind(this)
    this.decorate = this.decorate.bind(this)

    this.pagePath = window.location.pathname

    this.element.addEventListener("click", this.onClick)
    this.element.addEventListener("turbo:frame-load", this.decorate)
    window.addEventListener("popstate", this.onPopState)

    // Chosen and the datepicker fire jQuery-triggered change events, which native listeners never see
    if (window.jQuery) {
      window.jQuery(this.element).on("change.faeFrameFilter", "form select, form .datepicker input", this.onChange)
    } else {
      this.element.addEventListener("change", this.onChange)
    }

    this.decorate()
  }

  disconnect() {
    this.element.removeEventListener("click", this.onClick)
    this.element.removeEventListener("turbo:frame-load", this.decorate)
    window.removeEventListener("popstate", this.onPopState)
    clearTimeout(this.dateTimer)

    if (window.jQuery) {
      window.jQuery(this.element).off(".faeFrameFilter")
    } else {
      this.element.removeEventListener("change", this.onChange)
    }
  }

  // Only for history moving between states of this list; going back to another page is Turbo's to handle
  onPopState() {
    if (window.location.pathname === this.pagePath) window.location.reload()
  }

  onChange(event) {
    const field = event.target
    if (!field.matches("select, .datepicker input") || !field.closest("form")) return

    // A date is typed or picked in pieces, so wait for it to settle
    if (field.matches(".datepicker input")) {
      clearTimeout(this.dateTimer)
      this.dateTimer = setTimeout(() => this.submitForm(field.closest("form")), 500)
    } else {
      this.submitForm(field.closest("form"))
    }
  }

  onClick(event) {
    const target = event.target

    if (target.closest(".table-filter-keyword-wrapper i")) {
      event.preventDefault()
      this.submitForm(target.closest("form"))
      return
    }

    const header = target.closest("th[data-sort]")
    if (header && this.element.contains(header)) {
      event.preventDefault()
      this.sortBy(header)
      return
    }

    const link = target.closest(".pagination a[href]")
    if (link && this.element.contains(link)) {
      event.preventDefault()
      this.visit(link.href)
    }
  }

  submitForm(form) {
    if (form && typeof form.requestSubmit === "function") form.requestSubmit()
  }

  sortBy(header) {
    const params = new URLSearchParams(window.location.search)
    const direction = params.get("sort_by") === header.dataset.sort && params.get("sort_direction") === "asc" ? "desc" : "asc"

    params.set("sort_by", header.dataset.sort)
    params.set("sort_direction", direction)
    params.delete("page")

    this.visit(`${window.location.pathname}?${params.toString()}`)
  }

  visit(url) {
    window.Turbo.visit(url, { frame: this.element.id, action: "advance" })
  }

  // Marks the sorted column and wraps header text the way the legacy filtering does, so the same styles apply
  decorate() {
    const params = new URLSearchParams(window.location.search)
    const sortBy = params.get("sort_by")
    const direction = params.get("sort_direction") || "asc"

    this.element.querySelectorAll("th[data-sort]").forEach((header) => {
      header.classList.toggle(`-${direction}`, header.dataset.sort === sortBy)

      if (!header.querySelector(".th-sortable-title")) {
        const wrapper = document.createElement("div")
        wrapper.className = "th-sortable-title"
        while (header.firstChild) wrapper.appendChild(header.firstChild)
        header.appendChild(wrapper)
      }
    })
  }
}
