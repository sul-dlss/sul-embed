import { Controller } from "@hotwired/stimulus"
import videojs from 'video.js';

// This is tightly coupled to VideoJS's tracks implementation, because VideoJS removes the tracks from the
// native player when it initializes.  This depends on the media_tag_controller.js emitting a custom media-loaded
// event.
export default class extends Controller {
  static targets = [ "outlet" ]

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
    const cues = track.cues.cues_.map((cue) => `<p class="cue" data-controller="cue" data-action="click->cue#jump" data-cue-id="${cue.id}" data-cue-start-value="${cue.startTime}" data-cue-end-value="${cue.endTime}">${cue.text}</p>`)
    this.outletTarget.innerHTML = cues.join('')
    this.loaded = true
  }
}
