import { Controller } from "@hotwired/stimulus"
import OpenSeadragon from 'openseadragon';

export default class extends Controller {
  static values = {
    url: String,
    navImages: Object,
  }

  connect() {
    OpenSeadragon({
      id: this.element.id,
      tileSources: [this.urlValue],
      prefixUrl: '',
      navImages: this.navImagesValue,
    })
  }
}