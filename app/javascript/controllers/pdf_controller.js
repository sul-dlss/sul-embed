import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  show(evt) {
    const file_uri = evt.detail
    this.element.innerHTML = `
      <object data="${file_uri}" type="application/pdf" style="height: 100%; width: 100%">
        <p>Your browser does not support viewing PDFs.  Please <a href="${file_uri}">download the file</a> to view it.</p>
      </object>
    `
  }
}
