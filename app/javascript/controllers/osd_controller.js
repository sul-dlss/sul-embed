import { Controller } from "@hotwired/stimulus"
import OpenSeadragon from 'openseadragon'

export default class extends Controller {
  static values = {
    url: String,
    navImages: Object,
  }
  connect() {
    // Images are still on IIIF Auth V1 which does not include a probe service (V2 only).
    // file-auth-controller expects a probe service response for the first item in the manifest which isn't set up for images.
    // This will fix this issue until we get IIIF Auth V2 set up for images which is waiting on Mirador to support Auth V2.
    // https://github.com/ProjectMirador/mirador/issues/3789

    // setTimeout is needed, because without it, the viewer initializes before the drawer fully opens and the zoom is off.
    if (this.element.dataset.index == 0){
      setTimeout(() => {
        const event = new CustomEvent('thumbnail-clicked', { detail: { index: 0, fileUri: this.urlValue } })
        this.initializeViewer(event)
      }, 500);
    }
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