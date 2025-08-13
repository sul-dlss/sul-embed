export default function AllowDragAndDrop({ targetProps: props, TargetComponent }) {
  return <TargetComponent {...props} isWorkspaceControlPanelVisible classes={{ ...props.classes, workspaceWithControlPanel: '' }} />;
}
