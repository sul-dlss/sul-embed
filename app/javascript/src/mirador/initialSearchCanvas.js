import {
  getSearchForWindow,
  getSearchIsFetching,
  getSortedSearchAnnotationsForCompanionWindow,
  getVisibleCanvasIds,
  selectAnnotation,
  updateWindow,
} from "mirador"

/**
 * Finds the search companion window that has started fetching results. Search
 * state is keyed by companion window id, and an entry only grows a `data` key
 * once a query has been requested for it.
 */
const startedSearchCompanionWindowId = (state, windowId) => {
  const searches = getSearchForWindow(state, { windowId }) || {}

  return Object.keys(searches).find(companionWindowId =>
    Boolean(searches[companionWindowId]?.data),
  )
}

/**
 * Mirador's `switchCanvasOnSearch` config moves the viewer to the first hit in
 * the document as soon as content search results arrive, which discards the
 * canvas an embed asked for. When an embed requests a canvas *and* a search
 * term, init.js opens the window with `switchCanvasOnSearch` off and calls
 * this, which waits for the initial search to settle and then:
 *
 *   - selects the first hit on the requested canvas, when the term occurs
 *     there, so it highlights and reads as selected just like a hit the user
 *     clicked in the search panel
 *   - hands `switchCanvasOnSearch` back, so searches the user runs afterwards
 *     navigate the way they do in a stock viewer
 *
 * Returns the store's unsubscribe function so callers can bail out early.
 */
export function keepRequestedCanvasThroughInitialSearch(store, windowId) {
  const unsubscribe = store.subscribe(() => {
    const state = store.getState()
    const companionWindowId = startedSearchCompanionWindowId(state, windowId)

    if (!companionWindowId) return
    if (getSearchIsFetching(state, { companionWindowId, windowId })) return

    // The initial search has landed (or failed). Either way we are done
    // watching, and dispatching below would otherwise re-enter this callback.
    unsubscribe()

    const visibleCanvasIds = getVisibleCanvasIds(state, { windowId })
    const hit = getSortedSearchAnnotationsForCompanionWindow(state, {
      companionWindowId,
      windowId,
    }).find(annotation => visibleCanvasIds.includes(annotation.targetId))

    if (hit) store.dispatch(selectAnnotation(windowId, hit.id))

    store.dispatch(updateWindow(windowId, { switchCanvasOnSearch: true }))
  })

  return unsubscribe
}
