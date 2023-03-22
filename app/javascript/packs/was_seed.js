import { CssInjection } from '../../assets/javascripts/modules/css_injection';
import CommonViewerBehavior from '../../assets/javascripts/modules/common_viewer_behavior';
import { PopupPanels } from '../../assets/javascripts/modules/popup_panels';
import { EmbedThis } from '../../assets/javascripts/modules/embed_this';

document.addEventListener('DOMContentLoaded', () => {
  CssInjection.injectFontIcons();
  CssInjection.appendToHead();
  CommonViewerBehavior.initializeViewer();
  PopupPanels.init();
  EmbedThis.init();
})
