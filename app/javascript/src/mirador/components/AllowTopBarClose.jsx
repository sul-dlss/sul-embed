export default function AllowTopBarClose({ targetProps: props, TargetComponent }) {
  return <TargetComponent {...props} allowClose={props.windowId !== 'main'} />;
}
