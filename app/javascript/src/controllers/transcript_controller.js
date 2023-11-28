import { Controller } from "@hotwired/stimulus"
import videojs from 'video.js';

// This is tightly coupled to VideoJS's tracks implementation, because VideoJS removes the tracks from the
// native player when it initializes.  This depends on the media_tag_controller.js emitting a custom media-loaded
// event.  The load method on this class is called when that happens, and draws the transcript.
export default class extends Controller {
  static targets = [ ]

  load(evt) {
    const tracks = evt.detail.textTracks_.tracks_
    if (!tracks)
      return
    const track = tracks.find((track) => track.kind === 'captions' )
    const cues = track.cues.cues_.map((cue) => `<p class="cue" data-controller="cue" data-action="click->cue#jump" data-cue-id="${cue.id}" data-cue-start-value="${cue.startTime}" data-cue-end-value="${cue.endTime}">${cue.text}</p>`)
    this.element.innerHTML = cues.join('')
  }
}
