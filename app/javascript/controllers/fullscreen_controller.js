import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['area', 'enterIcon', 'exitIcon']

  toggle() {
    if (!document.fullscreenElement) {
      this.areaTarget.requestFullscreen().catch((err) => {
        alert(
          `Error attempting to enable fullscreen mode: ${err.message} (${err.name})`,
        )
      })
    } else {
      document.exitFullscreen()
    }
  }

  updateButton() {
    if (document.fullscreenElement !== null) {
      // The hidden attribute doesn't appear to work on SVG in Firefox
      this.enterIconTarget.style.display = 'none'
      this.exitIconTarget.style.display = 'inline-block'
    } else {
      this.enterIconTarget.style.display = 'inline-block'
      this.exitIconTarget.style.display = 'none'
    }
  }
}
