import React from 'react';

export const AllowWindowTopBarCloseForNonMainWindows = ({ targetProps: props, TargetComponent}) => (
  <TargetComponent {...props} allowClose={props.windowId === 'main' ? false : true} />
);

export const AllowDragAndDrop = ({ targetProps: props, TargetComponent}) => (
  <TargetComponent {...props} isWorkspaceControlPanelVisible={true} classes={{ ...props.classes, workspaceWithControlPanel: '' }}/>
);
