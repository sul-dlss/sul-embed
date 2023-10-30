import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ ]

  activate(evt) {
    evt.preventDefault();
    document.querySelectorAll('[data-slider-object]').forEach((element) => element.hidden = true)
    document.querySelector(`[data-slider-object="${evt.params.index}"]`).hidden = false
  }
}
