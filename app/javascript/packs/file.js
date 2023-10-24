import { CssInjection } from '../src/modules/css_injection';
import { EmbedThis } from '../src/modules/embed_this';
import { PopupPanels } from '../src/modules/popup_panels';
import { DownloadAll } from '../src/modules/download_all';
import { FilePreview } from '../src/modules/file_preview';
import CommonViewerBehavior from '../src/modules/common_viewer_behavior';
import '../src/tree'

document.addEventListener('DOMContentLoaded', () => {
  CssInjection.injectFontIcons();
  CssInjection.appendToHead();
  CommonViewerBehavior.initializeViewer();
  FilePreview.init();
  PopupPanels.init();
  EmbedThis.init();
  DownloadAll.init();
})