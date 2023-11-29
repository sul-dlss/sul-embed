import CommonViewerBehavior from '../src/modules/common_viewer_behavior';
import { PopupPanels } from '../src/modules/popup_panels';
import EmbedThis from '../src/modules/embed_this';

document.addEventListener('DOMContentLoaded', () => {
  CommonViewerBehavior.initializeViewer();
  PopupPanels.init();
  EmbedThis.init();
})
