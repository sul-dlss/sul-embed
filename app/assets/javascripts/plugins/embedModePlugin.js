import {
  AllowWindowTopBarCloseForNonMainWindows,
  AllowDragAndDrop,
  CompareDialog,
  CompareMenuItem,
} from '../components/embedMode';
import * as actions from 'mirador/dist/es/src/state/actions/index.js';
import { getWindow } from 'mirador/dist/es/src/state/selectors';

export default [
  {
    component: AllowWindowTopBarCloseForNonMainWindows,
    mode: 'wrap',
    target: 'WindowTopBar',
  },
  {
    component: AllowDragAndDrop,
    mode: 'wrap',
    target: 'Workspace',
  },
  {
    component: CompareMenuItem,
    mapDispatchToProps: {
      updateWindow: actions.updateWindow,
    },
    mode: 'add',
    name: 'CompareMenuItem',
    target: 'WindowTopBarPluginMenu',
  },
  {
    component: CompareDialog,
    mapDispatchToProps: {
      addWindow: actions.addWindow,
      updateWindow: actions.updateWindow,
    },
    mapStateToProps: (state, { windowId }) => ({
      show: getWindow(state, { windowId }).showCompareDialog,
    }),
    mode: 'add',
    name: 'CompareDialog',
    target: 'Window',
  },
];
