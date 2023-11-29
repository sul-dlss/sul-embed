'use strict';

import EmbedThis from '../src/modules/embed_this';
import { PopupPanels } from '../src/modules/popup_panels.js';
import CommonViewerBehavior from '../src/modules/common_viewer_behavior.js';
import PDFViewer from '../src/modules/pdf_viewer.js';
import Fullscreen from '../src/modules/fullscreen.js';

$(document).ready(function() {
  CommonViewerBehavior.initializeViewer();
  PopupPanels.init();
  EmbedThis.init();
  PDFViewer.init();
  Fullscreen.init('.sul-embed-pdf');
});
