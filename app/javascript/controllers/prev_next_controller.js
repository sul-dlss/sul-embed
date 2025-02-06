import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static outlets = [ "content-list" ]

  prevNextMedia(evt) {
    this.contentListOutlet.showMedia(evt);
  }
}