import { Controller } from "@hotwired/stimulus"
import videojs from 'video.js';

// This is tightly coupled to VideoJS's tracks implementation, because VideoJS removes the tracks from the
// native player when it initializes.  This depends on the media_tag_controller.js emitting a custom media-loaded
// event.
export default class extends Controller {
  static targets = [ "outlet", "autoscroll", "button" ]

  // When the media-loaded event occurs, store the handle to the player
  persistPlayer(evt) {
    this.player = evt.detail
  }

  // We can't load right away, because the VTT tracks may not have been parsed yet. So we wait until this panel is revealed.
  load() {
    if (this.loaded)
      return
    const cues = this.textTrackCues().map((cue) => this.buildCue(cue))
    this.outletTarget.innerHTML = cues.join('')
    this.revealButton()
    this.loaded = true
    this.setupTranscriptScroll()
  }

  textTrackCues() {
    const tracks = this.player.textTracks_.tracks_
    if (!tracks)
      return []
    const track = tracks.find((track) => track.kind === 'captions' )
    if (!track)
      return []
    return track.cues.cues_
  }

  buildCue(cue) {
    const htmlClass = cue.text.startsWith('<v ') ? 'cue-new-speaker cue' : 'cue'
    const text = cue.text.replace(/<[^>]*>/g, '')
    // NOTE: We're explicitly not using anchors or buttons for this, even though it would make it unnecessary to have keybinding here.
    //       This is because we don't want to clutter the interactive elements view in the screen-reader with thousands of
    //       items that they need to step through.
    return `<span class="${htmlClass}" data-controller="cue" data-action="click->cue#jump keydown.enter->cue#jump"
      tabindex="0"
      data-cue-id="${cue.id}" data-cue-start-value="${cue.startTime}" data-cue-end-value="${cue.endTime}">${text}</span>`
  }

  // Reveal the button to display the transcript if there is a transcript.
  revealButton() {
    this.buttonTarget.hidden = false
  }

  setupTranscriptScroll() {
    const cues = this.textTrackCues()
    this.minStartTime = 0
    this.lastCueEndTime = 0
    if (cues.length > 0) {
      //Retrieve all the start times for the various cues for this transcript
      this.cueStartTimes = cues.map((cue) => cue.startTime)
      // Transcript scroll and highlighting should begin after the first speaking cue starts
      this.minStartTime = Math.min.apply(Math, this.cueStartTimes)
      // The transcript highlight should continue only until the last cue end time
      this.lastCueEndTime = Math.max.apply(Math, cues.map((cue) => cue.endTime))
    }
  }

  scrollPlayer(evt) {
    // For transcript scroll to take effect, the companion window should be showing the transcript
    // and the autoscroll button should be checked and there must be cues present within the transcript
    if (!this.loaded || !this.autoscrollTarget.checked || (this.textTrackCues().length == 0))
      return

    // this.minStartTime and this.lastCueEndTime represent the starting and end point of all cues
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
    this.outletTarget.querySelectorAll('span.cue').forEach(function(elem) {
      elem.classList.remove('highlight')
    })
  }

  toggleAutoscroll() {
    if(! this.autoscrollTarget.checked) {
      this.removeAllCueHighlights()
    }
  }
}
