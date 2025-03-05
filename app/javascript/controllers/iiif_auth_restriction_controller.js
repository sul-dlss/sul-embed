import { Controller } from "@hotwired/stimulus"

// Display auth controls for the file_auth_controller.js
export default class extends Controller {
  static targets = ["locationRestriction", "locationRestrictionMessage", "messagePanel", "loginPanel",
                    "loginButton", "loginMessage"]

  // Bound to auth-denied CustomEvents
  displayMessage(event) {
    // If they switched to a thumbnail with location restriction access, clear out login or logged in messages
    this.resetMessages()

    const detail = event.detail
    this.locationRestrictionTarget.hidden = false
    this.locationRestrictionMessageTarget.innerHTML = this.#retrieveAuthResponseMessage(detail.authResponse)
  }

  resetMessages() {
    this.hideLoginPrompt()
    this.hideMessagePanel()
    this.clearLocationRestriction()
  }


  // Called when switching to a new file
  clearLocationRestriction() {
    this.locationRestrictionTarget.hidden = true
  }

  // Allow the user to dismiss the message
  hideMessagePanel() {
    this.messagePanelTarget.hidden = true
  }

  // When login done
  showMessagePanel() {
    this.messagePanelTarget.hidden = false
  }

  // Make the prompt go away after pressing the button
  hideLoginPrompt() {
    this.loginPanelTarget.hidden = true
  }

  // Bound to needs-login CustomEvents
  displayLoginPrompt(event) {
    const {activeAccessService, messageId} = event.detail

    this.messagePanelTarget.hidden = true
    this.loginPanelTarget.hidden = false
    this.loginButtonTarget.innerHTML = activeAccessService.confirmLabel.en[0]
    this.loginButtonTarget.setAttribute('data-file-auth-messageId-param', messageId)
    this.loginButtonTarget.setAttribute('data-file-auth-url-param', activeAccessService.id)
    this.loginMessageTarget.innerHTML = activeAccessService.label.en[0]
  }

  #retrieveAuthResponseMessage(json) {
    return json.heading.en[0]
  }
}
