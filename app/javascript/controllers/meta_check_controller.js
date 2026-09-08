import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    url: String,
  }

  async connect() {
    const meta = await this.fetchMeta()
    if (meta) this.hideLink(meta)
  }

  // This can fail when bots load an embed, because F5 will return them a 500
  // with no body. We don't need the Honeybadger noise in those cases. Anything
  // else is a real error, so let it reject and be reported.
  async fetchMeta() {
    const response = await fetch(this.urlValue)
    if (response.status === 500) return undefined
    if (!response.ok) throw new Error(`meta_json returned ${response.status}`)

    return await response.json()
  }

  hideLink(meta_json) {
    if (!meta_json["earthworks"]) this.element.remove()
  }
}
