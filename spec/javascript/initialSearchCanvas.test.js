import { describe, it, expect, vi } from "vitest"
import { keepRequestedCanvasThroughInitialSearch } from "@/mirador/initialSearchCanvas.js"

const MANIFEST_ID = "https://example.edu/iiif/manifest"
const SEARCH_ID = "https://example.edu/search?q=cats"
const canvasId = n => `https://example.edu/iiif/canvas/${n}`
const annotationId = n => `https://example.edu/search/annotation/${n}`

const manifestJson = {
  "@context": "http://iiif.io/api/presentation/2/context.json",
  "@id": MANIFEST_ID,
  "@type": "sc:Manifest",
  label: "A document",
  sequences: [
    {
      "@id": "https://example.edu/iiif/sequence-1",
      "@type": "sc:Sequence",
      canvases: [1, 2, 3, 4].map(n => ({
        "@id": canvasId(n),
        "@type": "sc:Canvas",
        height: 1000,
        images: [],
        label: `Page ${n}`,
        width: 800,
      })),
    },
  ],
}

// IIIF Content Search 1.0 response with hits on pages 2 and 3, deliberately
// listed out of canvas order so we can tell sorted-first from response-first.
const searchJson = {
  "@context": "http://iiif.io/api/presentation/2/context.json",
  "@id": SEARCH_ID,
  "@type": "sc:AnnotationList",
  resources: [
    { canvas: 3, id: 30 },
    { canvas: 2, id: 20 },
    { canvas: 3, id: 31 },
  ].map(({ canvas, id }) => ({
    "@id": annotationId(id),
    "@type": "oa:Annotation",
    motivation: "sc:painting",
    on: `${canvasId(canvas)}#xywh=10,10,50,20`,
    resource: { "@type": "cnt:ContentAsText", chars: "cats" },
  })),
}

const COMPANION_WINDOW_ID = "cw-search"

const buildState = ({
  canvasIndex,
  isFetching = false,
  json = searchJson,
}) => ({
  manifests: {
    [MANIFEST_ID]: { id: MANIFEST_ID, isFetching: false, json: manifestJson },
  },
  searches: {
    main: {
      [COMPANION_WINDOW_ID]: {
        data: { [SEARCH_ID]: { isFetching, json } },
        query: "cats",
      },
    },
  },
  windows: {
    main: {
      canvasId: canvasId(canvasIndex),
      id: "main",
      manifestId: MANIFEST_ID,
      switchCanvasOnSearch: false,
      visibleCanvases: [canvasId(canvasIndex)],
    },
  },
})

/** A minimal store stand-in that lets a test drive subscriber notifications. */
const fakeStore = initialState => {
  const subscribers = []

  return {
    dispatch: vi.fn(),
    getState: () => initialState,
    notify: () => subscribers.slice().forEach(fn => fn()),
    setState: next => {
      initialState = next
    },
    subscribe: fn => {
      subscribers.push(fn)
      return () => subscribers.splice(subscribers.indexOf(fn), 1)
    },
    subscribers,
  }
}

describe("keepRequestedCanvasThroughInitialSearch", () => {
  it("selects the first hit on the requested canvas and restores switchCanvasOnSearch", () => {
    const store = fakeStore(buildState({ canvasIndex: 3 }))
    keepRequestedCanvasThroughInitialSearch(store, "main")
    store.notify()

    expect(store.dispatch.mock.calls.map(([action]) => action)).toEqual([
      {
        annotationId: annotationId(30),
        type: "mirador/SELECT_ANNOTATION",
        windowId: "main",
      },
      {
        id: "main",
        payload: { switchCanvasOnSearch: true },
        type: "mirador/UPDATE_WINDOW",
      },
    ])
  })

  it("does not select a hit from another canvas, but still restores switchCanvasOnSearch", () => {
    const store = fakeStore(buildState({ canvasIndex: 1 }))
    keepRequestedCanvasThroughInitialSearch(store, "main")
    store.notify()

    expect(store.dispatch).toHaveBeenCalledTimes(1)
    expect(store.dispatch).toHaveBeenCalledWith({
      id: "main",
      payload: { switchCanvasOnSearch: true },
      type: "mirador/UPDATE_WINDOW",
    })
  })

  it("restores switchCanvasOnSearch when the search returns no hits", () => {
    const store = fakeStore(
      buildState({ canvasIndex: 3, json: { ...searchJson, resources: [] } }),
    )
    keepRequestedCanvasThroughInitialSearch(store, "main")
    store.notify()

    expect(store.dispatch).toHaveBeenCalledTimes(1)
    expect(store.dispatch).toHaveBeenCalledWith({
      id: "main",
      payload: { switchCanvasOnSearch: true },
      type: "mirador/UPDATE_WINDOW",
    })
  })

  it("waits for the search to settle before acting", () => {
    const store = fakeStore(buildState({ canvasIndex: 3, isFetching: true }))
    keepRequestedCanvasThroughInitialSearch(store, "main")
    store.notify()

    expect(store.dispatch).not.toHaveBeenCalled()

    store.setState(buildState({ canvasIndex: 3 }))
    store.notify()

    expect(store.dispatch).toHaveBeenCalled()
  })

  it("ignores state changes before the search has been requested", () => {
    const store = fakeStore({
      ...buildState({ canvasIndex: 3 }),
      searches: {},
    })
    keepRequestedCanvasThroughInitialSearch(store, "main")
    store.notify()

    expect(store.dispatch).not.toHaveBeenCalled()
  })

  it("unsubscribes once the initial search has been handled", () => {
    const store = fakeStore(buildState({ canvasIndex: 3 }))
    keepRequestedCanvasThroughInitialSearch(store, "main")
    store.notify()

    const dispatchCount = store.dispatch.mock.calls.length
    expect(store.subscribers).toHaveLength(0)

    store.notify()
    expect(store.dispatch.mock.calls).toHaveLength(dispatchCount)
  })
})
