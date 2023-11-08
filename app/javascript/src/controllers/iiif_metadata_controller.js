import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    url: String
  }
  connect() {
    fetch(this.urlValue)
      .then((response) => response.json())
      .then((json) => this.drawMetadata(json))
      .catch((err) => console.error(err))
  }

  drawMetadata(json) {
    const html = json.metadata.map((record) => `<dt>${record.label.en[0]}</dt>${this.valueToDefinition(record.value.en)}`).join('')
    this.element.innerHTML = html
  }

  valueToDefinition(defs) {
    return defs.map((record) => `<dd>${record}</dd>`).join('')
  }
}