import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // Display the lock if the video tag doesn't have a poster
  show() {
    if (!this.hasPoster())
      this.element.hidden = false
  }

  hide() {
    this.element.hidden = true
  }

  hasPoster() {
    const tags = document.querySelectorAll('video')
    return [...tags].some((tag) => tag.getAttribute('poster'))
  }
}
