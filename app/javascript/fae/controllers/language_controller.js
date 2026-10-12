import { Controller } from "@hotwired/stimulus"

// Shows/hides `div[data-language]` field wrappers based on the form header's
// language select and persists the choice to the current user.
// Replaces Fae.navigation.language's setInitialState/addNavEvents.
export default class extends Controller {
  static values = { preferencePath: String }

  connect() {
    this.change = this.change.bind(this)

    // Chosen fires jQuery-triggered change events, which native listeners never
    // see; jQuery handlers receive both those and genuine browser events.
    if (window.jQuery) {
      window.jQuery(this.element).on("change.faeLanguage", this.change)
    } else {
      this.element.addEventListener("change", this.change)
    }

    this.toggleFields(this.currentLanguage)
  }

  disconnect() {
    if (window.jQuery) {
      window.jQuery(this.element).off(".faeLanguage")
    } else {
      this.element.removeEventListener("change", this.change)
    }
  }

  change() {
    const lang = this.currentLanguage

    this.toggleFields(lang)
    this.persistPreference(lang)
    document.querySelectorAll(".hidden_errors").forEach((node) => node.remove())
  }

  get currentLanguage() {
    return this.element.value || "all"
  }

  toggleFields(lang) {
    document.querySelectorAll("div[data-language]").forEach((field) => {
      const fieldLang = field.getAttribute("data-language")
      const visible = lang === "all" || fieldLang === "en" || fieldLang === lang

      field.style.display = visible ? "" : "none"
    })
  }

  persistPreference(lang) {
    if (!this.hasPreferencePathValue) return

    const token = document.querySelector('meta[name="csrf-token"]')?.content
    const headers = { "X-Requested-With": "XMLHttpRequest" }
    if (token) headers["X-CSRF-Token"] = token

    fetch(`${this.preferencePathValue}/${encodeURIComponent(lang)}`, {
      method: "POST",
      headers,
      credentials: "same-origin"
    }).catch(() => {})
  }
}
