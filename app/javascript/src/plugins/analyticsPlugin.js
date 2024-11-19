import {
  all, put, select, takeEvery,
} from 'redux-saga/effects';
import ActionTypes from 'mirador/dist/es/src/state/actions/action-types.js';
import { getManifest, getCompanionWindow } from 'mirador/dist/es/src/state/selectors/index.js';

function* onSetCanvas({ type, windowId, canvasId }) {
  // TODO fix this
  // Cannot destructure property 'id' of '(intermediate value)' as it is undefined.
  // const { id: manifestId } = yield select(getManifest, { windowId });
  // Assume that windowIds is an array of window IDs
    // const windowIds = yield select(getWindowIds); // Replace with your actual selector

    // Filter out null IDs
    const validWindowIds = windowIds.filter(id => id !== null);

    // If there are valid IDs, use the first one; otherwise handle the case where no valid ID exists
    if (validWindowIds.length > 0) {
        const { id: manifestId } = yield select(getManifest, { windowId: validWindowIds[0] });
        yield put({ type: 'mirador/analytics', payload: {
          eventCategory: manifestId,
          eventAction: type,
          eventLabel: canvasId,
        }});
    } else {
        // Handle the case where no valid windowId is found
        console.error('No valid windowId found');
    }
}

function* onAddResource({ type, manifestId }) {
  yield put({ type: 'mirador/analytics', payload: {
    eventCategory: manifestId,
    eventAction: type,
  }});
}

function* onAddCompanionWindow({ payload: { position, content }, type, windowId }) {
  if (!windowId) return;

  const { id: manifestId } = yield select(getManifest, { windowId });

  yield put({ type: 'mirador/analytics', payload: {
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
    eventCategory: manifestId,
    eventAction: type,
    eventLabel: `${content || existingContent}/${position}`,
  }});
}


function* onReceiveManifest({ manifestId, type }) {
  yield put({ type: 'mirador/analytics', payload: {
    eventCategory: manifestId,
    eventAction: type,
  }});
}

function* onRequestSearch({ query, type, windowId }) {
  const { id: manifestId } = yield select(getManifest, { windowId });

  yield put({ type: 'mirador/analytics', payload: {
    eventCategory: manifestId,
    eventAction: type,
    eventLabel: query,
  }});
}

function* onAddWindow({ type, window: { canvasId, manifestId } }) {
  yield put({ type: 'mirador/analytics', payload: {
    eventCategory: manifestId,
    eventAction: type,
    eventLabel: canvasId,
  }});
}

function* onMaximizeWindow({ type, windowId }) {
  const { id: manifestId } = yield select(getManifest, { windowId });

  yield put({ type: 'mirador/analytics', payload: {
    eventCategory: manifestId,
    eventAction: type,
  }});
}

function* onSetWindowViewType({ type, viewType, windowId }) {
  const { id: manifestId } = yield select(getManifest, { windowId });

  yield put({ type: 'mirador/analytics', payload: {
    eventCategory: manifestId,
    eventAction: type,
    eventLabel: viewType,
  }});
}

function* onSelectAnnotation({ annotationId, type, windowId }) {
  const { id: manifestId } = yield select(getManifest, { windowId });

  yield put({ type: 'mirador/analytics', payload: {
    eventCategory: manifestId,
    eventAction: type,
    eventLabel: annotationId,
  }});
}

function* onSetWorkspaceAction({ type }) {
  yield put({ type: 'mirador/analytics', payload: {
    eventAction: type,
  }});
}

function* onSetWorkspaceActionLayout({ layout, type }) {
  yield put({ type: 'mirador/analytics', payload: {
    eventCategory: layout,
    eventAction: type,
  }});
}

const authTimes = {};

function* onAddAuthRequest({ id, type, windowId }) {
  const { id: manifestId } = yield select(getManifest, { windowId });

  authTimes[id] = Date.now();

  yield put({ type: 'mirador/analytics', payload: {
    eventCategory: manifestId,
    eventAction: type,
    eventLabel: id,
  }});
}

function* onResetAuthState({ id, type }) {
  const sessionMinutes = Math.ceil((Date.now() - (authTimes[id] || Date.now())) / 1000 / 60);
  authTimes[id] = undefined;

  yield put({ type: 'mirador/analytics', payload: {
    eventAction: type,
    eventLabel: id,
    eventValue: sessionMinutes,
  }});
}

const tokenRequests = {};
function* onTokenRequest({ type, authId }) {
  const sessionMinutes = Math.ceil((Date.now() - (authTimes[authId] || Date.now())) / 1000 / 60);

  // probably the initial token request
  if (sessionMinutes < 5) return;
  tokenRequests[authId] = (tokenRequests[authId] || 0) + 1;

  yield put({ type: 'mirador/analytics', payload: {
    eventAction: type,
    eventLabel: authId,
    eventValue: tokenRequests[authId],
  }});
}

function* onTokenFailure({ type, authId }) {
  const sessionMinutes = Math.ceil((Date.now() - (authTimes[authId] || Date.now())) / 1000 / 60);
  let newOrExpired = 'expired';

  if (sessionMinutes < 5) {
    newOrExpired = 'login failed';
  }

  yield put({ type: 'mirador/analytics', payload: {
    eventAction: type,
    eventCategory: newOrExpired,
    eventLabel: authId,
  }});
}

// This function sends events in the required format for GA4
function* sendAnalyticsEvent({ payload: { eventAction, eventCategory, eventLabel, eventValue } }) {
  window.gtag && window.gtag('event', eventAction, {
    event_category: eventCategory,
    event_label: eventLabel,
    event_value: eventValue
  });  
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
    takeEvery(ActionTypes.RESET_AUTHENTICATION_STATE, onResetAuthState),
    takeEvery(ActionTypes.REQUEST_ACCESS_TOKEN, onTokenRequest),
    takeEvery(ActionTypes.RECEIVE_ACCESS_TOKEN_FAILURE, onTokenFailure),
    takeEvery('mirador/analytics', sendAnalyticsEvent),
  ]);
}

export default {
  component: () => {},
  saga: analyticsSaga,
};
