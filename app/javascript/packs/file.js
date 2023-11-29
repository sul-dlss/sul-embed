import { EmbedThis } from '../src/modules/embed_this';
import { PopupPanels } from '../src/modules/popup_panels';
import { DownloadAll } from '../src/modules/download_all';
import CommonViewerBehavior from '../src/modules/common_viewer_behavior';
import '../src/tree'

document.addEventListener('DOMContentLoaded', () => {
  CommonViewerBehavior.initializeViewer();
  PopupPanels.init();
  EmbedThis.init();
  DownloadAll.init();
})