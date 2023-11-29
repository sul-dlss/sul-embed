import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ ]

  // Sends an event that tells the MediaWrapperController to display the selected media.
  activate(evt) {
    evt.preventDefault();
    const event = new CustomEvent('thumbnail-clicked', { detail: { index: evt.params.index } })
    window.dispatchEvent(event)

    const tabs = this.element.closest('[role="tablist"]').querySelectorAll('[role="tab"]')
    tabs.forEach((target) => {
      target.classList.remove('active')
      target.setAttribute("aria-selected", false)
    })

    const target = this.element
    target.classList.add('active')
    target.setAttribute("aria-selected", true)
  }
}
