import { Controller } from "@hotwired/stimulus"

// The form header's Cancel button. Replaces Fae.form.cancel.
//
// - Adds `?cancelled=true` to the link once the user edits the form, so the index can say changes weren't saved.
// - On drafts (`data-draft="true"`), confirms before discarding, turns the link into a DELETE of the draft
//   (`data-delete-path`), and warns before the page is closed or navigated away from with unsaved work.
export default class extends Controller {
  connect() {
    this.allowUnload = false
    this.onChange = this.onChange.bind(this)
    this.onSubmit = this.onSubmit.bind(this)
    this.confirmDiscard = this.confirmDiscard.bind(this)
    this.onBeforeUnload = this.onBeforeUnload.bind(this)

    this.removeCancelledParam()

    // Chosen, the datepicker and specs fire jQuery-triggered events that native listeners never see, so
    // go through jQuery when it's present.
    this.forms = document.querySelectorAll("form")
    if (window.jQuery) {
      window.jQuery(this.forms)
        .on("change.faeCancel", "input, textarea, select", this.onChange)
        .on("submit.faeCancel", this.onSubmit)
    } else {
      this.forms.forEach((form) => {
        form.addEventListener("change", this.onChange)
        form.addEventListener("submit", this.onSubmit)
      })
    }

    if (this.isDraft) {
      this.useDeleteLink()
      this.element.addEventListener("click", this.confirmDiscard)
      window.addEventListener("beforeunload", this.onBeforeUnload)
    }
  }

  disconnect() {
    if (window.jQuery) {
      window.jQuery(this.forms).off(".faeCancel")
    } else {
      this.forms.forEach((form) => {
        form.removeEventListener("change", this.onChange)
        form.removeEventListener("submit", this.onSubmit)
      })
    }

    this.element.removeEventListener("click", this.confirmDiscard)
    window.removeEventListener("beforeunload", this.onBeforeUnload)
  }

  get isDraft() {
    return this.element.dataset.draft === "true"
  }

  // A cancelled index page shouldn't keep the flag in its URL (reloads would repeat the message)
  removeCancelledParam() {
    const params = window.location.search
    if (params.length && params.toLowerCase().includes("cancelled") && params.indexOf("&") !== 0) {
      window.history.replaceState(null, null, window.location.pathname)
    }
  }

  onChange() {
    const href = this.element.getAttribute("href")

    if (href && !href.includes("cancelled=true")) {
      this.element.setAttribute("href", `${href}?cancelled=true`)
    }
  }

  onSubmit() {
    this.allowUnload = true
  }

  // Cancelling a draft deletes it through Rails UJS (`data-method`), which then redirects to the index
  useDeleteLink() {
    const deletePath = this.element.dataset.deletePath
    if (!deletePath) return

    this.element.dataset.indexPath = this.element.getAttribute("href").split("?")[0]
    this.element.setAttribute("href", deletePath)
    this.element.setAttribute("data-method", "delete")
  }

  confirmDiscard(event) {
    if (!window.confirm("You will lose any changes to this draft. Are you sure you want to cancel?")) {
      event.preventDefault()
      event.stopPropagation()
      return
    }

    this.allowUnload = true
  }

  onBeforeUnload(event) {
    if (this.allowUnload) return

    event.preventDefault()
    event.returnValue = ""
  }
}
