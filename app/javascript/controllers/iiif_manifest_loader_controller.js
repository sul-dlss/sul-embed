import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    iiifManifest: String
  }

  connect() {
    this.fetchIiifManifest()
  }

  fetchIiifManifest() {
    fetch(this.iiifManifestValue)
      .then((response) => response.json())
      .then((json) => this.dispatchManifestEvent(json))
      .catch((err) => console.error(err))
  }

  dispatchManifestEvent(json) {
    const event = new CustomEvent('iiif-manifest-received', { detail: json })
    window.dispatchEvent(event)
  }
}
