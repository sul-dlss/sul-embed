// Reload text tracks after changing the media source. The Video.js 10 custom media element
// clones these elements into its internal <video>, and changing the source leaves the
// default (showing) track loaded with an empty cue list.
//
// Blanking and restoring the src attribute cannot fix that: changing src empties the cue
// list, and restoring the *same* URL doesn't re-parse it, because the browser skips a load
// whose URL matches the one the track already loaded. The track is then stuck reporting
// LOADED with no cues. Replacing the elements instead makes the player drop its copies and
// clone new ones, and a brand new track element loads its URL from scratch.
export const reloadTextTracks = mediaElement => {
  const tracks = Array.from(
    mediaElement.querySelectorAll(":scope > track[src]"),
  )
  if (tracks.length === 0) return

  tracks.forEach(track => track.remove())

  // The player mirrors our track elements on slotchange, so it needs a task boundary to
  // drop the old copies before the replacements arrive. Shorter microtask and zero-delay
  // boundaries leave the default track in a loaded state with no parsed cues.
  setTimeout(() => {
    tracks.forEach(track => mediaElement.append(track))
  }, 100)
}
