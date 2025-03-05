import { Controller } from "@hotwired/stimulus"
import ModelViewer from "src/modules/model_viewer"

export default class extends Controller {

  show(evt) {
    const fileUri = evt.detail.fileUri;
    // with-credentials breaks things for local development
    // we should figure out how to set up auth to not check if the file is open, then we can fix this
    this.element.innerHTML = `
      <model-viewer with-credentials="true" auto-rotate camera-controls ar-modes="webxr scene-viewer quick-look" src="${fileUri}"></model-viewer>
    `
    ModelViewer.init()
  }
}