import { Controller } from "@hotwired/stimulus"
import { captionCredentials, fetchCues } from "src/modules/captions"

// This depends on the media player controller emitting a custom media-loaded event.
//
// The transcript reads the caption files the server listed on the media element and fetches
// them itself. It deliberately does not read the player's text tracks: the player enables at
// most one caption track at a time and a disabled track exposes no cues, so the tracks can
// only describe the language currently on screen.
export default class extends Controller {
  static targets = ["outlet", "autoscroll", "button", "captionLanguageSelect"]

  initialize() {
    this.captions = []
    this.transcripts = {}
  }

  // When the media-loaded event occurs, store the handle to the player
  persistPlayer(evt) {
    this.setPlayer(evt.detail)
  }

  // Point the transcript at a media element. Transcripts are cached per media element, so
  // pointing at a different one starts over.
  setPlayer(player) {
    if (this.player === player) return

    this.player = player
    this.captions = JSON.parse(player?.dataset.captions || "[]")
    this.transcripts = {}
    this.renderedTranscript = null
    this.renderedLanguage = null
  }

  // This function is triggered by the 'media-data-loaded' event, which is triggered by the
  // 'loadeddata' event. We wait for it rather than acting on connect because restricted
  // media only gets that far once the viewer is authorized to read its caption files.
  load(evt) {
    // Prefer the player carried on the event so we don't depend on the media-loaded
    // (persistPlayer) event having fired first.
    if (evt?.detail) this.setPlayer(evt.detail)

    // Return if this method has already been called or the item has no captions.
    if (!this.player || this.player.loaded || this.captions.length === 0) return

    this.player.loaded = true
    this.revealButton()
    this.setupTranscriptLanguageSwitching()
    return this.renderCues()
  }

  // event called when switch-transcript event is fired.
  // This really only happens when there are more than one media item with captions.
  switchTranscript(evt) {
    this.setPlayer(evt.detail)
    this.setupTranscriptLanguageSwitching()
    return this.renderCues()
  }

  selectLanguage(evt) {
    this.selectedLanguage = evt.target.value
    return this.renderCues()
  }

  // The language to display: the one the user picked when this media has captions for it,
  // otherwise the first one.
  // We need to check if there are captions for multiple videos with mixed languages.
  // for example if video 1 has english and russian captions and video 2 has spanish and english captions
  // if we switched to russian, this.selectedLanguage = 'ru', but if we then switch to video 2
  // it won't have any captions in russian.
  // https://github.com/sul-dlss/sul-embed/issues/2293
  get transcriptLanguage() {
    const languages = this.captions.map(caption => caption.language)
    if (languages.includes(this.selectedLanguage)) return this.selectedLanguage

    return languages[0]
  }

  async renderCues() {
    const language = this.transcriptLanguage
    const transcript = await this.transcriptFor(language)

    // Leave whatever is on screen alone if we couldn't read the file, rather than replacing
    // a readable transcript with nothing. Selecting the language again retries the fetch.
    if (!transcript) return

    this.renderedLanguage = language
    this.renderedTranscript = transcript
    this.outletTarget.innerHTML = transcript.asHtml
  }

  // Cached per language, and the cache holds the promise so that switching back and forth
  // doesn't refetch. A failed fetch is dropped from the cache so it can be retried.
  transcriptFor(language) {
    if (!(language in this.transcripts)) {
      this.transcripts[language] = this.buildTranscript(language).catch(
        error => {
          delete this.transcripts[language]
          console.error(error)
          return null
        },
      )
    }

    return this.transcripts[language]
  }

  async buildTranscript(language) {
    const caption = this.captions.find(file => file.language === language)
    if (!caption) return null

    const cues = await fetchCues(caption.url, captionCredentials(this.player))
    const cueStartTimes = cues.map(cue => cue.startTime)

    return {
      cues,
      cueStartTimes,
      // minStartTime and lastCueEndTime represent the starting and end point of all cues
      minStartTime: cues.length === 0 ? 0 : Math.min(...cueStartTimes),
      lastCueEndTime:
        cues.length === 0 ? 0 : Math.max(...cues.map(cue => cue.endTime)),
      asHtml: cues.map(cue => this.buildCue(cue)).join(""),
    }
  }

  setupTranscriptLanguageSwitching() {
    const language = this.transcriptLanguage

    this.captionLanguageSelectTarget.replaceChildren(
      ...this.captions.map(caption => {
        const option = new Option(caption.label, caption.language)
        option.selected = caption.language === language
        return option
      }),
    )
  }

  buildCue(cue) {
    const htmlClass = cue.text.startsWith("<v ") ? "cue-new-speaker cue" : "cue"
    const text = cue.text.replace(/<[^>]*>/g, "")
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
    const transcript = this.renderedTranscript

    // For transcript cue highlighting to take effect, the companion window should be showing
    // the transcript and there must be cues present within the transcript.
    if (!transcript || transcript.cues.length === 0) return

    // minStartTime and lastCueEndTime represent the starting and end point of all cues
    if (
      evt.detail >= transcript.minStartTime &&
      evt.detail <= transcript.lastCueEndTime
    ) {
      // Retrieve the last cue start time less than or equal to the current video time
      const startTime = Math.max.apply(
        Math,
        transcript.cueStartTimes.filter(x => x <= evt.detail),
      )
      // Find the cue element in the transcript that corresponds to this start time
      const cueElement = this.outletTarget.querySelector(
        `[data-cue-start-value="${startTime}"]`,
      )
      if (cueElement) {
        // Remove highlighting from all the other cue elements
        this.removeAllCueHighlights()
        // Apply CSS highlighting to the cue for this video time
        cueElement.classList.add("highlight")

        // Scroll the transcript window to the cue for this video
        // These options have the element scroll to the nearest visible container position without scrolling
        // the page itself further up or down
        if (this.autoscrollTarget.checked)
          cueElement.scrollIntoView({
            behavior: "smooth",
            block: "nearest",
            inline: "nearest",
          })
      }
    } else if (evt.detail > transcript.lastCueEndTime) {
      //After we reach the end time of the last transcript, remove all the highlighting
      this.removeAllCueHighlights()
    }
  }

  removeAllCueHighlights() {
    this.outletTarget.querySelectorAll("span.cue").forEach(elem => {
      elem.classList.remove("highlight")
    })
  }
}
