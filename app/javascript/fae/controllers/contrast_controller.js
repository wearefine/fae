import { Controller } from "@hotwired/stimulus"

const HEX_REGEX = /^#[0-9a-fA-F]{6}$/

// Sets --foreground-color to black or white, whichever contrasts best with the
// user-configured --highlight-color.
export default class extends Controller {
  connect() {
    const highlight = getComputedStyle(this.element).getPropertyValue("--highlight-color").trim()
    if (!HEX_REGEX.test(highlight)) return

    const color = this.yiq(highlight) >= 170 ? "#000" : "#fff"
    this.element.style.setProperty("--foreground-color", color)
  }

  yiq(hex) {
    const r = parseInt(hex.substr(1, 2), 16)
    const g = parseInt(hex.substr(3, 2), 16)
    const b = parseInt(hex.substr(5, 2), 16)
    return ((r * 299) + (g * 587) + (b * 114)) / 1000
  }
}
