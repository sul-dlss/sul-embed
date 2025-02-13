import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  show() {
    if (!this.tooltip) {
      this.tooltip = document.createElement("div")
      this.tooltip.classList.add('tooltip')
      const rect = this.element.getBoundingClientRect()
      this.tooltip.style.left = `${rect.left}px`
      this.tooltip.style.top = `${rect.bottom + 2}px`

      this.tooltip.innerHTML = this.element.getAttribute('aria-label')
      document.body.appendChild(this.tooltip);
    }
    setTimeout(() => this.tooltip.classList.add('show'), 1);
  }

  hide() {
    if (!this.tooltip)
      return
     // this.tooltip.remove()
    this.tooltip.classList.remove('show')
    // setTimeout(() => this.tooltip.remove(), 100);

  }
}
