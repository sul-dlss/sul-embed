import { Controller } from "@hotwired/stimulus"
import videojs from 'video.js'

export default class extends Controller {
  static values = {
    uri: String
  }

  // Every media player receives every auth-success event
  initializeVideoJSPlayer(evt) {
    this.updatePoster()
    console.debug("evt.detail.fileUri: ", evt.detail.fileUri, " this.uriValue:", this.uriValue)
    // We only take action if this event is for this element
    if (evt.detail.fileUri != this.uriValue)
      return

    this.writeToken(evt.detail)
    this.videoElement().classList.add('video-js', 'vjs-default-skin')
    this.player = videojs(this.videoElement().id,
                          { responsive: true,
                            preload: 'auto', // we need to preload video for the transcript panel
                            userActions: { hotkeys: true }
                          })
    this.player.on('loadedmetadata', () => {
      const event = new CustomEvent('media-loaded', { detail: this.player })
      window.dispatchEvent(event)
    })

    // occurs when time of the video changes.
    this.player.on('timeupdate', () => {
      const timestamp = this.player.currentTime()
      const event = new CustomEvent('time-update', { detail: timestamp })
      window.dispatchEvent(event)
    })

    // The loadeddata event occurs when the first frame of the video is available, and
    // happens after loadedmetadata
    this.player.on('loadeddata', () => {
      const event = new CustomEvent('media-data-loaded');
      window.dispatchEvent(event);
    })
  }

  // Don't show videojs fullscreen button when sul-embed is in fullscreen
  // Only used in safari (see #2567)
  fullscreenChange(event) {
    if (!/^((?!chrome|android).)*safari/i.test(navigator.userAgent)) return;
    if (event.srcElement.classList.contains('video-js') || !this.player) return;
    if (document.fullscreenElement !== null) {
      this.player.controlBar.fullscreenToggle.hide();
    } else {
      this.player.controlBar.fullscreenToggle.show();
    }
  }

  // Listen for events emitted by cue_controller.js to jump to a particular time
  // "this.player" was returning undefined, so we are relying on the element id to
  // retrieve the player
  seek(event) {
    const playerObject =  videojs(this.videoElement().id)
    if (playerObject) {
      playerObject.currentTime(event.detail)
    }
  }

  updatePoster() {
    if(!this.videoElement().dataset.fallbackPoster) return;

    const fallbackPoster = this.videoElement().dataset.fallbackPoster;
    delete this.videoElement().dataset.fallbackPoster;
    if (fallbackPoster.includes('locked')) return;

    this.videoElement().setAttribute('poster', fallbackPoster)
  }

  writeToken({fileUri, location}) {
    console.log("Looking for ", `source[src="${fileUri}"]`)

    // The current event may be for a different video on the page, so see if it's ours
    const source = this.videoElement().querySelector(`source[src="${fileUri}"]`)
    console.log("Found", source)
    source?.setAttribute('src', location)
  }

  // We don't use a stimulus target here, because videoJS makes a duplicate node, so the target attribute would be duplicated
  videoElement() {
    return this.element.querySelector('video')
  }
}
