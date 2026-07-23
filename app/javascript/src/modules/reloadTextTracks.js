// Reload text tracks after changing the media source. The Video.js 10 custom
// media element clones these elements into its internal <video>. Changing the
// source can leave a default (showing) track loaded with no parsed cues, so
// update the public track elements to make the internal tracks load again.
export const reloadTextTracks = mediaElement => {
  const tracks = Array.from(
    mediaElement.querySelectorAll(":scope > track[src]"),
  )
  const sources = tracks.map(track => track.getAttribute("src"))

  tracks.forEach(track => track.removeAttribute("src"))

  // The browser needs a task boundary to unload the internal tracks before
  // their URLs are restored. Shorter microtask and zero-delay boundaries leave
  // the default track in a loaded state with no parsed cues.
  setTimeout(() => {
    tracks.forEach((track, index) => track.setAttribute("src", sources[index]))
  }, 100)
}
