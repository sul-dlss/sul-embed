import { all, put, select, takeEvery } from "redux-saga/effects"
import {
  ActionTypes,
  getManifest,
  getManifestTitle,
  getCanvases,
  getCompanionWindow,
  getWindow,
} from "mirador"

export function deriveManifestType(json = {}) {
  const type = json.type || json["@type"] || ""

  if (/collection/i.test(type)) return "collection"
  if (/manifest/i.test(type)) return "manifest"

  return "unknown"
}

function* manifestAnalytics({ windowId, manifestId } = {}) {
  const manifest = yield select(
    getManifest,
    windowId ? { windowId } : { manifestId },
  )

  const json = manifest?.json || {}

  const manifestTitle = yield select(getManifestTitle, { windowId, manifestId })

  let canvasCount

  if (windowId) {
    const canvases = yield select(getCanvases, { windowId })
    canvasCount = canvases?.length ?? 0
  } else {
    const canvases = json.items ?? json.sequences?.[0]?.canvases ?? []

    canvasCount = canvases.length ?? 0
  }

  return {
    manifestId: manifest?.id,
    manifestTitle: manifestTitle || "",
    canvasCount,
    manifestType: deriveManifestType(json),
  }
}

function* onSetCanvas({ type, windowId, canvasId }) {
  const metadata = yield* manifestAnalytics({ windowId })

  const allCanvases = yield select(getCanvases, { windowId })
  const canvasIndex = allCanvases?.findIndex(c => c.id === canvasId)

  yield put({
    type: "mirador/analytics",
    payload: {
      // legacy/compatibility
      eventCategory: metadata.manifestId,
      eventLabel: canvasId,
      // new semantic fields
      eventAction: type,
      interactionType: "canvas",
      canvasId,
      canvasIndex,
      ...metadata,
    },
  })
}

function* onAddResource({ type, manifestId }) {
  yield put({
    type: "mirador/analytics",
    payload: {
      // legacy/compatibility
      eventCategory: manifestId,
      // new semantic fields
      eventAction: type,
      interactionType: "resource",
      manifestId,
    },
  })
}

/* the content param for companionWindows can have these values:
"info"	Manifest/canvas info
"attribution"	Attribution/rights
"canvas"	Canvas index / table of contents
"annotations"	Annotations list
"search"	Content search
"layers"	Canvas layers
"collection"	Collection browser (opened from the canvas panel, position "right")
(plugin string)	Any plugin that adds a sidebar tab sets its own value

* TODO: remove ultimately remove position param
*/
function* onAddCompanionWindow({
  payload: { position, content },
  type,
  windowId,
}) {
  if (!windowId) return

  const metadata = yield* manifestAnalytics({ windowId })

  yield put({
    type: "mirador/analytics",
    payload: {
      // legacy/compatibility
      eventCategory: metadata.manifestId,
      eventLabel: `${content}/${position}`,
      // new semantic fields
      eventAction: type,
      interactionType: "companion",
      companionWindow: content,
      ...metadata,
    },
  })
}

function* onUpdateCompanionWindow({
  id,
  payload: { position, content },
  type,
  windowId,
}) {
  if (!windowId) return

  const metadata = yield* manifestAnalytics({ windowId })

  const { content: existingContent } = yield select(getCompanionWindow, {
    companionWindowId: id,
  })

  const resolvedContent = content || existingContent

  yield put({
    type: "mirador/analytics",
    payload: {
      // legacy/compatibility
      eventCategory: metadata.manifestId,
      eventLabel: `${resolvedContent}/${position}`,
      // new semantic fields
      eventAction: type,
      interactionType: "companion",
      companionWindow: resolvedContent,
      ...metadata,
    },
  })
}

function* onToggleSideBar({ type, windowId }) {
  const win = yield select(getWindow, { windowId })
  if (!win?.sideBarOpen) return

  const metadata = yield* manifestAnalytics({ windowId })

  yield put({
    type: "mirador/analytics",
    payload: {
      // legacy/compatibility
      eventCategory: metadata.manifestId,
      // new semantic fields
      eventAction: type,
      interactionType: "companion",
      ...metadata,
    },
  })
}

function* onReceiveManifest({ manifestId, type }) {
  const metadata = yield* manifestAnalytics({ manifestId })

  yield put({
    type: "mirador/analytics",
    payload: {
      // legacy/compatibility
      eventCategory: manifestId,
      // new semantic fields
      eventAction: type,
      ...metadata,
    },
  })
}

