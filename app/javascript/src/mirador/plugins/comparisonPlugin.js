/**
 * As of Septemeber 2025, we believe this plugin is only used in the 
 * Parker exhibits site. You can see it within the three-dot top bar menu,
 * by clicking "Compare To" and adding a second manifest.
 *  */ 
import CompareDialog from '@/mirador/components/CompareDialog.jsx';
import CompareMenuItem from '@/mirador/components/CompareMenuItem.jsx';
import AllowTopBarClose from '@/mirador/components/AllowTopBarClose.jsx';
import AllowDragAndDrop from '@/mirador/components/AllowDragAndDrop.jsx';
import { addWindow, getWindow, updateWindow } from 'mirador';

export default [
  {
    component: AllowTopBarClose,
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
    mapDispatchToProps: { updateWindow },
    mode: 'add',
    target: 'WindowTopBarPluginMenu',
  },
  {
    component: CompareDialog,
    mapDispatchToProps: { addWindow, updateWindow },
    mapStateToProps: (state, { windowId }) => ({
      show: getWindow(state, { windowId })?.showCompareDialog,
    }),
    mode: 'add',
    target: 'Window',
  },
];
