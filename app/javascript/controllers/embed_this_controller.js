import { Controller } from "@hotwired/stimulus"

// handles Embed This form interaction
export default class extends Controller {
  static targets = ['title', 'search', 'searchMinFiles', 'embed', 'output']
  connect() {
    const [prefix, url, ...rest] = this.outputTarget.value.split(/"/)
    this.prefix = prefix
    const [urlPrefix] = url.split("&", 1) // remove all of the attributes represented on the embed this form.
    this.url = urlPrefix
    this.suffix = rest.join()
  }

  change() {
    this.outputTarget.value = `${this.prefix}"${this.url}&${this.#buildParams()}"${this.suffix}`
  }

  #buildParams() {
    const params = []
    if (!this.titleTarget.checked)
      params.push('hide_title=true')
    if (!this.embedTarget.checked)
      params.push('hide_embed=true')
    if (this.hasSearchTarget) { // only for file type
      if (!this.searchTarget.checked) {
        params.push('hide_search=true')
      } else {
        params.push(`min_files_to_search=${this.searchMinFilesTarget.value}`)
      }
    }
    return params.join('&')
  }
}
