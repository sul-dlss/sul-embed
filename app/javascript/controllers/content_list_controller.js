import { Controller } from "@hotwired/stimulus"
import Thumbnail from 'src/modules/thumbnail'

export default class extends Controller {
  static targets = ['listItem']
  // This listens for a thumbnails-found event. Then it draws the media thumbnails in the contents panel
  drawThumbnails(evt) {
    const thumbnails = evt.detail.
      map((thumbnailData, index) => new Thumbnail(thumbnailData).build(index))
    this.element.innerHTML = thumbnails.join('')
  }

  // Show a different media file when the user selects it in the list
  // Sends an event that tells the MediaWrapperController to display the selected media.
  showMedia(evt) {
    evt.preventDefault()
    this.sendThubmnailClickedEvent(evt.params.index, evt.currentTarget.dataset.url)

    this.listItemTargets.forEach((target) => {
      this.unsetActive(target)
    })

    const target = this.listItemTargets.find(element => element.dataset.contentListIndexParam == evt.params.index)
    this.setActive(target)
  }

  // Show a different PDF when the user selects it in the list
  // Sends an event that tells the PDFController to display the selected PDF.
  showPdf(evt) {
    evt.preventDefault()
    this.sendThubmnailClickedEvent(evt.params.index, evt.currentTarget.dataset.url)

    const fileThumbActive = document?.querySelector('.file-thumb.active')
    if (fileThumbActive){
      this.unsetActive(fileThumbActive)
    }

    this.setActive(evt.currentTarget)
  }

  sendThubmnailClickedEvent(index, fileUri) {
    const event = new CustomEvent('thumbnail-clicked', { detail: { index: index, fileUri: fileUri } })
    window.dispatchEvent(event)
  }

  setActive(target) {
    target.setAttribute("aria-selected", true)
    target.classList.add('active')
  }

  unsetActive(target) {
    target.setAttribute("aria-selected", false)
    target.classList.remove('active')
  }
}
