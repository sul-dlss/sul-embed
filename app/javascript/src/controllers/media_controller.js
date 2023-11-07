import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "leftDrawer", "leftButton", "metadata", "shareModal", "contents", "downloadModal", "rights", "modalComponentsPopover" ]

  connect() {
    this.metadataTarget.hidden = false
  }

  toggleLeft() {
    this.leftDrawerTarget.classList.toggle('open')
  }

  openModalComponentsPopover() {
    this.modalComponentsPopoverTarget.showModal()
    this.modalComponentsPopoverTarget.addEventListener('click', () => this.modalComponentsPopoverTarget.close())
  }

  handleBackdropClicks(closeModal, event) {
    const modal = event.target.closest('dialog').getBoundingClientRect()
    const clickWithinDialog = (modal.top <= event.clientY && event.clientY <= modal.top + modal.height &&
                               modal.left <= event.clientX && event.clientX <= modal.left + modal.width)

    if (!clickWithinDialog) closeModal.bind(this)()
  }

  openShareModal() {
    this.shareModalTarget.style.display = "flex"
    this.shareModalTarget.addEventListener('click', this.handleBackdropClicks.bind(this, this.closeShareModal))
    this.shareModalTarget.showModal()
  }

  closeShareModal() {
    this.shareModalTarget.style.display = "none"
    this.shareModalTarget.removeEventListener('click', this.handleBackdropClicks.bind(this, this.closeShareModal))
    this.shareModalTarget.close()
  }

  openDownloadModal() {
    this.downloadModalTarget.style.display = "flex"
    this.downloadModalTarget.addEventListener('click', this.handleBackdropClicks.bind(this, this.closeDownloadModal))
    this.downloadModalTarget.showModal()
  }

  closeDownloadModal() {
    this.downloadModalTarget.style.display = "none"
    this.downloadModalTarget.removeEventListener('click', this.handleBackdropClicks.bind(this, this.closeDownloadModal))
    this.downloadModalTarget.close()
  }

  displayMetadata(evt) {
    this.setLeftButtonActive(evt)

    this.metadataTarget.hidden = false
    this.contentsTarget.hidden = true
    this.rightsTarget.hidden = true
  }

  displayContents(evt) {
    this.setLeftButtonActive(evt)

    this.metadataTarget.hidden = true
    this.contentsTarget.hidden = false
    this.rightsTarget.hidden = true
  }

  displayRights(evt) {
    this.setLeftButtonActive(evt)

    this.metadataTarget.hidden = true
    this.contentsTarget.hidden = true
    this.rightsTarget.hidden = false
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
}
