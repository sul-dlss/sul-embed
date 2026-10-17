import { afterEach, describe, expect, it, vi } from "vitest"
import { reloadTextTracks } from "../../app/javascript/src/modules/reloadTextTracks"

describe("reloadTextTracks", () => {
  afterEach(() => {
    vi.useRealTimers()
  })

  it("replaces the track elements so the player clones new ones", () => {
    vi.useFakeTimers()
    const player = document.createElement("hlsjs-video")
    const english = document.createElement("track")
    const russian = document.createElement("track")
    english.src = "https://example.com/english.vtt"
    russian.src = "https://example.com/russian.vtt"
    player.append(english, russian)

    reloadTextTracks(player)

    expect(player.querySelectorAll("track")).toHaveLength(0)

    vi.advanceTimersByTime(99)
    expect(player.querySelectorAll("track")).toHaveLength(0)

    vi.advanceTimersByTime(1)
    expect(Array.from(player.querySelectorAll("track"))).toEqual([
      english,
      russian,
    ])
  })

  it("keeps each track's source", () => {
    vi.useFakeTimers()
    const player = document.createElement("hlsjs-video")
    const english = document.createElement("track")
    english.src = "https://example.com/english.vtt"
    player.append(english)

    reloadTextTracks(player)
    vi.runAllTimers()

    expect(english.src).toBe("https://example.com/english.vtt")
  })

  it("does not touch nested or source-less tracks", () => {
    vi.useFakeTimers()
    const player = document.createElement("hlsjs-video")
    const sourceLessTrack = document.createElement("track")
    const wrapper = document.createElement("div")
    const nestedTrack = document.createElement("track")
    nestedTrack.src = "https://example.com/nested.vtt"
    wrapper.append(nestedTrack)
    player.append(sourceLessTrack, wrapper)

    reloadTextTracks(player)
    vi.runAllTimers()

    expect(sourceLessTrack.parentNode).toBe(player)
    expect(nestedTrack.parentNode).toBe(wrapper)
  })
})
