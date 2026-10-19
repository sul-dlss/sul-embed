import { Controller } from "@hotwired/stimulus"
import Thumbnail from "src/modules/thumbnail"

export default class extends Controller {
  static targets = ["listItem"]

  // The viewer can open on an item far down a long list; we need to wait
  // until it's onscreen and then scroll down to whatever item is active
  connect() {
    this.revealObserver = new ResizeObserver(() => this.revealActiveItem())
    this.revealObserver.observe(this.element)
  }

  disconnect() {
    this.revealObserver.disconnect()
  }

  // Scroll the list so that the active item is visible, once
  revealActiveItem() {
    const item = this.element.querySelector("[role=tab].active")
    if (!item || item.getClientRects().length === 0) return

    this.revealObserver.disconnect()
    const container = this.scrollContainer()
    if (!container) return

    const itemRect = item.getBoundingClientRect()
    const containerRect = container.getBoundingClientRect()
    if (
      itemRect.top >= containerRect.top &&
      itemRect.bottom <= containerRect.bottom
    )
      return

    // Scroll the list, not the page we're embedded in
    container.scrollTop +=
      itemRect.top -
      containerRect.top -
      (container.clientHeight - itemRect.height) / 2
  }

  // The nearest ancestor that scrolls the list, if it is long enough to need scrolling
  scrollContainer() {
    for (let el = this.element.parentElement; el; el = el.parentElement) {
      const { overflowY } = getComputedStyle(el)
      if (
        ["auto", "scroll"].includes(overflowY) &&
        el.scrollHeight > el.clientHeight
      )
        return el
    }
  }

  // This listens for a thumbnails-found event. Then it draws the media thumbnails in the contents panel
  drawThumbnails(evt) {
    const thumbnails = evt.detail.map((thumbnailData, index) =>
      new Thumbnail(thumbnailData).build(index),
    )
    this.element.innerHTML = thumbnails.join("")
  }

  // Show a different media file when the user selects it in the list
  // Sends an event that tells the MediaWrapperController to display the selected media.
  showMedia(evt) {
    evt.preventDefault()
    this.sendThubmnailClickedEvent(
      evt.params.index,
      evt.currentTarget.dataset.url,
    )

    this.listItemTargets.forEach(target => {
      this.unsetActive(target)
    })

    const target = this.listItemTargets.find(
      element => element.dataset.contentListIndexParam == evt.params.index,
    )
    this.setActive(target)
  }

  // Show a different PDF when the user selects it in the list
  // Sends an event that tells the PDFController to display the selected PDF.
  showPdf(evt) {
    evt.preventDefault()
    this.sendThubmnailClickedEvent(
      evt.params.index,
      evt.currentTarget.dataset.url,
    )

    const fileThumbActive = document?.querySelector(".file-thumb.active")
    if (fileThumbActive) {
      this.unsetActive(fileThumbActive)
    }

    this.setActive(evt.currentTarget)
  }

  sendThubmnailClickedEvent(index, fileUri) {
    const event = new CustomEvent("thumbnail-clicked", {
      detail: { index: index, fileUri: fileUri },
    })
    window.dispatchEvent(event)
  }

  setActive(target) {
    target.setAttribute("aria-selected", true)
    target.classList.add("active")
  }

  unsetActive(target) {
    target.setAttribute("aria-selected", false)
    target.classList.remove("active")
  }
}
