// NOTE: Remove this and app/javascripts/src/modules/pdf_viewer.js file when LegacyPDFComponent is removed

"use strict";

import EmbedThis from "../src/modules/embed_this.js";
import PopupPanels from "../src/modules/popup_panels";
import PDFViewer from "../src/modules/pdf_viewer.js";
import Fullscreen from "../src/modules/fullscreen.js";
import { trackView, trackFileDownloads } from "../src/modules/metrics.js";

document.addEventListener("DOMContentLoaded", () => {
  document.getElementById("sul-embed-object").hidden = false;
  PopupPanels.init();
  EmbedThis.init();
  PDFViewer.init();
  Fullscreen.init(".sul-embed-pdf");
  trackView();
  trackFileDownloads();
});
