import { afterEach, describe, expect, it, vi } from "vitest"
import { reloadTextTracks } from "../../app/javascript/src/modules/reloadTextTracks"

describe("reloadTextTracks", () => {
  afterEach(() => {
    vi.useRealTimers()
  })

  it("leaves enough time for the internal tracks to unload", () => {
    vi.useFakeTimers()
    const player = document.createElement("hlsjs-video")
    const english = document.createElement("track")
    const russian = document.createElement("track")
    english.src = "https://example.com/english.vtt"
    russian.src = "https://example.com/russian.vtt"
    player.append(english, russian)

    reloadTextTracks(player)

    expect(english).not.toHaveAttribute("src")
    expect(russian).not.toHaveAttribute("src")

    vi.advanceTimersByTime(99)
    expect(english).not.toHaveAttribute("src")
    expect(russian).not.toHaveAttribute("src")

    vi.advanceTimersByTime(1)
    expect(english.src).toBe("https://example.com/english.vtt")
    expect(russian.src).toBe("https://example.com/russian.vtt")
  })

  it("does not change nested or source-less tracks", () => {
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

    expect(sourceLessTrack).not.toHaveAttribute("src")
    expect(nestedTrack.src).toBe("https://example.com/nested.vtt")
  })
})
