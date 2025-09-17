/**
 * As of Septemeber 2025, we believe this plugin is only used in the 
 * Parker exhibits site. You can see it within the three-dot top bar menu,
 * by clicking "Compare To" and adding a second manifest.
 *  */ 
import CompareDialog from '@/mirador/components/CompareDialog.jsx';
import CompareMenuItem from '@/mirador/components/CompareMenuItem.jsx';
import { addWindow, getWindow, updateWindow } from 'mirador';

export default [
  // {
  //   // Wrap the target Workspace in order to allow drag and drop of manifests 
  //   component: function AllowDragAndDrop({ targetProps: props, TargetComponent }) {
  //     return <TargetComponent {...props} classes={{ ...props.classes, workspaceWithControlPanel: '' }} />;
  //   },
  //   mode: 'wrap',
  //   target: 'Workspace',
  // },
  {
    component: function AllowTopBarClose({ targetProps: props, TargetComponent }) {
      // Wrap the target WindowTopBar in order to set `allowClose`
      // This will show the 'x' close button for non-main comparison windows,
      // i.e. windows that have been added for comparison.
      return <TargetComponent {...props} allowClose={props.windowId !== 'main'} />;
    },
    mode: 'wrap',
    target: 'WindowTopBar',
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
