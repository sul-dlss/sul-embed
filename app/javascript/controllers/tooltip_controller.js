import { Controller } from "@hotwired/stimulus"
import { createPopper }  from 'popper'

export default class extends Controller {
  connect () {
    this.tooltip = document.createElement("div")
    this.tooltip.classList.add('tooltip')
    this.tooltip.innerHTML = this.element.getAttribute('aria-label')
    this.tooltip.ariaHidden = 'true'
    // tooltip must be appended to a parent of any part of the viewer
    // that might otherwise cover it and be within the area shown in
    // fullscreen mode.
    this.element.closest('#sul-embed-object').appendChild(this.tooltip)

    this.popperInstance = createPopper(this.element, this.tooltip)
  }
  show() {
    this.tooltip.classList.add('show')

    this.popperInstance.update()
  }

  hide() {
      this.tooltip.classList.remove('show')
  }
}
