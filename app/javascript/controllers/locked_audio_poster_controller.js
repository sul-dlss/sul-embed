import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // Display the waveform when logged out as the audio tag
  // does not support the poster attribute
  show() {
    if (this.isAudio()) {
      const poster_path = this.poster()
      if (poster_path)
        document.getElementById('audio-poster').setAttribute('src', poster_path)

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
    const tags = document.querySelectorAll('audio')
    const audio_posters = [...tags].map((tag) => tag.getAttribute('poster'))
    return audio_posters.filter(poster => poster.includes('default.jpg'))[0]
  }
}
