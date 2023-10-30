import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "leftDrawer", "leftButton", "rightDrawer", "metadata", "share", "contents", "downloads" ]
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

  displayMetadata(evt) {
    this.leftButtonTargets.forEach((target) => target.classList.remove('active'))
    // The evt.target may be the SVG, so need to look for a button
    evt.target.closest('button').classList.add('active')
    this.metadataTarget.hidden = false
    this.shareTarget.hidden = true
  }

  displayShare(evt) {
    this.leftButtonTargets.forEach((target) => target.classList.remove('active'))
    // The evt.target may be the SVG, so need to look for a button
    evt.target.closest('button').classList.add('active')
    this.metadataTarget.hidden = true
    this.shareTarget.hidden = false
  }
}