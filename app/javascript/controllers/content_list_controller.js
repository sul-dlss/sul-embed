import { Controller } from "@hotwired/stimulus"
import Thumbnail from 'src/modules/thumbnail'

export default class extends Controller {
  // This listens for a thumbnails-found event. Then it draws each on the page.
  draw(evt) {
    const thumbnails = evt.detail.
      map((thumbnailData, index) => new Thumbnail(thumbnailData).build(index))
    this.element.innerHTML = thumbnails.join('')
  }
}
