import { CssInjection } from '../../assets/javascripts/modules/css_injection';
import { EmbedThis } from '../../assets/javascripts/modules/embed_this';
import { PopupPanels } from '../../assets/javascripts/modules/popup_panels';
import { DownloadAll } from '../../assets/javascripts/modules/download_all';
import { FilePreview } from '../../assets/javascripts/modules/file_preview';
import CommonViewerBehavior from '../../assets/javascripts/modules/common_viewer_behavior';

document.addEventListener('DOMContentLoaded', () => {
  CssInjection.injectFontIcons();
  CssInjection.appendToHead();
  CommonViewerBehavior.initializeViewer();
  FilePreview.init();
  PopupPanels.init();
  EmbedThis.init();
  DownloadAll.init();
})