'use strict';

import { CssInjection } from '../../assets/javascripts/modules/css_injection.js';
import { EmbedThis } from '../../assets/javascripts/modules/embed_this.js';
import { PopupPanels } from '../../assets/javascripts/modules/popup_panels.js';
import CommonViewerBehavior from '../../assets/javascripts/modules/common_viewer_behavior.js';
import PDFViewer from '../../assets/javascripts/modules/pdf_viewer.js';
import Fullscreen from '../../assets/javascripts/modules/fullscreen.js';

$(document).ready(function() {
  CssInjection.injectFontIcons();
  CssInjection.appendToHead();
  CommonViewerBehavior.initializeViewer();
  PopupPanels.init();
  EmbedThis.init();
  PDFViewer.init();
  Fullscreen.init('.sul-embed-pdf');
});
