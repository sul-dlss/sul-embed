import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "leftDrawer", "rightDrawer", "metadata", "share", "contents", "downloads" ]
  connect() {
    this.metadataTarget.hidden = false
  }
  
  toggleLeft() {
    this.leftDrawerTarget.classList.toggle('open')
  }

  displayDownloads() {
    this.rightDrawerTarget.classList.add('open')
    this.downloadsTarget.hidden = false
    this.contentsTarget.hidden = true
  }

  displayContents() {
    this.rightDrawerTarget.classList.add('open')
    this.downloadsTarget.hidden = true
    this.contentsTarget.hidden = false
  }

  displayMetadata() {
    this.metadataTarget.hidden = false
    this.shareTarget.hidden = true
  }

  displayShare() {
    this.metadataTarget.hidden = true
    this.shareTarget.hidden = false
  }
}