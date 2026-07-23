import { Controller } from "@hotwired/stimulus"
import { reloadTextTracks } from "src/modules/reloadTextTracks"

export default class extends Controller {
  static values = {
    uri: String,
  }

  connect() {
    this.player = this.mediaElement()
    this.addPlayerEventListeners()
  }

  disconnect() {
    this.listenerAbort?.abort()
  }

  addPlayerEventListeners() {
    this.listenerAbort = new AbortController()
    const options = { signal: this.listenerAbort.signal }

    this.player.addEventListener(
      "loadedmetadata",
      () => {
        const event = new CustomEvent("media-loaded", { detail: this.player })
        window.dispatchEvent(event)
      },
      options,
    )

    this.player.addEventListener(
      "timeupdate",
      () => {
        const event = new CustomEvent("time-update", {
          detail: this.player.currentTime,
        })
        window.dispatchEvent(event)
      },
      options,
    )

    this.player.addEventListener(
      "loadeddata",
      () => {
        const event = new CustomEvent("media-data-loaded", {
          detail: this.player,
        })
        window.dispatchEvent(event)
      },
      options,
    )
  }

  // Every media player receives every auth-success event
  initializePlayer(evt) {
    console.debug(
      "evt.detail.fileUri: ",
      evt.detail.fileUri,
      " this.uriValue:",
      this.uriValue,
    )
    // We only take action if this event is for this element
    if (evt.detail.fileUri != this.uriValue) return

    // The probe service returns an HLS (m3u8) streaming URL, which must be played through hls.js.
    // Only when we fall back to the direct file do we use its stored mimetype. The content type
    // must be set before the src so hlsjs-video selects the right playback engine.
    const src = evt.detail.location || this.player.dataset.mediaSrc
    const contentType = evt.detail.location
      ? "application/vnd.apple.mpegurl"
      : this.player.dataset.contentType
    this.player.config = { contentType }

    // Preload the media so the transcript panel has access to its text tracks.
    this.player.preload = "auto"
    this.player.src = src
    reloadTextTracks(this.player)
  }

  // Don't show the player fullscreen button when sul-embed is in fullscreen.
  // Only used in safari (see #2567)
  fullscreenChange() {
    if (!/^((?!chrome|android).)*safari/i.test(navigator.userAgent)) return
    if (!this.player) return

    const skin = this.element.querySelector("video-skin")
    const fullscreenButton = skin?.shadowRoot?.querySelector(
      "media-fullscreen-button",
    )
    if (!fullscreenButton) return

    const playerIsFullscreen = Boolean(skin.shadowRoot.fullscreenElement)
    fullscreenButton.hidden =
      document.fullscreenElement !== null && !playerIsFullscreen
  }

  // Listen for events emitted by cue_controller.js to jump to a particular time
  seek(event) {
    if (this.player) {
      this.player.currentTime = event.detail
    }
  }

  mediaElement() {
    return this.element.querySelector("hlsjs-video")
  }
}