function* onRequestSearch({ query, type, windowId }) {
  const metadata = yield* manifestAnalytics({ windowId })

  yield put({
    type: "mirador/analytics",
    payload: {
      // legacy/compatibility
      eventCategory: metadata.manifestId,
      eventLabel: query,
      // new semantic fields
      eventAction: type,
      interactionType: "search",
      searchTerm: query,
      ...metadata,
    },
  })
}

function* onReceiveSearch({ searchJson, type, windowId }) {
  const metadata = yield* manifestAnalytics({ windowId })

  const searchResultCount =
    searchJson?.resources?.length ?? searchJson?.items?.length ?? 0

  yield put({
    type: "mirador/analytics",
    payload: {
      // legacy/compatibility
      eventCategory: metadata.manifestId,
      eventValue: searchResultCount,
      // new semantic fields
      eventAction: type,
      interactionType: "search",
      searchResultCount,
      ...metadata,
    },
  })
}

function* onAddWindow({ type, window: { canvasId, manifestId } }) {
  yield put({
    type: "mirador/analytics",
    payload: {
      // legacy/compatibility
      eventCategory: manifestId,
      eventLabel: canvasId,
      // new semantic fields
      eventAction: type,
      canvasId,
      manifestId,
    },
  })
}

function* onMaximizeWindow({ type, windowId }) {
  const metadata = yield* manifestAnalytics({ windowId })

  yield put({
    type: "mirador/analytics",
    payload: {
      // legacy/compatibility
      eventCategory: metadata.manifestId,
      eventAction: type,
      // new semantic fields
      interactionType: "window",
      ...metadata,
    },
  })
}

function* onSetWindowViewType({ type, viewType, windowId }) {
  const metadata = yield* manifestAnalytics({ windowId })

  yield put({
    type: "mirador/analytics",
    payload: {
      // legacy/compatibility
      eventCategory: metadata.manifestId,
      eventLabel: viewType,
      // new semantic fields
      viewType,
      eventAction: type,
      ...metadata,
    },
  })
}

function* onSelectAnnotation({ annotationId, type, windowId }) {
  const metadata = yield* manifestAnalytics({ windowId })

  yield put({
    type: "mirador/analytics",
    payload: {
      // legacy/compatibility
      eventCategory: metadata.manifestId,
      eventLabel: annotationId,
      // new semantic fields
      annotationId,
      eventAction: type,
      interactionType: "annotation",
      ...metadata,
    },
  })
}

function* onSetWorkspaceAction({ type }) {
  yield put({
    type: "mirador/analytics",
    payload: {
      eventAction: type,
      interactionType: "workspace",
    },
  })
}

function* onSetWorkspaceActionLayout({ layout, type }) {
  yield put({
    type: "mirador/analytics",
    payload: {
      // legacy/compatibility
      eventCategory: layout,
      // new semantic fields
      eventAction: type,
      interactionType: "layout",
      layout,
    },
  })
}

const authTimes = {}

function* onAddAuthRequest({ id, type, windowId }) {
  const metadata = yield* manifestAnalytics({ windowId })

  authTimes[id] = Date.now()

  yield put({
    type: "mirador/analytics",
    payload: {
      // legacy/compatibility
      eventCategory: metadata.manifestId,
      eventLabel: id,
      // new semantic fields
      eventAction: type,
      interactionType: "auth",
      authId: id,
      ...metadata,
    },
  })
}

function* onResetAuthState({ id, type }) {
  const sessionMinutes = Math.ceil(
    (Date.now() - (authTimes[id] || Date.now())) / 1000 / 60,
  )

  authTimes[id] = undefined

  yield put({
    type: "mirador/analytics",
    payload: {
      // legacy/compatibility
      eventLabel: id,
      eventValue: sessionMinutes,
      // new semantic fields
      eventAction: type,
      interactionType: "auth",
      authId: id,
      sessionMinutes,
    },
  })
}

const tokenRequests = {}

function* onTokenRequest({ type, authId }) {
  const sessionMinutes = Math.ceil(
    (Date.now() - (authTimes[authId] || Date.now())) / 1000 / 60,
  )

  if (sessionMinutes < 5) return

  tokenRequests[authId] = (tokenRequests[authId] || 0) + 1

  yield put({
    type: "mirador/analytics",
    payload: {
      // legacy/compatibility
      eventLabel: authId,
      eventValue: tokenRequests[authId],
      // new semantic fields
      eventAction: type,
      interactionType: "auth",
      authId,
      tokenRequestCount: tokenRequests[authId],
    },
  })
}

