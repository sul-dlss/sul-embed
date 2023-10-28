import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "leftDrawer", "rightDrawer" ]

  toggleLeft() {
    this.leftDrawerTarget.classList.toggle('open')
  }

  toggleRight() {
    this.rightDrawerTarget.classList.toggle('open')
  }
}