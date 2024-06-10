import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // make the object-content tab active by default if it exists
    if (this.element.attributes['aria-controls'].value === 'object-content') {
      this.switch()
    }
  }

  switch() {
    this.#deactivate(this.#currentlyActiveButton())
    this.#makeActive(this.element)
  }

  #currentlyActiveButton() {
    return this.#tabList.querySelector('[role=tab].active')
  }

  get #tabList() {
    return this.element.closest('[role=tablist]')
  }

  #makeActive(button) {
    button.classList.add("active")
    button.setAttribute('aria-selected', true)
    this.#tabPanelFor(button).hidden = false
  }

  #deactivate(button) {
    button.classList.remove("active")
    button.setAttribute('aria-selected', false)
    this.#tabPanelFor(button).hidden = true
  }

  #tabPanelFor(button) {
    const id = button.getAttribute('aria-controls')
    return document.getElementById(id)
  }
}
