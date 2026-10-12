import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { name: { type: String, default: "Fae" } }

  connect() {
    this.element.textContent = `Hello, ${this.nameValue}`
  }
}
