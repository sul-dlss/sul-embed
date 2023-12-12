import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  drawMetadata(event) {
    const json = event.detail
    const html = json.metadata.map((record) => `<dt>${record.label.en[0]}</dt>${this.valueToDefinition(record.value.en)}`).join('')
    this.element.innerHTML = html
  }

  valueToDefinition(defs) {
    return defs.map((record) => `<dd>${record}</dd>`).join('')
  }
}