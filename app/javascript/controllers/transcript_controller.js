import { Controller } from "@hotwired/stimulus"
import videojs from 'video.js';

// This is tightly coupled to VideoJS's tracks implementation, because VideoJS removes the tracks from the
// native player when it initializes.  This depends on the media_tag_controller.js emitting a custom media-loaded
// event.
export default class extends Controller {
  static targets = [ "outlet", "button" ]

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
}
