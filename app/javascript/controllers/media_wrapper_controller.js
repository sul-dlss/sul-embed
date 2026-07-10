import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = []
  static values = {
    index: Number,
  }

  toggleVisibility(event) {
    const index = event.detail.index
    this.element.hidden = this.indexValue !== index
    this.pauseAllMedia(index)
  }

  // switch transcript if media object index is the same as the visible index.
  pauseAllMedia(index) {
    const mediaObject = this.element.querySelector("hlsjs-video")
    if (mediaObject) {
      mediaObject.pause()
      if (mediaObject.dataset.index == index) {
        window.dispatchEvent(
          new CustomEvent("switch-transcript", { detail: mediaObject }),
        )
      }
    }
  }
}
