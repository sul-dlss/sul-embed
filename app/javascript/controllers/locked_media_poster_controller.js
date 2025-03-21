import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  hide() {
    document.querySelectorAll('video').forEach(video => {
      if(video.getAttribute("poster").includes('locked'))
        video.removeAttribute("poster")
    })
  }
}
