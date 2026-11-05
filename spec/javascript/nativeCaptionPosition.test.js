import { afterEach, beforeEach, describe, expect, it, vi } from "vitest"
import {
  positionNativeCues,
  shiftCaptionsWithControls,
} from "../../app/javascript/src/modules/nativeCaptionPosition"

class FakeVTTCue {
  constructor({ line = "auto", snapToLines = true, lineAlign = "start" } = {}) {
    Object.assign(this, { line, snapToLines, lineAlign })
  }
}

const track = (kind, cues) => {
  const t = new EventTarget()
  t.kind = kind
  t.cues = cues
  return t
}

describe("positionNativeCues", () => {
  beforeEach(() => vi.stubGlobal("VTTCue", FakeVTTCue))
  afterEach(() => vi.unstubAllGlobals())

  it("lifts bottom cues two lines while the controls are visible and restores them after", () => {
    const automatic = new FakeVTTCue()
    const percent = new FakeVTTCue({ line: 90, snapToLines: false })
    const lineNumber = new FakeVTTCue({ line: -1 })
    const tracks = [track("captions", [automatic, percent, lineNumber])]

    positionNativeCues(tracks, true)
    expect(automatic).toMatchObject({ line: -3, snapToLines: true })
    expect(percent).toMatchObject({ line: 78, snapToLines: false })
    expect(lineNumber).toMatchObject({ line: -3, snapToLines: true })

    positionNativeCues(tracks, true)
    positionNativeCues(tracks, false)
    expect(automatic).toMatchObject({ line: "auto", snapToLines: true })
    expect(percent).toMatchObject({ line: 90, snapToLines: false })
    expect(lineNumber).toMatchObject({ line: -1, snapToLines: true })
  })

  it("leaves cues placed near the top alone", () => {
    const topLine = new FakeVTTCue({ line: 0 })
    const topPercent = new FakeVTTCue({ line: 10, snapToLines: false })
    positionNativeCues([track("captions", [topLine, topPercent])], true)
    expect(topLine).toMatchObject({ line: 0, snapToLines: true })
    expect(topPercent).toMatchObject({ line: 10, snapToLines: false })
  })

  it("leaves non-caption tracks alone", () => {
    const cue = new FakeVTTCue()
    positionNativeCues([track("metadata", [cue])], true)
    expect(cue.line).toBe("auto")
  })

  it("tolerates tracks whose cues haven't loaded", () => {
    expect(() =>
      positionNativeCues([track("captions", null)], true),
    ).not.toThrow()
  })
})

describe("shiftCaptionsWithControls", () => {
  beforeEach(() => vi.stubGlobal("VTTCue", FakeVTTCue))
  afterEach(() => vi.unstubAllGlobals())

  const setup = () => {
    customElements.get("test-skin") ||
      customElements.define(
        "test-skin",
        class extends HTMLElement {
          constructor() {
            super()
            this.attachShadow({ mode: "open" }).innerHTML =
              "<media-container></media-container>"
          }
        },
      )
    const skin = document.createElement("test-skin")
    const container = skin.shadowRoot.querySelector("media-container")
    const cue = new FakeVTTCue()
    const textTracks = Object.assign(new EventTarget(), {
      0: track("captions", [cue]),
      length: 1,
    })
    return { skin, container, cue, mediaElement: { textTracks } }
  }

  it("does nothing when the browser can style the text track container", () => {
    vi.stubGlobal("CSS", { supports: () => true })
    const { skin, container, cue, mediaElement } = setup()
    container.setAttribute("data-controls-visible", "")

    shiftCaptionsWithControls(skin, mediaElement, {
      signal: new AbortController().signal,
    })
    mediaElement.textTracks[0].dispatchEvent(new Event("cuechange"))

    expect(cue.line).toBe("auto")
  })

  it("follows the skin's controls visibility", async () => {
    vi.stubGlobal("CSS", { supports: () => false })
    const { skin, container, cue, mediaElement } = setup()

    shiftCaptionsWithControls(skin, mediaElement, {
      signal: new AbortController().signal,
    })
    await customElements.whenDefined("test-skin")

    container.setAttribute("data-controls-visible", "")
    await vi.waitFor(() => expect(cue.line).toBe(-3))

    container.removeAttribute("data-controls-visible")
    await vi.waitFor(() => expect(cue.line).toBe("auto"))
  })
})
