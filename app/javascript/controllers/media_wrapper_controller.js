import { Controller } from "@hotwired/stimulus"
import videojs from 'video.js'

export default class extends Controller {
  static targets = [ ]
  static values = {
    index: Number
  }


  toggleVisibility(event) {
    const index =  event.detail.index
    this.element.hidden = this.indexValue !== index
    this.pauseAllMedia(index)
  }

  // switch transcript if media object index is the same as the visible index.
  pauseAllMedia(index) {
    const mediaObject = this.element.querySelector('.video-js')
    if (mediaObject) {
      const playerObject = videojs(mediaObject.id);
      playerObject.pause()
      if (mediaObject.dataset.index == index){
        window.dispatchEvent(new CustomEvent('switch-transcript', { detail: playerObject }))
      }
    }
  }
}
