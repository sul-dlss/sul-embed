import {
  AllowWindowTopBarCloseForNonMainWindows,
  AllowDragAndDrop,
  CompareDialog,
  CompareMenuItem,
} from '@/components/embedMode.jsx'
import { addWindow, getWindow, updateWindow } from 'mirador'

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
      updateWindow: updateWindow,
    },
    mode: 'add',
    name: 'CompareMenuItem',
    target: 'WindowTopBarPluginMenu',
  },
  {
    component: CompareDialog,
    mapDispatchToProps: {
      addWindow: addWindow,
      updateWindow: updateWindow,
    },
    mapStateToProps: (state, { windowId }) => ({
      show: getWindow(state, { windowId }).showCompareDialog,
    }),
    mode: 'add',
    name: 'CompareDialog',
    target: 'Window',
  },
]
