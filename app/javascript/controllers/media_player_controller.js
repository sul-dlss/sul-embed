import { Controller } from "@hotwired/stimulus"
import videojs from 'video.js';

export default class extends Controller {
  initializeVideoJSPlayer() {
    this.element.classList.add('video-js', 'vjs-default-skin')
    this.player = videojs(this.element.id, {"responsive": true})
    this.player.index = this.element.dataset.index;

    this.player.on('loadedmetadata', (evt) => {

      // Stop the `loadedmetadata` event and don't bother listening for
      // `timeupdate` events until after `loadedmetadata` fires completes.
      // Why? If we don't, `timeupdate` will be triggered before the video
      // (and its captions) are fully present, and we use the custom
      // `time-update` event to scroll the transcript panel.
      this.player.off('loadedmetadata')
      this.player.on('timeupdate', () => {
        const timestamp = this.player.currentTime()
        const event = new CustomEvent('time-update', { detail: timestamp })
        window.dispatchEvent(event)
      })

      if (evt.target.player.index == 0){
        const event = new CustomEvent('media-loaded', { detail: this.player });
        window.dispatchEvent(event);
      }
    })

    // The loadeddata event occurs when the first frame of the video is available, and
    // happens after loadedmetadata
    this.player.on('loadeddata', (evt) => {
      if (evt.target.player.index == 0){
        const event = new CustomEvent('media-data-loaded');
        window.dispatchEvent(event);
      }
    })
  }

  // Listen for events emitted by cue_controller.js to jump to a particular time
  // "this.player" was returning undefined, so we are relying on the element id to
  // retrieve the player
  seek(event) {
    const playerObject =  videojs(this.element.id)
    if (playerObject) {
      playerObject.currentTime(event.detail)
    }
  }
}
