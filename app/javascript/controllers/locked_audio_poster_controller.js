import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // Display the waveform when logged out as the audio tag
  // does not support the poster attribute
  show() {
    if (this.isAudio())
      this.element.style.display = 'flex'
  }

  hide() {
    this.element.style.display = 'none'
  }

  isAudio() {
    return document.querySelectorAll('audio').length > 0
  }
}
