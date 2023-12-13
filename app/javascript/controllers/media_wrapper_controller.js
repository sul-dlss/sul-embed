import { Controller } from "@hotwired/stimulus"
import videojs from 'video.js';

export default class extends Controller {
  static targets = [ ]
  static values = {
    index: Number
  }


  toggleVisibility(event) {
    const index =  event.detail.index
    this.element.hidden = this.indexValue !== index
    this.pauseAllMedia();
  }

  pauseAllMedia() {
    const mediaObject = this.element.querySelector('.video-js')
    if (mediaObject) {
      videojs(mediaObject.id).pause()
    }
  }
}
