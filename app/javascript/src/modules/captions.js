// Fetching and parsing caption files for the transcript panel.
//
// The transcript deliberately does not read the player's text tracks. The player enables at
// most one caption track at a time and disabled tracks expose no cues, so the tracks can
// only ever tell us about the language currently on screen — and the source swap the player
// needs while loading empties the cues of whichever track was already loaded. Fetching the
// files ourselves gives the transcript every language, independent of the player.

const TIMING =
  /^((?:\d+:)?\d{1,2}:\d{2}[.,]\d{1,3})\s+-->\s+((?:\d+:)?\d{1,2}:\d{2}[.,]\d{1,3})/

// Blocks that carry no cues. STYLE and REGION are only legal in the header, but skipping
// them anywhere is simpler and harmless.
const NOT_A_CUE = /^(WEBVTT|NOTE|STYLE|REGION)\b/

// "00:01:02.500" and "01:02.500" both mean 62.5 seconds. Some files in the wild use a comma
// as the decimal separator, so accept that too.
export const parseTimestamp = timestamp =>
  timestamp
    .replace(",", ".")
    .split(":")
    .reduce((seconds, part) => seconds * 60 + Number(part), 0)

// Parse WebVTT into plain objects shaped like the VTTCue properties the transcript uses.
// Cue text keeps its markup: the transcript strips tags itself, and uses a leading voice
// span to mark a change of speaker.
export const parseWebVtt = source =>
  source
    .replace(/^\uFEFF/, "")
    .replace(/\r\n?/g, "\n")
    .split(/\n{2,}/)
    .map(block => block.split("\n").filter(line => line.trim() !== ""))
    .filter(lines => lines.length > 0 && !NOT_A_CUE.test(lines[0]))
    .map(lines => {
      // A cue may open with an identifier line before its timings.
      const timingIndex = TIMING.test(lines[0]) ? 0 : 1
      const timing = lines[timingIndex]?.match(TIMING)
      if (!timing) return null

      return {
        id: timingIndex === 1 ? lines[0] : "",
        startTime: parseTimestamp(timing[1]),
        endTime: parseTimestamp(timing[2]),
        text: lines.slice(timingIndex + 1).join("\n"),
      }
    })
    .filter(Boolean)

// Caption files can be restricted, so send credentials wherever the <track> elements do.
// The media element carries the same crossorigin setting the player uses for them.
export const captionCredentials = mediaElement =>
  mediaElement?.getAttribute("crossorigin") === "use-credentials"
    ? "include"
    : "same-origin"

// Throws if the file can't be read, so the caller can leave the language uncached and retry.
export const fetchCues = async (url, credentials) => {
  const response = await fetch(url, { credentials })
  if (!response.ok)
    throw new Error(`Could not fetch captions at ${url}: ${response.status}`)

  return parseWebVtt(await response.text())
}
