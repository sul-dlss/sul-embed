import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ ]

  // Sends an event that tells the MediaWrapperController to display the selected media.
  activate(evt) {
    evt.preventDefault();
    const event = new CustomEvent('thumbnail-clicked', { detail: { index: evt.params.index } })
    window.dispatchEvent(event)
  }
}
