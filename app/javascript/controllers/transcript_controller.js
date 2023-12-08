import { Controller } from "@hotwired/stimulus"
import videojs from 'video.js';

// This is tightly coupled to VideoJS's tracks implementation, because VideoJS removes the tracks from the
// native player when it initializes.  This depends on the media_tag_controller.js emitting a custom media-loaded
// event.
export default class extends Controller {
  static targets = [ "outlet", "autoscroll", "button", "captionLanguageSelect" ]

  // When the media-loaded event occurs, store the handle to the player
  persistPlayer(evt) {
    this.player = evt.detail
  }

  // We can't load right away, because the VTT tracks may not have been parsed yet. So we wait until this panel is revealed.
  load() {
    if (this.loaded)
      return
    this.revealButton()
    this.setupTranscriptLanguageSwitching()
    this.renderCues()
    this.loaded = true
  }

  get captionTracks() {
    const tracks = this.player.textTracks_?.tracks_
    if (!tracks) return []

    return tracks.filter(track => track.kind === 'captions')
  }

  get cuesByLanguage() {
    const cues = {}
    if (this.captionTracks.length == 0) return cues

    this.captionTracks.forEach(track => {
      const list = track.cues.cues_
      const cueStartTimes = list.length === 0 ? undefined : list.map((cue) => cue.startTime)

      cues[track.language] = {
        list,
        cueStartTimes,
        minStartTime: list.length === 0 ? 0 : Math.min.apply(Math, cueStartTimes),
        lastCueEndTime: list.length === 0 ? 0 : Math.max.apply(Math, list.map((cue) => cue.endTime)),
        asHtml: list.map((cue) => this.buildCue(cue)).join('')
      }
    })

    return cues
  }

  currentCues() {
    return this.selectedLanguage ?
      this.cuesByLanguage[this.selectedLanguage] :
      Object.values(this.cuesByLanguage)[0]
  }

  renderCues() {
    this.outletTarget.innerHTML = this.currentCues().asHtml
  }

  selectLanguage(evt) {
    this.selectedLanguage = evt.target.value
    this.renderCues()
  }

  setupTranscriptLanguageSwitching() {
    if (this.captionTracks.length == 0) return

    this.captionTracks.forEach(track => {
      this.captionLanguageSelectTarget.insertAdjacentHTML(
        'beforeend',
        `<option value="${track.language}">${track.label}</option>`
      )
    })
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

  highlightCue(evt) {
    const cues = this.currentCues()

    // For transcript cue highlighting to take effect, the companion window should be showing the transcript
    // and there must be cues present within the transcript.
    if (!this.loaded || (cues.list.length === 0))
      return

    // this.minStartTime and this.lastCueEndTime represent the starting and end point of all cues
    if (evt.detail >= cues.minStartTime && evt.detail <= cues.lastCueEndTime) {
      // Retrieve the last cue start time less than or equal to the current video time
      const startTime = Math.max.apply(Math, cues.cueStartTimes.filter(x => x <= evt.detail))
      // Find the cue element in the transcript that corresponds to this start time
      const cueElement = this.outletTarget.querySelector(`[data-cue-start-value="${startTime}"]`)
      // Remove highlighting from all the other cue elements
      this.removeAllCueHighlights()
      // Apply CSS highlighting to the cue for this video time
      cueElement.classList.add('highlight')

      // Scroll the transcript window to the cue for this video
      // These options have the element scroll to the nearest visible container position without scrolling
      // the page itself further up or down
      if (this.autoscrollTarget.checked)
        cueElement.scrollIntoView({behavior: 'smooth', block: 'nearest', inline: 'nearest'})
    }
    else if (evt.detail > cues.lastCueEndTime) {
      //After we reach the end time of the last transcript, remove all the highlighting
      this.removeAllCueHighlights()
    }
  }

  removeAllCueHighlights() {
    this.outletTarget.querySelectorAll('span.cue').forEach(elem => {
      elem.classList.remove('highlight')
    })
  }
}
