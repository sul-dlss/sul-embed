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
    })

    // The loadeddata event occurs when the first frame of the video is available, and 
    // happens after loadedmetadata
    this.player.on('loadeddata', () => {
      //At this point, we should have some track information, even if the cues have not been loaded
      if(this.hasCaptionTracks()) {
        const cuesAvailable = this.hasCaptionTrackCues(this.firstCaptionTrack())
        if(cuesAvailable) {
          // Trigger the media-data-loaded event which will then lead to the transcript load method
          this.dispatchMediaDataEvent()
        } else {
          this.retryCaptionTracks()
       }
      }
    })
  }

  // Listen for events emitted by cue_controller.js to jump to a particular time
  seek(event) {
    const playerObject = this.player || videojs(this.element.id)
    if (playerObject) {
      playerObject.currentTime(event.detail)
    }
  }

  // Trigger the media-data-loaded event which helps execute the transcript load method
  dispatchMediaDataEvent() {
    const event = new CustomEvent('media-data-loaded')
    window.dispatchEvent(event)
  }

  // Call check for caption tracks at specific intervals
  // We are including this option in case the cues have still not been added for the tracks
  // at the "loadeddata" event.  A better solution would rely on an event associated with 
  // the tracks being loaded. 
  retryCaptionTracks() {
    const _this = this
    // If the cues are not available, try iterating every half second a maximum of four times
    let intervalTries = 0;
    const intervalId = window.setInterval(() => {
      intervalTries += 1
      if(_this.hasCaptionTrackCues(_this.firstCaptionTrack())) {
        _this.dispatchMediaDataEvent()
        // If track cues are now available, stop iterating
        window.clearInterval(intervalId)
      }
      else if(intervalTries > 4) {
        // After reaching a certain number of attempts, stop iterating
        window.clearInterval(intervalId)
        console.error("Maximum number of attempts reached to retrieve cues for caption tracks")
      }
    }, 500)
  }

  // Check if the player has any caption tracks available
  hasCaptionTracks() {
    const tracks = this.player.textTracks_?.tracks_
    if (!tracks) 
      return false
    
    return (tracks.filter(track => track.kind === 'captions').length > 0)
  }

  // We need to check if a particular track has any cues available
  hasCaptionTrackCues(track) {
    const cues = track.cues
    return (cues && cues.length > 0)
  }

  firstCaptionTrack() {
    return this.player.textTracks_.tracks_.filter(track => track.kind === 'captions')[0]
  }
}
