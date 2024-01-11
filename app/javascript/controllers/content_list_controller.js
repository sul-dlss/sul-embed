import { Controller } from "@hotwired/stimulus"
import Thumbnail from 'src/modules/thumbnail'

export default class extends Controller {
  // This listens for a thumbnails-found event. Then it draws the media thumbnails in the contents panel
  drawThumbnails(evt) {
    const thumbnails = evt.detail.
      map((thumbnailData, index) => new Thumbnail(thumbnailData).build(index))
    this.element.innerHTML = thumbnails.join('')
  }

  // Show a different media file when the user selects it in the list
  // Sends an event that tells the MediaWrapperController to display the selected media.
  showMedia(evt) {
    evt.preventDefault();
    const event = new CustomEvent('thumbnail-clicked', { detail: { index: evt.params.index } })
    window.dispatchEvent(event)

    const tabs = this.element.closest('[role="tablist"]').querySelectorAll('[role="tab"]')
    tabs.forEach((target) => {
      target.classList.remove('active')
      target.setAttribute("aria-selected", false)
    })

    const target = this.element
    target.classList.add('active')
    target.setAttribute("aria-selected", true)
  }

  // Show a different PDF when the user selects it in the list
  // Sends an event that tells the PDFController to display the selected PDF.
  showPdf(evt) {
    evt.preventDefault()
    const file_uri = evt.currentTarget.dataset.url
    window.dispatchEvent(new CustomEvent('auth-success', { detail: file_uri }))
  }
}
