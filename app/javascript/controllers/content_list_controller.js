import { Controller } from "@hotwired/stimulus"
import Thumbnail from 'src/modules/thumbnail'

export default class extends Controller {
  // This listens for a thumbnails-found event. Then it draws the media thumbnails in the contents panel
  drawThumbnails(evt) {
    const thumbnails = evt.detail.
      map((thumbnailData, index) => new Thumbnail(thumbnailData).build(index))
    this.element.innerHTML = thumbnails.join('')
  }

  // show a different PDF when the user selects it in the list
  showPdf(evt) {
    evt.preventDefault()
    const file_uri = evt.currentTarget.dataset.url
    window.dispatchEvent(new CustomEvent('auth-success', { detail: file_uri }))
  }
}
