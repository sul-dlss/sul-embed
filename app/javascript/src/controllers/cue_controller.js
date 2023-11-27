import { Controller } from "@hotwired/stimulus"

// Changes clicks on cues to events that the player listens for
export default class extends Controller {
  static values = {
    start: String,
    end: String,
  }
  jump(evt) {
    const event = new CustomEvent('media-seek', { detail: this.startValue })
    window.dispatchEvent(event)
  }
}
