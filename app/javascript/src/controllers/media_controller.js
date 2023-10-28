import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "leftDrawer" ]

  toggleLeft() {
    this.leftDrawerTarget.classList.toggle('open')
  }
}