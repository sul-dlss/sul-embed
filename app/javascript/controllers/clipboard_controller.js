import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['value']

  copy () {
    navigator.clipboard.writeText(this.valueTarget.value)
  }
}
