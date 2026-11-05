// The Video.js 10 skin lifts native captions above the control bar by styling
// video::-webkit-media-text-track-container, which Firefox doesn't support, so there the
// captions overlap the visible controls. Until Video.js renders captions itself, move the
// cues up while the controls are visible, and restore each cue's authored position when
// they hide.
// See https://github.com/videojs/video.js/issues/9303
//
// While the controls are showing, lift every bottom-anchored cue two lines from wherever
// its author put it, keeping the way it was positioned: cues can be placed by line number
// (snapToLines) or by percentage, and a line value means something different in each.
const LIFT_LINES = 2
// The browser sizes caption text at 5% of the video's height; a line is a little taller.
const LINE_HEIGHT_PERCENT = 6

// Line numbers count rows; negative ones count up from the bottom, where "auto" sits at -1.
// Percentages place the cue by its lineAlign edge, so moving that edge moves every line.
const liftedLine = ({ line, snapToLines }) =>
  snapToLines
    ? (line === "auto" ? -1 : line) - LIFT_LINES
    : Math.max(
        0,
        (line === "auto" ? 100 : line) - LIFT_LINES * LINE_HEIGHT_PERCENT,
      )

const originalPositions = new WeakMap()

export const supportsTextTrackContainerStyling = () =>
  CSS.supports("selector(video::-webkit-media-text-track-container)")

// Cues the author placed toward the top of the frame don't collide with the controls.
const isTopAnchored = ({ line, snapToLines }) =>
  typeof line === "number" && (snapToLines ? line >= 0 : line < 50)

export const positionNativeCues = (textTracks, controlsVisible) => {
  for (const track of Array.from(textTracks ?? [])) {
    if (track.kind !== "captions" && track.kind !== "subtitles") continue

    for (const cue of Array.from(track.cues ?? [])) {
      if (typeof VTTCue === "undefined" || !(cue instanceof VTTCue)) continue

      if (!originalPositions.has(cue)) {
        const { line, snapToLines } = cue
        originalPositions.set(cue, { line, snapToLines })
      }
      const original = originalPositions.get(cue)

      const line =
        controlsVisible && !isTopAnchored(original)
          ? liftedLine(original)
          : original.line
      if (cue.line !== line) cue.line = line
    }
  }
}

// skin: the <video-skin> element, whose shadow root holds the media-container that carries
// data-controls-visible. mediaElement: the <hlsjs-video> whose text tracks get the cues.
export const shiftCaptionsWithControls = (skin, mediaElement, { signal }) => {
  if (!skin || !mediaElement || supportsTextTrackContainerStyling()) return

  const update = () =>
    positionNativeCues(
      mediaElement.textTracks,
      Boolean(
        skin.shadowRoot?.querySelector(
          "media-container[data-controls-visible]",
        ),
      ),
    )

  customElements.whenDefined(skin.localName).then(() => {
    if (signal.aborted || !skin.shadowRoot) return

    const observer = new MutationObserver(update)
    observer.observe(skin.shadowRoot, {
      attributes: true,
      attributeFilter: ["data-controls-visible"],
      subtree: true,
    })
    signal.addEventListener("abort", () => observer.disconnect())
    update()
  })

  // Cues load asynchronously, and the player replaces its tracks when the source changes,
  // so position cues as tracks arrive and whenever the cues on screen change.
  const textTracks = mediaElement.textTracks
  if (!textTracks) return

  const watchTrack = track =>
    track.addEventListener("cuechange", update, { signal })
  Array.from(textTracks).forEach(watchTrack)
  textTracks.addEventListener(
    "addtrack",
    event => {
      watchTrack(event.track)
      update()
    },
    { signal },
  )
  textTracks.addEventListener("change", update, { signal })
}
