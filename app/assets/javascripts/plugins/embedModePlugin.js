import { AllowWindowTopBarCloseForNonMainWindows, AllowDragAndDrop } from '../components/embedMode';

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
];