function* onTokenFailure({ type, authId }) {
  const sessionMinutes = Math.ceil(
    (Date.now() - (authTimes[authId] || Date.now())) / 1000 / 60,
  )

  const authStatus = sessionMinutes < 5 ? "login failed" : "expired"

  yield put({
    type: "mirador/analytics",
    payload: {
      // legacy/compatibility
      eventCategory: authStatus,
      eventLabel: authId,
      // new semantic fields
      eventAction: type,
      interactionType: "auth",
      authId,
      authStatus,
    },
  })
}

function* sendAnalyticsEvent({ payload }) {
  const {
    eventAction,
    eventCategory,
    eventLabel,
    eventValue,

    manifestId,
    manifestTitle,
    canvasCount,
    manifestType,

    canvasId,
    canvasIndex,
    companionWindow,
    companionWindowOpenCount,
    searchTerm,
    searchResultCount,
    viewType,
    annotationId,
    authId,
    authStatus,
    sessionMinutes,
    tokenRequestCount,
    layout,
    interactionType,
  } = payload

  const eventParams = clean({
    event_category: eventCategory,
    event_label: eventLabel,
    event_value: eventValue,

    manifest_id: manifestId,
    manifest_title: manifestTitle,
    canvas_count: canvasCount,
    manifest_type: manifestType,

    canvas_id: canvasId,
    canvas_index: canvasIndex,
    companion_window_type: companionWindow,
    companion_window_open_count: companionWindowOpenCount,
    search_term: searchTerm,
    search_result_count: searchResultCount,
    view_type: viewType,
    annotation_id: annotationId,

    auth_id: authId,
    auth_status: authStatus,
    session_minutes: sessionMinutes,
    token_request_count: tokenRequestCount,

    layout,
    interaction_type: interactionType,
  })

  window.gtag && window.gtag("event", eventAction, eventParams)
}

export function clean(obj) {
  return Object.fromEntries(
    Object.entries(obj).filter(
      ([, v]) => v !== undefined && v !== null && v !== "",
    ),
  )
}

function* analyticsSaga() {
  yield all([
    takeEvery(ActionTypes.SET_CANVAS, onSetCanvas),
    takeEvery(ActionTypes.ADD_RESOURCE, onAddResource),
    takeEvery(ActionTypes.ADD_COMPANION_WINDOW, onAddCompanionWindow),
    takeEvery(ActionTypes.UPDATE_COMPANION_WINDOW, onUpdateCompanionWindow),
    takeEvery(ActionTypes.TOGGLE_WINDOW_SIDE_BAR, onToggleSideBar),
    takeEvery(ActionTypes.RECEIVE_MANIFEST, onReceiveManifest),
    takeEvery(ActionTypes.REQUEST_SEARCH, onRequestSearch),
    takeEvery(ActionTypes.RECEIVE_SEARCH, onReceiveSearch),
    takeEvery(ActionTypes.ADD_WINDOW, onAddWindow),
    takeEvery(ActionTypes.MAXIMIZE_WINDOW, onMaximizeWindow),
    takeEvery(ActionTypes.SET_WINDOW_VIEW_TYPE, onSetWindowViewType),
    takeEvery(ActionTypes.SELECT_ANNOTATION, onSelectAnnotation),
    takeEvery(ActionTypes.SET_WORKSPACE_FULLSCREEN, onSetWorkspaceAction),
    takeEvery(ActionTypes.SET_WORKSPACE_ADD_VISIBILITY, onSetWorkspaceAction),
    takeEvery(
      ActionTypes.UPDATE_WORKSPACE_MOSAIC_LAYOUT,
      onSetWorkspaceActionLayout,
    ),
    takeEvery(ActionTypes.ADD_AUTHENTICATION_REQUEST, onAddAuthRequest),
    takeEvery(ActionTypes.RESET_AUTHENTICATION_STATE, onResetAuthState),
    takeEvery(ActionTypes.REQUEST_ACCESS_TOKEN, onTokenRequest),
    takeEvery(ActionTypes.RECEIVE_ACCESS_TOKEN_FAILURE, onTokenFailure),
    takeEvery("mirador/analytics", sendAnalyticsEvent),
  ])
}

export default {
  component: () => {},
  saga: analyticsSaga,
}
