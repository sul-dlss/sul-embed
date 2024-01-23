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

  // We can't load right away, because the VTT tracks may not have been parsed yet. 
  // This function is triggered by the 'media-data-loaded' event which is triggered
  // by the 'loadeddata' event on the first track.  
  async load() {
    // Return if this method has already been called, there are no caption tracks
    // or no cues for the tracks.  In the case of Safari, we need to wait to check,
    // hence the async/await combination for checkCues.
    if (this.loaded || !(await this.checkCues()))  
      return
    
    this.revealButton()
    this.setupTranscriptLanguageSwitching()
    this.renderCues()
    this.loaded = true
  }

  // Safari cues require special handling.
  // We want the track cues to be available so we can properly generate the transcript sidebar language dropdown
  // if there is more than one language track.
  convertDisabledTracks() {
    const captions = this.player.remoteTextTracks()?.tracks_.filter(track => track.kind === 'captions')
    captions.forEach(track => {
      if (track.mode === 'disabled') {
        track.mode = 'hidden'
      }
    })
  }

  // This function is only called on load and allows us to check Safari in a custom way
  async checkCues() {
    if(videojs.browser.IS_ANY_SAFARI) {
      return await this.cuesPromise()
    } else {
      // Carry on as usual if the browser isn't Safari
      return this.currentCues()
    }
  }

  // To enable tracks to be readable in Safari, we must change their mode to hidden and then wait
  // before can check the cues.
  cuesPromise() {
    return new Promise((resolve, reject) => {
      // Change any disabled tracks to hidden mode to enable getting their cues
      this.convertDisabledTracks()
      // We need to wait before we check for cues, since they won't be immediately available
      setTimeout(() => {
        resolve(this.currentCues())
      }, 200)
    })
  }

  // Tracks may be of different kinds. 
  // Retrieve tracks that are of kind "caption" which also have associated cues
  get captionTracks() {
    // The documentation recommends using remoteTextTracks() instead of textTracks().
    // Also, using this method allows the change to text track mode to 'hidden'
    // to reveal the cues for text tracks in Safari, whereas directly using
    // this.player.textTracks_ was not allowing for this change to take effect. 
    const tracks = this.player.remoteTextTracks()?.tracks_
    
    if (!tracks) return []

    const captions = tracks.filter(track => track.kind === 'captions')

    // captionTracks is called multiple times and users may select and deselect
    // captions in the video player itself. For Safari, we want to continue
    // changing disabled mode to "hidden" to prevent losing cue information. 
    if(videojs.browser.IS_ANY_SAFARI) {
      this.convertDisabledTracks()
    }

    // Return caption tracks that have associated cues
    return captions.filter(track => this.trackCues(track).length)
  }

  get cuesByLanguage() {
    const cues = {}
    this.captionTracks.forEach(track => {
      // Retreive the cues for this track
      const list = this.trackCues(track)
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

  // Different browsers may provide different types of objects for TextTrackCueList.
  // For example, Safari does not recognize track.cues.cues_.
  // For Firefox/Chrome, track.cues are not iterable, but track.cues[n] will work, where n is an integer.
  // We will map the list to an array, which will allow the return values to be filterable/iterable. 
  trackCues(track) {
    let mappedCues = []
    if(track && track?.cues && track.cues?.length) {
      for(let x = 0; x < track.cues.length; x++) {
        mappedCues.push(track.cues[x])
      }
    }
    return mappedCues
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
      // Handling a case where there is a mismatch between the assumed start time and the cues we have
      // For example, a multi-lingual caption situation in Safari where the transcript loads for only the 
      // language for the selected caption.
      if (cueElement) {
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
