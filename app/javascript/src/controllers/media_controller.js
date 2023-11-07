import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "leftDrawer", "leftButton", "rightDrawer", "metadata", "share", "contents", "downloads", "rights" ]
  connect() {
    this.metadataTarget.hidden = false
  }

  toggleLeft() {
    this.leftDrawerTarget.classList.toggle('open')
  }

  toggleDownloads() {
    if (this.downloadsTarget.hidden) {
      this._openRightDrawer();
      this.downloadsTarget.hidden = false
      this.contentsTarget.hidden = true
    } else {
      this._closeRightDrawer()
    }
  }

  toggleContents() {
    if (this.contentsTarget.hidden) {
      this._openRightDrawer();
      this.downloadsTarget.hidden = true
      this.contentsTarget.hidden = false
    } else {
      this._closeRightDrawer()
    }
  }

  _openRightDrawer() {
    this.rightDrawerTarget.classList.add('open')
  }

  _closeRightDrawer() {
    this.rightDrawerTarget.classList.remove('open')
    setTimeout(() => {
      // Wait for drawer to close
      this.downloadsTarget.hidden = true
      this.contentsTarget.hidden = true
    }, 500);
  }

  displayMetadata(evt) {
    this.setLeftButtonActive(evt)

    this.metadataTarget.hidden = false
    this.rightsTarget.hidden = true
    this.shareTarget.hidden = true
  }

  displayRights(evt) {
    this.setLeftButtonActive(evt)

    this.metadataTarget.hidden = true
    this.rightsTarget.hidden = false
    this.shareTarget.hidden = true
  }

  displayShare(evt) {
    this.setLeftButtonActive(evt)

    this.metadataTarget.hidden = true
    this.rightsTarget.hidden = true
    this.shareTarget.hidden = false
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
