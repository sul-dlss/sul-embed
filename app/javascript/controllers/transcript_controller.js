import { Controller } from "@hotwired/stimulus"
import videojs from 'video.js';

// This is tightly coupled to VideoJS's tracks implementation, because VideoJS removes the tracks from the
// native player when it initializes.  This depends on the media_tag_controller.js emitting a custom media-loaded
// event.
export default class extends Controller {
  static targets = [ "outlet", "autoscroll" ]

  // When the media-loaded event occurs, store the handle to the player
  persistPlayer(evt) {
    this.player = evt.detail
  }

  // We can't load right away, because the VTT tracks may not have been parsed yet. So we wait until this panel is revealed.
  load() {
    if (this.loaded)
      return
    const tracks = this.player.textTracks_.tracks_
    if (!tracks)
      return
    const track = tracks.find((track) => track.kind === 'captions' )
    const cues = track.cues.cues_.map((cue) => this.buildCue(cue))
    this.outletTarget.innerHTML = cues.join('')
    this.loaded = true
    //Retrieve all the start times for the various cues for this transcript
    this.cueStartTimes = track.cues.cues_.map((cue) => cue.startTime)
    // Transcript scroll and highlighting should begin after the first speaking cue starts
    this.minStartTime = Math.min.apply(Math, this.cueStartTimes)
    // The transcript highlight should continue only until the last cue end time
    this.lastCueEndTime = Math.max.apply(Math, track.cues.cues_.map((cue) => cue.endTime))
  }

  buildCue(cue) {
    const htmlClass = cue.text.startsWith('<v ') ? 'cue-new-speaker cue' : 'cue'
    const text = cue.text.replace(/<[^>]*>/g, '')
    return `<span class="${htmlClass}" data-controller="cue" data-action="click->cue#jump" data-cue-id="${cue.id}" data-cue-start-value="${cue.startTime}" data-cue-end-value="${cue.endTime}">${text}</span>`
  }

  scrollPlayer(evt) {
    if (!this.loaded || !this.autoscrollTarget.checked)
      return

    if(evt.detail >= this.minStartTime && evt.detail <= this.lastCueEndTime) {
      // Retrieve the last cue start time less than or equal to the current video time
      const startTime = this.maxStartCueTime(evt.detail)
      // Find the cue element in the transcript that corresponds to this start time
      const cueElement = this.outletTarget.querySelector(`[data-cue-start-value="${startTime}"]`)
      // Scroll the transcript window to the cue for this video
      cueElement.scrollIntoView()
      // Apply CSS highlighting to the cue for this video time
      this.highlightCue(cueElement)
    }
    else if(evt.detail > this.lastCueEndTime) {
      //After we reach the end time of the last transcript, remove all the highlighting
      this.removeAllCueHighlights()
    }
  }

  maxStartCueTime(transcriptTime) {
    return Math.max.apply(Math, this.cueStartTimes.filter(function(x){return x <= transcriptTime}))
  }

  highlightCue(cueElement) {
    // Remove highlighting from all the other cue elements
    this.removeAllCueHighlights()
    //Add highlight class to the current cue element
    cueElement.classList.add('highlight')
  }

  removeAllCueHighlights() {
    for (let elem of this.outletTarget.querySelectorAll('span.cue')) {
      elem.classList.remove('highlight')
    }
  }

  toggleAutoscroll() {
    if(! this.autoscrollTarget.checked) {
      this.removeAllCueHighlights()
    }
  }
}
