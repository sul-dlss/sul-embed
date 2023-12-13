import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["stanfordRestriction", "stanfordRestrictionMessage", "stanfordRestrictionNotLoggedInIcon",
                    "stanfordRestrictionLoggedInIcon", "stanfordRestrictionDismissButton", "stanfordLoginButton",
                    "locationRestriction", "embargoRestriction", "embargoAndStanfordRestriction",
                    "embargoLoginButton", "noAccess"]

  // Listener for auth-denied events
  displayMessage(event) {
    const authResponse = event.detail
    const status = authResponse.status
    if (!status) {
      this.displayNoAccess()
    } else if (status.includes('embargoed')) { // Embargo check must come before stanford_restricted, because both can occur together
      if (status.includes('stanford_restricted'))
        this.displayEmbargoAndStanfordRestriction(authResponse.embargo, authResponse.service)
      else
        this.displayEmbargoRestriction(authResponse.embargo)
    } else if (status.includes('stanford_restricted')) {
      this.displayStanfordRestriction(authResponse.service)
    } else if (status.includes('location_restricted')) {
      this.displayLocationRestriction(authResponse.location)
    }
  }

  hideLoginPrompt() {
    this.stanfordRestrictionMessageTarget.innerHTML = "Logged in."
    this.stanfordLoginButtonTarget.hidden = true
    this.stanfordRestrictionNotLoggedInIconTarget.hidden = true
    this.stanfordRestrictionLoggedInIconTarget.hidden = false
    this.embargoAndStanfordRestrictionTarget.hidden = true
    this.stanfordRestrictionDismissButtonTarget.hidden = false
  }

  hideAuthRestrictionMessages() {
    this.element.hidden = true
  }

  displayNoAccess() {
    this.element.hidden = false
    this.noAccessTarget.hidden = false
  }

  displayStanfordRestriction(loginService) {
    this.element.hidden = false
    this.stanfordLoginButtonTarget.dataset.mediaTagLoginServiceParam = loginService['@id']
    this.stanfordRestrictionTarget.hidden = false
  }

  displayLocationRestriction(restrictionLocation) {
    this.element.hidden = false
    this.locationRestrictionTarget.querySelector('.loginMessage').innerText = `Access is restricted to the ${restrictionLocation.label}. See Access conditions for more information.`
    this.locationRestrictionTarget.hidden = false
  }

  displayEmbargoRestriction(embargo) {
    this.element.hidden = false
    this.embargoRestrictionTarget.querySelector('.loginMessage').innerText = `Access is restricted until ${this.formattedEmbargo(embargo)}`
    this.embargoRestrictionTarget.hidden = false
  }

  displayEmbargoAndStanfordRestriction(embargo, loginService) {
    this.element.hidden = false
    this.embargoAndStanfordRestrictionTarget.querySelector('.loginMessage').innerText = `Access is restricted to Stanford-affiliated patrons until ${this.formattedEmbargo(embargo)}`
    this.embargoLoginButtonTarget.dataset.mediaTagLoginServiceParam = loginService['@id']
    this.embargoAndStanfordRestrictionTarget.hidden = false
  }

  formattedEmbargo(embargo) {
    const releaseDate = new Date(embargo.release_date)
    return new Intl.DateTimeFormat().format(releaseDate)
  }
}