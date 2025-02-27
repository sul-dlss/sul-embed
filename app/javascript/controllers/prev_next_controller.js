import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static outlets = [ "content-list" ]

  prevNextMedia(evt) {
    const index = evt.currentTarget.dataset.prevNextIndexParam
    const thumbnail = this.contentListOutlet.element.querySelector(`[data-content-list-index-param="${index}"]`)
    thumbnail.click()
  }
}
