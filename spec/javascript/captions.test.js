import { afterEach, describe, expect, it, vi } from "vitest"
import {
  captionCredentials,
  fetchCues,
  parseTimestamp,
  parseWebVtt,
} from "../../app/javascript/src/modules/captions"

// Shaped like the caption files this app serves: a bare WEBVTT header, cue settings on the
// timing line, and a leading cue with no text.
const VTT = `WEBVTT

00:00:00.000 --> 00:00:00.600 align:middle line:90%


00:00:00.600 --> 00:00:04.470 align:middle line:84%
Таким был до войны
древнерусский город Новгород.

00:00:05.100 --> 00:00:08.370 align:middle line:84%
Он полностью сохранял
свою тысячелетнюю культуру.
`

describe("parseTimestamp", () => {
  it("reads hours, minutes and seconds", () => {
    expect(parseTimestamp("00:00:00.600")).toBe(0.6)
    expect(parseTimestamp("00:05:35.440")).toBe(335.44)
    expect(parseTimestamp("01:00:00.000")).toBe(3600)
  })

  it("reads timestamps with no hours field", () => {
    expect(parseTimestamp("01:02.500")).toBe(62.5)
  })

  it("accepts a comma as the decimal separator", () => {
    expect(parseTimestamp("00:00:04,470")).toBe(4.47)
  })
})

describe("parseWebVtt", () => {
  it("parses every cue, including one with no text", () => {
    const cues = parseWebVtt(VTT)

    expect(cues).toHaveLength(3)
    expect(cues[0]).toEqual({
      id: "",
      startTime: 0,
      endTime: 0.6,
      text: "",
    })
    expect(cues[1]).toEqual({
      id: "",
      startTime: 0.6,
      endTime: 4.47,
      text: "Таким был до войны\nдревнерусский город Новгород.",
    })
  })

  it("keeps cue identifiers", () => {
    const cues = parseWebVtt(
      "WEBVTT\n\nintro\n00:00:01.000 --> 00:00:02.000\nHello",
    )

    expect(cues).toEqual([
      { id: "intro", startTime: 1, endTime: 2, text: "Hello" },
    ])
  })

  it("skips NOTE, STYLE and REGION blocks", () => {
    const cues = parseWebVtt(`WEBVTT

NOTE this is a comment
spanning two lines

STYLE
::cue { color: peachpuff; }

REGION
id:fred

00:00:01.000 --> 00:00:02.000
Hello`)

    expect(cues).toEqual([{ id: "", startTime: 1, endTime: 2, text: "Hello" }])
  })

  it("keeps cue markup so the transcript can detect a change of speaker", () => {
    const cues = parseWebVtt(
      "WEBVTT\n\n00:00:01.000 --> 00:00:02.000\n<v Ann>Hello</v>",
    )

    expect(cues[0].text).toBe("<v Ann>Hello</v>")
  })

  it("handles CRLF line endings and a byte order mark", () => {
    const cues = parseWebVtt(
      "﻿WEBVTT\r\n\r\n00:00:01.000 --> 00:00:02.000\r\nHello\r\n",
    )

    expect(cues).toEqual([{ id: "", startTime: 1, endTime: 2, text: "Hello" }])
  })

  it("ignores blocks that have no timing line", () => {
    expect(parseWebVtt("WEBVTT\n\nnot a cue at all")).toEqual([])
    expect(parseWebVtt("")).toEqual([])
  })
})

describe("captionCredentials", () => {
  it("sends credentials when the player does", () => {
    const player = document.createElement("hlsjs-video")
    player.setAttribute("crossorigin", "use-credentials")

    expect(captionCredentials(player)).toBe("include")
  })

  it("does not send credentials otherwise", () => {
    const player = document.createElement("hlsjs-video")
    player.setAttribute("crossorigin", "")

    expect(captionCredentials(player)).toBe("same-origin")
    expect(captionCredentials(null)).toBe("same-origin")
  })
})

describe("fetchCues", () => {
  afterEach(() => {
    vi.unstubAllGlobals()
  })

  it("fetches and parses a caption file", async () => {
    const fetchMock = vi.fn().mockResolvedValue({
      ok: true,
      text: () => Promise.resolve(VTT),
    })
    vi.stubGlobal("fetch", fetchMock)

    const cues = await fetchCues("https://example.com/ru.vtt", "include")

    expect(fetchMock).toHaveBeenCalledWith("https://example.com/ru.vtt", {
      credentials: "include",
    })
    expect(cues).toHaveLength(3)
  })

  it("throws when the file cannot be read, so the caller can retry", async () => {
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({ ok: false, status: 403 }),
    )

    await expect(
      fetchCues("https://example.com/ru.vtt", "include"),
    ).rejects.toThrow("403")
  })
})
