import { Controller } from "@hotwired/stimulus"
import videojs from 'video.js'

export default class extends Controller {
  static values = {
    uri: String
  }

  // Every media player receives every auth-success event
  initializeVideoJSPlayer(evt) {
    console.debug("evt.detail.fileUri: ", evt.detail.fileUri, " this.uriValue:", this.uriValue)
    // We only take action if this event is for this element
    // We need to strip out the url parameters because purl always builds version urls
    // i.e. /v2/file/bc123df4567/version/1/abc_123.mp4
    // sul-embed isn't aware of file version paths unless the user provides it
    // i.e. /file/bc123df4567/abc_123.mp4 (this still gets the latest version)
    if (this.fileName(evt.detail.fileUri) != this.fileName(this.uriValue))
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

  // we use regex to allow for nested filepaths (i.e. /file/movie1, /file2/movie1)
  fileName(filepath){
    const regex = /\/(v2\/)?file\/\w{11,16}\/(version\/\d+\/)?(.*)/gm;
    return regex.exec(filepath)[3]
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

  writeToken({fileUri, location}) {
    console.log("Looking for ", `source[src="${fileUri}"]`)

    // The current event may be for a different video on the page, so see if it's ours
    const source = this.videoElement().querySelector(`source[src="${decodeURIComponent(fileUri)}"]`)
    console.log("Found", source)
    source?.setAttribute('src', location)
  }

  // We don't use a stimulus target here, because videoJS makes a duplicate node, so the target attribute would be duplicated
  videoElement() {
    return this.element.querySelector('video')
  }
}
