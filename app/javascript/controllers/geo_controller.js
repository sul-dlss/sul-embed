import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  connect() {
    console.log("GEO JS connected")
  }

  show(evt) {
    this.element.innerHTML = `
       <div class="authLinkWrapper">
          <p class="loginMessage">Login Message</p>
        </div>>
    `
  }
}
