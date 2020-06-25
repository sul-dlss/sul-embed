import {
  all, put, select, takeEvery,
} from 'redux-saga/effects';
import ActionTypes from 'mirador/dist/es/src/state/actions/action-types.js';
import { getManifest, getCompanionWindow } from 'mirador/dist/es/src/state/selectors/index.js';

function* onSetCanvas({ type, windowId, canvasId }) {
  const { id: manifestId } = yield select(getManifest, { windowId });
  yield put({ type: 'mirador/analytics', payload: {
    hitType: 'event',
    eventCategory: manifestId,
    eventAction: type,
    eventLabel: canvasId,
  }});
}

function* onAddResource({ type, manifestId }) {
  yield put({ type: 'mirador/analytics', payload: {
    hitType: 'event',
    eventCategory: manifestId,
    eventAction: type,
  }});
}

function* onAddCompanionWindow({ payload: { position, content }, type, windowId }) {
  if (!windowId) return;

  const { id: manifestId } = yield select(getManifest, { windowId });

  yield put({ type: 'mirador/analytics', payload: {
    hitType: 'event',
    eventCategory: manifestId,
    eventAction: type,
    eventLabel: `${content}/${position}`,
  }});
}

function* onUpdateCompanionWindow({ id, payload: { position, content }, type, windowId }) {
  if (!windowId) return;

  const { id: manifestId } = yield select(getManifest, { windowId });
  const { content: existingContent } = yield select(getCompanionWindow, { companionWindowId: id });

  yield put({ type: 'mirador/analytics', payload: {
    hitType: 'event',
    eventCategory: manifestId,
    eventAction: type,
    eventLabel: `${content || existingContent}/${position}`,
  }});
}


function* onReceiveManifest({ manifestId, type }) {
  yield put({ type: 'mirador/analytics', payload: {
    hitType: 'event',
    eventCategory: manifestId,
    eventAction: type,
  }});
}

function* onRequestSearch({ query, type, windowId }) {
  const { id: manifestId } = yield select(getManifest, { windowId });

  yield put({ type: 'mirador/analytics', payload: {
    hitType: 'event',
    eventCategory: manifestId,
    eventAction: type,
    eventLabel: query,
  }});
}

function* onAddWindow({ type, window: { canvasId, manifestId } }) {
  yield put({ type: 'mirador/analytics', payload: {
    hitType: 'event',
    eventCategory: manifestId,
    eventAction: type,
    eventLabel: canvasId,
  }});
}

function* onMaximizeWindow({ type, windowId }) {
  const { id: manifestId } = yield select(getManifest, { windowId });

  yield put({ type: 'mirador/analytics', payload: {
    hitType: 'event',
    eventCategory: manifestId,
    eventAction: type,
  }});
}

function* onSetWindowViewType({ type, viewType, windowId }) {
  const { id: manifestId } = yield select(getManifest, { windowId });

  yield put({ type: 'mirador/analytics', payload: {
    hitType: 'event',
    eventCategory: manifestId,
    eventAction: type,
    eventLabel: viewType,
  }});
}

function* onSelectAnnotation({ annotationId, type, windowId }) {
  const { id: manifestId } = yield select(getManifest, { windowId });

  yield put({ type: 'mirador/analytics', payload: {
    hitType: 'event',
    eventCategory: manifestId,
    eventAction: type,
    eventLabel: annotationId,
  }});
}

function* onSetWorkspaceAction({ type }) {
  yield put({ type: 'mirador/analytics', payload: {
    hitType: 'event',
    eventAction: type,
  }});
}

function* onSetWorkspaceActionLayout({ layout, type }) {
  yield put({ type: 'mirador/analytics', payload: {
    hitType: 'event',
    eventCategory: layout,
    eventAction: type,
  }});
}

function* onAddAuthRequest({ type, profile, windowId }) {
  const { id: manifestId } = yield select(getManifest, { windowId });

  yield put({ type: 'mirador/analytics', payload: {
    hitType: 'event',
    eventCategory: manifestId,
    eventAction: type,
    eventLabel: profile,
  }});
}

function* sendAnalyticsEvent({ payload }) {
  window.ga && window.ga('send', payload);
}

/** */
function* analyticsSaga() {
  yield all([
    takeEvery(ActionTypes.SET_CANVAS, onSetCanvas),
    takeEvery(ActionTypes.ADD_RESOURCE, onAddResource),
    takeEvery(ActionTypes.ADD_COMPANION_WINDOW, onAddCompanionWindow),
    takeEvery(ActionTypes.UPDATE_COMPANION_WINDOW, onUpdateCompanionWindow),
    takeEvery(ActionTypes.RECEIVE_MANIFEST, onReceiveManifest),
    takeEvery(ActionTypes.REQUEST_SEARCH, onRequestSearch),
    takeEvery(ActionTypes.ADD_WINDOW, onAddWindow),
    takeEvery(ActionTypes.MAXIMIZE_WINDOW, onMaximizeWindow),
    takeEvery(ActionTypes.SET_WINDOW_VIEW_TYPE, onSetWindowViewType),
    takeEvery(ActionTypes.SELECT_ANNOTATION, onSelectAnnotation),
    takeEvery(ActionTypes.SET_WORKSPACE_FULLSCREEN, onSetWorkspaceAction),
    takeEvery(ActionTypes.SET_WORKSPACE_ADD_VISIBILITY, onSetWorkspaceAction),
    takeEvery(ActionTypes.UPDATE_WORKSPACE_MOSAIC_LAYOUT, onSetWorkspaceActionLayout),
    takeEvery(ActionTypes.ADD_AUTHENTICATION_REQUEST, onAddAuthRequest),
    takeEvery('mirador/analytics', sendAnalyticsEvent),
  ]);
}

export default {
  component: () => {},
  saga: analyticsSaga,
};
