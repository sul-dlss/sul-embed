import { Controller } from "@hotwired/stimulus"
import videojs from 'video.js';
import validator from '../modules/validator.js'
import mediaTagTokenWriter from '../modules/media_tag_token_writer.js'
import buildThumbnail from '../modules/media_thumbnail_builder.js'

export default class extends Controller {
  static targets = [ "mediaTag", "list" ]

  connect() {
    this.setupThumbnails()
    this.validateMedia()
  }

  validateMedia(completeCallback) {
    const validators = this.mediaTagTargets
      .map((mediaTag) => validator(mediaTag.dataset.authUrl, mediaTagTokenWriter(mediaTag)))
    Promise.all(validators).then((values) => {
      values.forEach((result) => {
        return this.afterValidate(result, completeCallback)})
    }).catch((err) => console.error(err))
  }

  // NOTE: result.authResponse.status can be a string or an array.
  afterValidate(result, completeCallback) {
    if (result.authResponse.status === 'success') {
      this.initializeVideoJSPlayer()
      const event = new CustomEvent('auth-success')
      window.dispatchEvent(event)
    } else {
      const event = new CustomEvent('auth-denied', { detail: result.authResponse })
      window.dispatchEvent(event)
    }

    if(typeof(completeCallback) === 'function') {
      completeCallback(result.authResponse);
    }
  }

  initializeVideoJSPlayer() {
    this.players = this.mediaTagTargets.map((mediaTag) => {
      mediaTag.classList.add('video-js', 'vjs-default-skin')
      const player = videojs(mediaTag.id)
      player.on('loadedmetadata', () => {
        const event = new CustomEvent('media-loaded', { detail: player })
        window.dispatchEvent(event)
      })
      return player
    })
  }

  // Listen for events emitted by cue_controller.js to jump to a particular time
  seek(event) {
    this.players.forEach((player) => player.currentTime(event.detail))
  }

  setupThumbnails() {
    const thumbnails = [...this.element.querySelectorAll('[data-slider-object]')].
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