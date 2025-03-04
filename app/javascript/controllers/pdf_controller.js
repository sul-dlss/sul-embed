import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  show(evt) {
    const fileUri = evt.detail
    this.element.innerHTML = `
      <object data="${fileUri}" type="application/pdf" style="height: 100%; width: 100%">
        <div class="authLinkWrapper">
          <svg class="MuiSvgIcon-root WarningAmberSharp" focusable="false" aria-hidden="true" viewBox="0 0 24 24">
            <path d="M12 5.99 19.53 19H4.47zM12 2 1 21h22zm1 14h-2v2h2zm0-6h-2v4h2z"/>
          </svg>
          <p class="loginMessage">There was an issue viewing this item.</p>
        </div>
      </object>
    `
  }
}
