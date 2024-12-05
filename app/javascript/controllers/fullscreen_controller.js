import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['area']

  toggle () {
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
}
