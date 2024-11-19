import {
  getAccessTokens,
  getWindow,
  selectCurrentAuthServices,
  getCurrentCanvas,
} from 'mirador/dist/es/src/state/selectors';
import { fetchInfoResponse } from 'mirador/dist/es/src/state/actions';
import ActionTypes from 'mirador/dist/es/src/state/actions/action-types';
import MiradorCanvas from 'mirador/dist/es/src/lib/MiradorCanvas';
import {
  all, put, select, takeEvery, call, delay,
} from 'redux-saga/effects';
import CdlAuthenticationControl, { CdlAuthenticationControlPlugin } from '../components/CdlAuthenticationControl';
import CdlCopyright, { CdlCopyrightPlugin } from '../components/CdlCopyright';
import CdlLoginWindowSizing from '../components/CdlLoginWindowSizing';


/** */
function* getAuthInfo() {
  const service = yield select(selectCurrentAuthServices, { windowId: 'main' });
  if (!service || service.length === 0) return;
  const authInfoService = service[0].getService('http://iiif.io/api/auth/1/info');
  if (!authInfoService) return;
  const endpoint = authInfoService.id;
  const accessTokens = yield select(getAccessTokens);
  const accessTokenService = Object.values(accessTokens).find(s => s.authId === service[0].id);
  const accessToken = accessTokenService && accessTokenService.json && accessTokenService.json.accessToken;
  yield call(requestCdlInfoAndAvailability, endpoint, accessToken);
}

/**
 * Wait a little bit to refresh availability
 */
function* sleepyRefreshCdlInfo(params) {
  yield (delay(2000));
  yield call(refreshCdlInfo, params);
}

/** */
function* refreshCdlInfo({ json, id }) {
  const window = yield select(getWindow, { windowId: 'main' });
  if (!window.cdlInfoResponseUrl) {
    return;
  }

  let accessToken;
  accessToken = json && json.accessToken;

  if (id && !accessToken) {
    const accessTokens = yield select(getAccessTokens);
    const accessTokenService = Object.values(accessTokens).find(service => service.authId === id);
    accessToken = accessTokenService && accessTokenService.json && accessTokenService.json.accessToken;
  }
  yield call(requestCdlInfoAndAvailability, window.cdlInfoResponseUrl, accessToken);
}

/** */
function* requestCdlInfoAndAvailability(cdlInfoEndpoint, accessToken) {
  let options = {};

  if (accessToken) {
    options.headers = {
      Authorization: `Bearer ${accessToken}`,
    }
  }

  const cdlInfoResponse = yield fetch(cdlInfoEndpoint, options)
    .then(res => res.json());

  // yield put({ id: 'main', payload: {
  //   cdlInfoResponse,
  //   cdlInfoResponseUrl: cdlInfoEndpoint,
  // }, type: ActionTypes.UPDATE_WINDOW });

  const cdlAvailability = yield fetch(cdlInfoResponse.availability_url)
    .then(res => res.json());

  // yield put({ id: 'main', payload: {
  //     cdlAvailability,
  // }, type: ActionTypes.UPDATE_WINDOW });
}

/** */
function* startTheClock({ id, payload: { cdlInfoResponse }}) {
  if (!cdlInfoResponse) return;

  const canvas = yield select(getCurrentCanvas, { windowId: id });
  if (!canvas) return;

  const service = yield select(selectCurrentAuthServices, { windowId: id });
  if (!service || service.length == 0) return;

  // if there was no token payload, our token was no good.. 🤷‍♂️
  if (!cdlInfoResponse.payload) {
    return;
  }

  // wait until the token is probably expired...
  const expectedDueDate = new Date(cdlInfoResponse.payload.exp * 1000);
  yield delay(expectedDueDate - Date.now() + 5000);

  // double check that we're now after the expiry date (in case the resource got renewed or something)
  const window = yield select(getWindow, { windowId: id });
  const actualDueDate = new Date(window.cdlInfoResponse.payload.exp * 1000);
  if ((Date.now() - actualDueDate) >= 0) {
    const accessTokens = yield select(getAccessTokens);
    const accessToken = Object.values(accessTokens).find(s => s.authId === service[0].id);
    if (!accessToken) return;

    yield put({
      id: service[0].id,
      tokenServiceId: accessToken.id,
      type: ActionTypes.RESET_AUTHENTICATION_STATE,
    });

    // Refetch the info response so we get a failure state which will reinitiate the auth controls
    yield call(resetInfoResponses);
  }
}

/** */
function* resetInfoResponses() {
  const canvas = yield select(getCurrentCanvas, { windowId: 'main' });
  if (!canvas) return;
  yield all(new MiradorCanvas(canvas).iiifImageResources.map(imageResource => {
    return put(fetchInfoResponse({ imageResource }));
  }))
}

/** */
const saga = function* cdlSaga() {
  yield all([
    takeEvery(ActionTypes.RECEIVE_INFO_RESPONSE, getAuthInfo),
    takeEvery(ActionTypes.RECEIVE_ACCESS_TOKEN, refreshCdlInfo),
    takeEvery(ActionTypes.RESET_AUTHENTICATION_STATE, refreshCdlInfo),
    takeEvery(ActionTypes.RESET_AUTHENTICATION_STATE, sleepyRefreshCdlInfo),
    takeEvery(ActionTypes.RESET_AUTHENTICATION_STATE, resetInfoResponses),
    takeEvery(ActionTypes.RECEIVE_DEGRADED_INFO_RESPONSE, getAuthInfo), // checked in elsewhere
    takeEvery(ActionTypes.UPDATE_WINDOW, startTheClock),
  ]);
};

export default [
  {
    component: CdlAuthenticationControl,
    mapDispatchToProps: CdlAuthenticationControlPlugin.mapDispatchToProps,
    mapStateToProps: CdlAuthenticationControlPlugin.mapStateToProps,
    mode: 'wrap',
    saga,
    target: 'WindowAuthenticationBar',
  },
  {
    component: CdlCopyright,
    mapStateToProps: CdlCopyrightPlugin.mapStateToProps,
    mode: 'wrap',
    target: 'PrimaryWindow',
  },
  {
    component: CdlLoginWindowSizing,
    mode: 'wrap',
    target: 'IIIFAuthentication',
  },
];
