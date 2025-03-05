import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  show(evt) {
    const fileUri = evt.detail.fileUri;
    console.log('fileUri', this.element)
    this.element.innerHTML = `
      <model-viewer auto-rotate camera-controls ar-modes="webxr scene-viewer quick-look" src="${fileUri}" crossorigin="use-credentials"></model-viewer>
    `
  }
}