import CdlAuthenticationControl from '../components/CdlAuthenticationControl';
import { CdlAuthenticationControlPlugin } from '../components/CdlAuthenticationControl';
import CdlLogout from '../components/CdlLogout';
import { CdlLogoutPlugin } from '../components/CdlLogout';

import {
  getAccessTokens,
  getWindow,
  selectCanvasAuthService,
} from 'mirador/dist/es/src/state/selectors';
import ActionTypes from 'mirador/dist/es/src/state/actions/action-types';
import {
  all, put, select, takeEvery, call,
} from 'redux-saga/effects';

function* getAuthInfo({infoId, infoJson, ok, tokenServiceId}) {
  const service = yield select(selectCanvasAuthService, { infoId });
  const endpoint = service.getService('http://iiif.io/api/auth/1/info').id
  const accessTokens = yield select(getAccessTokens);
  const accessToken = Object.values(accessTokens).find(service => service.authId === service.id);
  yield call(requestCdlInfoAndAvailability, endpoint, accessToken);
}

function* refreshCdlInfo({ json, id }) {

  const window = yield select(getWindow, { windowId: 'main' });
  if (!window.cdlInfoResponseUrl) {
    return;
  }
  
  let accessToken;
  accessToken = json && json.accessToken;

  if (id) {
    const accessTokens = yield select(getAccessTokens);
    accessToken = Object.values(accessTokens).find(service => service.authId === id);
  }
  yield call(requestCdlInfoAndAvailability, window.cdlInfoResponseUrl, accessToken);  
}

function* requestCdlInfoAndAvailability(cdlInfoEndpoint, accessToken) {
  let options = {};
  
  if (accessToken) {
    options.headers = {
      Authorization: `Bearer ${accessToken}`,
    }
  }

  const cdlInfoResponse = yield fetch(cdlInfoEndpoint, options)
    .then(res => res.json());
  
  yield put({ id: 'main', payload: {
    cdlInfoResponse,
    cdlInfoResponseUrl: cdlInfoEndpoint,
  }, type: ActionTypes.UPDATE_WINDOW });

  const cdlAvailability = yield fetch(cdlInfoResponse.availability_url)
    .then(res => res.json());

  yield put({ id: 'main', payload: {
      cdlAvailability,
  }, type: ActionTypes.UPDATE_WINDOW });
}

const saga = function* cdlSaga() {
  yield all([
    takeEvery(ActionTypes.RECEIVE_INFO_RESPONSE, getAuthInfo),
    takeEvery(ActionTypes.RECEIVE_ACCESS_TOKEN, refreshCdlInfo),
    takeEvery(ActionTypes.RESET_AUTHENTICATION_STATE, refreshCdlInfo),
    takeEvery(ActionTypes.RECEIVE_DEGRADED_INFO_RESPONSE, getAuthInfo) // checked in elsewhere
  ])
}

export default [
  {
    component: CdlAuthenticationControl,
    mapStateToProps: CdlAuthenticationControlPlugin.mapStateToProps,
    target: 'WindowAuthenticationControl',
    mode: 'wrap',
    saga,
  },
  {
    component: CdlLogout,
    mapStateToProps: CdlLogoutPlugin.mapStateToProps,
    mode: 'wrap',
    target: 'AuthenticationLogout',
  }
]
