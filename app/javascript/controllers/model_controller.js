import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modelViewerContainer"]
  show(evt) {
    const fileUri = evt.detail.fileUri;
    // with-credentials breaks things for local development
    // we should figure out how to set up auth to not check if the file is open, then we can fix this
    this.modelViewerContainerTarget.innerHTML = `
      <model-viewer with-credentials auto-rotate camera-controls ar-modes="webxr scene-viewer quick-look" src="${fileUri}"></model-viewer>
    `
    this.modelViewer = this.modelViewerContainerTarget.getElementsByTagName('model-viewer')[0]
  }

  zoomIn() {
    this.modelViewer?.zoom(1)
  }

  zoomOut() {
    this.modelViewer?.zoom(-1)
  }
}
