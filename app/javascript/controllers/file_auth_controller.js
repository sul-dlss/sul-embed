import { Controller } from "@hotwired/stimulus"
import AuthorizationClient, {
  manifestResources,
} from "src/modules/authorization_client"
import TokenStore from "src/modules/token_store"

export default class extends Controller {
  connect() {
    this.client = new AuthorizationClient({
      tokenStore: new TokenStore(),
      onResult: result => this.handleResult(result),
    })
  }

  disconnect() {
    this.client.dispose()
    this.documents = []
  }

  parseFiles(event) {
    this.documents = manifestResources(event.detail)
    this.client.authorize(this.documents[0])
  }

  authFileAndDisplay(event) {
    const resource = this.documents?.find(
      item => item.id === event.detail.fileUri,
    )
    if (!resource)
      throw new Error("No document found for " + event.detail.fileUri)
    this.client.authorize(resource)
  }

  login(event) {
    this.client.login(event.params.messageid)
  }

  handleResult(result) {
    switch (result.type) {
      case "authorized":
        if (result.loggedIn) this.emit("show-message-panel", {})
        this.renderViewer(result)
        break
      case "login":
        this.emit("needs-login", result)
        break
      case "denied":
        this.emit("auth-denied", { authResponse: result.authResponse })
        break
      case "error":
        console.error("Authorization failed", result.error)
        alert(
          "An authentication error occurred. You may not be able to view content at this time.",
        )
        break
    }
  }

  emit(name, detail) {
    window.dispatchEvent(new CustomEvent(name, { detail }))
  }

  renderViewer(result) {
    const { fileUri, location } = result
    this.emit("auth-success", { fileUri, location })
    const filename = fileUri.split("/").pop()
    const contentItem = document.querySelector(
      '[data-url*="' + CSS.escape(filename) + '"]',
    )
    contentItem?.parentElement.classList.add("active")
  }
}
