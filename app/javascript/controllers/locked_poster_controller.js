import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // Display the lock
  show() {
    this.element.hidden = false
  }

  hide() {
    this.element.hidden = true
  }
}
