import { Controller } from "@hotwired/stimulus"
import EmbedThis from 'src/modules/embed_this'

export default class extends Controller {
  // TODO: accessability and transcript should move to a controller just for media.
  static targets = [ "leftDrawer", "shareButton", "shareModal",
                     "downloadModal", "accessibility", "modalComponentsPopover"]
  connect() {
    this.element.hidden = false
    // Open the drawer on load
    this.openLeftDrawer()
    EmbedThis.init()
  }

  toggleLeft() {
    if (this.leftDrawerTarget.classList.contains('open')) {
      this.closeLeftDrawer()
    } else {
      this.openLeftDrawer()
    }
  }

  openLeftDrawer() {
    this.leftDrawerTarget.classList.add('open')
    this.leftDrawerTarget.style.visibility = ''
  }

  closeLeftDrawer() {
    this.leftDrawerTarget.classList.remove('open')
    setTimeout(() => {
      this.leftDrawerTarget.style.visibility = 'hidden' // remove from accessability tree
    }, 500)
  }

  openModalComponentsPopover() {
    this.modalComponentsPopoverTarget.showModal()
  }

  closePopover() {
    this.modalComponentsPopoverTarget.close()
  }

  closeModal() {
    this.downloadModalTarget.close()
    this.shareModalTarget.close()

    // After closing the modal, we need to put the focus back to the button that launched the
    // original interaction.  We need to do this because the immediately preceeding action was
    //  on the popover, which has already been closed.
    this.shareButtonTarget.focus()
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

  displayAccessibility() {
    this.accessibilityTarget.showModal()
  }
}
