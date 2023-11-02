import { Controller } from "@hotwired/stimulus"
import videojs from 'video.js';
import validator from '../modules/validator.js'
import mediaTagTokenWriter from '../modules/media_tag_token_writer.js'
import buildThumbnail from '../modules/media_thumbnail_builder.js'

export default class extends Controller {
  static targets = [ "mediaTag", "list", "authComponent", "loginButton"]

  connect() {
    // TODO: once we get rid of the legacy media viewer, we shuld remove this from MediaTagComponent
    //       and remove this line.
    this.element.querySelectorAll('[data-access-restricted-message]').forEach((elem) => elem.hidden = true)

    this.setupThumbnails()
    this.validateMedia()
  }

  validateMedia(completeCallback) {
    const validators = this.mediaTagTargets
      .map((mediaTag) => {
        const mediaContext = { isRestricted: mediaTag.dataset.stanfordOnly === "true" || mediaTag.dataset.locationRestricted === "true" }
        return validator(mediaTag.dataset.authUrl, mediaTagTokenWriter(mediaTag), mediaContext)
      })
    Promise.all(validators).then((values) => {
      values.forEach((result) => {
        return this.afterValidate(result, completeCallback)})
    }).catch((err) => console.error(err))
  }

  // NOTE: result.authResponse.status can be a string or an array.
  afterValidate(result, completeCallback) {
    const status = result.authResponse.status
    if(status.includes('stanford_restricted')) {
      this.displayAuthLink(result.authResponse.service)
    } else if(status === 'success') {
      // If the item is restricted and the user has access, then remove the login banner.
      if (result.mediaContext.isRestricted)
        this.hideAuthLink()
      
      this.initializeVideoJSPlayer()
    }

    if(typeof(completeCallback) === 'function') {
      completeCallback(result.authResponse);
    }
  }

  initializeVideoJSPlayer() {
    this.transformAudioToVideoForSafari()
    this.mediaTagTargets.forEach((mediaTag) => {
      mediaTag.classList.add('video-js', 'vjs-default-skin')
      videojs(mediaTag.id).removeChild('textTrackSettings')
    })
  }

  // Safari 16.6 and below don't render vtt tracks for audio, so change those to be video elements.
  transformAudioToVideoForSafari() {
    if (!navigator.userAgent.match(/Safari/i))
      return
    if (![...this.mediaTagTargets].some((mediaTag) => mediaTag.nodeName === "AUDIO" && mediaTag.querySelector('track')))
      return

    this.mediaTagTargets.forEach((audioTag) => {
      if (audioTag.nodeName !== "AUDIO")
        return
      const videoTag = document.createElement('video');
      [...audioTag.attributes].forEach( attr => videoTag.setAttribute(attr.nodeName, attr.nodeValue))
      audioTag.childNodes.forEach(child => videoTag.appendChild(child))
      audioTag.parentNode.replaceChild(videoTag, audioTag);
    })

  }

  setupThumbnails() {
    const thumbnails = [...this.element.querySelectorAll('[data-slider-object]')].
      map((mediaDiv, index) => buildThumbnail(mediaDiv.dataset, index))
    this.listTarget.innerHTML = thumbnails.join('')
  }

  displayAuthLink(loginService) {
    this.loginButtonTarget.dataset.mediaTagLoginServiceParam = loginService['@id']
    this.authComponentTarget.hidden = false
  }

  hideAuthLink() {
    this.authComponentTarget.hidden = true
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