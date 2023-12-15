import { Controller } from "@hotwired/stimulus"
import validator from 'src/modules/validator'
import mediaTagTokenWriter from 'src/modules/media_tag_token_writer'
import buildThumbnail from 'src/modules/media_thumbnail_builder'

export default class extends Controller {
  static targets = [ "authorizeableResource", "mediaWrapper", "list" ]
  static values = {
    iiifManifest: String
  }

  connect() {
    this.setupThumbnails()
    this.validateMedia()
  }

  validateMedia(completeCallback) {
    const validators = this.authorizeableResourceTargets
      .map((mediaTag) => validator(mediaTag.dataset.authUrl, mediaTagTokenWriter(mediaTag)))
    Promise.all(validators).then((values) => {
      values.forEach((result) => {
        return this.afterValidate(result, completeCallback)})
    }).catch((err) => console.error(err))
  }

  // NOTE: result.authResponse.status can be a string or an array.
  afterValidate(result, completeCallback) {
    if (result.authResponse.status === 'success') {
      if (result.authResponse.access_restrictions.stanford_restricted === true)
        window.dispatchEvent(new CustomEvent('auth-stanford-restricted'))
      window.dispatchEvent(new CustomEvent('auth-success'))
    } else {
      const event = new CustomEvent('auth-denied', { detail: result.authResponse })
      window.dispatchEvent(event)
    }

    if(typeof(completeCallback) === 'function') {
      completeCallback(result.authResponse);
    }
  }

  setupThumbnails() {
    const thumbnails = this.mediaWrapperTargets.
      map((mediaDiv, index) => buildThumbnail(mediaDiv.dataset, index))
    this.listTarget.innerHTML = thumbnails.join('')
  }

  // Open the login window in a new window and then poll to see if the auth credentials are now active.
  logIn(event) {
    const windowReference = window.open(event.params.loginService);
    this.loginStart = Date.now();
    var checkWindow = setInterval(() => {
      if ((Date.now() - this.loginStart) < 30000 &&
        (!windowReference || !windowReference.closed)) return;
      this.validateMedia((authResponse) => {
        if(authResponse.status === 'success') {
          clearInterval(checkWindow);
        }
      });
      return;
    }, 500)
  }
}
