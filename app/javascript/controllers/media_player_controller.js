import { Controller } from "@hotwired/stimulus"
import videojs from 'video.js'

export default class extends Controller {
  initializeVideoJSPlayer() {
    this.videoElement().classList.add('video-js', 'vjs-default-skin')
    console.log(this.videoElement())
    this.player = videojs(this.videoElement().id,
                          { responsive: true,
                            preload: 'auto',
                            userActions: { hotkeys: true }
                          })
    this.player.on('loadedmetadata', (evt) => {
      // for multiple media items, we only want to load the first (visible) item
      if (evt.target.player.index == 0){
        const event = new CustomEvent('media-loaded', { detail: this.player })
        window.dispatchEvent(event)
      }
    })

    // occurs when time of the video changes.
    this.player.on('timeupdate', () => {
      const timestamp = this.player.currentTime()
      const event = new CustomEvent('time-update', { detail: timestamp })
      window.dispatchEvent(event)
    })

    this.player.index = this.element.dataset.index;

    this.player.on('loadedmetadata', (evt) => {
      // only load media for the first player
      if (evt.target.player.index == 0){
        const event = new CustomEvent('media-loaded', { detail: this.player });
        window.dispatchEvent(event);
      }
    })

    // The loadeddata event occurs when the first frame of the video is available, and
    // happens after loadedmetadata
    this.player.on('loadeddata', (evt) => {
      console.log(evt.target.player)
      console.log(evt.target.dataset.index)
      console.log(evt.target.dataset.index == '0')
      if (evt.target.dataset.index == '0'){
        const event = new CustomEvent('media-data-loaded');
        window.dispatchEvent(event);
      }
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

  videoElement() {
    return this.element.querySelector('video')
  }
}
