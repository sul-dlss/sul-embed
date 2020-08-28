import CdlAuthenticationControl from '../components/CdlAuthenticationControl';
import {
  getCurrentCanvas,
  selectCanvasAuthService,
} from 'mirador/dist/es/src/state/selectors';

const mapStateToProps = (state, { windowId} ) => {
  const canvasId = (getCurrentCanvas(state, { windowId }) || {}).id;
  const service = selectCanvasAuthService(state, { canvasId, windowId });
  return {
    service,
  }
}

export default {
  component: CdlAuthenticationControl,
  mapStateToProps,
  target: 'WindowAuthenticationControl',
  mode: 'wrap'
}
