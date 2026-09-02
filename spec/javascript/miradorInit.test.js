import { describe, it, expect, vi, beforeEach, afterEach } from "vitest"

const viewerInstance = { store: { subscribe: vi.fn() } }
const viewer = vi.fn(() => viewerInstance)
const keepRequestedCanvasThroughInitialSearch = vi.fn()

vi.mock("mirador", () => ({ default: { viewer } }))
vi.mock("mirador-image-tools", () => ({ miradorImageToolsPlugin: [] }))
vi.mock("mirador-share-plugin", () => ({
  miradorShareDialogPlugin: {},
  miradorSharePlugin: {},
}))
vi.mock("mirador-dl-plugin", () => ({
  miradorDownloadDialogPlugin: {},
  miradorDownloadPlugin: {},
}))
vi.mock("@/mirador/plugins/comparisonPlugin.jsx", () => ({ default: [] }))
vi.mock("@/mirador/plugins/analyticsPlugin.js", () => ({ default: {} }))
vi.mock("@/mirador/plugins/xywhPlugin.js", () => ({ default: [] }))
vi.mock("@/mirador/plugins/customMenuPlugin.jsx", () => ({ default: [] }))
vi.mock("@/mirador/postMessageHandler.js", () => ({
  handleViewerPostMessage: vi.fn(),
}))
vi.mock("@/mirador/initialSearchCanvas.js", () => ({
  keepRequestedCanvasThroughInitialSearch,
}))

const { default: init } = await import("@/mirador/init.js")

/** Renders the container div the way mirador_component.html.erb does. */
const renderContainer = (attributes = {}) => {
  const el = document.createElement("div")
  el.id = "sul-embed-mirador"

  // The template always emits these attributes, empty when the param is absent
  const dataset = {
    canvasId: "",
    canvasIndex: "",
    miradorUri: "https://example.edu/iiif/manifest",
    search: "",
    suggestedSearch: "",
    ...attributes,
  }

  Object.assign(el.dataset, dataset)
  document.body.appendChild(el)
}

const windowConfig = () => viewer.mock.calls[0][0].windows[0]

describe("mirador init", () => {
  beforeEach(() => {
    viewer.mockClear()
    keepRequestedCanvasThroughInitialSearch.mockClear()
  })

  afterEach(() => {
    document.body.innerHTML = ""
  })

  it("leaves switchCanvasOnSearch alone when only a search is requested", () => {
    renderContainer({ search: "cats" })
    init.init()

    expect(windowConfig()).not.toHaveProperty("switchCanvasOnSearch")
    expect(keepRequestedCanvasThroughInitialSearch).not.toHaveBeenCalled()
  })

  it("leaves switchCanvasOnSearch alone when only a canvas is requested", () => {
    renderContainer({ canvasIndex: "11" })
    init.init()

    expect(windowConfig()).not.toHaveProperty("switchCanvasOnSearch")
    expect(keepRequestedCanvasThroughInitialSearch).not.toHaveBeenCalled()
  })

  it("holds the requested canvas when canvas_index and search are combined", () => {
    renderContainer({ canvasIndex: "11", search: "Net assets" })
    init.init()

    expect(windowConfig()).toMatchObject({
      canvasIndex: 11,
      defaultSearchQuery: "Net assets",
      switchCanvasOnSearch: false,
    })
    expect(keepRequestedCanvasThroughInitialSearch).toHaveBeenCalledWith(
      viewerInstance.store,
      "main",
    )
  })

  it("holds the requested canvas when canvas_id and search are combined", () => {
    renderContainer({
      canvasId: "https://example.edu/iiif/canvas/12",
      search: "Net assets",
    })
    init.init()

    expect(windowConfig()).toMatchObject({ switchCanvasOnSearch: false })
    expect(keepRequestedCanvasThroughInitialSearch).toHaveBeenCalledWith(
      viewerInstance.store,
      "main",
    )
  })

  it("treats canvas_index=0 as a requested canvas", () => {
    renderContainer({ canvasIndex: "0", search: "cats" })
    init.init()

    expect(windowConfig()).toMatchObject({
      canvasIndex: 0,
      switchCanvasOnSearch: false,
    })
    expect(keepRequestedCanvasThroughInitialSearch).toHaveBeenCalled()
  })
})
