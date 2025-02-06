import { Controller } from "@hotwired/stimulus"
import OpenSeadragon from 'openseadragon'

export default class extends Controller {
  static values = {
    url: String,
    navImages: Object,
  }

  initializeViewer(evt) {
    // Customize the error message displayed to users:
    OpenSeadragon.setString('Errors.OpenFailed', 'Restricted')

    // only load viewer if the image has been clicked in the sidebar
    // and the viewer has never been initialized.
    if (this.viewer || this.element.dataset.index != String(evt.detail.index)) return;
    this.viewer = OpenSeadragon({
      id: this.element.id,
      tileSources: [this.urlValue],
      prefixUrl: '',
      navImages: this.navImagesValue,
    })
  }
}