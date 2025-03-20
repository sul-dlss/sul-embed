import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // TODO: accessability and transcript should move to a controller just for media.
  static values = {
    autoExpand: Boolean
  }
  static targets = [ "leftDrawer", "toggleButton", "shareButton", "shareModal",
                     "downloadModal", "accessibility", "modalComponentsPopover"]
  connect() {
    this.element.hidden = false
    if (!this.isSmallViewportWidth() && this.autoExpandValue) {
      // Open the drawer on load
      this.openLeftDrawer()
    }
  }

  toggleLeft(evt) {
    const button = this.toggleButtonTarget
    button.disabled = true // Prevent additional clicks until all mutations are complete.
    let action;
    if (this.leftDrawerTarget.classList.contains('open')) {
      action = this.closeLeftDrawer()
    } else {
      action = this.openLeftDrawer()
    }
    action.then(() => button.disabled = false) // reenable the button
  }

  openLeftDrawer() {
    this.leftDrawerTarget.classList.add('open')
    this.leftDrawerTarget.style.visibility = ''
    return Promise.resolve()
  }

  closeLeftDrawer() {
    this.leftDrawerTarget.classList.remove('open')
    return new Promise(resolve => setTimeout(() => {
        this.leftDrawerTarget.style.visibility = 'hidden' // remove from accessability tree
        resolve()
      }, 500)
    )
  }

  openModalComponentsPopover() {
    this.modalComponentsPopoverTarget.showModal()
  }

  closePopover() {
    this.modalComponentsPopoverTarget.close()
  }

  closeModal(event) {
    event.target.closest('dialog')?.close()

    // After closing the modal, we need to put the focus back to the button that launched the
    // original interaction.  We need to do this because the immediately preceeding action was
    // on the popover, which has already been closed.
    // We only want to do this for users using the keyboard and not users using the mouse
    this.returnFocusButton?.focus()
  }

  handleBackdropClicks(event) {
    const modal = event.target.closest('dialog')
    const rect = modal.getBoundingClientRect()
    const clickWithinDialog = (rect.top <= event.clientY && event.clientY <= rect.top + rect.height &&
                               rect.left <= event.clientX && event.clientX <= rect.left + rect.width)

    if (!clickWithinDialog) modal.close()
  }

  openModal(event) {
    const clickedButton = event.currentTarget.closest('button')
    this.setReturnFocusButton(clickedButton)
    const modalName = clickedButton.dataset.target
    this[`${modalName}Target`].showModal()
  }

  setReturnFocusButton(button) {
    this.returnFocusButton = undefined
    // we want the focus to return to share/download button not to the closed dropdown menu
    if (button.parentElement.tagName !== 'DIALOG' && button.matches(':focus-visible')){
      this.returnFocusButton = button
    }
  }

  isSmallViewportWidth() {
    return document.documentElement.clientWidth < 800
  }
}
