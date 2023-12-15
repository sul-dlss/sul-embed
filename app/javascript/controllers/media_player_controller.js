import { Controller } from "@hotwired/stimulus"
import videojs from 'video.js';

export default class extends Controller {
  initializeVideoJSPlayer() {
    this.element.classList.add('video-js', 'vjs-default-skin')
    this.player = videojs(this.element.id)
    this.player.on('loadedmetadata', () => {
      const event = new CustomEvent('media-loaded', { detail: this.player })
      window.dispatchEvent(event)

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
     
      // When at least one of the tracks has been loaded, trigger transcript loading
      // Before the tracks are loaded, the cues will not be recognized and the transcript will
      // not load properly
      this.player.textTracks().on('addtrack', () => {
        // Retrieve the track objects.  Unfortunately, the "textTracks()" method did not cooperate
        const tracks = this.player.textTracks_?.tracks_
        // If there is at least one track we can attach the "loadeddata" event to
        if(tracks && tracks.length > 0) {
          this.player.textTracks_.tracks_[0].on('loadeddata', () => {
            // Trigger this event, which will then lead to the transcript player load method
            const event = new CustomEvent('media-data-loaded', { detail: this.player })
            window.dispatchEvent(event)
          })
        }
      })
    })
  }

  // Listen for events emitted by cue_controller.js to jump to a particular time
  seek(event) {
    this.player.currentTime(event.detail)
  }
}
