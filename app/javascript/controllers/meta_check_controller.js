import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    url: String
  }

  connect() {
    fetch(this.urlValue)
      .then((response) => response.json())
      .then((json) => this.hideLink(json))
  }

  hideLink(meta_json) {
    if (!meta_json['earthworks']) this.element.remove();
  } 
}