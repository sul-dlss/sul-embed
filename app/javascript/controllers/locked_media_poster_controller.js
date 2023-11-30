import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // Display the lock if the video tag doesn't have a poster
  show() {
    if (!this.hasPoster())
      this.element.style.display = 'flex'
  }

  hide() {
    this.element.style.display = 'none'
  }

  hasPoster() {
    const tags = document.querySelectorAll('video,audio')
    return [...tags].some((tag) => tag.getAttribute('poster'))
  }
}