import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  drawMetadata(event) {
    const json = event.detail
    const html = json.metadata.map((record) => `<dt>${record.label.en[0]}</dt>${this.valueToDefinition(record.value.en)}`).join('')
    this.element.innerHTML = html
  }

  valueToDefinition(defs) {
    return defs.map(record => {
      // Make sure all links open in a new window
      const node = new DOMParser().parseFromString(record, "text/html").body.firstChild
      if ('target' in node) {
        // Set all elements owning target to target=_blank
        node.setAttribute('target', '_blank')
        // Prevent https://www.owasp.org/index.php/Reverse_Tabnabbing
        node.setAttribute('rel', 'noopener noreferrer')
        node.classList.add('su-underline')
        return `<dd>${node.outerHTML}</dd>`
      } else {
        return `<dd>${record}</dd>`
      }
    }).join('')
  }
}
