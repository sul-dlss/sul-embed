import SvgIcon from '@mui/material/SvgIcon';
import { withPlugins, WindowTopBarPluginMenu, getContainerId } from 'mirador';

const ShareMenuIcon = (props) => (
  <SvgIcon {...props}>
    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">
      <path d="M0,0H24V24H0Z" fill="none" />
      <path d="M19,12v7H5V12H3v9H21V12Z" />
      <path d="M11.741,8.178V5L17.3,10.562l-5.562,5.562V12.867c-3.973,0-6.754,1.271-8.741,4.052C3.795,12.946,6.178,8.973,11.741,8.178Z" transform="translate(4 -4)" />
    </svg>
  </SvgIcon>
);

const ShareMenu = (props) => (
  <WindowTopBarPluginMenu
    {...props}
    menuIcon={<ShareMenuIcon />}
  />
);

const ShareMenuWithPlugins = withPlugins('SulEmbedShareMenu')(ShareMenu);

export const shareMenuPlugin = {
  component: ShareMenuWithPlugins,
  config: {
    translations: {
      en: {
        'windowPluginMenu': 'Share & download',
      },
    }
  },
  mapStateToProps: (state) => ({
    containerId: getContainerId(state),
  }),
  mode: 'add',
  name: 'SulEmbedShareMenu',
  target: 'WindowTopBarPluginArea',
};
