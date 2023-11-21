import { Controller } from "@hotwired/stimulus"
import { EmbedThis } from '../modules/embed_this.js';

export default class extends Controller {
  static targets = [ "leftDrawer", "leftButton", "metadata", "shareModal", "contents", "transcript",
                     "downloadModal", "rights", "accessibility", "modalComponentsPopover"]
  connect() {
    this.element.style.display = ''
    this.metadataTarget.hidden = false
    EmbedThis.init();
  }

  toggleLeft() {
    const classList = this.leftDrawerTarget.classList
    if (classList.contains('open')) {
      classList.remove('open')
      setTimeout(() => {
        this.leftDrawerTarget.style.visibility = 'hidden' // remove from accessability tree
      }, 1000)
    } else {
      this.leftDrawerTarget.style.visibility = ''
      classList.add('open')
    }
  }

  openModalComponentsPopover() {
    this.modalComponentsPopoverTarget.showModal()
  }

  closePopover() {
    this.modalComponentsPopoverTarget.close()
  }

  handleBackdropClicks(event) {
    const modal = event.target.closest('dialog')
    const rect = modal.getBoundingClientRect()
    const clickWithinDialog = (rect.top <= event.clientY && event.clientY <= rect.top + rect.height &&
                               rect.left <= event.clientX && event.clientX <= rect.left + rect.width)

    if (!clickWithinDialog) modal.close()
  }

  openShareModal() {
    this.shareModalTarget.showModal()
  }

  openDownloadModal() {
    this.downloadModalTarget.showModal()
  }

  displayMetadata(evt) {
    this.setLeftButtonActive(evt)

    this.metadataTarget.hidden = false
    this.contentsTarget.hidden = true
    this.rightsTarget.hidden = true
    this.transcriptTarget.hidden = true

  }

  displayContents(evt) {
    this.setLeftButtonActive(evt)

    this.metadataTarget.hidden = true
    this.contentsTarget.hidden = false
    this.rightsTarget.hidden = true
    this.transcriptTarget.hidden = true
  }

  displayRights(evt) {
    this.setLeftButtonActive(evt)

    this.metadataTarget.hidden = true
    this.contentsTarget.hidden = true
    this.rightsTarget.hidden = false
    this.transcriptTarget.hidden = true
  }

  displayTranscript(evt) {
    this.setLeftButtonActive(evt)

    this.metadataTarget.hidden = true
    this.contentsTarget.hidden = true
    this.rightsTarget.hidden = true
    this.transcriptTarget.hidden = false
  }

  setLeftButtonActive(evt) {
    this.leftButtonTargets.forEach((button) => {
      button.classList.remove('active')
      button.setAttribute("aria-selected", false);
    })
    // The evt.target may be the SVG, so need to look for a button
    const button = evt.target.closest('button')
    button.classList.add('active')
    button.setAttribute("aria-selected", true);
  }

  displayAccessibility() {
    this.accessibilityTarget.showModal()
  }
}
