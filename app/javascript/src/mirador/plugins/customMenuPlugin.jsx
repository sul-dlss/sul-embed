import SvgIcon from '@mui/material/SvgIcon';
import { WindowTopBarPluginMenu } from 'mirador';

const CustomIcon = (props) => (
  <SvgIcon {...props} data-testid="custom-icon-svg">
    <path d="M0,0H24V24H0Z" fill="none" />
    <path d="M19,12v7H5V12H3v9H21V12Z" />
    <path
      d="M11.741,8.178V5L17.3,10.562l-5.562,5.562V12.867c-3.973,0-6.754,1.271-8.741,4.052C3.795,12.946,6.178,8.973,11.741,8.178Z"
      transform="translate(4 -4)"
    />
  </SvgIcon>
);

const CustomMenuComponent = (props) => {
  return (
    <WindowTopBarPluginMenu
      windowId={props.windowId}
      pluginTarget="CustomMenuComponent"
      menuIcon={<CustomIcon />}
    />
  );
};

export default {
  target: 'WindowTopBarPluginArea',
  mode: 'add',
  name: 'CustomMenuPlugin',
  component: CustomMenuComponent,
  mapStateToProps: (state, { windowId }) => ({
    windowId: windowId,
  }),
};
    