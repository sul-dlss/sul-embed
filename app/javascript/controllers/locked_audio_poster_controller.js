import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "poster"]
  // Display the waveform when logged out as the audio tag
  // does not support the poster attribute
  show() {
    if (this.isAudio()) {
      const posterPath = this.poster()
      if (posterPath)
        this.posterTarget.setAttribute('src', posterPath)

      this.element.hidden = false
    }
  }

  hide() {
    this.element.hidden = true
  }

  isAudio() {
    return document.querySelectorAll('audio').length > 0
  }

  poster() {
    return document.querySelector('audio').getAttribute('poster')
  }
}
